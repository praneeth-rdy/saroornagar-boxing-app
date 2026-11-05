-- Attendance and trial bookings: tables, RLS, marking functions, roster, history, booking window.
begin;
select plan(143);

-- Fixtures: a blocked coach and the pinned clock (2026-06-10 is a Wednesday in India; 06-14 is a Sunday).
select tests.create_user('blocked@local.test', 'blocked-local-1234', 'Blocked Coach', 'coach');
update public.profiles set is_blocked = true where email = 'blocked@local.test';
select tests.set_clock('2026-06-10 12:00:00+00');

select tests.authenticate_as('coach@local.test');
select (public.create_trainee('Zed Zulu')).id as t_zed \gset
select (public.create_trainee('amy Adams')).id as t_amy \gset
select (public.create_trainee('Bob Bell')).id as t_bob \gset
select (public.create_trainee('Dormant Dan')).id as t_dan \gset
select (public.set_trainee_status(:'t_dan', 'inactive')).id;
select id as s_morning from public.ensure_day_sessions('2026-06-10') where slot = 'morning' \gset
select id as s_evening from public.ensure_day_sessions('2026-06-10') where slot = 'evening' \gset
select (public.add_extra_session('2026-06-10', '13:00', '14:00')).id as s_extra \gset
select tests.clear_auth();

-- Structure ----------------------------------------------------------------
select has_table('public', 'attendance', 'attendance table exists');
select has_table('public', 'trial_bookings', 'trial_bookings table exists');
select enum_has_labels('public', 'attendance_status', array['present', 'absent'], 'attendance_status labels');
select is((select relrowsecurity from pg_class where oid = 'public.attendance'::regclass), true, 'attendance has RLS enabled');
select is((select relrowsecurity from pg_class where oid = 'public.trial_bookings'::regclass), true, 'trial_bookings has RLS enabled');
select policies_are('public', 'attendance', array['attendance_select_staff'], 'attendance has exactly the staff select policy');
select policies_are('public', 'trial_bookings', array['trial_bookings_select_staff'], 'trial_bookings has exactly the staff select policy');
select policy_cmd_is('public', 'attendance', 'attendance_select_staff', 'select', 'attendance policy is select');
select policy_cmd_is('public', 'trial_bookings', 'trial_bookings_select_staff', 'select', 'trial_bookings policy is select');
select policy_roles_are('public', 'attendance', 'attendance_select_staff', array['authenticated'], 'attendance policy is for authenticated');
select policy_roles_are('public', 'trial_bookings', 'trial_bookings_select_staff', array['authenticated'], 'trial_bookings policy is for authenticated');
select has_index('public', 'attendance', 'attendance_trainee_idx', 'attendance trainee index exists');
select has_index('public', 'trial_bookings', 'trial_bookings_date_idx', 'trial_bookings date index exists');
select has_index('public', 'trial_bookings', 'trial_bookings_phone_slot_key', 'trial_bookings phone slot unique index exists');

-- Privileges ----------------------------------------------------------------
select is(
  has_table_privilege('authenticated', 'public.attendance', 'insert')
    or has_table_privilege('authenticated', 'public.attendance', 'update')
    or has_table_privilege('authenticated', 'public.attendance', 'delete')
    or has_table_privilege('authenticated', 'public.attendance', 'truncate')
    or has_table_privilege('anon', 'public.attendance', 'insert')
    or has_table_privilege('anon', 'public.attendance', 'update')
    or has_table_privilege('anon', 'public.attendance', 'delete')
    or has_table_privilege('anon', 'public.attendance', 'truncate'),
  false, 'anon and authenticated have no write privilege on attendance'
);
select is(
  has_table_privilege('authenticated', 'public.trial_bookings', 'insert')
    or has_table_privilege('authenticated', 'public.trial_bookings', 'update')
    or has_table_privilege('authenticated', 'public.trial_bookings', 'delete')
    or has_table_privilege('authenticated', 'public.trial_bookings', 'truncate')
    or has_table_privilege('anon', 'public.trial_bookings', 'insert')
    or has_table_privilege('anon', 'public.trial_bookings', 'update')
    or has_table_privilege('anon', 'public.trial_bookings', 'delete')
    or has_table_privilege('anon', 'public.trial_bookings', 'truncate'),
  false, 'anon and authenticated have no write privilege on trial_bookings'
);
select is(
  has_function_privilege('authenticated', 'public.mark_attendance(uuid, uuid, public.attendance_status)', 'execute')
    and has_function_privilege('authenticated', 'public.mark_remaining_absent(uuid)', 'execute')
    and has_function_privilege('authenticated', 'public.session_roster(uuid)', 'execute')
    and has_function_privilege('authenticated', 'public.trainee_attendance_history(uuid, date, date)', 'execute')
    and has_function_privilege('authenticated', 'public.trial_bookings_between(date, date)', 'execute'),
  true, 'authenticated can execute every attendance function and the staff booking list'
);
select is(
  has_function_privilege('anon', 'public.mark_attendance(uuid, uuid, public.attendance_status)', 'execute')
    or has_function_privilege('anon', 'public.mark_remaining_absent(uuid)', 'execute')
    or has_function_privilege('anon', 'public.session_roster(uuid)', 'execute')
    or has_function_privilege('anon', 'public.trainee_attendance_history(uuid, date, date)', 'execute')
    or has_function_privilege('anon', 'public.trial_bookings_between(date, date)', 'execute')
    or has_function_privilege('anon', 'public.delete_extra_session(uuid)', 'execute'),
  false, 'anon cannot execute any staff function'
);
select is(
  has_function_privilege('anon', 'public.book_trial(text, text, date, public.session_slot, text, date, integer, text)', 'execute')
    and has_function_privilege('authenticated', 'public.book_trial(text, text, date, public.session_slot, text, date, integer, text)', 'execute')
    and has_function_privilege('anon', 'public.my_trial_bookings(text)', 'execute')
    and has_function_privilege('authenticated', 'public.my_trial_bookings(text)', 'execute'),
  true, 'anon and authenticated can execute book_trial and my_trial_bookings'
);
select is(
  (select bool_and(prosecdef and 'search_path=""' = any(proconfig)) from pg_proc
   where oid in (
     'public.mark_attendance(uuid, uuid, public.attendance_status)'::regprocedure,
     'public.mark_remaining_absent(uuid)'::regprocedure,
     'public.session_roster(uuid)'::regprocedure,
     'public.trainee_attendance_history(uuid, date, date)'::regprocedure,
     'public.book_trial(text, text, date, public.session_slot, text, date, integer, text)'::regprocedure,
     'public.my_trial_bookings(text)'::regprocedure,
     'public.trial_bookings_between(date, date)'::regprocedure
   )),
  true, 'every new function is security definer with an empty search_path'
);

-- mark_attendance: access ----------------------------------------------------
select tests.authenticate_as_anon();
select throws_ok(format($$select public.mark_attendance(%L, %L, 'present')$$, :'s_morning', :'t_amy'), '42501', null, 'anon cannot call mark_attendance');
select tests.authenticate_as('blocked@local.test');
select throws_ok(format($$select public.mark_attendance(%L, %L, 'present')$$, :'s_morning', :'t_amy'), 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot mark attendance');
select throws_ok(format($$select public.mark_remaining_absent(%L)$$, :'s_morning'), 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot mark everyone absent');
select throws_ok(format($$select * from public.session_roster(%L)$$, :'s_morning'), 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot read the roster');
select throws_ok(format($$select * from public.trainee_attendance_history(%L, '2026-06-01', '2026-06-30')$$, :'t_amy'), 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot read attendance history');
select throws_ok($$select * from public.trial_bookings_between('2026-06-01', '2026-06-30')$$, 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot list trial bookings');

-- mark_attendance: behaviour ---------------------------------------------------
select tests.authenticate_as('coach@local.test');
select is((select status::text from public.mark_attendance(:'s_morning', :'t_amy', 'present')), 'present', 'marking present inserts and returns the row');
select is((select marked_by from public.attendance where session_id = :'s_morning' and trainee_id = :'t_amy'), tests.user_id('coach@local.test'), 'the mark records the coach who made it');
select is((select count(*)::int from public.attendance where session_id = :'s_morning'), 1, 'one attendance row exists after the first mark');

-- Advance the clock so a real update is distinguishable from a no-op.
select tests.set_clock('2026-06-10 12:05:00+00');
select tests.authenticate_as('admin@local.test');
select is((select status::text from public.mark_attendance(:'s_morning', :'t_amy', 'present')), 'present', 'the same status is a no-op that still returns the row');
select is((select marked_by from public.attendance where session_id = :'s_morning' and trainee_id = :'t_amy'), tests.user_id('coach@local.test'), 'a no-op keeps the original marker');
select is((select marked_at from public.attendance where session_id = :'s_morning' and trainee_id = :'t_amy'), '2026-06-10 12:00:00+00'::timestamptz, 'a no-op keeps the original time');
select is((select status::text from public.mark_attendance(:'s_morning', :'t_amy', 'absent')), 'absent', 'a different status corrects the mark');
select is((select marked_by from public.attendance where session_id = :'s_morning' and trainee_id = :'t_amy'), tests.user_id('admin@local.test'), 'a correction records the new marker');
select is((select marked_at from public.attendance where session_id = :'s_morning' and trainee_id = :'t_amy'), '2026-06-10 12:05:00+00'::timestamptz, 'a correction records the new time');
select is((select count(*)::int from public.attendance where session_id = :'s_morning'), 1, 'correcting never adds a second row');
select tests.authenticate_as('coach@local.test');
select throws_ok(format($$select public.mark_attendance(%L, %L, 'present')$$, :'s_morning', :'t_dan'), 'BXVAL', 'This trainee is inactive', 'an inactive trainee cannot be marked');
select throws_ok(format($$select public.mark_attendance(%L, %L, 'present')$$, gen_random_uuid(), :'t_amy'), 'BXNTF', 'Session not found', 'an unknown session is not found');
select throws_ok(format($$select public.mark_attendance(%L, %L, 'present')$$, :'s_morning', gen_random_uuid()), 'BXNTF', 'Trainee not found', 'an unknown trainee is not found');
select throws_ok(format($$select public.mark_attendance(%L, %L, null)$$, :'s_morning', :'t_amy'), 'BXVAL', 'Choose present or absent', 'a null status is refused');
select is((select count(*)::int from public.attendance where session_id = :'s_morning' and trainee_id = :'t_dan'), 0, 'the refused inactive mark stored nothing');

-- mark_remaining_absent ----------------------------------------------------------
select tests.set_clock('2026-06-10 12:10:00+00');
select is((select status::text from public.mark_attendance(:'s_morning', :'t_bob', 'present')), 'present', 'Bob is marked present before the bulk call');
select is(public.mark_remaining_absent(:'s_morning'), 1, 'the bulk call inserts only for the one unmarked active trainee');
select is((select status::text from public.attendance where session_id = :'s_morning' and trainee_id = :'t_zed'), 'absent', 'the unmarked trainee became absent');
select is((select status::text from public.attendance where session_id = :'s_morning' and trainee_id = :'t_bob'), 'present', 'an existing present mark is untouched');
select is((select status::text from public.attendance where session_id = :'s_morning' and trainee_id = :'t_amy'), 'absent', 'an existing absent mark is untouched');
select is((select marked_at from public.attendance where session_id = :'s_morning' and trainee_id = :'t_bob'), '2026-06-10 12:10:00+00'::timestamptz, 'existing marks keep their time');
select is((select count(*)::int from public.attendance where session_id = :'s_morning' and trainee_id = :'t_dan'), 0, 'inactive trainees get no row');
select is(public.mark_remaining_absent(:'s_morning'), 0, 'a repeated bulk call inserts nothing');
select is(public.mark_remaining_absent(:'s_evening'), 3, 'a fresh session gets one absent row per active trainee');
select throws_ok(format($$select public.mark_remaining_absent(%L)$$, gen_random_uuid()), 'BXNTF', 'Session not found', 'bulk absent on an unknown session is not found');

-- session_roster ---------------------------------------------------------------------
select is(
  (select array_agg(full_name order by ordinality) from public.session_roster(:'s_morning') with ordinality),
  array['Zed Zulu', 'amy Adams', 'Bob Bell'],
  'the roster lists active trainees in roll number order'
);
select is(
  (select array_agg(roll_no order by ordinality) from public.session_roster(:'s_morning') with ordinality),
  array[1, 2, 3],
  'the roster carries each roll number'
);
select is(
  (select array_agg(status::text order by ordinality) from public.session_roster(:'s_morning') with ordinality),
  array['absent', 'absent', 'present'],
  'the roster carries each trainee mark'
);
select is((select count(*)::int from public.session_roster(:'s_extra') where status is null), 3, 'an unmarked session shows every active trainee with a null status');
select is((select count(*)::int from public.session_roster(:'s_extra') where trainee_id = :'t_dan'), 0, 'the roster hides inactive trainees');
select throws_ok(format($$select * from public.session_roster(%L)$$, gen_random_uuid()), 'BXNTF', 'Session not found', 'the roster of an unknown session is not found');
select tests.authenticate_as('coach@local.test');
select (public.update_trainee(:'t_zed', 'Zed Zulu', null, null, null, null, 9)).id;
select is(
  (select array_agg(full_name order by ordinality) from public.session_roster(:'s_morning') with ordinality),
  array['amy Adams', 'Bob Bell', 'Zed Zulu'],
  'a changed roll number moves the trainee in the roster'
);

-- trainee_attendance_history ----------------------------------------------------------
select tests.set_clock('2026-06-12 12:00:00+00');
select id as s_thu_morning from public.ensure_day_sessions('2026-06-12') where slot = 'morning' \gset
select public.mark_attendance(:'s_thu_morning', :'t_amy', 'present');
select is(
  (select array_agg(session_date::text || ' ' || slot::text || ' ' || status::text order by ordinality)
   from public.trainee_attendance_history(:'t_amy', '2026-06-01', '2026-06-30') with ordinality),
  array['2026-06-12 morning present', '2026-06-10 evening absent', '2026-06-10 morning absent'],
  'history is newest first, later batch first within a day, and carries slot and status'
);
select is((select count(*)::int from public.trainee_attendance_history(:'t_amy', '2026-06-11', '2026-06-30')), 1, 'history respects the start date');
select is((select count(*)::int from public.trainee_attendance_history(:'t_amy', '2026-06-01', '2026-06-10')), 2, 'history includes the end date');
select is((select count(*)::int from public.trainee_attendance_history(:'t_dan', '2026-06-01', '2026-06-30')), 0, 'a trainee without marks has an empty history');
select throws_ok(format($$select * from public.trainee_attendance_history(%L, '2026-06-30', '2026-06-01')$$, :'t_amy'), 'BXVAL', 'The end date is before the start date', 'history refuses an inverted range');
select throws_ok(format($$select * from public.trainee_attendance_history(%L, '2026-06-01', '2026-06-30')$$, gen_random_uuid()), 'BXNTF', 'Trainee not found', 'history of an unknown trainee is not found');
select tests.set_clock('2026-06-10 12:00:00+00');

-- Direct access to attendance -----------------------------------------------------------
select is((select count(*)::int from public.attendance where session_id = :'s_morning'), 3, 'staff can select attendance rows');
select throws_ok(format($$insert into public.attendance (session_id, trainee_id, status) values (%L, %L, 'present')$$, :'s_extra', :'t_amy'), '42501', null, 'staff cannot insert attendance directly');
select throws_ok(format($$update public.attendance set status = 'present' where session_id = %L$$, :'s_morning'), '42501', null, 'staff cannot update attendance directly');
select throws_ok(format($$delete from public.attendance where session_id = %L$$, :'s_morning'), '42501', null, 'staff cannot delete attendance directly');
select tests.authenticate_as('blocked@local.test');
select is((select count(*)::int from public.attendance), 0, 'a blocked coach sees no attendance rows');
select tests.authenticate_as_anon();
select throws_ok($$select count(*) from public.attendance$$, '42501', null, 'anon has no select privilege on attendance');
select tests.authenticate_as('coach@local.test');

-- delete_extra_session with attendance -------------------------------------------------------
select public.mark_attendance(:'s_extra', :'t_bob', 'present');
select throws_ok(format($$select public.delete_extra_session(%L)$$, :'s_extra'), 'BXVAL', 'This session already has attendance', 'a session with attendance cannot be deleted');
select is((select count(*)::int from public.sessions where id = :'s_extra'), 1, 'the refused delete kept the session');
select is((select count(*)::int from public.attendance where session_id = :'s_extra'), 1, 'the refused delete kept the marks');
select (public.add_extra_session('2026-06-10', '16:00', '17:00')).id as s_extra2 \gset
select lives_ok(format($$select public.delete_extra_session(%L)$$, :'s_extra2'), 'an extra session without attendance can still be deleted');
select throws_ok(format($$select public.delete_extra_session(%L)$$, :'s_morning'), 'BXVAL', 'Only extra sessions can be removed', 'regular sessions still cannot be deleted');

-- book_trial: anon positive path ----------------------------------------------------------------
select tests.authenticate_as_anon();
select is(
  (select phone from public.book_trial('  Ravi Teja ', '98765 43210', '2026-06-11', 'morning', 'device-key-aaaaaaaa-0001', null, 25, '  first time  ')),
  '919876543210', 'anon can book a trial and the phone is normalized'
);
select is(
  (select full_name || '|' || note from public.my_trial_bookings('device-key-aaaaaaaa-0001')),
  'Ravi Teja|first time', 'the name and note are trimmed'
);
select is((select count(*)::int from public.book_trial('Today Visitor', '+91 98765 43211', '2026-06-10', 'evening', 'device-key-aaaaaaaa-0001', '2005-01-01', null, null)), 1, 'a booking for today is accepted');
select is((select note from public.my_trial_bookings('device-key-aaaaaaaa-0001') where session_date = '2026-06-10'), null, 'an absent note is stored as null');
select is((select count(*)::int from public.book_trial('Edge Visitor', '9876543212', '2026-07-10', 'morning', 'device-key-bbbbbbbb-0002', '2005-01-01', null, null)), 1, 'a booking exactly 30 days ahead is accepted');
select is((select count(*)::int from public.book_trial('Same Number', '9876543210', '2026-06-11', 'evening', 'device-key-bbbbbbbb-0002', null, 30, null)), 1, 'the same number may book the other batch');
select is((select count(*)::int from public.book_trial('Same Number', '9876543210', '2026-06-12', 'morning', 'device-key-bbbbbbbb-0002', null, 30, null)), 1, 'the same number may book another day');

-- book_trial: validation order and messages ---------------------------------------------------------
select throws_ok($$select public.book_trial('A', '9876543299', '2026-06-11', 'morning', 'device-key-cccccccc-0003', null, 25)$$, 'BXVAL', 'Enter your name', 'a one-character name is refused');
select throws_ok($$select public.book_trial(null, '9876543299', '2026-06-11', 'morning', 'device-key-cccccccc-0003', null, 25)$$, 'BXVAL', 'Enter your name', 'a null name is refused');
select throws_ok(format($$select public.book_trial(%L, '9876543299', '2026-06-11', 'morning', 'device-key-cccccccc-0003', null, 25)$$, repeat('n', 81)), 'BXVAL', 'Enter your name', 'a name over 80 characters is refused');
select throws_ok($$select public.book_trial('Short Phone', '12345', '2026-06-11', 'morning', 'device-key-cccccccc-0003', null, 25)$$, 'BXVAL', 'Enter a 10-digit mobile number', 'a malformed phone is refused');
select throws_ok($$select public.book_trial('Extra Slot', '9876543299', '2026-06-11', 'extra', 'device-key-cccccccc-0003', null, 25)$$, 'BXVAL', 'Pick the morning or the evening batch', 'the extra slot is refused');
select throws_ok($$select public.book_trial('Past Day', '9876543299', '2026-06-09', 'morning', 'device-key-cccccccc-0003', null, 25)$$, 'BXVAL', 'Pick today or a later day', 'a past day is refused');
select throws_ok($$select public.book_trial('Far Day', '9876543299', '2026-07-11', 'morning', 'device-key-cccccccc-0003', null, 25)$$, 'BXVAL', 'Trials can be booked up to 30 days ahead', 'a day 31 days ahead is refused');
select throws_ok($$select public.book_trial('Sunday Man', '9876543299', '2026-06-14', 'morning', 'device-key-cccccccc-0003', null, 25)$$, 'BXVAL', 'The club is closed on Sundays', 'a Sunday is refused');
select throws_ok($$select public.book_trial('No Age', '9876543299', '2026-06-11', 'morning', 'device-key-cccccccc-0003')$$, 'BXVAL', 'Tell us your age or date of birth', 'neither age nor date of birth is refused');
select throws_ok($$select public.book_trial('Future Born', '9876543299', '2026-06-11', 'morning', 'device-key-cccccccc-0003', '2026-06-11', null)$$, 'BXVAL', 'Date of birth cannot be in the future', 'a future date of birth is refused');
select throws_ok($$select public.book_trial('Ancient', '9876543299', '2026-06-11', 'morning', 'device-key-cccccccc-0003', '1900-01-01', null)$$, 'BXVAL', 'Enter a valid date of birth', 'a date of birth on the 1900 floor is refused');
select throws_ok($$select public.book_trial('Too Young', '9876543299', '2026-06-11', 'morning', 'device-key-cccccccc-0003', null, 2)$$, 'BXVAL', 'Enter an age between 3 and 99', 'an age of 2 is refused');
select throws_ok($$select public.book_trial('Too Old', '9876543299', '2026-06-11', 'morning', 'device-key-cccccccc-0003', null, 100)$$, 'BXVAL', 'Enter an age between 3 and 99', 'an age of 100 is refused');
select throws_ok(format($$select public.book_trial('Long Note', '9876543299', '2026-06-11', 'morning', 'device-key-cccccccc-0003', null, 25, %L)$$, repeat('n', 301)), 'BXVAL', 'Keep the note to 300 characters or fewer', 'a note over 300 characters is refused');
select throws_ok($$select public.book_trial('Short Key', '9876543299', '2026-06-11', 'morning', 'short-key', null, 25)$$, 'BXVAL', 'Invalid device key', 'a device key under 16 characters is refused');
select throws_ok(format($$select public.book_trial('Long Key', '9876543299', '2026-06-11', 'morning', %L, null, 25)$$, repeat('k', 129)), 'BXVAL', 'Invalid device key', 'a device key over 128 characters is refused');
select throws_ok($$select public.book_trial('Null Key', '9876543299', '2026-06-11', 'morning', null, null, 25)$$, 'BXVAL', 'Invalid device key', 'a null device key is refused');
select lives_ok($$select public.book_trial('Age Three', '9876543298', '2026-06-11', 'morning', 'device-key-cccccccc-0003', null, 3)$$, 'age 3 is accepted');
select lives_ok($$select public.book_trial('Age Ninety', '9876543297', '2026-06-11', 'morning', 'device-key-cccccccc-0003', null, 99)$$, 'age 99 is accepted');

-- book_trial: duplicates -------------------------------------------------------------------------------
select throws_ok($$select public.book_trial('Ravi Again', '+919876543210', '2026-06-11', 'morning', 'device-key-dddddddd-0004', null, 25)$$, 'BXDUP', 'This number already has a trial booked for that batch', 'the same number, day and batch is a duplicate however it is typed');
select is((select count(*)::int from public.my_trial_bookings('device-key-dddddddd-0004')), 0, 'a duplicate stored nothing for the second device');

-- my_trial_bookings and direct access -----------------------------------------------------------------------
select throws_ok($$select count(*) from public.trial_bookings$$, '42501', null, 'anon has no select privilege on trial_bookings');
select tests.authenticate_as_anon();
select throws_ok($$insert into public.trial_bookings (full_name, phone, age, session_date, slot, device_key) values ('Direct Row', '919876543201', 20, '2026-06-11', 'morning', 'device-key-eeeeeeee-0005')$$, '42501', null, 'anon cannot insert trial_bookings directly');
select throws_ok($$delete from public.trial_bookings$$, '42501', null, 'anon cannot delete trial_bookings');
select is((select count(*)::int from public.my_trial_bookings('device-key-zzzzzzzz-9999')), 0, 'another device key sees nothing');
select is((select count(*)::int from public.my_trial_bookings(null)), 0, 'a null device key sees nothing');
select is(
  (select array_agg(full_name order by ordinality) from public.my_trial_bookings('device-key-aaaaaaaa-0001') with ordinality),
  array['Today Visitor', 'Ravi Teja'], 'my bookings are soonest first'
);
select is((select count(*)::int from public.my_trial_bookings('device-key-bbbbbbbb-0002')), 3, 'the second device sees only its own three bookings');

select tests.set_clock('2026-06-11 12:00:00+00');
select is(
  (select array_agg(full_name order by ordinality) from public.my_trial_bookings('device-key-aaaaaaaa-0001') with ordinality),
  array['Ravi Teja'], 'my bookings drop days that have passed'
);
select tests.set_clock('2026-06-10 12:00:00+00');

-- trial_bookings_between: staff ---------------------------------------------------------------------------------
select tests.authenticate_as('coach@local.test');
select is((select count(*)::int from public.trial_bookings), 7, 'staff can select every trial booking directly');
select is((select count(*)::int from public.trial_bookings_between('2026-06-10', '2026-06-12')), 6, 'the staff list covers the requested range');
select is(
  (select array_agg(session_date::text || ' ' || slot::text order by ordinality) from public.trial_bookings_between('2026-06-10', '2026-06-12') with ordinality),
  array['2026-06-10 evening', '2026-06-11 morning', '2026-06-11 morning', '2026-06-11 morning', '2026-06-11 evening', '2026-06-12 morning'],
  'the staff list is ordered by day, then batch'
);
select is((select count(*)::int from public.trial_bookings_between('2026-06-13', '2026-07-31')), 1, 'the staff list excludes days outside the range');
select throws_ok($$select * from public.trial_bookings_between('2026-06-30', '2026-06-01')$$, 'BXVAL', 'The end date is before the start date', 'the staff list refuses an inverted range');
select tests.authenticate_as('blocked@local.test');
select is((select count(*)::int from public.trial_bookings), 0, 'a blocked coach sees no trial bookings directly');
select tests.authenticate_as_anon();
select throws_ok($$select * from public.trial_bookings_between('2026-06-01', '2026-06-30')$$, '42501', null, 'anon cannot call trial_bookings_between');

-- Authenticated users can book too ------------------------------------------------------------------------------------
select tests.authenticate_as('coach@local.test');
select is((select count(*)::int from public.book_trial('Staff Friend', '9876543255', '2026-06-13', 'evening', 'device-key-ffffffff-0006', null, 40)), 1, 'a signed-in user can book a trial');

-- unmark_attendance (presence-only marking) ------------------------------------------------------------------------
select is(
  (select prosecdef and 'search_path=""' = any(proconfig) from pg_proc where oid = 'public.unmark_attendance(uuid, uuid)'::regprocedure),
  true, 'unmark_attendance is security definer with an empty search_path'
);
select is(
  has_function_privilege('authenticated', 'public.unmark_attendance(uuid, uuid)', 'execute')
    and not has_function_privilege('anon', 'public.unmark_attendance(uuid, uuid)', 'execute'),
  true, 'authenticated can execute unmark_attendance and anon cannot'
);
-- August is untouched by the fixtures above, so its summary reflects only these marks.
select id as s_aug from public.ensure_day_sessions('2026-08-03') where slot = 'morning' \gset
select public.mark_attendance(:'s_aug', :'t_amy', 'present');
select public.mark_attendance(:'s_aug', :'t_bob', 'present');
select tests.authenticate_as_anon();
select throws_ok(format($$select public.unmark_attendance(%L, %L)$$, :'s_aug', :'t_amy'), '42501', null, 'anon cannot call unmark_attendance');
select tests.authenticate_as('blocked@local.test');
select throws_ok(format($$select public.unmark_attendance(%L, %L)$$, :'s_aug', :'t_amy'), 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot unmark attendance');
select tests.authenticate_as('coach@local.test');
select is((select session_count from public.monthly_attendance_summary('2026-08-01') limit 1), 1, 'the marked August session counts as held');
select lives_ok(format($$select public.unmark_attendance(%L, %L)$$, :'s_aug', :'t_bob'), 'a coach can remove a mark');
select is((select session_count from public.monthly_attendance_summary('2026-08-01') limit 1), 1, 'a session with a mark left is still held');
select lives_ok(format($$select public.unmark_attendance(%L, %L)$$, :'s_aug', :'t_amy'), 'a coach can remove the last mark');
select is((select count(*)::int from public.attendance where session_id = :'s_aug'), 0, 'the removed marks are gone');
select is((select session_count from public.monthly_attendance_summary('2026-08-01') limit 1), 0, 'a session whose only mark was removed no longer counts');
select is((select present_count from public.monthly_attendance_summary('2026-08-01') where trainee_id = :'t_amy'), 0, 'the removed mark no longer counts as present');
select throws_ok(format($$select public.unmark_attendance(%L, %L)$$, :'s_aug', :'t_amy'), 'BXNTF', 'No mark to remove', 'removing a mark twice is not found');
select throws_ok(format($$select public.unmark_attendance(%L, %L)$$, gen_random_uuid(), :'t_amy'), 'BXNTF', 'Session not found', 'unmarking on an unknown session is not found');

-- reset_session_attendance -----------------------------------------------------------------------------------------
select is(
  (select prosecdef and 'search_path=""' = any(proconfig) from pg_proc where oid = 'public.reset_session_attendance(uuid)'::regprocedure),
  true, 'reset_session_attendance is security definer with an empty search_path'
);
select is(
  has_function_privilege('authenticated', 'public.reset_session_attendance(uuid)', 'execute')
    and not has_function_privilege('anon', 'public.reset_session_attendance(uuid)', 'execute'),
  true, 'authenticated can execute reset_session_attendance and anon cannot'
);
select id as s_aug_eve from public.ensure_day_sessions('2026-08-03') where slot = 'evening' \gset
select public.mark_attendance(:'s_aug_eve', :'t_amy', 'present');
select public.mark_attendance(:'s_aug_eve', :'t_bob', 'present');
select tests.authenticate_as_anon();
select throws_ok(format($$select public.reset_session_attendance(%L)$$, :'s_aug_eve'), '42501', null, 'anon cannot call reset_session_attendance');
select tests.authenticate_as('blocked@local.test');
select throws_ok(format($$select public.reset_session_attendance(%L)$$, :'s_aug_eve'), 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot reset a session');
select tests.authenticate_as('coach@local.test');
select is((select count(*)::int from public.attendance where session_id = :'s_aug_eve'), 2, 'the refused resets removed nothing');
select is((select session_count from public.monthly_attendance_summary('2026-08-01') limit 1), 1, 'the marked August evening counts as held before the reset');
select is(public.reset_session_attendance(:'s_aug_eve'), 2, 'a coach reset removes every mark of the session and returns the count');
select is((select count(*)::int from public.attendance where session_id = :'s_aug_eve'), 0, 'the reset session has no marks');
select is((select session_count from public.monthly_attendance_summary('2026-08-01') limit 1), 0, 'a reset session no longer counts as held');
select is(public.reset_session_attendance(:'s_aug_eve'), 0, 'a repeated reset removes nothing and returns 0');
select throws_ok(format($$select public.reset_session_attendance(%L)$$, gen_random_uuid()), 'BXNTF', 'Session not found', 'resetting an unknown session is not found');

select * from finish();
rollback;
