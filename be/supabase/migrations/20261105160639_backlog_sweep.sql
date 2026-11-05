-- Backlog sweep: student wording in server messages (B-12), session times in the attendance
-- history (B-13), no trial in a batch that has ended today (B-05), inactive students with marks
-- kept in the monthly summary (B-06), one profiles select policy (B-09).

-- ---------------------------------------------------------------------------
-- B-09: one permissive select policy on profiles, so each row is checked once
-- ---------------------------------------------------------------------------

drop policy if exists profiles_select_own on public.profiles;
drop policy if exists profiles_select_staff on public.profiles;
drop policy if exists profiles_select_staff_or_own on public.profiles;

-- A blocked user still reads their own row so the app can show the blocked screen.
create policy profiles_select_staff_or_own on public.profiles
  for select to authenticated
  using (id = (select auth.uid()) or (select private.is_staff()));

-- ---------------------------------------------------------------------------
-- B-12: server messages say student; same signatures, bodies otherwise unchanged
-- ---------------------------------------------------------------------------

-- Every field is replaced (null clears), except a null roll number, which keeps the current one.
create or replace function public.update_trainee(
  p_trainee_id uuid,
  p_full_name text,
  p_phone text,
  p_date_of_birth date,
  p_joined_on date,
  p_notes text,
  p_roll_no integer default null
)
returns public.trainees
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_clean record;
  v_current public.trainees;
  v_roll_no integer;
  v_trainee public.trainees;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  -- Row lock so two coaches saving the same student apply one after the other.
  select * into v_current from public.trainees where id = p_trainee_id for update;
  if not found then
    perform private.fail('BXNTF', 'Student not found');
  end if;

  select * into v_clean
  from private.clean_trainee_input(p_full_name, p_phone, p_date_of_birth, p_joined_on, p_notes);

  v_roll_no := coalesce(p_roll_no, v_current.roll_no);
  if v_roll_no <= 0 then
    perform private.fail('BXVAL', 'Enter a roll number above 0');
  end if;
  -- An inactive student may hold a number in use; the clash is checked when they are reactivated.
  if v_current.status = 'active' then
    perform private.check_roll_no(v_roll_no, p_trainee_id);
  end if;

  begin
    update public.trainees
    set full_name = v_clean.o_full_name,
        phone = v_clean.o_phone,
        date_of_birth = p_date_of_birth,
        joined_on = p_joined_on,
        notes = v_clean.o_notes,
        roll_no = v_roll_no
    where id = p_trainee_id
    returning * into v_trainee;
  exception
    when unique_violation then
      perform private.fail('BXDUP', format('Roll number %s is already in use', v_roll_no));
  end;

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
    perform private.fail('BXNTF', 'Student not found');
  end if;

  if p_status is null then
    perform private.fail('BXVAL', 'Choose a status');
  end if;

  -- Same status is a no-op, so updated_at only moves on a real change.
  if v_trainee.status = p_status then
    return v_trainee;
  end if;

  -- The number may have been handed to someone else while this student was inactive.
  if p_status = 'active' then
    perform private.check_roll_no(v_trainee.roll_no, p_trainee_id);
  end if;

  begin
    update public.trainees
    set status = p_status
    where id = p_trainee_id
    returning * into v_trainee;
  exception
    when unique_violation then
      perform private.fail('BXDUP', format('Roll number %s is already in use', v_trainee.roll_no));
  end;

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
    perform private.fail('BXNTF', 'Student not found');
  end if;

  -- Needs a file name after the folder and no parent segments, so the path stays in that folder.
  if p_photo_path is not null and (
    not starts_with(p_photo_path, v_prefix)
    or length(p_photo_path) <= length(v_prefix)
    or p_photo_path ~ '(^|/)\.\.(/|$)'
  ) then
    perform private.fail('BXVAL', 'Photo path must be inside the student folder');
  end if;

  update public.trainees
  set photo_path = p_photo_path
  where id = p_trainee_id
  returning * into v_trainee;

  return v_trainee;
end;
$$;

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

  -- Share lock so the student cannot turn inactive between this check and the insert.
  select status into v_trainee_status
  from public.trainees
  where id = p_trainee_id
  for share;
  if not found then
    perform private.fail('BXNTF', 'Student not found');
  end if;

  if v_trainee_status <> 'active' then
    perform private.fail('BXVAL', 'This student is inactive');
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

-- Record only: several payments for one month are allowed (partial payments), no due logic.
create or replace function public.record_fee_payment(
  p_trainee_id uuid,
  p_amount integer,
  p_method public.payment_method,
  p_paid_on date,
  p_period_month date,
  p_note text default null
)
returns public.fee_payments
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_note text := nullif(trim(p_note), '');
  v_payment public.fee_payments;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  -- Key share lock so the student cannot be deleted between this check and the insert.
  perform 1 from public.trainees where id = p_trainee_id for key share;
  if not found then
    perform private.fail('BXNTF', 'Student not found');
  end if;

  if p_paid_on is null then
    perform private.fail('BXVAL', 'Enter the payment date');
  end if;

  if p_paid_on > private.today() then
    perform private.fail('BXVAL', 'The payment date cannot be in the future');
  end if;

  if p_period_month is null or p_period_month <> date_trunc('month', p_period_month)::date then
    perform private.fail('BXVAL', 'Period must be a month');
  end if;

  -- Mirrors the table check so the app gets BXVAL instead of a raw constraint error.
  if p_amount is null or p_amount not between 1 and 100000 then
    perform private.fail('BXVAL', 'Enter an amount between 1 and 100000');
  end if;

  if p_method is null then
    perform private.fail('BXVAL', 'Choose cash or UPI');
  end if;

  if v_note is not null and length(v_note) > 300 then
    perform private.fail('BXVAL', 'Keep the note to 300 characters or fewer');
  end if;

  insert into public.fee_payments (
    trainee_id, amount, method, paid_on, period_month, note, recorded_by, created_at
  )
  values (
    p_trainee_id, p_amount, p_method, p_paid_on, p_period_month, v_note, (select auth.uid()), private.clock()
  )
  returning * into v_payment;

  return v_payment;
end;
$$;

create or replace function public.trainee_fee_history(p_trainee_id uuid)
returns setof public.fee_payments
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  perform 1 from public.trainees t where t.id = p_trainee_id;
  if not found then
    perform private.fail('BXNTF', 'Student not found');
  end if;

  return query
  select f.*
  from public.fee_payments f
  where f.trainee_id = p_trainee_id
  order by f.period_month desc, f.paid_on desc, f.created_at desc, f.id;
end;
$$;

-- ---------------------------------------------------------------------------
-- B-13 (and B-12): attendance history carries each session's start and end time
-- ---------------------------------------------------------------------------

-- The return shape changes, which create or replace cannot do.
drop function if exists public.trainee_attendance_history(uuid, date, date);

-- starts_at and ends_at let the app label an extra session by its time.
create function public.trainee_attendance_history(
  p_trainee_id uuid,
  p_from date,
  p_to date
)
returns table (
  session_id uuid,
  session_date date,
  slot public.session_slot,
  status public.attendance_status,
  marked_at timestamptz,
  starts_at time,
  ends_at time
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
    perform private.fail('BXNTF', 'Student not found');
  end if;

  if p_from is null or p_to is null then
    perform private.fail('BXVAL', 'Choose a start and an end date');
  end if;

  if p_to < p_from then
    perform private.fail('BXVAL', 'The end date is before the start date');
  end if;

  return query
  select s.id, s.session_date, s.slot, a.status, a.marked_at, s.starts_at, s.ends_at
  from public.attendance a
  join public.sessions s on s.id = a.session_id
  where a.trainee_id = p_trainee_id
    and s.session_date between p_from and p_to
  order by s.session_date desc, s.starts_at desc, s.ends_at desc, s.id;
end;
$$;

-- ---------------------------------------------------------------------------
-- B-05: no trial in a batch that has already ended today
-- ---------------------------------------------------------------------------

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
  v_now time := (private.clock() at time zone 'Asia/Kolkata')::time;
  v_batch_end time;
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

  -- Batch ends match ensure_day_sessions (morning 06:00-08:30, evening 17:30-20:00, India time).
  if p_slot = 'morning' then
    v_batch_end := time '08:30';
  else
    v_batch_end := time '20:00';
  end if;
  if p_session_date = v_today and v_now >= v_batch_end then
    perform private.fail('BXVAL', 'That batch has already ended today');
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
    -- Same floor as student records, so a typo year is caught before staff see it.
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

-- ---------------------------------------------------------------------------
-- B-06: the monthly summary keeps inactive students who have marks that month
-- ---------------------------------------------------------------------------

-- session_count is the month's held total, the same on every row, so the app can show "n of m".
create or replace function public.monthly_attendance_summary(p_month date)
returns table (
  trainee_id uuid,
  full_name text,
  photo_path text,
  present_count integer,
  absent_count integer,
  session_count integer
)
language plpgsql
security definer
set search_path = ''
as $$
#variable_conflict use_column
declare
  v_session_count integer;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  if p_month is null or p_month <> date_trunc('month', p_month)::date then
    perform private.fail('BXVAL', 'Period must be a month');
  end if;

  select count(*)::integer into v_session_count
  from public.sessions s
  where s.session_date >= p_month
    and s.session_date < (p_month + interval '1 month')::date
    and exists (select 1 from public.attendance a where a.session_id = s.id);

  return query
  select
    t.id,
    t.full_name,
    t.photo_path,
    coalesce(c.present_count, 0)::integer,
    coalesce(c.absent_count, 0)::integer,
    v_session_count
  from public.trainees t
  left join (
    select
      a.trainee_id,
      count(*) filter (where a.status = 'present') as present_count,
      count(*) filter (where a.status = 'absent') as absent_count
    from public.attendance a
    join public.sessions s on s.id = a.session_id
    where s.session_date >= p_month
      and s.session_date < (p_month + interval '1 month')::date
    group by a.trainee_id
  ) c on c.trainee_id = t.id
  -- A student made inactive later still owns the marks they earned that month.
  where t.status = 'active' or c.trainee_id is not null
  order by lower(t.full_name), t.id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Execute grants: create or replace keeps grants; the recreated history function needs them again
-- ---------------------------------------------------------------------------

revoke execute on function public.trainee_attendance_history(uuid, date, date) from public, anon;
grant execute on function public.trainee_attendance_history(uuid, date, date) to authenticated;

revoke execute on function public.update_trainee(uuid, text, text, date, date, text, integer) from public, anon;
revoke execute on function public.set_trainee_status(uuid, public.trainee_status) from public, anon;
revoke execute on function public.set_trainee_photo(uuid, text) from public, anon;
revoke execute on function public.mark_attendance(uuid, uuid, public.attendance_status) from public, anon;
revoke execute on function public.record_fee_payment(uuid, integer, public.payment_method, date, date, text) from public, anon;
revoke execute on function public.trainee_fee_history(uuid) from public, anon;
revoke execute on function public.monthly_attendance_summary(date) from public, anon;
revoke execute on function public.book_trial(text, text, date, public.session_slot, text, date, integer, text) from public;

grant execute on function public.update_trainee(uuid, text, text, date, date, text, integer) to authenticated;
grant execute on function public.set_trainee_status(uuid, public.trainee_status) to authenticated;
grant execute on function public.set_trainee_photo(uuid, text) to authenticated;
grant execute on function public.mark_attendance(uuid, uuid, public.attendance_status) to authenticated;
grant execute on function public.record_fee_payment(uuid, integer, public.payment_method, date, date, text) to authenticated;
grant execute on function public.trainee_fee_history(uuid) to authenticated;
grant execute on function public.monthly_attendance_summary(date) to authenticated;
grant execute on function public.book_trial(text, text, date, public.session_slot, text, date, integer, text) to anon, authenticated;
