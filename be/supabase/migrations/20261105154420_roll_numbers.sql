-- Roll numbers: a number per student for roll call, unique among active students, chosen in the
-- form with a server suggestion (the smallest free number, else the highest plus one).

-- ---------------------------------------------------------------------------
-- Column, backfill, constraints
-- ---------------------------------------------------------------------------

alter table public.trainees add column if not exists roll_no integer;

-- Existing students are numbered 1, 2, 3 in the order they were added; the trigger is paused so
-- the backfill does not show up as an edit in updated_at.
alter table public.trainees disable trigger trainees_set_updated_at;

with numbered as (
  select
    t.id,
    coalesce((select max(x.roll_no) from public.trainees x), 0)
      + row_number() over (order by t.created_at, t.id) as roll_no
  from public.trainees t
  where t.roll_no is null
)
update public.trainees t
set roll_no = n.roll_no
from numbered n
where t.id = n.id;

alter table public.trainees enable trigger trainees_set_updated_at;

alter table public.trainees alter column roll_no set not null;

do $$
begin
  alter table public.trainees add constraint trainees_roll_no_check check (roll_no > 0);
exception
  when duplicate_object then null;
end;
$$;

-- An inactive student's number may be handed to someone else, so uniqueness covers active rows only.
create unique index if not exists trainees_roll_no_active_key
  on public.trainees (roll_no)
  where status = 'active';

-- ---------------------------------------------------------------------------
-- Suggested number
-- ---------------------------------------------------------------------------

-- Gaps left by deactivated students are filled first; otherwise the highest active number plus one.
create or replace function private.next_roll_no()
returns integer
language plpgsql
stable
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.trainees where status = 'active' and roll_no = 1
  ) then
    return 1;
  end if;

  return (
    select min(t.roll_no) + 1
    from public.trainees t
    where t.status = 'active'
      and not exists (
        select 1
        from public.trainees n
        where n.status = 'active'
          and n.roll_no = t.roll_no + 1
      )
  );
end;
$$;

create or replace function public.next_roll_no()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  return private.next_roll_no();
end;
$$;

-- Shared by the trainee functions so every path rejects a clash with the same message.
create or replace function private.check_roll_no(p_roll_no integer, p_trainee_id uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  if p_roll_no is null or p_roll_no <= 0 then
    perform private.fail('BXVAL', 'Enter a roll number above 0');
  end if;

  perform 1
  from public.trainees
  where status = 'active'
    and roll_no = p_roll_no
    and id is distinct from p_trainee_id;
  if found then
    perform private.fail('BXDUP', format('Roll number %s is already in use', p_roll_no));
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- Trainee functions take the roll number (the old signatures are replaced)
-- ---------------------------------------------------------------------------

drop function if exists public.create_trainee(text, text, date, date, text);
drop function if exists public.update_trainee(uuid, text, text, date, date, text);

-- A null roll number takes the server suggestion.
create or replace function public.create_trainee(
  p_full_name text,
  p_phone text default null,
  p_date_of_birth date default null,
  p_joined_on date default null,
  p_notes text default null,
  p_roll_no integer default null
)
returns public.trainees
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_clean record;
  v_roll_no integer;
  v_trainee public.trainees;
begin
  if not private.is_staff() then
    perform private.fail('BXPRM', 'Only club staff can do this');
  end if;

  select * into v_clean
  from private.clean_trainee_input(p_full_name, p_phone, p_date_of_birth, p_joined_on, p_notes);

  v_roll_no := coalesce(p_roll_no, private.next_roll_no());
  perform private.check_roll_no(v_roll_no, null);

  begin
    insert into public.trainees (full_name, phone, date_of_birth, joined_on, notes, created_by, roll_no)
    values (
      v_clean.o_full_name,
      v_clean.o_phone,
      p_date_of_birth,
      p_joined_on,
      v_clean.o_notes,
      (select auth.uid()),
      v_roll_no
    )
    returning * into v_trainee;
  exception
    -- Two coaches saving the same number at once: the index decides, the message stays the same.
    when unique_violation then
      perform private.fail('BXDUP', format('Roll number %s is already in use', v_roll_no));
  end;

  return v_trainee;
end;
$$;

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

  -- Row lock so two coaches saving the same trainee apply one after the other.
  select * into v_current from public.trainees where id = p_trainee_id for update;
  if not found then
    perform private.fail('BXNTF', 'Trainee not found');
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
    perform private.fail('BXNTF', 'Trainee not found');
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

-- ---------------------------------------------------------------------------
-- session_roster gains roll_no and is ordered by it, matching the roll call
-- ---------------------------------------------------------------------------

-- The return shape changes, which create or replace cannot do.
drop function if exists public.session_roster(uuid);

-- A null status means the trainee has not been marked for this session yet.
create function public.session_roster(p_session_id uuid)
returns table (
  trainee_id uuid,
  roll_no integer,
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
  select t.id, t.roll_no, t.full_name, t.photo_path, a.status, a.marked_at
  from public.trainees t
  left join public.attendance a
    on a.session_id = p_session_id
   and a.trainee_id = t.id
  where t.status = 'active'
  order by t.roll_no;
end;
$$;

-- ---------------------------------------------------------------------------
-- Execute grants: API roles reach only what they need
-- ---------------------------------------------------------------------------

revoke execute on function private.next_roll_no() from public, anon, authenticated;
revoke execute on function private.check_roll_no(integer, uuid) from public, anon, authenticated;
revoke execute on function public.next_roll_no() from public, anon;
revoke execute on function public.create_trainee(text, text, date, date, text, integer) from public, anon;
revoke execute on function public.update_trainee(uuid, text, text, date, date, text, integer) from public, anon;
revoke execute on function public.session_roster(uuid) from public, anon;

grant execute on function public.next_roll_no() to authenticated;
grant execute on function public.create_trainee(text, text, date, date, text, integer) to authenticated;
grant execute on function public.update_trainee(uuid, text, text, date, date, text, integer) to authenticated;
grant execute on function public.session_roster(uuid) to authenticated;
