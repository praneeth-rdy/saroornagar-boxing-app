-- Staff sign in by email and password: profiles carry the email, the phone becomes optional
-- contact data that an admin edits through update_staff.

-- ---------------------------------------------------------------------------
-- Email helper
-- ---------------------------------------------------------------------------

-- Emails are stored trimmed and lower-cased so the unique key matches how Auth compares them.
create or replace function private.normalize_email(p_email text)
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_email text := lower(trim(coalesce(p_email, '')));
begin
  if v_email !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then
    perform private.fail('BXVAL', 'Enter a valid email address');
  end if;
  return v_email;
end;
$$;

-- ---------------------------------------------------------------------------
-- profiles: email required and unique, phone optional
-- ---------------------------------------------------------------------------

alter table public.profiles add column if not exists email text;

update public.profiles p
set email = lower(trim(u.email))
from auth.users u
where u.id = p.id
  and p.email is null;

alter table public.profiles alter column email set not null;
alter table public.profiles alter column phone drop not null;

do $$
begin
  alter table public.profiles add constraint profiles_email_key unique (email);
exception
  when duplicate_table or duplicate_object then null;
end;
$$;

do $$
begin
  alter table public.profiles
    add constraint profiles_email_check check (email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$');
exception
  when duplicate_object then null;
end;
$$;

-- ---------------------------------------------------------------------------
-- Keep profiles in step with auth.users
-- ---------------------------------------------------------------------------

-- Same app_metadata-only role rule as 20261105081756; an auth user without an email is never staff.
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_role text := new.raw_app_meta_data ->> 'role';
  v_phone text := coalesce(nullif(trim(new.phone), ''), nullif(trim(new.raw_app_meta_data ->> 'phone'), ''));
begin
  if v_role is null or v_role not in ('admin', 'coach') then
    return new;
  end if;
  if nullif(trim(new.email), '') is null then
    return new;
  end if;

  if v_phone is not null then
    v_phone := private.normalize_phone(v_phone);
  end if;

  insert into public.profiles (id, full_name, email, phone, role)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_app_meta_data ->> 'full_name'), ''),
      nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
      v_phone,
      'Staff'
    ),
    private.normalize_email(new.email),
    v_phone,
    v_role::public.staff_role
  );
  return new;
end;
$$;

-- A cleared auth email leaves the profile email as it was, since a profile always needs one.
create or replace function private.handle_user_email_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if nullif(trim(new.email), '') is null then
    return new;
  end if;
  update public.profiles
  set email = private.normalize_email(new.email)
  where id = new.id;
  return new;
end;
$$;

create or replace trigger on_auth_user_email_changed
  after update of email on auth.users
  for each row
  when (old.email is distinct from new.email)
  execute function private.handle_user_email_change();

-- on_auth_user_phone_changed from 20261105074646 stays: an Auth phone change still syncs.

-- ---------------------------------------------------------------------------
-- update_staff gains the phone
-- ---------------------------------------------------------------------------

-- The 3-argument form is replaced, not overloaded, so PostgREST resolves one signature.
-- Dropping it is part of the approved email sign-in change (run 3, task-01).
drop function if exists public.update_staff(uuid, text, public.staff_role);

create or replace function public.update_staff(
  p_user_id uuid,
  p_full_name text,
  p_role public.staff_role,
  p_phone text
)
returns public.profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_profile public.profiles;
  v_full_name text := trim(p_full_name);
  v_phone text := nullif(trim(p_phone), '');
begin
  if not private.is_admin() then
    perform private.fail('BXPRM', 'Only an admin can edit staff');
  end if;

  -- Row lock so two admins editing the same person apply one after the other.
  select * into v_profile
  from public.profiles
  where id = p_user_id
  for update;
  if not found then
    perform private.fail('BXNTF', 'Staff member not found');
  end if;

  -- An admin demoting themselves could leave the club without an admin.
  if p_user_id = (select auth.uid()) and p_role is distinct from v_profile.role then
    perform private.fail('BXVAL', 'You cannot change your own role');
  end if;

  if v_full_name is null or length(v_full_name) not between 2 and 80 then
    perform private.fail('BXVAL', 'Enter a name between 2 and 80 characters');
  end if;

  if p_role is null then
    perform private.fail('BXVAL', 'Choose a role');
  end if;

  if v_phone is not null then
    v_phone := private.normalize_phone(v_phone);
  end if;

  begin
    update public.profiles
    set full_name = v_full_name,
        role = p_role,
        phone = v_phone
    where id = p_user_id
    returning * into v_profile;
  exception
    when unique_violation then
      perform private.fail('BXDUP', 'This number belongs to another staff member');
  end;

  return v_profile;
end;
$$;

-- ---------------------------------------------------------------------------
-- Execute grants
-- ---------------------------------------------------------------------------

revoke execute on function private.normalize_email(text) from public, anon, authenticated;
revoke execute on function private.handle_new_user() from public, anon, authenticated;
revoke execute on function private.handle_user_email_change() from public, anon, authenticated;

revoke execute on function public.update_staff(uuid, text, public.staff_role, text) from public, anon;
grant execute on function public.update_staff(uuid, text, public.staff_role, text) to authenticated;
