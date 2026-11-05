-- Identity: helpers, profiles RLS, update_staff, current_profile, auth triggers, seed accounts.
begin;
select plan(101);

-- Fixed seed accounts (seed.sql) plus fixtures created per test run.
select tests.create_user('blocked@local.test', 'blocked-local-1234', 'Blocked Coach', 'coach') as blocked_id \gset
select tests.create_user('blocked-admin@local.test', 'blocked-local-1234', 'Blocked Admin', 'admin') as blocked_admin_id \gset
update public.profiles set is_blocked = true where email in ('blocked@local.test', 'blocked-admin@local.test');

-- Structure ----------------------------------------------------------------
select has_table('public', 'profiles', 'profiles table exists');
select has_type('public', 'staff_role', 'staff_role enum exists');
select enum_has_labels('public', 'staff_role', array['admin', 'coach'], 'staff_role labels');
select is(
  (select relrowsecurity from pg_class where oid = 'public.profiles'::regclass),
  true, 'profiles has RLS enabled'
);
select policies_are(
  'public', 'profiles', array['profiles_select_staff_or_own'],
  'profiles has exactly the one merged select policy'
);
select policy_cmd_is('public', 'profiles', 'profiles_select_staff_or_own', 'select', 'merged policy is select');
select policy_roles_are('public', 'profiles', 'profiles_select_staff_or_own', array['authenticated'], 'merged policy is for authenticated');
select has_trigger('public', 'profiles', 'profiles_set_updated_at', 'updated_at trigger exists');
select has_trigger('auth', 'users', 'on_auth_user_created', 'profile-creation trigger exists');
select has_trigger('auth', 'users', 'on_auth_user_phone_changed', 'phone-sync trigger exists');
select col_is_unique('public', 'profiles', 'phone', 'profiles.phone is unique');
select col_default_is('public', 'profiles', 'role', 'coach'::text, 'role defaults to coach');
select col_default_is('public', 'profiles', 'is_blocked', 'false', 'is_blocked defaults to false');

-- Privileges ----------------------------------------------------------------
select is(
  has_table_privilege('authenticated', 'public.profiles', 'insert')
    or has_table_privilege('authenticated', 'public.profiles', 'update')
    or has_table_privilege('authenticated', 'public.profiles', 'delete')
    or has_table_privilege('authenticated', 'public.profiles', 'truncate'),
  false, 'authenticated has no write privilege on profiles'
);
select is(
  has_function_privilege('authenticated', 'private.is_staff()', 'execute')
    and has_function_privilege('authenticated', 'private.is_admin()', 'execute'),
  true, 'authenticated can execute is_staff and is_admin'
);
select is(
  has_function_privilege('anon', 'private.is_staff()', 'execute')
    or has_function_privilege('anon', 'private.is_admin()', 'execute'),
  false, 'anon cannot execute is_staff or is_admin'
);
select is(
  has_function_privilege('authenticated', 'private.fail(text, text)', 'execute')
    or has_function_privilege('authenticated', 'private.clock()', 'execute')
    or has_function_privilege('authenticated', 'private.today()', 'execute')
    or has_function_privilege('authenticated', 'private.normalize_phone(text)', 'execute')
    or has_function_privilege('authenticated', 'private.set_updated_at()', 'execute')
    or has_function_privilege('authenticated', 'private.handle_new_user()', 'execute')
    or has_function_privilege('authenticated', 'private.handle_user_phone_change()', 'execute'),
  false, 'authenticated cannot execute the other private functions'
);
select is(
  has_function_privilege('anon', 'public.update_staff(uuid, text, public.staff_role, text)', 'execute')
    or has_function_privilege('anon', 'public.current_profile()', 'execute'),
  false, 'anon cannot execute update_staff or current_profile'
);
select is(
  has_function_privilege('authenticated', 'public.update_staff(uuid, text, public.staff_role, text)', 'execute')
    and has_function_privilege('authenticated', 'public.current_profile()', 'execute'),
  true, 'authenticated can execute update_staff and current_profile'
);

-- normalize_phone --------------------------------------------------------------
select is(private.normalize_phone('9876543210'), '919876543210', '10 digits get the 91 prefix');
select is(private.normalize_phone('919876543210'), '919876543210', '12 digits with 91 stay as is');
select is(private.normalize_phone('+91 98765-43210'), '919876543210', 'punctuation and spaces are stripped');
select is(private.normalize_phone(' (98765) 43210 '), '919876543210', 'brackets are stripped');
select throws_ok($$select private.normalize_phone('987654321')$$, 'BXVAL', 'Enter a 10-digit mobile number', '9 digits fail');
select throws_ok($$select private.normalize_phone('98765432101')$$, 'BXVAL', 'Enter a 10-digit mobile number', '11 digits fail');
select throws_ok($$select private.normalize_phone('449876543210')$$, 'BXVAL', 'Enter a 10-digit mobile number', '12 digits not starting 91 fail');
select throws_ok($$select private.normalize_phone('')$$, 'BXVAL', 'Enter a 10-digit mobile number', 'empty fails');
select throws_ok($$select private.normalize_phone(null)$$, 'BXVAL', 'Enter a 10-digit mobile number', 'null fails');
select throws_ok($$select private.normalize_phone('abcdefghij')$$, 'BXVAL', 'Enter a 10-digit mobile number', 'letters fail');

-- fail, clock, today ------------------------------------------------------------
select throws_ok($$select private.fail('BXDUP', 'Already there')$$, 'BXDUP', 'Already there', 'private.fail raises the given SQLSTATE and message');
select tests.set_clock('2026-03-01 20:00:00+00');
select is(private.clock(), '2026-03-01 20:00:00+00'::timestamptz, 'clock returns the pinned time');
select is(private.today(), '2026-03-02'::date, 'today is the India date (20:00 UTC is 01:30 next day IST)');
select tests.set_clock('2026-03-01 18:29:59+00');
select is(private.today(), '2026-03-01'::date, 'today is still the same India date at 23:59:59 IST');
select tests.set_clock('2026-03-01 18:30:00+00');
select is(private.today(), '2026-03-02'::date, 'today rolls over at midnight IST');
select tests.set_clock(null);
select ok(abs(extract(epoch from (private.clock() - now()))) < 5, 'clock falls back to now() when not pinned');

-- updated_at trigger -----------------------------------------------------------
select tests.set_clock('2026-04-01 10:00:00+00');
update public.profiles set full_name = 'Local Coach Two' where email = 'coach@local.test';
select is(
  (select updated_at from public.profiles where email = 'coach@local.test'),
  '2026-04-01 10:00:00+00'::timestamptz, 'update stamps updated_at from private.clock()'
);
select tests.set_clock(null);

-- Seed accounts and auth triggers --------------------------------------------------
select is(
  (select role::text from public.profiles where email = 'admin@local.test'),
  'admin', 'seed admin profile exists with role admin'
);
select is(
  (select role::text from public.profiles where email = 'coach@local.test'),
  'coach', 'seed coach profile exists with role coach'
);
select is(
  (select id from public.profiles where email = 'admin@local.test'),
  '00000000-0000-4000-a000-000000000001'::uuid, 'seed admin uses the fixed uuid'
);
select is(
  (select count(*)::int from auth.identities where user_id in
    ('00000000-0000-4000-a000-000000000001', '00000000-0000-4000-a000-000000000002')),
  2, 'seed accounts have email identities'
);

select tests.create_user('nameless@local.test', 'x-local-1234', null, 'coach', '919000000020') as nameless_id \gset
select is(
  (select full_name from public.profiles where id = :'nameless_id'),
  '919000000020', 'missing full_name falls back to the phone'
);
-- The role is read from app_metadata only; a sign-up without it, or with it only in user metadata, is not staff.
select tests.create_user_without_role('roleless@local.test', 'x-local-1234') as roleless_id \gset
select tests.create_user_without_role('self-admin@local.test', 'x-local-1234', 'admin') as self_admin_id \gset
select is(
  (select count(*)::int from public.profiles where id in (:'roleless_id', :'self_admin_id')),
  0, 'no app_metadata role (none, or admin in user metadata only) creates no profile'
);
select is(
  tests.create_user('nameless@local.test', 'x-local-1234', null, 'coach', '919000000020'), :'nameless_id'::uuid,
  'tests.create_user is idempotent on email'
);
update auth.users set phone = '919000000021' where id = :'nameless_id';
select is(
  (select phone from public.profiles where id = :'nameless_id'),
  '919000000021', 'changing auth.users.phone updates profiles.phone'
);
select throws_ok(
  $$insert into public.profiles (id, full_name, email, phone) values (gen_random_uuid(), 'No Auth User', 'ghost@local.test', '919000000078')$$,
  '23503', null, 'profile needs an auth user (foreign key)'
);
select throws_ok(
  $$update public.profiles set phone = '919000000021' where email = 'coach@local.test'$$,
  '23505', null, 'phone is unique'
);
select throws_ok(
  $$update public.profiles set full_name = 'x' where email = 'coach@local.test'$$,
  '23514', null, 'full_name shorter than 2 characters is rejected'
);
delete from auth.users where phone = '919000000021';
select is(
  (select count(*)::int from public.profiles where phone = '919000000021'),
  0, 'deleting the auth user cascades to the profile'
);

-- is_staff / is_admin (role reset: callers reach them only through policies; claims stay) --
select tests.authenticate_as('admin@local.test');
reset role;
select is(private.is_staff(), true, 'admin is staff');
select is(private.is_admin(), true, 'admin is admin');
select tests.authenticate_as('coach@local.test');
reset role;
select is(private.is_staff(), true, 'coach is staff');
select is(private.is_admin(), false, 'coach is not admin');
select tests.authenticate_as('blocked-admin@local.test');
reset role;
select is(private.is_staff(), false, 'blocked admin is not staff');
select is(private.is_admin(), false, 'blocked admin is not admin');
select tests.clear_auth();

-- profiles RLS ---------------------------------------------------------------------
select tests.authenticate_as('coach@local.test');
select cmp_ok((select count(*)::int from public.profiles), '>=', 4, 'coach reads every staff row');
select tests.authenticate_as('blocked@local.test');
select is((select count(*)::int from public.profiles), 1, 'blocked coach reads only their own row');
select is((select email from public.profiles), 'blocked@local.test', 'the blocked coach row is their own');

select tests.authenticate_as('coach@local.test');
select throws_ok($$insert into public.profiles (id, full_name, phone) values (gen_random_uuid(), 'Sneaky', '919000000077')$$, '42501', null, 'coach cannot insert a profile');
select tests.authenticate_as('coach@local.test');
select throws_ok($$update public.profiles set role = 'admin' where email = 'coach@local.test'$$, '42501', null, 'coach cannot promote themselves with a direct update');
select tests.authenticate_as('coach@local.test');
select throws_ok($$delete from public.profiles where email = 'admin@local.test'$$, '42501', null, 'coach cannot delete a profile');
select tests.authenticate_as('admin@local.test');
select throws_ok($$update public.profiles set role = 'coach' where email = 'coach@local.test'$$, '42501', null, 'admin cannot update profiles directly either');

select tests.authenticate_as_anon();
select throws_ok($$select count(*) from public.profiles$$, '42501', null, 'anon has no select privilege on profiles');
select tests.clear_auth();

-- update_staff ----------------------------------------------------------------------
select tests.authenticate_as('coach@local.test');
select throws_ok(
  format($$select public.update_staff(%L, 'Hacked Name', 'admin', null)$$, tests.user_id('coach@local.test')),
  'BXPRM', 'Only an admin can edit staff', 'coach cannot edit staff (self)'
);
select tests.authenticate_as('coach@local.test');
select throws_ok(
  format($$select public.update_staff(%L, 'Hacked Name', 'coach', null)$$, tests.user_id('admin@local.test')),
  'BXPRM', 'Only an admin can edit staff', 'coach cannot edit the admin'
);
select tests.authenticate_as('blocked-admin@local.test');
select throws_ok(
  format($$select public.update_staff(%L, 'Still Admin', 'admin', null)$$, tests.user_id('coach@local.test')),
  'BXPRM', 'Only an admin can edit staff', 'blocked admin cannot edit staff'
);
select tests.authenticate_as_anon();
select throws_ok(
  format($$select public.update_staff(%L, 'Anon Edit', 'coach', null)$$, tests.user_id('coach@local.test')),
  '42501', null, 'anon cannot call update_staff'
);

select tests.authenticate_as('admin@local.test');
select throws_ok(
  $$select public.update_staff('00000000-0000-4000-a000-0000000000ff', 'Ghost Person', 'coach', null)$$,
  'BXNTF', 'Staff member not found', 'missing staff id fails BXNTF'
);
select tests.authenticate_as('admin@local.test');
select throws_ok(
  format($$select public.update_staff(%L, 'Local Admin', 'coach', null)$$, tests.user_id('admin@local.test')),
  'BXVAL', 'You cannot change your own role', 'admin cannot change their own role'
);
select tests.authenticate_as('admin@local.test');
select throws_ok(
  format($$select public.update_staff(%L, 'X', 'coach', null)$$, tests.user_id('coach@local.test')),
  'BXVAL', 'Enter a name between 2 and 80 characters', 'one-character name fails'
);
select tests.authenticate_as('admin@local.test');
select throws_ok(
  format($$select public.update_staff(%L, '   ', 'coach', null)$$, tests.user_id('coach@local.test')),
  'BXVAL', 'Enter a name between 2 and 80 characters', 'blank name fails'
);
select tests.authenticate_as('admin@local.test');
select throws_ok(
  format($$select public.update_staff(%L, %L, 'coach', null)$$, tests.user_id('coach@local.test'), repeat('a', 81)),
  'BXVAL', 'Enter a name between 2 and 80 characters', '81-character name fails'
);
select tests.authenticate_as('admin@local.test');
select throws_ok(
  format($$select public.update_staff(%L, 'Local Coach', null, null)$$, tests.user_id('coach@local.test')),
  'BXVAL', 'Choose a role', 'null role fails'
);

select tests.authenticate_as('admin@local.test');
select is(
  (select role::text || '|' || full_name from public.update_staff(
    tests.user_id('coach@local.test'), '  Coach Renamed  ', 'admin', null)),
  'admin|Coach Renamed', 'admin edits another staff member; name is trimmed'
);
select is(
  (select role::text from public.update_staff(tests.user_id('admin@local.test'), 'Local Admin Two', 'admin', null)),
  'admin', 'admin can rename themselves keeping their role'
);
select tests.clear_auth();
select is(
  (select full_name from public.profiles where email = 'admin@local.test'),
  'Local Admin Two', 'the rename was persisted'
);

-- current_profile ------------------------------------------------------------------------
select tests.authenticate_as('coach@local.test');
select is((select email from public.current_profile()), 'coach@local.test', 'current_profile returns the own row');
select tests.authenticate_as('blocked@local.test');
select is((select is_blocked from public.current_profile()), true, 'current_profile returns the own row for a blocked user');
select is((select email from public.current_profile()), 'blocked@local.test', 'blocked user gets their own email');
select tests.clear_auth();

select tests.create_user('orphan@local.test', 'x-local-1234', 'No Profile', 'coach') as orphan_id \gset
delete from public.profiles where id = :'orphan_id';
select tests.authenticate_as('orphan@local.test');
select throws_ok($$select public.current_profile()$$, 'BXNTF', 'Profile not found', 'current_profile fails BXNTF without a profile');
select tests.authenticate_as_anon();
select throws_ok($$select public.current_profile()$$, '42501', null, 'anon cannot call current_profile');
select tests.clear_auth();

-- Email identity ---------------------------------------------------------------------------
select col_not_null('public', 'profiles', 'email', 'profiles.email is required');
select col_is_unique('public', 'profiles', 'email', 'profiles.email is unique');
select col_is_null('public', 'profiles', 'phone', 'profiles.phone is optional');
select has_trigger('auth', 'users', 'on_auth_user_email_changed', 'email-sync trigger exists');

select tests.create_user('Mixed.Case@Local.Test', 'x-local-1234', 'Mixed Case', 'coach') as mixed_id \gset
select is(
  (select email from public.profiles where id = :'mixed_id'),
  'mixed.case@local.test', 'profile email is lower-cased'
);
select is(
  (select phone from public.profiles where id = :'mixed_id'),
  null, 'a profile can be created without a phone'
);
insert into auth.users (id, aud, role, raw_app_meta_data)
values ('00000000-0000-4000-a000-0000000000e1', 'authenticated', 'authenticated', '{"role": "coach"}'::jsonb);
select is(
  (select count(*)::int from public.profiles where id = '00000000-0000-4000-a000-0000000000e1'),
  0, 'an auth user without an email gets no profile'
);
update auth.users set email = 'Renamed.Mixed@Local.Test' where id = :'mixed_id';
select is(
  (select email from public.profiles where id = :'mixed_id'),
  'renamed.mixed@local.test', 'changing auth.users.email updates profiles.email'
);
select throws_ok(
  $$update public.profiles set email = 'not-an-email' where email = 'renamed.mixed@local.test'$$,
  '23514', null, 'a malformed profile email is rejected'
);
select throws_ok(
  $$update public.profiles set email = 'admin@local.test' where email = 'renamed.mixed@local.test'$$,
  '23505', null, 'email is unique'
);

-- update_staff phone -------------------------------------------------------------------------
select tests.create_user('phoned@local.test', 'x-local-1234', 'Phoned Coach', 'coach', '919000000040') as phoned_id \gset
select tests.authenticate_as('admin@local.test');
select is(
  (select phone from public.update_staff(:'mixed_id', 'Mixed Case', 'coach', '919000000041')),
  '919000000041', 'admin sets a staff phone'
);
select is(
  (select phone from public.update_staff(:'mixed_id', 'Mixed Case', 'coach', null)),
  null, 'a null phone clears the staff phone'
);
select throws_ok(
  format($$select public.update_staff(%L, 'Mixed Case', 'coach', '919000000040')$$, :'mixed_id'),
  'BXDUP', 'This number belongs to another staff member', 'a phone used by another staff member fails BXDUP'
);
select tests.authenticate_as('phoned@local.test');
select throws_ok(
  format($$select public.update_staff(%L, 'Mixed Case', 'coach', '919000000042')$$, :'mixed_id'),
  'BXPRM', 'Only an admin can edit staff', 'coach cannot set a staff phone'
);
select tests.authenticate_as_anon();
select throws_ok(
  format($$select public.update_staff(%L, 'Mixed Case', 'coach', '919000000042')$$, :'mixed_id'),
  '42501', null, 'anon cannot set a staff phone'
);
select tests.clear_auth();

-- profile on app_metadata update --------------------------------------------------------------
select tests.create_user_like_gotrue('Gotrue@Local.Test', 'x-local-1234', 'Gotrue Coach', 'coach') as gotrue_id \gset
select is(
  (select email || '|' || full_name || '|' || role::text from public.profiles where id = :'gotrue_id'),
  'gotrue@local.test|Gotrue Coach|coach', 'insert then app_metadata update creates the profile'
);
select tests.create_user('direct@local.test', 'x-local-1234', 'Direct Coach', 'coach') as direct_id \gset
select is(
  (select role::text from public.profiles where id = :'direct_id'), 'coach',
  'direct insert with app_metadata still creates the profile'
);
update auth.users set raw_app_meta_data = raw_app_meta_data || '{"role": "admin"}'::jsonb where id = :'gotrue_id';
select is(
  (select role::text from public.profiles where id = :'gotrue_id'), 'coach',
  'a later app_metadata role change leaves profiles.role alone'
);
select tests.create_user_without_role('meta-norole@local.test', 'x-local-1234') as meta_norole_id \gset
update auth.users set raw_app_meta_data = raw_app_meta_data || '{"full_name": "No Role"}'::jsonb where id = :'meta_norole_id';
select is(
  (select count(*)::int from public.profiles where id = :'meta_norole_id'), 0,
  'a metadata update without a role creates no profile'
);
update auth.users set raw_app_meta_data = raw_app_meta_data || '{"role": "trainee"}'::jsonb where id = :'meta_norole_id';
select is(
  (select count(*)::int from public.profiles where id = :'meta_norole_id'), 0,
  'a metadata update with a non-staff role creates no profile'
);
select tests.authenticate_as_anon();
select throws_ok(
  format($$select private.ensure_profile((select u from auth.users u where u.id = %L))$$, :'gotrue_id'),
  '42501', null, 'anon cannot call private.ensure_profile'
);
select tests.clear_auth();

select * from finish();
rollback;
