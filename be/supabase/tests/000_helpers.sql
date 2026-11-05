-- pgTAP helpers shared by every test file; runs first and commits so later files can use them.
-- Local stack only: the tests schema is not exposed through the API and never belongs on hosted.

set client_min_messages = warning;

create extension if not exists pgtap with schema extensions;

create schema if not exists tests;
grant usage on schema tests to public;

-- Security definer so lookups still work after a test has switched to the authenticated role.
create or replace function tests.user_id(p_phone text)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select u.id from auth.users u where u.phone = p_phone;
$$;

-- Same rows as seed.sql; the on_auth_user_created trigger creates the profile from the
-- app_metadata role, as the admin-staff Edge Function sets it. A null role makes no profile.
create or replace function tests.create_user(
  p_phone text,
  p_password text,
  p_full_name text,
  p_role text
)
returns uuid
language plpgsql
set search_path = ''
as $$
declare
  v_id uuid := tests.user_id(p_phone);
begin
  if v_id is not null then
    return v_id;
  end if;

  v_id := gen_random_uuid();

  insert into auth.users (
    instance_id, id, aud, role, phone, encrypted_password, phone_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change
  )
  values (
    '00000000-0000-0000-0000-000000000000', v_id, 'authenticated', 'authenticated', p_phone,
    extensions.crypt(p_password, extensions.gen_salt('bf')), now(),
    jsonb_build_object('provider', 'phone', 'providers', jsonb_build_array('phone'))
      || jsonb_strip_nulls(jsonb_build_object('role', p_role, 'full_name', p_full_name)),
    jsonb_strip_nulls(jsonb_build_object('full_name', p_full_name)),
    now(), now(), '', '', '', ''
  );

  insert into auth.identities (
    id, provider_id, user_id, provider, identity_data, last_sign_in_at, created_at, updated_at
  )
  values (
    v_id, v_id::text, v_id, 'phone',
    jsonb_build_object(
      'sub', v_id::text, 'phone', p_phone, 'email_verified', false, 'phone_verified', true
    ),
    now(), now(), now()
  );

  return v_id;
end;
$$;

-- A plain sign-up: the role sits only in user metadata, which the caller controls, so the
-- trigger must create no profile. p_user_role null leaves user metadata empty.
create or replace function tests.create_user_without_role(
  p_phone text,
  p_password text,
  p_user_role text default null
)
returns uuid
language plpgsql
set search_path = ''
as $$
declare
  v_id uuid := tests.user_id(p_phone);
begin
  if v_id is not null then
    return v_id;
  end if;

  v_id := gen_random_uuid();

  insert into auth.users (
    instance_id, id, aud, role, phone, encrypted_password, phone_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new, email_change
  )
  values (
    '00000000-0000-0000-0000-000000000000', v_id, 'authenticated', 'authenticated', p_phone,
    extensions.crypt(p_password, extensions.gen_salt('bf')), now(),
    '{"provider": "phone", "providers": ["phone"]}'::jsonb,
    jsonb_strip_nulls(jsonb_build_object('role', p_user_role)),
    now(), now(), '', '', '', ''
  );

  insert into auth.identities (
    id, provider_id, user_id, provider, identity_data, last_sign_in_at, created_at, updated_at
  )
  values (
    v_id, v_id::text, v_id, 'phone',
    jsonb_build_object(
      'sub', v_id::text, 'phone', p_phone, 'email_verified', false, 'phone_verified', true
    ),
    now(), now(), now()
  );

  return v_id;
end;
$$;

-- Transaction-local, like a PostgREST request: test files wrap themselves in begin/rollback.
create or replace function tests.authenticate_as(p_phone text)
returns void
language plpgsql
set search_path = ''
as $$
declare
  v_id uuid := tests.user_id(p_phone);
begin
  if v_id is null then
    raise exception 'tests.authenticate_as: no user with phone %', p_phone;
  end if;
  perform set_config(
    'request.jwt.claims',
    json_build_object('sub', v_id, 'role', 'authenticated')::text,
    true
  );
  perform set_config('role', 'authenticated', true);
end;
$$;

create or replace function tests.authenticate_as_anon()
returns void
language plpgsql
set search_path = ''
as $$
begin
  perform set_config('request.jwt.claims', json_build_object('role', 'anon')::text, true);
  perform set_config('role', 'anon', true);
end;
$$;

create or replace function tests.clear_auth()
returns void
language plpgsql
set search_path = ''
as $$
begin
  perform set_config('role', 'none', true);
  perform set_config('request.jwt.claims', '', true);
end;
$$;

-- Pins private.clock() for the rest of the transaction; null goes back to now().
create or replace function tests.set_clock(p_at timestamptz)
returns void
language plpgsql
set search_path = ''
as $$
begin
  perform set_config('private.clock', coalesce(to_json(p_at) #>> '{}', ''), true);
end;
$$;

-- pg_prove needs a plan from every file; these prove the helpers installed.
select plan(7);
select has_function('tests', 'user_id', array['text'], 'tests.user_id exists');
select has_function('tests', 'create_user', array['text', 'text', 'text', 'text'], 'tests.create_user exists');
select has_function('tests', 'create_user_without_role', array['text', 'text', 'text'], 'tests.create_user_without_role exists');
select has_function('tests', 'authenticate_as', array['text'], 'tests.authenticate_as exists');
select has_function('tests', 'authenticate_as_anon', array[]::text[], 'tests.authenticate_as_anon exists');
select has_function('tests', 'clear_auth', array[]::text[], 'tests.clear_auth exists');
select has_function('tests', 'set_clock', array['timestamp with time zone'], 'tests.set_clock exists');
select * from finish();
