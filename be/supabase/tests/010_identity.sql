-- Identity: helpers, profiles RLS, update_staff, current_profile, auth triggers, seed accounts.
begin;
select plan(80);

-- Fixed seed accounts (seed.sql) plus fixtures created per test run.
select tests.create_user('919000000010', 'blocked-local-1234', 'Blocked Coach', 'coach') as blocked_id \gset
select tests.create_user('919000000011', 'blocked-local-1234', 'Blocked Admin', 'admin') as blocked_admin_id \gset
update public.profiles set is_blocked = true where phone in ('919000000010', '919000000011');

-- Structure ----------------------------------------------------------------
select has_table('public', 'profiles', 'profiles table exists');
select has_type('public', 'staff_role', 'staff_role enum exists');
select enum_has_labels('public', 'staff_role', array['admin', 'coach'], 'staff_role labels');
select is(
  (select relrowsecurity from pg_class where oid = 'public.profiles'::regclass),
  true, 'profiles has RLS enabled'
);
select policies_are(
  'public', 'profiles', array['profiles_select_own', 'profiles_select_staff'],
  'profiles has exactly the two named select policies'
);
select policy_cmd_is('public', 'profiles', 'profiles_select_own', 'select', 'own policy is select');
select policy_cmd_is('public', 'profiles', 'profiles_select_staff', 'select', 'staff policy is select');
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
  has_function_privilege('anon', 'public.update_staff(uuid, text, public.staff_role)', 'execute')
    or has_function_privilege('anon', 'public.current_profile()', 'execute'),
  false, 'anon cannot execute update_staff or current_profile'
);
select is(
  has_function_privilege('authenticated', 'public.update_staff(uuid, text, public.staff_role)', 'execute')
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
update public.profiles set full_name = 'Local Coach Two' where phone = '919000000002';
select is(
  (select updated_at from public.profiles where phone = '919000000002'),
  '2026-04-01 10:00:00+00'::timestamptz, 'update stamps updated_at from private.clock()'
);
select tests.set_clock(null);

-- Seed accounts and auth triggers --------------------------------------------------
select is(
  (select role::text from public.profiles where phone = '919000000001'),
  'admin', 'seed admin profile exists with role admin'
);
select is(
  (select role::text from public.profiles where phone = '919000000002'),
  'coach', 'seed coach profile exists with role coach'
);
select is(
  (select id from public.profiles where phone = '919000000001'),
  '00000000-0000-4000-a000-000000000001'::uuid, 'seed admin uses the fixed uuid'
);
select is(
  (select count(*)::int from auth.identities where user_id in
    ('00000000-0000-4000-a000-000000000001', '00000000-0000-4000-a000-000000000002')),
  2, 'seed accounts have phone identities'
);

select tests.create_user('919000000020', 'x-local-1234', null, null) as nameless_id \gset
select is(
  (select full_name from public.profiles where id = :'nameless_id'),
  '919000000020', 'missing full_name falls back to the phone'
);
select is(
  (select role::text from public.profiles where id = :'nameless_id'),
  'coach', 'missing role falls back to coach'
);
select is(
  tests.create_user('919000000020', 'x-local-1234', null, null), :'nameless_id'::uuid,
  'tests.create_user is idempotent on phone'
);
update auth.users set phone = '919000000021' where id = :'nameless_id';
select is(
  (select phone from public.profiles where id = :'nameless_id'),
  '919000000021', 'changing auth.users.phone updates profiles.phone'
);
select throws_ok(
  $$insert into public.profiles (id, full_name, phone) values (gen_random_uuid(), 'No Auth User', '919000000078')$$,
  '23503', null, 'profile needs an auth user (foreign key)'
);
select throws_ok(
  $$update public.profiles set phone = '919000000001' where phone = '919000000002'$$,
  '23505', null, 'phone is unique'
);
select throws_ok(
  $$update public.profiles set full_name = 'x' where phone = '919000000002'$$,
  '23514', null, 'full_name shorter than 2 characters is rejected'
);
delete from auth.users where phone = '919000000021';
select is(
  (select count(*)::int from public.profiles where phone = '919000000021'),
  0, 'deleting the auth user cascades to the profile'
);

-- is_staff / is_admin (role reset: callers reach them only through policies; claims stay) --
select tests.authenticate_as('919000000001');
reset role;
select is(private.is_staff(), true, 'admin is staff');
select is(private.is_admin(), true, 'admin is admin');
select tests.authenticate_as('919000000002');
reset role;
select is(private.is_staff(), true, 'coach is staff');
select is(private.is_admin(), false, 'coach is not admin');
select tests.authenticate_as('919000000011');
reset role;
select is(private.is_staff(), false, 'blocked admin is not staff');
select is(private.is_admin(), false, 'blocked admin is not admin');
select tests.clear_auth();

-- profiles RLS ---------------------------------------------------------------------
select tests.authenticate_as('919000000002');
select cmp_ok((select count(*)::int from public.profiles), '>=', 4, 'coach reads every staff row');
select tests.authenticate_as('919000000010');
select is((select count(*)::int from public.profiles), 1, 'blocked coach reads only their own row');
select is((select phone from public.profiles), '919000000010', 'the blocked coach row is their own');

select tests.authenticate_as('919000000002');
select throws_ok($$insert into public.profiles (id, full_name, phone) values (gen_random_uuid(), 'Sneaky', '919000000077')$$, '42501', null, 'coach cannot insert a profile');
select tests.authenticate_as('919000000002');
select throws_ok($$update public.profiles set role = 'admin' where phone = '919000000002'$$, '42501', null, 'coach cannot promote themselves with a direct update');
select tests.authenticate_as('919000000002');
select throws_ok($$delete from public.profiles where phone = '919000000001'$$, '42501', null, 'coach cannot delete a profile');
select tests.authenticate_as('919000000001');
select throws_ok($$update public.profiles set role = 'coach' where phone = '919000000002'$$, '42501', null, 'admin cannot update profiles directly either');

select tests.authenticate_as_anon();
select is((select count(*)::int from public.profiles), 0, 'anon reads no profile rows');
select tests.clear_auth();

-- update_staff ----------------------------------------------------------------------
select tests.authenticate_as('919000000002');
select throws_ok(
  format($$select public.update_staff(%L, 'Hacked Name', 'admin')$$, tests.user_id('919000000002')),
  'BXPRM', 'Only an admin can edit staff', 'coach cannot edit staff (self)'
);
select tests.authenticate_as('919000000002');
select throws_ok(
  format($$select public.update_staff(%L, 'Hacked Name', 'coach')$$, tests.user_id('919000000001')),
  'BXPRM', 'Only an admin can edit staff', 'coach cannot edit the admin'
);
select tests.authenticate_as('919000000011');
select throws_ok(
  format($$select public.update_staff(%L, 'Still Admin', 'admin')$$, tests.user_id('919000000002')),
  'BXPRM', 'Only an admin can edit staff', 'blocked admin cannot edit staff'
);
select tests.authenticate_as_anon();
select throws_ok(
  format($$select public.update_staff(%L, 'Anon Edit', 'coach')$$, tests.user_id('919000000002')),
  '42501', null, 'anon cannot call update_staff'
);

select tests.authenticate_as('919000000001');
select throws_ok(
  $$select public.update_staff('00000000-0000-4000-a000-0000000000ff', 'Ghost Person', 'coach')$$,
  'BXNTF', 'Staff member not found', 'missing staff id fails BXNTF'
);
select tests.authenticate_as('919000000001');
select throws_ok(
  format($$select public.update_staff(%L, 'Local Admin', 'coach')$$, tests.user_id('919000000001')),
  'BXVAL', 'You cannot change your own role', 'admin cannot change their own role'
);
select tests.authenticate_as('919000000001');
select throws_ok(
  format($$select public.update_staff(%L, 'X', 'coach')$$, tests.user_id('919000000002')),
  'BXVAL', 'Enter a name between 2 and 80 characters', 'one-character name fails'
);
select tests.authenticate_as('919000000001');
select throws_ok(
  format($$select public.update_staff(%L, '   ', 'coach')$$, tests.user_id('919000000002')),
  'BXVAL', 'Enter a name between 2 and 80 characters', 'blank name fails'
);
select tests.authenticate_as('919000000001');
select throws_ok(
  format($$select public.update_staff(%L, %L, 'coach')$$, tests.user_id('919000000002'), repeat('a', 81)),
  'BXVAL', 'Enter a name between 2 and 80 characters', '81-character name fails'
);
select tests.authenticate_as('919000000001');
select throws_ok(
  format($$select public.update_staff(%L, 'Local Coach', null)$$, tests.user_id('919000000002')),
  'BXVAL', 'Choose a role', 'null role fails'
);

select tests.authenticate_as('919000000001');
select is(
  (select role::text || '|' || full_name from public.update_staff(
    tests.user_id('919000000002'), '  Coach Renamed  ', 'admin')),
  'admin|Coach Renamed', 'admin edits another staff member; name is trimmed'
);
select is(
  (select role::text from public.update_staff(tests.user_id('919000000001'), 'Local Admin Two', 'admin')),
  'admin', 'admin can rename themselves keeping their role'
);
select tests.clear_auth();
select is(
  (select full_name from public.profiles where phone = '919000000001'),
  'Local Admin Two', 'the rename was persisted'
);

-- current_profile ------------------------------------------------------------------------
select tests.authenticate_as('919000000002');
select is((select phone from public.current_profile()), '919000000002', 'current_profile returns the own row');
select tests.authenticate_as('919000000010');
select is((select is_blocked from public.current_profile()), true, 'current_profile returns the own row for a blocked user');
select is((select phone from public.current_profile()), '919000000010', 'blocked user gets their own phone');
select tests.clear_auth();

select tests.create_user('919000000030', 'x-local-1234', 'No Profile', 'coach') as orphan_id \gset
delete from public.profiles where id = :'orphan_id';
select tests.authenticate_as('919000000030');
select throws_ok($$select public.current_profile()$$, 'BXNTF', 'Profile not found', 'current_profile fails BXNTF without a profile');
select tests.authenticate_as_anon();
select throws_ok($$select public.current_profile()$$, '42501', null, 'anon cannot call current_profile');
select tests.clear_auth();

select * from finish();
rollback;
