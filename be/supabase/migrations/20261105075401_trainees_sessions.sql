-- Trainees and sessions: the roster with photos, the daily batches and extra sessions.

-- ---------------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------------

do $$
begin
  create type public.trainee_status as enum ('active', 'inactive');
exception
  when duplicate_object then null;
end;
$$;

do $$
begin
  create type public.session_slot as enum ('morning', 'evening', 'extra');
exception
  when duplicate_object then null;
end;
$$;

-- ---------------------------------------------------------------------------
-- Trainees
-- ---------------------------------------------------------------------------

create table if not exists public.trainees (
  id uuid primary key default gen_random_uuid(),
  full_name text not null check (length(trim(full_name)) between 2 and 80),
  phone text null,
  photo_path text null,
  date_of_birth date null check (date_of_birth > date '1900-01-01'),
  joined_on date null,
  status public.trainee_status not null default 'active',
  notes text null check (notes is null or length(notes) <= 500),
  created_by uuid null references public.profiles (id) on delete set null,
  created_at timestamptz not null default private.clock(),
  updated_at timestamptz not null default private.clock()
);

-- The roster lists by status, then by name without regard to case.
create index if not exists trainees_status_full_name_idx
  on public.trainees (status, lower(full_name));

-- Removing a staff profile nulls created_by; the index keeps that from scanning the roster.
create index if not exists trainees_created_by_idx
  on public.trainees (created_by);

create or replace trigger trainees_set_updated_at
  before update on public.trainees
  for each row execute function private.set_updated_at();

alter table public.trainees enable row level security;

create policy trainees_select_staff on public.trainees
  for select to authenticated
  using ((select private.is_staff()));

-- Rows change only through the trainee functions below; truncate would bypass RLS.
revoke insert, update, delete, truncate, references, trigger on public.trainees from anon, authenticated;

-- Shared by create_trainee and update_trainee so both enforce the same rules and messages.
create or replace function private.clean_trainee_input(
  p_full_name text,
  p_phone text,
  p_date_of_birth date,
  p_joined_on date,
  p_notes text,
  out o_full_name text,
  out o_phone text,
  out o_notes text
)
language plpgsql
set search_path = ''
as $$
declare
  v_today date := private.today();
begin
  o_full_name := trim(p_full_name);
  if o_full_name is null or length(o_full_name) not between 2 and 80 then
    perform private.fail('BXVAL', 'Enter a name between 2 and 80 characters');
  end if;

  -- A blank phone field means no phone, not an invalid one.
  o_phone := nullif(trim(p_phone), '');
  if o_phone is not null then
    o_phone := private.normalize_phone(o_phone);
  end if;

  if p_date_of_birth is not null then
    if p_date_of_birth > v_today then
      perform private.fail('BXVAL', 'Date of birth cannot be in the future');
    end if;
    -- Mirrors the table check so the app gets BXVAL instead of a raw constraint error.
    if p_date_of_birth <= date '1900-01-01' then
      perform private.fail('BXVAL', 'Enter a valid date of birth');
    end if;
  end if;

  -- One day of slack so a trainee joining tomorrow morning can be added the evening before.
  if p_joined_on is not null and p_joined_on > v_today + 1 then
    perform private.fail('BXVAL', 'Joining date cannot be in the future');
  end if;

  o_notes := nullif(trim(p_notes), '');
  if o_notes is not null and length(o_notes) > 500 then
    perform private.fail('BXVAL', 'Notes must be 500 characters or fewer');
  end if;
end;
$$;

create or replace function public.create_trainee(
  p_full_name text,
  p_phone text default null,
  p_date_of_birth date default null,
  p_joined_on date default null,
  p_notes text default null
)
returns public.trainees
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_clean record;
  v_trainee public.trainees;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  select * into v_clean
  from private.clean_trainee_input(p_full_name, p_phone, p_date_of_birth, p_joined_on, p_notes);

  insert into public.trainees (full_name, phone, date_of_birth, joined_on, notes, created_by)
  values (
    v_clean.o_full_name,
    v_clean.o_phone,
    p_date_of_birth,
    p_joined_on,
    v_clean.o_notes,
    (select auth.uid())
  )
  returning * into v_trainee;

  return v_trainee;
end;
$$;

-- Every field is replaced (null clears), so the app always sends the full record.
create or replace function public.update_trainee(
  p_trainee_id uuid,
  p_full_name text,
  p_phone text,
  p_date_of_birth date,
  p_joined_on date,
  p_notes text
)
returns public.trainees
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_clean record;
  v_trainee public.trainees;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  -- Row lock so two coaches saving the same trainee apply one after the other.
  perform 1 from public.trainees where id = p_trainee_id for update;
  if not found then
    perform private.fail('BXNTF', 'Trainee not found');
  end if;

  select * into v_clean
  from private.clean_trainee_input(p_full_name, p_phone, p_date_of_birth, p_joined_on, p_notes);

  update public.trainees
  set full_name = v_clean.o_full_name,
      phone = v_clean.o_phone,
      date_of_birth = p_date_of_birth,
      joined_on = p_joined_on,
      notes = v_clean.o_notes
  where id = p_trainee_id
  returning * into v_trainee;

  return v_trainee;
end;
$$;

create or replace function public.set_trainee_status(
  p_trainee_id uuid,
  p_status public.trainee_status
)
returns public.trainees
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_trainee public.trainees;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  select * into v_trainee
  from public.trainees
  where id = p_trainee_id
  for update;
  if not found then
    perform private.fail('BXNTF', 'Trainee not found');
  end if;

  if p_status is null then
    perform private.fail('BXVAL', 'Choose a status');
  end if;

  -- Same status is a no-op, so updated_at only moves on a real change.
  if v_trainee.status = p_status then
    return v_trainee;
  end if;

  update public.trainees
  set status = p_status
  where id = p_trainee_id
  returning * into v_trainee;

  return v_trainee;
end;
$$;

-- p_photo_path is the object name inside bucket trainee-photos; null clears the photo.
create or replace function public.set_trainee_photo(
  p_trainee_id uuid,
  p_photo_path text
)
returns public.trainees
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_trainee public.trainees;
  v_prefix text := p_trainee_id::text || '/';
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  perform 1 from public.trainees where id = p_trainee_id for update;
  if not found then
    perform private.fail('BXNTF', 'Trainee not found');
  end if;

  -- Needs a file name after the folder and no parent segments, so the path stays in that folder.
  if p_photo_path is not null and (
    not starts_with(p_photo_path, v_prefix)
    or length(p_photo_path) <= length(v_prefix)
    or p_photo_path ~ '(^|/)\.\.(/|$)'
  ) then
    perform private.fail('BXVAL', 'Photo path must be inside the trainee folder');
  end if;

  update public.trainees
  set photo_path = p_photo_path
  where id = p_trainee_id
  returning * into v_trainee;

  return v_trainee;
end;
$$;

-- ---------------------------------------------------------------------------
-- Storage: trainee photos, private bucket readable and writable by staff only
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('trainee-photos', 'trainee-photos', false, 2097152, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create policy trainee_photos_select_staff on storage.objects
  for select to authenticated
  using (bucket_id = 'trainee-photos' and (select private.is_staff()));

create policy trainee_photos_insert_staff on storage.objects
  for insert to authenticated
  with check (bucket_id = 'trainee-photos' and (select private.is_staff()));

create policy trainee_photos_update_staff on storage.objects
  for update to authenticated
  using (bucket_id = 'trainee-photos' and (select private.is_staff()))
  with check (bucket_id = 'trainee-photos' and (select private.is_staff()));

create policy trainee_photos_delete_staff on storage.objects
  for delete to authenticated
  using (bucket_id = 'trainee-photos' and (select private.is_staff()));

-- ---------------------------------------------------------------------------
-- Sessions
-- ---------------------------------------------------------------------------

create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  session_date date not null,
  slot public.session_slot not null,
  starts_at time not null,
  ends_at time not null check (ends_at > starts_at),
  created_by uuid null references public.profiles (id) on delete set null,
  created_at timestamptz not null default private.clock()
);

-- At most one morning and one evening batch per day; extra sessions are unlimited.
create unique index if not exists sessions_regular_slot_key
  on public.sessions (session_date, slot)
  where slot <> 'extra';

create index if not exists sessions_date_idx
  on public.sessions (session_date);

-- Removing a staff profile nulls created_by; the index keeps that from scanning every session.
create index if not exists sessions_created_by_idx
  on public.sessions (created_by);

alter table public.sessions enable row level security;

create policy sessions_select_staff on public.sessions
  for select to authenticated
  using ((select private.is_staff()));

-- Rows change only through the session functions below; truncate would bypass RLS.
revoke insert, update, delete, truncate, references, trigger on public.sessions from anon, authenticated;

-- Regular batches are created lazily, so no scheduled job is needed on the free tier.
create or replace function public.ensure_day_sessions(p_date date)
returns setof public.sessions
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  if p_date is null then
    perform private.fail('BXVAL', 'Choose a date');
  end if;

  -- The club has no regular batches on Sunday (ISO day 7).
  if extract(isodow from p_date) <> 7 then
    -- The partial unique index makes concurrent first opens of a day safe.
    insert into public.sessions (session_date, slot, starts_at, ends_at)
    values
      (p_date, 'morning', time '06:00', time '08:30'),
      (p_date, 'evening', time '17:30', time '20:00')
    on conflict (session_date, slot) where slot <> 'extra' do nothing;
  end if;

  return query
  select s.*
  from public.sessions s
  where s.session_date = p_date
  order by s.starts_at, s.ends_at, s.created_at, s.id;
end;
$$;

create or replace function public.add_extra_session(
  p_date date,
  p_starts_at time,
  p_ends_at time
)
returns public.sessions
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_session public.sessions;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  if p_date is null then
    perform private.fail('BXVAL', 'Choose a date');
  end if;

  if p_starts_at is null or p_ends_at is null then
    perform private.fail('BXVAL', 'Choose a start and an end time');
  end if;

  if p_ends_at <= p_starts_at then
    perform private.fail('BXVAL', 'End time must be after the start time');
  end if;

  insert into public.sessions (session_date, slot, starts_at, ends_at, created_by)
  values (p_date, 'extra', p_starts_at, p_ends_at, (select auth.uid()))
  returning * into v_session;

  return v_session;
end;
$$;

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

  -- Task-03 adds the "This session already has attendance" check once the attendance table exists.

  delete from public.sessions
  where id = p_session_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Execute grants: API roles reach only what they need
-- ---------------------------------------------------------------------------

revoke execute on function private.clean_trainee_input(text, text, date, date, text) from public, anon, authenticated;

revoke execute on function public.create_trainee(text, text, date, date, text) from public, anon;
revoke execute on function public.update_trainee(uuid, text, text, date, date, text) from public, anon;
revoke execute on function public.set_trainee_status(uuid, public.trainee_status) from public, anon;
revoke execute on function public.set_trainee_photo(uuid, text) from public, anon;
revoke execute on function public.ensure_day_sessions(date) from public, anon;
revoke execute on function public.add_extra_session(date, time, time) from public, anon;
revoke execute on function public.delete_extra_session(uuid) from public, anon;

grant execute on function public.create_trainee(text, text, date, date, text) to authenticated;
grant execute on function public.update_trainee(uuid, text, text, date, date, text) to authenticated;
grant execute on function public.set_trainee_status(uuid, public.trainee_status) to authenticated;
grant execute on function public.set_trainee_photo(uuid, text) to authenticated;
grant execute on function public.ensure_day_sessions(date) to authenticated;
grant execute on function public.add_extra_session(date, time, time) to authenticated;
grant execute on function public.delete_extra_session(uuid) to authenticated;
