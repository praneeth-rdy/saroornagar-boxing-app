-- Auth admin createUser inserts auth.users with only provider keys in raw_app_meta_data and
-- writes the custom app_metadata in a later update of the same transaction, so the profile is
-- also created when app_metadata gains a staff role after the insert.

-- ---------------------------------------------------------------------------
-- Shared profile insert
-- ---------------------------------------------------------------------------

-- Same rules as handle_new_user in 20261105105121: role from app_metadata only, email required.
-- An existing profile is left as it is, so profiles.role stays the source of truth after creation.
create or replace function private.ensure_profile(p_user auth.users)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_role text := p_user.raw_app_meta_data ->> 'role';
  v_phone text := coalesce(
    nullif(trim(p_user.phone), ''),
    nullif(trim(p_user.raw_app_meta_data ->> 'phone'), '')
  );
begin
  if v_role is null or v_role not in ('admin', 'coach') then
    return;
  end if;
  if nullif(trim(p_user.email), '') is null then
    return;
  end if;
  -- Checked before normalizing so a later metadata edit can never fail the auth update.
  if exists (select 1 from public.profiles where id = p_user.id) then
    return;
  end if;

  if v_phone is not null then
    v_phone := private.normalize_phone(v_phone);
  end if;

  insert into public.profiles (id, full_name, email, phone, role)
  values (
    p_user.id,
    coalesce(
      nullif(trim(p_user.raw_app_meta_data ->> 'full_name'), ''),
      nullif(trim(p_user.raw_user_meta_data ->> 'full_name'), ''),
      v_phone,
      'Staff'
    ),
    private.normalize_email(p_user.email),
    v_phone,
    v_role::public.staff_role
  )
  on conflict (id) do nothing;
end;
$$;

-- ---------------------------------------------------------------------------
-- Triggers on auth.users
-- ---------------------------------------------------------------------------

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.ensure_profile(new);
  return new;
end;
$$;

create or replace function private.handle_user_app_metadata_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.ensure_profile(new);
  return new;
end;
$$;

create or replace trigger on_auth_user_app_metadata_changed
  after update of raw_app_meta_data on auth.users
  for each row
  when (old.raw_app_meta_data is distinct from new.raw_app_meta_data)
  execute function private.handle_user_app_metadata_change();

-- ---------------------------------------------------------------------------
-- Execute grants
-- ---------------------------------------------------------------------------

revoke execute on function private.ensure_profile(auth.users) from public, anon, authenticated;
revoke execute on function private.handle_new_user() from public, anon, authenticated;
revoke execute on function private.handle_user_app_metadata_change() from public, anon, authenticated;
