-- Trainees and sessions: tables, RLS, trainee functions, photo bucket, day sessions, extra sessions.
begin;
select plan(196);

-- Fixtures: a blocked coach, plus the pinned clock (2026-06-10 is a Wednesday in India; 06-14 is a Sunday).
select tests.create_user('919000000010', 'blocked-local-1234', 'Blocked Coach', 'coach');
update public.profiles set is_blocked = true where phone = '919000000010';
select tests.set_clock('2026-06-10 12:00:00+00');

-- Roster rows the later sections read and change: one made by the coach, one by the admin.
select tests.authenticate_as('919000000002');
select (public.create_trainee('Ravi Kumar', '98765 43210', '2000-05-01', '2026-01-10', 'Left hook')).id as t1 \gset
select tests.authenticate_as('919000000001');
select (public.create_trainee('Anil Rao')).id as t2 \gset
select tests.clear_auth();

-- Structure ----------------------------------------------------------------
select has_table('public', 'trainees', 'trainees table exists');
select has_table('public', 'sessions', 'sessions table exists');
select enum_has_labels('public', 'trainee_status', array['active', 'inactive'], 'trainee_status labels');
select enum_has_labels('public', 'session_slot', array['morning', 'evening', 'extra'], 'session_slot labels');
select is((select relrowsecurity from pg_class where oid = 'public.trainees'::regclass), true, 'trainees has RLS enabled');
select is((select relrowsecurity from pg_class where oid = 'public.sessions'::regclass), true, 'sessions has RLS enabled');
select policies_are('public', 'trainees', array['trainees_select_staff'], 'trainees has exactly the staff select policy');
select policies_are('public', 'sessions', array['sessions_select_staff'], 'sessions has exactly the staff select policy');
select policy_cmd_is('public', 'trainees', 'trainees_select_staff', 'select', 'trainees policy is select');
select policy_cmd_is('public', 'sessions', 'sessions_select_staff', 'select', 'sessions policy is select');
select policy_roles_are('public', 'trainees', 'trainees_select_staff', array['authenticated'], 'trainees policy is for authenticated');
select policy_roles_are('public', 'sessions', 'sessions_select_staff', array['authenticated'], 'sessions policy is for authenticated');
select has_trigger('public', 'trainees', 'trainees_set_updated_at', 'trainees updated_at trigger exists');
select has_index('public', 'trainees', 'trainees_status_full_name_idx', 'trainees roster index exists');
select has_index('public', 'sessions', 'sessions_regular_slot_key', 'sessions regular slot unique index exists');
select has_index('public', 'sessions', 'sessions_date_idx', 'sessions date index exists');
select col_default_is('public', 'trainees', 'status', 'active'::text, 'trainee status defaults to active');

-- Privileges ----------------------------------------------------------------
select is(
  has_table_privilege('authenticated', 'public.trainees', 'insert')
    or has_table_privilege('authenticated', 'public.trainees', 'update')
    or has_table_privilege('authenticated', 'public.trainees', 'delete')
    or has_table_privilege('authenticated', 'public.trainees', 'truncate')
    or has_table_privilege('anon', 'public.trainees', 'insert')
    or has_table_privilege('anon', 'public.trainees', 'update')
    or has_table_privilege('anon', 'public.trainees', 'delete')
    or has_table_privilege('anon', 'public.trainees', 'truncate'),
  false, 'anon and authenticated have no write privilege on trainees'
);
select is(
  has_table_privilege('authenticated', 'public.sessions', 'insert')
    or has_table_privilege('authenticated', 'public.sessions', 'update')
    or has_table_privilege('authenticated', 'public.sessions', 'delete')
    or has_table_privilege('authenticated', 'public.sessions', 'truncate')
    or has_table_privilege('anon', 'public.sessions', 'insert')
    or has_table_privilege('anon', 'public.sessions', 'update')
    or has_table_privilege('anon', 'public.sessions', 'delete')
    or has_table_privilege('anon', 'public.sessions', 'truncate'),
  false, 'anon and authenticated have no write privilege on sessions'
);
select is(
  has_function_privilege('authenticated', 'public.create_trainee(text, text, date, date, text)', 'execute')
    and has_function_privilege('authenticated', 'public.update_trainee(uuid, text, text, date, date, text)', 'execute')
    and has_function_privilege('authenticated', 'public.set_trainee_status(uuid, public.trainee_status)', 'execute')
    and has_function_privilege('authenticated', 'public.set_trainee_photo(uuid, text)', 'execute')
    and has_function_privilege('authenticated', 'public.ensure_day_sessions(date)', 'execute')
    and has_function_privilege('authenticated', 'public.add_extra_session(date, time, time)', 'execute')
    and has_function_privilege('authenticated', 'public.delete_extra_session(uuid)', 'execute'),
  true, 'authenticated can execute every trainee and session function'
);
select is(
  has_function_privilege('anon', 'public.create_trainee(text, text, date, date, text)', 'execute')
    or has_function_privilege('anon', 'public.update_trainee(uuid, text, text, date, date, text)', 'execute')
    or has_function_privilege('anon', 'public.set_trainee_status(uuid, public.trainee_status)', 'execute')
    or has_function_privilege('anon', 'public.set_trainee_photo(uuid, text)', 'execute')
    or has_function_privilege('anon', 'public.ensure_day_sessions(date)', 'execute')
    or has_function_privilege('anon', 'public.add_extra_session(date, time, time)', 'execute')
    or has_function_privilege('anon', 'public.delete_extra_session(uuid)', 'execute'),
  false, 'anon cannot execute any trainee or session function'
);
select is(
  has_function_privilege('authenticated', 'private.clean_trainee_input(text, text, date, date, text)', 'execute')
    or has_function_privilege('anon', 'private.clean_trainee_input(text, text, date, date, text)', 'execute'),
  false, 'API roles cannot execute the private trainee input cleaner'
);
select is(
  (select prosecdef and 'search_path=""' = any(proconfig) from pg_proc where oid = 'public.create_trainee(text, text, date, date, text)'::regprocedure)
    and (select prosecdef and 'search_path=""' = any(proconfig) from pg_proc where oid = 'public.ensure_day_sessions(date)'::regprocedure)
    and (select prosecdef and 'search_path=""' = any(proconfig) from pg_proc where oid = 'public.delete_extra_session(uuid)'::regprocedure),
  true, 'functions are security definer with an empty search_path'
);

-- Table constraints (as postgres, bypassing the functions) ----------------------
select throws_ok($$insert into public.trainees (full_name) values ('x')$$, '23514', null, 'trainee name shorter than 2 characters is rejected by the table');
select throws_ok($$insert into public.trainees (full_name, date_of_birth) values ('Old Timer', '1900-01-01')$$, '23514', null, 'date of birth on 1900-01-01 is rejected by the table');
select throws_ok($$insert into public.trainees (full_name, notes) values ('Note Taker', repeat('n', 501))$$, '23514', null, 'notes over 500 characters are rejected by the table');
select throws_ok($$insert into public.sessions (session_date, slot, starts_at, ends_at) values ('2026-06-10', 'extra', '10:00', '10:00')$$, '23514', null, 'session ending at its start is rejected by the table');
select lives_ok($$insert into public.sessions (session_date, slot, starts_at, ends_at) values ('2026-06-20', 'morning', '06:00', '08:30')$$, 'a regular slot can be inserted once');
select throws_ok($$insert into public.sessions (session_date, slot, starts_at, ends_at) values ('2026-06-20', 'morning', '06:30', '09:00')$$, '23505', null, 'a second morning on the same date violates the partial unique index');
select lives_ok($$insert into public.sessions (session_date, slot, starts_at, ends_at) values ('2026-06-20', 'extra', '10:00', '11:00'), ('2026-06-20', 'extra', '10:00', '11:00')$$, 'extra sessions are not limited per date');

-- Storage bucket (as postgres: storage.buckets has RLS) -------------------------
select is((select count(*)::int from storage.buckets where id = 'trainee-photos'), 1, 'trainee-photos bucket exists');
select is((select public from storage.buckets where id = 'trainee-photos'), false, 'trainee-photos bucket is private');
select is((select file_size_limit from storage.buckets where id = 'trainee-photos'), 2097152::bigint, 'trainee-photos limit is 2 MiB');
select is((select allowed_mime_types from storage.buckets where id = 'trainee-photos'), array['image/jpeg', 'image/png', 'image/webp'], 'trainee-photos allows jpeg, png and webp');
select policy_cmd_is('storage', 'objects', 'trainee_photos_select_staff', 'select', 'photo select policy exists');
select policy_cmd_is('storage', 'objects', 'trainee_photos_insert_staff', 'insert', 'photo insert policy exists');
select policy_cmd_is('storage', 'objects', 'trainee_photos_update_staff', 'update', 'photo update policy exists');
select policy_cmd_is('storage', 'objects', 'trainee_photos_delete_staff', 'delete', 'photo delete policy exists');
select policy_roles_are('storage', 'objects', 'trainee_photos_select_staff', array['authenticated'], 'photo select policy is for authenticated');
select policy_roles_are('storage', 'objects', 'trainee_photos_insert_staff', array['authenticated'], 'photo insert policy is for authenticated');
select policy_roles_are('storage', 'objects', 'trainee_photos_update_staff', array['authenticated'], 'photo update policy is for authenticated');
select policy_roles_are('storage', 'objects', 'trainee_photos_delete_staff', array['authenticated'], 'photo delete policy is for authenticated');

-- Storage objects: staff read and write the bucket, a blocked coach and anon do not ---
insert into storage.objects (bucket_id, name) values ('trainee-photos', :'t1' || '/seed.jpg');
select tests.authenticate_as('919000000002');
select is((select count(*)::int from storage.objects where bucket_id = 'trainee-photos'), 1, 'coach reads trainee photo objects');
select lives_ok(format($$insert into storage.objects (bucket_id, name) values ('trainee-photos', %L)$$, :'t1' || '/new.jpg'), 'coach can add a photo object');
select tests.authenticate_as('919000000010');
select is((select count(*)::int from storage.objects where bucket_id = 'trainee-photos'), 0, 'blocked coach reads no photo objects');
select tests.authenticate_as('919000000010');
select throws_ok(format($$insert into storage.objects (bucket_id, name) values ('trainee-photos', %L)$$, :'t1' || '/blocked.jpg'), '42501', null, 'blocked coach cannot add a photo object');
select tests.authenticate_as_anon();
select is((select count(*)::int from storage.objects where bucket_id = 'trainee-photos'), 0, 'anon reads no photo objects');
select tests.authenticate_as_anon();
select throws_ok(format($$insert into storage.objects (bucket_id, name) values ('trainee-photos', %L)$$, :'t1' || '/anon.jpg'), '42501', null, 'anon cannot add a photo object');
select tests.authenticate_as('919000000002');
select lives_ok(format($$update storage.objects set name = %L where bucket_id = 'trainee-photos' and name = %L$$, :'t1' || '/renamed.jpg', :'t1' || '/new.jpg'), 'coach can update a photo object');
select tests.authenticate_as('919000000010');
update storage.objects set name = :'t1' || '/hijack.jpg' where bucket_id = 'trainee-photos' and name = :'t1' || '/seed.jpg';
select tests.clear_auth();
select is((select count(*)::int from storage.objects where bucket_id = 'trainee-photos' and name = :'t1' || '/seed.jpg'), 1, 'blocked coach update touched no photo object');

-- Trainee reads (RLS) --------------------------------------------------------
select tests.authenticate_as('919000000002');
select is((select count(*)::int from public.trainees where id in (:'t1', :'t2')), 2, 'coach reads every trainee');
select tests.authenticate_as('919000000001');
select is((select count(*)::int from public.trainees where id in (:'t1', :'t2')), 2, 'admin reads every trainee');
select tests.authenticate_as('919000000010');
select is((select count(*)::int from public.trainees), 0, 'blocked coach reads no trainees');
select tests.authenticate_as_anon();
select is((select count(*)::int from public.trainees), 0, 'anon reads no trainees');
select tests.authenticate_as('919000000002');
select throws_ok($$insert into public.trainees (full_name) values ('Direct Insert')$$, '42501', null, 'coach cannot insert a trainee directly');
select tests.authenticate_as('919000000002');
select throws_ok(format($$update public.trainees set full_name = 'Renamed' where id = %L$$, :'t1'), '42501', null, 'coach cannot update a trainee directly');
select tests.authenticate_as('919000000002');
select throws_ok(format($$delete from public.trainees where id = %L$$, :'t1'), '42501', null, 'coach cannot delete a trainee directly');

-- create_trainee ---------------------------------------------------------------
select tests.authenticate_as('919000000002');
select is((select full_name from public.trainees where id = :'t1'), 'Ravi Kumar', 'create_trainee stores the name');
select is((select phone from public.trainees where id = :'t1'), '919876543210', 'create_trainee normalizes the phone');
select is((select date_of_birth from public.trainees where id = :'t1'), '2000-05-01'::date, 'create_trainee stores the date of birth');
select is((select joined_on from public.trainees where id = :'t1'), '2026-01-10'::date, 'create_trainee stores the joining date');
select is((select notes from public.trainees where id = :'t1'), 'Left hook', 'create_trainee stores the notes');
select is((select status::text from public.trainees where id = :'t1'), 'active', 'a new trainee is active');
select is((select photo_path from public.trainees where id = :'t1'), null, 'a new trainee has no photo');
select is((select created_by from public.trainees where id = :'t1'), tests.user_id('919000000002'), 'create_trainee records the coach as creator');
select is((select created_by from public.trainees where id = :'t2'), tests.user_id('919000000001'), 'create_trainee records the admin as creator');
select is((select created_at from public.trainees where id = :'t1'), '2026-06-10 12:00:00+00'::timestamptz, 'created_at comes from private.clock()');
select is((select full_name from public.create_trainee('  Spaced Name  ')), 'Spaced Name', 'create_trainee trims the name');
select is((select phone from public.create_trainee('Blank Phone', '   ')), null, 'a blank phone becomes null');
select is((select notes from public.create_trainee('Blank Notes', null, null, null, '   ')), null, 'blank notes become null');
select is((select phone from public.create_trainee('Plus Phone', '+91 98765-43211')), '919876543211', 'create_trainee accepts a +91 phone');
select is((select date_of_birth from public.create_trainee('Born Today', null, '2026-06-10')), '2026-06-10'::date, 'date of birth today is allowed');
select is((select joined_on from public.create_trainee('Joins Tomorrow', null, null, '2026-06-11')), '2026-06-11'::date, 'joining tomorrow is allowed');
select is((select length(full_name) from public.create_trainee(repeat('a', 80))), 80, 'an 80 character name is allowed');
select is((select length(notes) from public.create_trainee('Long Notes', null, null, null, repeat('n', 500))), 500, '500 characters of notes are allowed');

select tests.authenticate_as('919000000002');
select throws_ok($$select public.create_trainee('x')$$, 'BXVAL', 'Enter a name between 2 and 80 characters', 'one character name fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.create_trainee('   ')$$, 'BXVAL', 'Enter a name between 2 and 80 characters', 'blank name fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.create_trainee(null)$$, 'BXVAL', 'Enter a name between 2 and 80 characters', 'null name fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.create_trainee(repeat('a', 81))$$, 'BXVAL', 'Enter a name between 2 and 80 characters', '81 character name fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.create_trainee('Bad Phone', '12345')$$, 'BXVAL', 'Enter a 10-digit mobile number', 'a short phone fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.create_trainee('Future Born', null, '2026-06-11')$$, 'BXVAL', 'Date of birth cannot be in the future', 'future date of birth fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.create_trainee('Too Old', null, '1900-01-01')$$, 'BXVAL', 'Enter a valid date of birth', 'date of birth on 1900-01-01 fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.create_trainee('Joins Later', null, null, '2026-06-12')$$, 'BXVAL', 'Joining date cannot be in the future', 'joining two days ahead fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.create_trainee('Long Notes', null, null, null, repeat('n', 501))$$, 'BXVAL', 'Notes must be 500 characters or fewer', '501 characters of notes fail');
select tests.authenticate_as('919000000010');
select throws_ok($$select public.create_trainee('Blocked Add')$$, 'BXPRM', 'Only club staff can do this', 'blocked coach cannot create a trainee');
select tests.authenticate_as_anon();
select throws_ok($$select public.create_trainee('Anon Add')$$, '42501', null, 'anon cannot create a trainee');

-- The India date drives the checks: 20:00 UTC on 06-10 is already 06-11 in India.
select tests.set_clock('2026-06-10 20:00:00+00');
select tests.authenticate_as('919000000002');
select lives_ok($$select public.create_trainee('Late Born', null, '2026-06-11')$$, 'date of birth on the India date is allowed after the UTC day ends');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.create_trainee('Later Born', null, '2026-06-12')$$, 'BXVAL', 'Date of birth cannot be in the future', 'date of birth after the India date fails');
select tests.set_clock('2026-06-10 12:00:00+00');

-- update_trainee -----------------------------------------------------------------
select tests.authenticate_as('919000000001');
select tests.set_clock('2026-07-01 09:00:00+00');
select is(
  (select phone from public.update_trainee(:'t1', 'Ravi K Updated', '9123456789', '1999-01-02', '2026-02-03', 'Southpaw')),
  '919123456789', 'update_trainee returns the row with the new phone'
);
select tests.authenticate_as('919000000002');
select is((select full_name from public.trainees where id = :'t1'), 'Ravi K Updated', 'update_trainee replaces the name');
select is((select date_of_birth from public.trainees where id = :'t1'), '1999-01-02'::date, 'update_trainee replaces the date of birth');
select is((select joined_on from public.trainees where id = :'t1'), '2026-02-03'::date, 'update_trainee replaces the joining date');
select is((select notes from public.trainees where id = :'t1'), 'Southpaw', 'update_trainee replaces the notes');
select is((select updated_at from public.trainees where id = :'t1'), '2026-07-01 09:00:00+00'::timestamptz, 'update_trainee stamps updated_at from the clock');
select is((select created_by from public.trainees where id = :'t1'), tests.user_id('919000000002'), 'update_trainee keeps the creator');
select is((select created_at from public.trainees where id = :'t1'), '2026-06-10 12:00:00+00'::timestamptz, 'update_trainee keeps created_at');
select is((select full_name from public.trainees where id = :'t2'), 'Anil Rao', 'update_trainee leaves other trainees alone');
select tests.set_clock('2026-06-10 12:00:00+00');
select tests.authenticate_as('919000000002');
select lives_ok(format($$select public.update_trainee(%L, 'Ravi K Updated', '9123456789', null, null, null)$$, :'t1'), 'update_trainee accepts nulls');
select is((select date_of_birth is null and joined_on is null and notes is null from public.trainees where id = :'t1'), true, 'null clears the date of birth, joining date and notes');
select tests.authenticate_as('919000000002');
select lives_ok(format($$select public.update_trainee(%L, 'Ravi K Updated', null, null, null, null)$$, :'t1'), 'update_trainee accepts a null phone');
select is((select phone from public.trainees where id = :'t1'), null, 'null clears the phone');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.update_trainee(%L, 'x', null, null, null, null)$$, :'t1'), 'BXVAL', 'Enter a name between 2 and 80 characters', 'update_trainee rejects a short name');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.update_trainee(%L, 'Valid Name', '123', null, null, null)$$, :'t1'), 'BXVAL', 'Enter a 10-digit mobile number', 'update_trainee rejects a bad phone');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.update_trainee(%L, 'Valid Name', null, '2026-06-11', null, null)$$, :'t1'), 'BXVAL', 'Date of birth cannot be in the future', 'update_trainee rejects a future date of birth');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.update_trainee(%L, 'Valid Name', null, null, '2026-06-12', null)$$, :'t1'), 'BXVAL', 'Joining date cannot be in the future', 'update_trainee rejects a far joining date');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.update_trainee(%L, 'Valid Name', null, null, null, repeat('n', 501))$$, :'t1'), 'BXVAL', 'Notes must be 500 characters or fewer', 'update_trainee rejects long notes');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.update_trainee('00000000-0000-4000-a000-0000000000ff', 'Ghost Person', null, null, null, null)$$, 'BXNTF', 'Trainee not found', 'update_trainee on a missing id fails BXNTF');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.update_trainee(null, 'Ghost Person', null, null, null, null)$$, 'BXNTF', 'Trainee not found', 'update_trainee on a null id fails BXNTF');
select tests.authenticate_as('919000000010');
select throws_ok(format($$select public.update_trainee(%L, 'Blocked Edit', null, null, null, null)$$, :'t1'), 'BXPRM', 'Only club staff can do this', 'blocked coach cannot update a trainee');
select tests.authenticate_as('919000000010');
select throws_ok($$select public.update_trainee('00000000-0000-4000-a000-0000000000ff', 'Blocked Edit', null, null, null, null)$$, 'BXPRM', 'Only club staff can do this', 'blocked coach gets BXPRM before BXNTF');
select tests.authenticate_as_anon();
select throws_ok(format($$select public.update_trainee(%L, 'Anon Edit', null, null, null, null)$$, :'t1'), '42501', null, 'anon cannot update a trainee');
select tests.clear_auth();
select is((select full_name from public.trainees where id = :'t1'), 'Ravi K Updated', 'denied updates changed nothing');

-- set_trainee_status ---------------------------------------------------------------
select tests.authenticate_as('919000000002');
select tests.set_clock('2026-08-01 09:00:00+00');
select is((select status::text from public.set_trainee_status(:'t1', 'inactive')), 'inactive', 'set_trainee_status deactivates a trainee');
select is((select updated_at from public.trainees where id = :'t1'), '2026-08-01 09:00:00+00'::timestamptz, 'a real status change stamps updated_at');
select tests.set_clock('2026-08-02 09:00:00+00');
select is((select status::text from public.set_trainee_status(:'t1', 'inactive')), 'inactive', 'the same status returns the row');
select is((select updated_at from public.trainees where id = :'t1'), '2026-08-01 09:00:00+00'::timestamptz, 'the same status is a no-op and leaves updated_at alone');
select is((select status::text from public.set_trainee_status(:'t1', 'active')), 'active', 'set_trainee_status reactivates a trainee');
select is((select status::text from public.trainees where id = :'t2'), 'active', 'set_trainee_status leaves other trainees alone');
select tests.set_clock('2026-06-10 12:00:00+00');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.set_trainee_status('00000000-0000-4000-a000-0000000000ff', 'inactive')$$, 'BXNTF', 'Trainee not found', 'set_trainee_status on a missing id fails BXNTF');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.set_trainee_status(%L, null)$$, :'t1'), 'BXVAL', 'Choose a status', 'set_trainee_status with a null status fails BXVAL');
select tests.authenticate_as('919000000010');
select throws_ok(format($$select public.set_trainee_status(%L, 'inactive')$$, :'t1'), 'BXPRM', 'Only club staff can do this', 'blocked coach cannot change a status');
select tests.authenticate_as_anon();
select throws_ok(format($$select public.set_trainee_status(%L, 'inactive')$$, :'t1'), '42501', null, 'anon cannot change a status');
select tests.clear_auth();
select is((select status::text from public.trainees where id = :'t1'), 'active', 'denied status changes changed nothing');

-- set_trainee_photo ------------------------------------------------------------------
select tests.authenticate_as('919000000002');
select is((select photo_path from public.set_trainee_photo(:'t1', :'t1' || '/front.jpg')), :'t1' || '/front.jpg', 'set_trainee_photo stores a path inside the trainee folder');
select is((select photo_path from public.trainees where id = :'t1'), :'t1' || '/front.jpg', 'the stored photo path persists');
select is((select photo_path from public.trainees where id = :'t2'), null, 'set_trainee_photo leaves other trainees alone');
select is((select photo_path from public.set_trainee_photo(:'t1', :'t1' || '/nested/side.png')), :'t1' || '/nested/side.png', 'a nested file inside the folder is allowed');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.set_trainee_photo(%L, %L)$$, :'t1', :'t2' || '/other.jpg'), 'BXVAL', 'Photo path must be inside the trainee folder', 'a path in another trainee folder fails');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.set_trainee_photo(%L, 'front.jpg')$$, :'t1'), 'BXVAL', 'Photo path must be inside the trainee folder', 'a path with no folder fails');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.set_trainee_photo(%L, %L)$$, :'t1', :'t1' || '/'), 'BXVAL', 'Photo path must be inside the trainee folder', 'a folder with no file name fails');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.set_trainee_photo(%L, %L)$$, :'t1', :'t1' || '/../' || :'t2' || '/x.jpg'), 'BXVAL', 'Photo path must be inside the trainee folder', 'a parent segment fails');
select tests.authenticate_as('919000000002');
select is((select photo_path from public.set_trainee_photo(:'t1', null)), null, 'a null path clears the photo');
select is((select photo_path from public.trainees where id = :'t1'), null, 'the cleared photo persists');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.set_trainee_photo('00000000-0000-4000-a000-0000000000ff', %L)$$, :'t1' || '/front.jpg'), 'BXNTF', 'Trainee not found', 'set_trainee_photo on a missing id fails BXNTF');
select tests.authenticate_as('919000000010');
select throws_ok(format($$select public.set_trainee_photo(%L, %L)$$, :'t1', :'t1' || '/front.jpg'), 'BXPRM', 'Only club staff can do this', 'blocked coach cannot set a photo');
select tests.authenticate_as_anon();
select throws_ok(format($$select public.set_trainee_photo(%L, %L)$$, :'t1', :'t1' || '/front.jpg'), '42501', null, 'anon cannot set a photo');
select tests.clear_auth();
select is((select photo_path from public.trainees where id = :'t1'), null, 'denied photo changes changed nothing');

-- ensure_day_sessions ------------------------------------------------------------------
select tests.authenticate_as('919000000002');
select is((select count(*)::int from public.ensure_day_sessions('2026-06-10')), 2, 'a Wednesday gets two sessions');
select is(
  (select array_agg(slot::text order by starts_at) from public.sessions where session_date = '2026-06-10'),
  array['morning', 'evening'], 'the Wednesday sessions are morning then evening'
);
select is((select starts_at from public.sessions where session_date = '2026-06-10' and slot = 'morning'), '06:00'::time, 'morning starts at 06:00');
select is((select ends_at from public.sessions where session_date = '2026-06-10' and slot = 'morning'), '08:30'::time, 'morning ends at 08:30');
select is((select starts_at from public.sessions where session_date = '2026-06-10' and slot = 'evening'), '17:30'::time, 'evening starts at 17:30');
select is((select ends_at from public.sessions where session_date = '2026-06-10' and slot = 'evening'), '20:00'::time, 'evening ends at 20:00');
select is((select count(*)::int from public.sessions where session_date = '2026-06-10' and created_by is null), 2, 'auto-created sessions have no creator');
select is((select created_at from public.sessions where session_date = '2026-06-10' and slot = 'morning'), '2026-06-10 12:00:00+00'::timestamptz, 'session created_at comes from private.clock()');
select is(
  (select array_agg(id order by id) from public.ensure_day_sessions('2026-06-10')),
  (select array_agg(id order by id) from public.sessions where session_date = '2026-06-10'),
  'the second call returns the same two sessions'
);
select is((select count(*)::int from public.sessions where session_date = '2026-06-10'), 2, 'the second call creates nothing');
select is((select count(*)::int from public.ensure_day_sessions('2026-06-14')), 0, 'a Sunday returns no sessions');
select is((select count(*)::int from public.sessions where session_date = '2026-06-14'), 0, 'a Sunday creates nothing');
select is((select count(*)::int from public.ensure_day_sessions('2026-06-14')), 0, 'a repeated Sunday call still creates nothing');
select is((select count(*)::int from public.ensure_day_sessions('2026-06-13')), 2, 'a Saturday gets two sessions');
select is((select count(*)::int from public.ensure_day_sessions('2026-06-15')), 2, 'a Monday gets two sessions');
select is((select count(*)::int from public.ensure_day_sessions('2027-01-04')), 2, 'a date far in the future gets two sessions');
select is((select count(*)::int from public.ensure_day_sessions('2026-06-10')), 2, 'other days do not touch Wednesday');
select tests.authenticate_as('919000000001');
select is((select count(*)::int from public.ensure_day_sessions('2026-06-12')), 2, 'an admin can ensure a day too');
select tests.authenticate_as('919000000002');
select (public.add_extra_session('2026-06-17', '10:00', '11:00')).id as e_early \gset
select (public.add_extra_session('2026-06-17', '19:00', '21:00')).id as e_late \gset
select is(
  (select array_agg(slot::text order by ord) from public.ensure_day_sessions('2026-06-17') with ordinality as s(id, session_date, slot, starts_at, ends_at, created_by, created_at, ord)),
  array['morning', 'extra', 'evening', 'extra'], 'ensure_day_sessions returns regular and extra sessions ordered by start time'
);
select is((select count(*)::int from public.sessions where session_date = '2026-06-17'), 4, 'extra sessions are kept when the day is ensured');
select (public.add_extra_session('2026-06-21', '07:00', '08:00')).id as e_sunday \gset
select is((select count(*)::int from public.ensure_day_sessions('2026-06-21')), 1, 'a Sunday with an extra session returns only the extra');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.ensure_day_sessions(null)$$, 'BXVAL', 'Choose a date', 'a null date fails BXVAL');
select tests.authenticate_as('919000000010');
select throws_ok($$select public.ensure_day_sessions('2026-06-18')$$, 'BXPRM', 'Only club staff can do this', 'blocked coach cannot ensure a day');
select tests.authenticate_as_anon();
select throws_ok($$select public.ensure_day_sessions('2026-06-18')$$, '42501', null, 'anon cannot ensure a day');
select tests.clear_auth();
select is((select count(*)::int from public.sessions where session_date = '2026-06-18'), 0, 'denied ensure calls created nothing');

-- Session reads (RLS) ----------------------------------------------------------------------
select tests.authenticate_as('919000000002');
select cmp_ok((select count(*)::int from public.sessions), '>=', 10, 'coach reads sessions');
select tests.authenticate_as('919000000001');
select cmp_ok((select count(*)::int from public.sessions), '>=', 10, 'admin reads sessions');
select tests.authenticate_as('919000000010');
select is((select count(*)::int from public.sessions), 0, 'blocked coach reads no sessions');
select tests.authenticate_as_anon();
select is((select count(*)::int from public.sessions), 0, 'anon reads no sessions');
select tests.authenticate_as('919000000002');
select throws_ok($$insert into public.sessions (session_date, slot, starts_at, ends_at) values ('2026-06-30', 'extra', '10:00', '11:00')$$, '42501', null, 'coach cannot insert a session directly');
select tests.authenticate_as('919000000002');
select throws_ok(format($$update public.sessions set starts_at = '05:00' where id = %L$$, :'e_early'), '42501', null, 'coach cannot update a session directly');
select tests.authenticate_as('919000000002');
select throws_ok(format($$delete from public.sessions where id = %L$$, :'e_early'), '42501', null, 'coach cannot delete a session directly');

-- add_extra_session ----------------------------------------------------------------------------
select tests.authenticate_as('919000000002');
select is((select slot::text from public.sessions where id = :'e_early'), 'extra', 'add_extra_session creates an extra slot');
select is((select session_date from public.sessions where id = :'e_early'), '2026-06-17'::date, 'add_extra_session stores the date');
select is((select starts_at from public.sessions where id = :'e_early'), '10:00'::time, 'add_extra_session stores the start');
select is((select ends_at from public.sessions where id = :'e_early'), '11:00'::time, 'add_extra_session stores the end');
select is((select created_by from public.sessions where id = :'e_early'), tests.user_id('919000000002'), 'add_extra_session records the coach as creator');
select tests.authenticate_as('919000000001');
select is((select created_by from public.add_extra_session('2026-06-17', '10:00', '11:00')), tests.user_id('919000000001'), 'an admin can add an extra session, even one identical to another');
select tests.authenticate_as('919000000002');
select lives_ok($$select public.add_extra_session('2026-06-14', '09:00', '10:30')$$, 'extra sessions are allowed on a Sunday');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.add_extra_session('2026-06-17', '11:00', '10:00')$$, 'BXVAL', 'End time must be after the start time', 'an end before the start fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.add_extra_session('2026-06-17', '10:00', '10:00')$$, 'BXVAL', 'End time must be after the start time', 'an end equal to the start fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.add_extra_session(null, '10:00', '11:00')$$, 'BXVAL', 'Choose a date', 'a null date fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.add_extra_session('2026-06-17', null, '11:00')$$, 'BXVAL', 'Choose a start and an end time', 'a null start fails');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.add_extra_session('2026-06-17', '10:00', null)$$, 'BXVAL', 'Choose a start and an end time', 'a null end fails');
select tests.authenticate_as('919000000010');
select throws_ok($$select public.add_extra_session('2026-06-17', '12:00', '13:00')$$, 'BXPRM', 'Only club staff can do this', 'blocked coach cannot add an extra session');
select tests.authenticate_as_anon();
select throws_ok($$select public.add_extra_session('2026-06-17', '12:00', '13:00')$$, '42501', null, 'anon cannot add an extra session');
select tests.clear_auth();
select is((select count(*)::int from public.sessions where session_date = '2026-06-17' and slot = 'extra'), 3, 'denied and invalid calls added nothing');

-- delete_extra_session -------------------------------------------------------------------------
select tests.authenticate_as('919000000002');
select lives_ok(format($$select public.delete_extra_session(%L)$$, :'e_late'), 'coach can delete an extra session');
select is((select count(*)::int from public.sessions where id = :'e_late'), 0, 'the deleted extra session is gone');
select is((select count(*)::int from public.sessions where id = :'e_early'), 1, 'other extra sessions stay');
select tests.authenticate_as('919000000001');
select lives_ok(format($$select public.delete_extra_session(%L)$$, :'e_sunday'), 'admin can delete an extra session');
select tests.authenticate_as('919000000002');
select throws_ok(format($$select public.delete_extra_session(%L)$$, :'e_late'), 'BXNTF', 'Session not found', 'deleting the same session again fails BXNTF');
select tests.authenticate_as('919000000002');
select throws_ok($$select public.delete_extra_session('00000000-0000-4000-a000-0000000000ff')$$, 'BXNTF', 'Session not found', 'a missing session fails BXNTF');
select tests.authenticate_as('919000000002');
select throws_ok(
  format($$select public.delete_extra_session(%L)$$, (select id from public.sessions where session_date = '2026-06-10' and slot = 'morning')),
  'BXVAL', 'Only extra sessions can be removed', 'a morning session cannot be removed'
);
select tests.authenticate_as('919000000002');
select throws_ok(
  format($$select public.delete_extra_session(%L)$$, (select id from public.sessions where session_date = '2026-06-10' and slot = 'evening')),
  'BXVAL', 'Only extra sessions can be removed', 'an evening session cannot be removed'
);
select tests.authenticate_as('919000000010');
select throws_ok(format($$select public.delete_extra_session(%L)$$, :'e_early'), 'BXPRM', 'Only club staff can do this', 'blocked coach cannot delete an extra session');
select tests.authenticate_as_anon();
select throws_ok(format($$select public.delete_extra_session(%L)$$, :'e_early'), '42501', null, 'anon cannot delete an extra session');
select tests.clear_auth();
select is((select count(*)::int from public.sessions where id = :'e_early'), 1, 'denied deletes removed nothing');
select is((select count(*)::int from public.sessions where session_date = '2026-06-10' and slot <> 'extra'), 2, 'the regular sessions survived every delete attempt');

select * from finish();
rollback;
