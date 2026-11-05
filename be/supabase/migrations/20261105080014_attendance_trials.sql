-- Attendance and trial bookings: per-session marks by staff, and trial slots booked by visitors.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

do $$
begin
  create type public.attendance_status as enum ('present', 'absent');
exception
  when duplicate_object then null;
end;
$$;

-- ---------------------------------------------------------------------------
-- Attendance
-- ---------------------------------------------------------------------------

create table if not exists public.attendance (
  session_id uuid not null references public.sessions (id) on delete cascade,
  trainee_id uuid not null references public.trainees (id) on delete cascade,
  status public.attendance_status not null,
  marked_by uuid null references public.profiles (id) on delete set null,
  marked_at timestamptz not null default private.clock(),
  primary key (session_id, trainee_id)
);

-- History by trainee; the primary key already serves lookups by session.
create index if not exists attendance_trainee_idx
  on public.attendance (trainee_id, session_id);

-- Removing a staff profile nulls marked_by; the index keeps that from scanning every mark.
create index if not exists attendance_marked_by_idx
  on public.attendance (marked_by);

alter table public.attendance enable row level security;

create policy attendance_select_staff on public.attendance
  for select to authenticated
  using ((select private.is_staff()));

-- Marks change only through the attendance functions below; truncate would bypass RLS.
revoke insert, update, delete, truncate, references, trigger on public.attendance from anon, authenticated;

-- Marking again with the other status corrects the record; the same status changes nothing.
create or replace function public.mark_attendance(
  p_session_id uuid,
  p_trainee_id uuid,
  p_status public.attendance_status
)
returns public.attendance
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_trainee_status public.trainee_status;
  v_attendance public.attendance;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  -- Key share lock so a concurrent delete_extra_session waits for this mark and then refuses.
  perform 1 from public.sessions where id = p_session_id for key share;
  if not found then
    perform private.fail('BXNTF', 'Session not found');
  end if;

  -- Share lock so the trainee cannot turn inactive between this check and the insert.
  select status into v_trainee_status
  from public.trainees
  where id = p_trainee_id
  for share;
  if not found then
    perform private.fail('BXNTF', 'Trainee not found');
  end if;

  if v_trainee_status <> 'active' then
    perform private.fail('BXVAL', 'This trainee is inactive');
  end if;

  if p_status is null then
    perform private.fail('BXVAL', 'Choose present or absent');
  end if;

  insert into public.attendance as a (session_id, trainee_id, status, marked_by, marked_at)
  values (p_session_id, p_trainee_id, p_status, (select auth.uid()), private.clock())
  on conflict (session_id, trainee_id) do update
    set status = excluded.status,
        marked_by = excluded.marked_by,
        marked_at = excluded.marked_at
    where a.status is distinct from excluded.status;

  -- Read back so a no-op mark still returns the stored row with its original marker and time.
  select * into v_attendance
  from public.attendance
  where session_id = p_session_id
    and trainee_id = p_trainee_id;

  return v_attendance;
end;
$$;

create or replace function public.mark_remaining_absent(p_session_id uuid)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_inserted integer;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  perform 1 from public.sessions where id = p_session_id for key share;
  if not found then
    perform private.fail('BXNTF', 'Session not found');
  end if;

  -- Do nothing on conflict so a mark made concurrently by another coach is kept, never overwritten.
  insert into public.attendance (session_id, trainee_id, status, marked_by, marked_at)
  select p_session_id, t.id, 'absent', (select auth.uid()), private.clock()
  from public.trainees t
  where t.status = 'active'
    and not exists (
      select 1
      from public.attendance a
      where a.session_id = p_session_id
        and a.trainee_id = t.id
    )
  on conflict (session_id, trainee_id) do nothing;

  get diagnostics v_inserted = row_count;
  return v_inserted;
end;
$$;

-- A null status means the trainee has not been marked for this session yet.
create or replace function public.session_roster(p_session_id uuid)
returns table (
  trainee_id uuid,
  full_name text,
  photo_path text,
  status public.attendance_status,
  marked_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
#variable_conflict use_column
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  perform 1 from public.sessions s where s.id = p_session_id;
  if not found then
    perform private.fail('BXNTF', 'Session not found');
  end if;

  return query
  select t.id, t.full_name, t.photo_path, a.status, a.marked_at
  from public.trainees t
  left join public.attendance a
    on a.session_id = p_session_id
   and a.trainee_id = t.id
  where t.status = 'active'
  order by lower(t.full_name), t.id;
end;
$$;

create or replace function public.trainee_attendance_history(
  p_trainee_id uuid,
  p_from date,
  p_to date
)
returns table (
  session_id uuid,
  session_date date,
  slot public.session_slot,
  status public.attendance_status,
  marked_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
#variable_conflict use_column
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  perform 1 from public.trainees t where t.id = p_trainee_id;
  if not found then
    perform private.fail('BXNTF', 'Trainee not found');
  end if;

  if p_from is null or p_to is null then
    perform private.fail('BXVAL', 'Choose a start and an end date');
  end if;

  if p_to < p_from then
    perform private.fail('BXVAL', 'The end date is before the start date');
  end if;

  return query
  select s.id, s.session_date, s.slot, a.status, a.marked_at
  from public.attendance a
  join public.sessions s on s.id = a.session_id
  where a.trainee_id = p_trainee_id
    and s.session_date between p_from and p_to
  order by s.session_date desc, s.starts_at desc, s.ends_at desc, s.id;
end;
$$;

-- Same signature as before; adds the attendance check so a cascade never erases marks.
create or replace function public.delete_extra_session(p_session_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_slot public.session_slot;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  select slot into v_slot
  from public.sessions
  where id = p_session_id
  for update;
  if not found then
    perform private.fail('BXNTF', 'Session not found');
  end if;

  -- Regular batches come back on the next ensure_day_sessions, so removing them means nothing.
  if v_slot <> 'extra' then
    perform private.fail('BXVAL', 'Only extra sessions can be removed');
  end if;

  -- The row lock above waits for in-flight marks, so this sees every committed one.
  if exists (select 1 from public.attendance a where a.session_id = p_session_id) then
    perform private.fail('BXVAL', 'This session already has attendance');
  end if;

  delete from public.sessions
  where id = p_session_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Trial bookings
-- ---------------------------------------------------------------------------

create table if not exists public.trial_bookings (
  id uuid primary key default gen_random_uuid(),
  full_name text not null check (length(trim(full_name)) between 2 and 80),
  phone text not null,
  date_of_birth date null,
  age integer null check (age between 3 and 99),
  session_date date not null,
  slot public.session_slot not null check (slot in ('morning', 'evening')),
  note text null check (note is null or length(note) <= 300),
  device_key text not null check (length(device_key) between 16 and 128),
  created_at timestamptz not null default private.clock(),
  check (date_of_birth is not null or age is not null),
  constraint trial_bookings_phone_slot_key unique (phone, session_date, slot)
);

-- Staff list bookings by day and batch.
create index if not exists trial_bookings_date_idx
  on public.trial_bookings (session_date, slot);

-- Visitors list their upcoming bookings by device key; anon calls must not scan the table.
create index if not exists trial_bookings_device_key_idx
  on public.trial_bookings (device_key, session_date);

alter table public.trial_bookings enable row level security;

-- No anon policy: visitors reach their own rows only through my_trial_bookings.
create policy trial_bookings_select_staff on public.trial_bookings
  for select to authenticated
  using ((select private.is_staff()));

-- Rows are created only through book_trial; truncate would bypass RLS.
revoke insert, update, delete, truncate, references, trigger on public.trial_bookings from anon, authenticated;

-- Open to anon: a visitor books without an account, identified by the device key the app keeps.
create or replace function public.book_trial(
  p_full_name text,
  p_phone text,
  p_session_date date,
  p_slot public.session_slot,
  p_device_key text,
  p_date_of_birth date default null,
  p_age integer default null,
  p_note text default null
)
returns public.trial_bookings
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_today date := private.today();
  v_full_name text := trim(p_full_name);
  v_phone text;
  v_note text := nullif(trim(p_note), '');
  v_booking public.trial_bookings;
begin
  if v_full_name is null or length(v_full_name) not between 2 and 80 then
    perform private.fail('BXVAL', 'Enter your name');
  end if;

  v_phone := private.normalize_phone(p_phone);

  if p_slot is null or p_slot = 'extra' then
    perform private.fail('BXVAL', 'Pick the morning or the evening batch');
  end if;

  if p_session_date is null or p_session_date < v_today then
    perform private.fail('BXVAL', 'Pick today or a later day');
  end if;

  if p_session_date > v_today + 30 then
    perform private.fail('BXVAL', 'Trials can be booked up to 30 days ahead');
  end if;

  -- The club has no regular batches on Sunday (ISO day 7).
  if extract(isodow from p_session_date) = 7 then
    perform private.fail('BXVAL', 'The club is closed on Sundays');
  end if;

  if p_date_of_birth is null and p_age is null then
    perform private.fail('BXVAL', 'Tell us your age or date of birth');
  end if;

  if p_date_of_birth is not null then
    if p_date_of_birth > v_today then
      perform private.fail('BXVAL', 'Date of birth cannot be in the future');
    end if;
    -- Same floor as trainee records, so a typo year is caught before staff see it.
    if p_date_of_birth <= date '1900-01-01' then
      perform private.fail('BXVAL', 'Enter a valid date of birth');
    end if;
  end if;

  -- Mirrors the table check so the app gets BXVAL instead of a raw constraint error.
  if p_age is not null and p_age not between 3 and 99 then
    perform private.fail('BXVAL', 'Enter an age between 3 and 99');
  end if;

  if v_note is not null and length(v_note) > 300 then
    perform private.fail('BXVAL', 'Keep the note to 300 characters or fewer');
  end if;

  if p_device_key is null or length(p_device_key) not between 16 and 128 then
    perform private.fail('BXVAL', 'Invalid device key');
  end if;

  -- Conflict target instead of an exception block: no subtransaction, and only this key maps to BXDUP.
  insert into public.trial_bookings (
    full_name, phone, date_of_birth, age, session_date, slot, note, device_key
  )
  values (
    v_full_name, v_phone, p_date_of_birth, p_age, p_session_date, p_slot, v_note, p_device_key
  )
  on conflict on constraint trial_bookings_phone_slot_key do nothing
  returning * into v_booking;

  if not found then
    perform private.fail('BXDUP', 'This number already has a trial booked for that batch');
  end if;

  return v_booking;
end;
$$;

-- The device key is the visitor's only credential, so the result is limited to that key's rows.
create or replace function public.my_trial_bookings(p_device_key text)
returns setof public.trial_bookings
language sql
stable
security definer
set search_path = ''
as $$
  select b.*
  from public.trial_bookings b
  where b.device_key = p_device_key
    and b.session_date >= private.today()
  order by b.session_date, b.slot, b.created_at, b.id;
$$;

create or replace function public.trial_bookings_between(p_from date, p_to date)
returns setof public.trial_bookings
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  if p_from is null or p_to is null then
    perform private.fail('BXVAL', 'Choose a start and an end date');
  end if;

  if p_to < p_from then
    perform private.fail('BXVAL', 'The end date is before the start date');
  end if;

  return query
  select b.*
  from public.trial_bookings b
  where b.session_date between p_from and p_to
  order by b.session_date, b.slot, b.created_at, b.id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Execute grants: API roles reach only what they need
-- ---------------------------------------------------------------------------

revoke execute on function public.mark_attendance(uuid, uuid, public.attendance_status) from public, anon;
revoke execute on function public.mark_remaining_absent(uuid) from public, anon;
revoke execute on function public.session_roster(uuid) from public, anon;
revoke execute on function public.trainee_attendance_history(uuid, date, date) from public, anon;
revoke execute on function public.delete_extra_session(uuid) from public, anon;
revoke execute on function public.trial_bookings_between(date, date) from public, anon;
revoke execute on function public.book_trial(text, text, date, public.session_slot, text, date, integer, text) from public;
revoke execute on function public.my_trial_bookings(text) from public;

grant execute on function public.mark_attendance(uuid, uuid, public.attendance_status) to authenticated;
grant execute on function public.mark_remaining_absent(uuid) to authenticated;
grant execute on function public.session_roster(uuid) to authenticated;
grant execute on function public.trainee_attendance_history(uuid, date, date) to authenticated;
grant execute on function public.delete_extra_session(uuid) to authenticated;
grant execute on function public.trial_bookings_between(date, date) to authenticated;
grant execute on function public.book_trial(text, text, date, public.session_slot, text, date, integer, text) to anon, authenticated;
grant execute on function public.my_trial_bookings(text) to anon, authenticated;
