-- Identity: shared private helpers, staff roles, profiles, and the admin-only staff edit.

-- ---------------------------------------------------------------------------
-- Schema private: helpers and security-definer internals, never exposed through the API.
-- ---------------------------------------------------------------------------

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

-- New private functions start unexecutable by API roles; grants are made one by one below.
alter default privileges in schema private revoke execute on functions from public;

-- The single way functions fail, so the app can map the SQLSTATE (BXVAL, BXPRM, BXNTF, BXDUP).
create or replace function private.fail(p_code text, p_message text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise exception using errcode = p_code, message = p_message;
end;
$$;

-- Server time with a transaction-local override so pgTAP can pin the clock.
create or replace function private.clock()
returns timestamptz
language sql
stable
set search_path = ''
as $$
  select coalesce(nullif(current_setting('private.clock', true), '')::timestamptz, now());
$$;

-- Club dates are India calendar dates whatever the server time zone is.
create or replace function private.today()
returns date
language sql
stable
set search_path = ''
as $$
  select (private.clock() at time zone 'Asia/Kolkata')::date;
$$;

-- Security definer so writers without access to schema private (service_role) can still update rows.
create or replace function private.set_updated_at()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.updated_at := private.clock();
  return new;
end;
$$;

-- Phones are stored as 12 digits with the 91 prefix and no plus, whatever the user typed.
create or replace function private.normalize_phone(p_phone text)
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_digits text := regexp_replace(coalesce(p_phone, ''), '[^0-9]', '', 'g');
begin
  if length(v_digits) = 10 then
    return '91' || v_digits;
  elsif length(v_digits) = 12 and left(v_digits, 2) = '91' then
    return v_digits;
  end if;
  perform private.fail('BXVAL', 'Enter a 10-digit mobile number');
  return null;
end;
$$;

-- ---------------------------------------------------------------------------
-- Staff roles and profiles
-- ---------------------------------------------------------------------------

do $$
begin
  create type public.staff_role as enum ('admin', 'coach');
exception
  when duplicate_object then null;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null check (length(trim(full_name)) between 2 and 80),
  phone text not null unique,
  role public.staff_role not null default 'coach',
  is_blocked boolean not null default false,
  created_at timestamptz not null default private.clock(),
  updated_at timestamptz not null default private.clock()
);

create or replace trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function private.set_updated_at();

-- Security definer so RLS on profiles can call these without recursing into its own policies.
create or replace function private.is_staff()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and not p.is_blocked
  );
$$;

create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and not p.is_blocked
      and p.role = 'admin'
  );
$$;

alter table public.profiles enable row level security;

-- A blocked user still reads their own row so the app can show the blocked screen.
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = (select auth.uid()));

create policy profiles_select_staff on public.profiles
  for select to authenticated
  using ((select private.is_staff()));

-- Rows change only through the auth triggers and update_staff; truncate would bypass RLS.
revoke insert, update, delete, truncate, references, trigger on public.profiles from anon, authenticated;

-- ---------------------------------------------------------------------------
-- Keep profiles in step with auth.users
-- ---------------------------------------------------------------------------

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, phone, role)
  values (
    new.id,
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''), nullif(new.phone, ''), 'Staff'),
    coalesce(nullif(new.phone, ''), new.raw_user_meta_data ->> 'phone'),
    coalesce((new.raw_user_meta_data ->> 'role')::public.staff_role, 'coach')
  );
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

create or replace function private.handle_user_phone_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.profiles
  set phone = new.phone
  where id = new.id;
  return new;
end;
$$;

create or replace trigger on_auth_user_phone_changed
  after update of phone on auth.users
  for each row
  when (old.phone is distinct from new.phone)
  execute function private.handle_user_phone_change();

-- ---------------------------------------------------------------------------
-- Functions the app calls
-- ---------------------------------------------------------------------------

create or replace function public.update_staff(
  p_user_id uuid,
  p_full_name text,
  p_role public.staff_role
)
returns public.profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_profile public.profiles;
  v_full_name text := trim(p_full_name);
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

  update public.profiles
  set full_name = v_full_name,
      role = p_role
  where id = p_user_id
  returning * into v_profile;

  return v_profile;
end;
$$;

-- Works for blocked users too, so the app can tell blocked from signed out.
create or replace function public.current_profile()
returns public.profiles
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_profile public.profiles;
begin
  select * into v_profile
  from public.profiles
  where id = (select auth.uid());
  if not found then
    perform private.fail('BXNTF', 'Profile not found');
  end if;
  return v_profile;
end;
$$;

-- ---------------------------------------------------------------------------
-- Execute grants: API roles reach only what they need
-- ---------------------------------------------------------------------------

revoke execute on function private.fail(text, text) from public, anon, authenticated;
revoke execute on function private.clock() from public, anon, authenticated;
revoke execute on function private.today() from public, anon, authenticated;
revoke execute on function private.set_updated_at() from public, anon, authenticated;
revoke execute on function private.normalize_phone(text) from public, anon, authenticated;
revoke execute on function private.handle_new_user() from public, anon, authenticated;
revoke execute on function private.handle_user_phone_change() from public, anon, authenticated;

-- RLS policies run as the caller, so the caller needs execute on the helpers they use.
revoke execute on function private.is_staff() from public, anon;
revoke execute on function private.is_admin() from public, anon;
grant execute on function private.is_staff() to authenticated;
grant execute on function private.is_admin() to authenticated;

revoke execute on function public.update_staff(uuid, text, public.staff_role) from public, anon;
revoke execute on function public.current_profile() from public, anon;
grant execute on function public.update_staff(uuid, text, public.staff_role) to authenticated;
grant execute on function public.current_profile() to authenticated;
