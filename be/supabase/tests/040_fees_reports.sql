-- Fee payments and staff reports: tier helper, table, RLS, payment functions, fee status, monthly summary.
begin;
select plan(104);

-- Fixtures: a blocked coach and the pinned clock (2026-06-10 12:00 UTC is 2026-06-10 in India).
select tests.create_user('blocked@local.test', 'blocked-local-1234', 'Blocked Coach', 'coach');
update public.profiles set is_blocked = true where email = 'blocked@local.test';
select tests.set_clock('2026-06-10 12:00:00+00');

select tests.authenticate_as('coach@local.test');
select (public.create_trainee('Zed Zulu', null, '2015-01-01')).id as t_zed \gset
select (public.create_trainee('amy Adams', null, '2000-03-15')).id as t_amy \gset
select (public.create_trainee('Bob Bell')).id as t_bob \gset
select (public.create_trainee('Cy Child', null, '2011-06-11')).id as t_cy \gset
select (public.create_trainee('Dormant Dan', null, '1990-01-01')).id as t_dan \gset
select (public.set_trainee_status(:'t_dan', 'inactive')).id;
select tests.clear_auth();

-- Structure -------------------------------------------------------------------
select has_table('public', 'fee_payments', 'fee_payments table exists');
select enum_has_labels('public', 'payment_method', array['cash', 'upi'], 'payment_method labels');
select is((select relrowsecurity from pg_class where oid = 'public.fee_payments'::regclass), true, 'fee_payments has RLS enabled');
select policies_are('public', 'fee_payments', array['fee_payments_select_staff'], 'fee_payments has exactly the staff select policy');
select policy_cmd_is('public', 'fee_payments', 'fee_payments_select_staff', 'select', 'fee_payments policy is select');
select policy_roles_are('public', 'fee_payments', 'fee_payments_select_staff', array['authenticated'], 'fee_payments policy is for authenticated');
select has_index('public', 'fee_payments', 'fee_payments_trainee_idx', 'fee_payments trainee index exists');
select has_index('public', 'fee_payments', 'fee_payments_period_idx', 'fee_payments period index exists');
select has_index('public', 'fee_payments', 'fee_payments_recorded_by_idx', 'fee_payments recorded_by index exists');
select col_is_pk('public', 'fee_payments', 'id', 'fee_payments id is the primary key');
select col_not_null('public', 'fee_payments', 'period_month', 'period_month is required');
select col_is_null('public', 'fee_payments', 'note', 'note is optional');
select col_is_null('public', 'fee_payments', 'recorded_by', 'recorded_by is nullable so staff can be removed');
select fk_ok('public', 'fee_payments', 'trainee_id', 'public', 'trainees', 'id', 'fee_payments references trainees');

-- Privileges ------------------------------------------------------------------
select is(
  has_table_privilege('authenticated', 'public.fee_payments', 'insert')
    or has_table_privilege('authenticated', 'public.fee_payments', 'update')
    or has_table_privilege('authenticated', 'public.fee_payments', 'delete')
    or has_table_privilege('authenticated', 'public.fee_payments', 'truncate')
    or has_table_privilege('anon', 'public.fee_payments', 'insert')
    or has_table_privilege('anon', 'public.fee_payments', 'update')
    or has_table_privilege('anon', 'public.fee_payments', 'delete')
    or has_table_privilege('anon', 'public.fee_payments', 'truncate'),
  false, 'anon and authenticated have no write privilege on fee_payments'
);
select is(
  has_function_privilege('authenticated', 'public.record_fee_payment(uuid, integer, public.payment_method, date, date, text)', 'execute')
    and has_function_privilege('authenticated', 'public.delete_fee_payment(uuid)', 'execute')
    and has_function_privilege('authenticated', 'public.trainee_fee_history(uuid)', 'execute')
    and has_function_privilege('authenticated', 'public.fee_status_list(date)', 'execute')
    and has_function_privilege('authenticated', 'public.monthly_attendance_summary(date)', 'execute'),
  true, 'authenticated can execute every fee and report function'
);
select is(
  has_function_privilege('anon', 'public.record_fee_payment(uuid, integer, public.payment_method, date, date, text)', 'execute')
    or has_function_privilege('anon', 'public.delete_fee_payment(uuid)', 'execute')
    or has_function_privilege('anon', 'public.trainee_fee_history(uuid)', 'execute')
    or has_function_privilege('anon', 'public.fee_status_list(date)', 'execute')
    or has_function_privilege('anon', 'public.monthly_attendance_summary(date)', 'execute'),
  false, 'anon cannot execute any fee or report function'
);
select is(
  has_function_privilege('authenticated', 'private.fee_tier_amount(date, date)', 'execute')
    or has_function_privilege('anon', 'private.fee_tier_amount(date, date)', 'execute'),
  false, 'the tier helper is not callable by API roles'
);
select is(
  (select bool_and(prosecdef and 'search_path=""' = any(proconfig)) from pg_proc
   where oid in (
     'public.record_fee_payment(uuid, integer, public.payment_method, date, date, text)'::regprocedure,
     'public.delete_fee_payment(uuid)'::regprocedure,
     'public.trainee_fee_history(uuid)'::regprocedure,
     'public.fee_status_list(date)'::regprocedure,
     'public.monthly_attendance_summary(date)'::regprocedure
   )),
  true, 'every fee function is security definer with an empty search_path'
);

-- Tier helper (runs as the test owner; API roles cannot call it) -------------------
select is(private.fee_tier_amount('2011-06-11', '2026-06-10'), 500, '14 years and 364 days is the junior tier');
select is(private.fee_tier_amount('2011-06-10', '2026-06-10'), 800, 'exactly 15 years is the senior tier');
select is(private.fee_tier_amount('2011-06-09', '2026-06-10'), 800, '15 years and a day is the senior tier');
select is(private.fee_tier_amount('2024-01-01', '2026-06-10'), 500, 'a toddler is the junior tier');
select is(private.fee_tier_amount('1985-01-01', '2026-06-10'), 800, 'an adult is the senior tier');
select is(private.fee_tier_amount(null, '2026-06-10'), null, 'no date of birth has no tier');
select is(private.fee_tier_amount('2011-06-10', null), null, 'no reference date has no tier');
select is(private.fee_tier_amount('2012-02-29', '2027-02-28'), 500, 'a 29 February birthday has not turned 15 on 28 February');
select is(private.fee_tier_amount('2012-02-29', '2027-03-01'), 800, 'a 29 February birthday turns 15 on 1 March in a common year');

-- Access: anon and blocked staff ------------------------------------------------------
select tests.authenticate_as_anon();
select throws_ok(format($$select public.record_fee_payment(%L, 500, 'cash', '2026-06-10', '2026-06-01')$$, :'t_amy'), '42501', null, 'anon cannot record a payment');
select throws_ok($$select public.delete_fee_payment(gen_random_uuid())$$, '42501', null, 'anon cannot delete a payment');
select throws_ok(format($$select * from public.trainee_fee_history(%L)$$, :'t_amy'), '42501', null, 'anon cannot read fee history');
select throws_ok($$select * from public.fee_status_list('2026-06-01')$$, '42501', null, 'anon cannot read the fee status list');
select throws_ok($$select * from public.monthly_attendance_summary('2026-06-01')$$, '42501', null, 'anon cannot read the attendance summary');
select tests.authenticate_as('blocked@local.test');
select throws_ok(format($$select public.record_fee_payment(%L, 500, 'cash', '2026-06-10', '2026-06-01')$$, :'t_amy'), 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot record a payment');
select throws_ok($$select public.delete_fee_payment(gen_random_uuid())$$, 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot delete a payment');
select throws_ok(format($$select * from public.trainee_fee_history(%L)$$, :'t_amy'), 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot read fee history');
select throws_ok($$select * from public.fee_status_list('2026-06-01')$$, 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot read the fee status list');
select throws_ok($$select * from public.monthly_attendance_summary('2026-06-01')$$, 'BXPRM', 'Only club staff can do this', 'a blocked coach cannot read the attendance summary');

-- record_fee_payment: positive path -----------------------------------------------------
select tests.authenticate_as('coach@local.test');
select is(
  (select amount from public.record_fee_payment(:'t_cy', 500, 'cash', '2026-06-10', '2026-06-01', '  first month  ')),
  500, 'recording a payment returns the row'
);
select is((select recorded_by from public.fee_payments where trainee_id = :'t_cy'), tests.user_id('coach@local.test'), 'the payment records the staff member who made it');
select is((select note from public.fee_payments where trainee_id = :'t_cy'), 'first month', 'the note is trimmed');
select is((select created_at from public.fee_payments where trainee_id = :'t_cy'), '2026-06-10 12:00:00+00'::timestamptz, 'created_at follows the pinned clock');
select is((select method::text || ' ' || paid_on::text || ' ' || period_month::text from public.fee_payments where trainee_id = :'t_cy'), 'cash 2026-06-10 2026-06-01', 'method, paid date and period are stored as given');
select is(
  (select note from public.record_fee_payment(:'t_dan', 1, 'upi', '2026-06-10', '2026-06-01', '   ')),
  null, 'a blank note is stored as null, the minimum amount and today are accepted, and an inactive trainee can pay arrears'
);
select is(
  (select length(note) from public.record_fee_payment(:'t_dan', 100000, 'cash', '2026-06-09', '2026-05-01', repeat('x', 300))),
  300, 'the maximum amount and a 300 character note are accepted'
);

-- record_fee_payment: validation ---------------------------------------------------------
select throws_ok(format($$select public.record_fee_payment(%L, 500, 'cash', '2026-06-10', '2026-06-01')$$, gen_random_uuid()), 'BXNTF', 'Trainee not found', 'an unknown trainee is not found');
select throws_ok(format($$select public.record_fee_payment(null, 500, 'cash', '2026-06-10', '2026-06-01')$$), 'BXNTF', 'Trainee not found', 'a null trainee is not found');
select throws_ok(format($$select public.record_fee_payment(%L, 500, 'cash', '2026-06-11', '2026-06-01')$$, :'t_amy'), 'BXVAL', 'The payment date cannot be in the future', 'a payment dated tomorrow is refused');
select throws_ok(format($$select public.record_fee_payment(%L, 500, 'cash', null, '2026-06-01')$$, :'t_amy'), 'BXVAL', 'Enter the payment date', 'a null payment date is refused');
select throws_ok(format($$select public.record_fee_payment(%L, 500, 'cash', '2026-06-10', '2026-06-15')$$, :'t_amy'), 'BXVAL', 'Period must be a month', 'a period that is not a month start is refused');
select throws_ok(format($$select public.record_fee_payment(%L, 500, 'cash', '2026-06-10', '2026-05-31')$$, :'t_amy'), 'BXVAL', 'Period must be a month', 'the last day of a month is not a month start');
select throws_ok(format($$select public.record_fee_payment(%L, 500, 'cash', '2026-06-10', null)$$, :'t_amy'), 'BXVAL', 'Period must be a month', 'a null period is refused');
select throws_ok(format($$select public.record_fee_payment(%L, 0, 'cash', '2026-06-10', '2026-06-01')$$, :'t_amy'), 'BXVAL', 'Enter an amount between 1 and 100000', 'a zero amount is refused');
select throws_ok(format($$select public.record_fee_payment(%L, -5, 'cash', '2026-06-10', '2026-06-01')$$, :'t_amy'), 'BXVAL', 'Enter an amount between 1 and 100000', 'a negative amount is refused');
select throws_ok(format($$select public.record_fee_payment(%L, 100001, 'cash', '2026-06-10', '2026-06-01')$$, :'t_amy'), 'BXVAL', 'Enter an amount between 1 and 100000', 'an amount above 100000 is refused');
select throws_ok(format($$select public.record_fee_payment(%L, null, 'cash', '2026-06-10', '2026-06-01')$$, :'t_amy'), 'BXVAL', 'Enter an amount between 1 and 100000', 'a null amount is refused');
select throws_ok(format($$select public.record_fee_payment(%L, 500, null, '2026-06-10', '2026-06-01')$$, :'t_amy'), 'BXVAL', 'Choose cash or UPI', 'a null method is refused');
select throws_ok(format($$select public.record_fee_payment(%L, 500, 'cash', '2026-06-10', '2026-06-01', repeat('x', 301))$$, :'t_amy'), 'BXVAL', 'Keep the note to 300 characters or fewer', 'a 301 character note is refused');
select is((select count(*)::int from public.fee_payments where trainee_id in (:'t_amy', :'t_zed', :'t_bob')), 0, 'refused payments stored nothing');
select is((select count(*)::int from public.fee_payments where trainee_id = :'t_dan'), 2, 'only the two accepted arrears payments exist for the inactive trainee');

-- Direct access to fee_payments -----------------------------------------------------------
select is((select count(*)::int from public.fee_payments), 3, 'staff can select fee payments');
select throws_ok(format($$insert into public.fee_payments (trainee_id, amount, method, paid_on, period_month) values (%L, 500, 'cash', '2026-06-10', '2026-06-01')$$, :'t_amy'), '42501', null, 'staff cannot insert a payment directly');
select throws_ok(format($$update public.fee_payments set amount = 1 where trainee_id = %L$$, :'t_cy'), '42501', null, 'staff cannot update a payment directly');
select throws_ok(format($$delete from public.fee_payments where trainee_id = %L$$, :'t_cy'), '42501', null, 'staff cannot delete a payment directly');
select tests.authenticate_as('blocked@local.test');
select is((select count(*)::int from public.fee_payments), 0, 'a blocked coach sees no fee payments');
select tests.authenticate_as_anon();
select throws_ok($$select count(*) from public.fee_payments$$, '42501', null, 'anon has no select privilege on fee_payments');
select tests.authenticate_as('coach@local.test');

-- Table checks stay in force even for the table owner ------------------------------------------
select tests.clear_auth();
select throws_ok(format($$insert into public.fee_payments (trainee_id, amount, method, paid_on, period_month) values (%L, 500, 'cash', '2026-06-10', '2026-06-15')$$, :'t_amy'), '23514', null, 'the table refuses a period that is not a month start');
select throws_ok(format($$insert into public.fee_payments (trainee_id, amount, method, paid_on, period_month) values (%L, 0, 'cash', '2026-06-10', '2026-06-01')$$, :'t_amy'), '23514', null, 'the table refuses a zero amount');
select throws_ok(format($$insert into public.fee_payments (trainee_id, amount, method, paid_on, period_month, note) values (%L, 500, 'cash', '2026-06-10', '2026-06-01', repeat('x', 301))$$, :'t_amy'), '23514', null, 'the table refuses a long note');
select tests.authenticate_as('coach@local.test');

-- Payments for the reports below: amy pays June in two parts, Bob only May ---------------------------
select tests.set_clock('2026-06-09 12:00:00+00');
select public.record_fee_payment(:'t_amy', 300, 'cash', '2026-05-03', '2026-05-01');
select public.record_fee_payment(:'t_amy', 200, 'upi', '2026-05-20', '2026-05-01');
select public.record_fee_payment(:'t_amy', 400, 'cash', '2026-06-02', '2026-06-01');
select public.record_fee_payment(:'t_amy', 600, 'upi', '2026-06-09', '2026-06-01');
select public.record_fee_payment(:'t_bob', 200, 'cash', '2026-05-10', '2026-05-01');
select tests.set_clock('2026-06-10 12:00:00+00');

-- trainee_fee_history -------------------------------------------------------------------------
select is(
  (select array_agg(period_month::text || ' ' || paid_on::text || ' ' || amount::text order by ordinality)
   from public.trainee_fee_history(:'t_amy') with ordinality),
  array['2026-06-01 2026-06-09 600', '2026-06-01 2026-06-02 400', '2026-05-01 2026-05-20 200', '2026-05-01 2026-05-03 300'],
  'history is newest period first, then latest payment first'
);
select is((select count(*)::int from public.trainee_fee_history(:'t_bob')), 1, 'history holds only that trainee payments');
select is((select count(*)::int from public.trainee_fee_history(:'t_zed')), 0, 'a trainee without payments has an empty history');
select is((select count(*)::int from public.trainee_fee_history(:'t_dan')), 2, 'an inactive trainee still has a history');
select throws_ok(format($$select * from public.trainee_fee_history(%L)$$, gen_random_uuid()), 'BXNTF', 'Trainee not found', 'history of an unknown trainee is not found');

-- delete_fee_payment: the seven day window ---------------------------------------------------------
select id as p_old from public.fee_payments where trainee_id = :'t_bob' and period_month = '2026-05-01' \gset
select tests.authenticate_as('admin@local.test');
select tests.set_clock('2026-06-16 12:00:01+00');
select throws_ok(format($$select public.delete_fee_payment(%L)$$, :'p_old'), 'BXVAL', 'Payments older than 7 days cannot be removed', 'a payment older than 7 days cannot be removed');
select is((select count(*)::int from public.fee_payments where id = :'p_old'), 1, 'the refused delete kept the payment');
select tests.set_clock('2026-06-16 12:00:00+00');
select lives_ok(format($$select public.delete_fee_payment(%L)$$, :'p_old'), 'a payment exactly 7 days old can be removed by another staff member');
select is((select count(*)::int from public.fee_payments where id = :'p_old'), 0, 'the removed payment is gone');
select throws_ok(format($$select public.delete_fee_payment(%L)$$, :'p_old'), 'BXNTF', 'Payment not found', 'removing a payment twice is not found');
select throws_ok($$select public.delete_fee_payment(null)$$, 'BXNTF', 'Payment not found', 'removing a null payment is not found');
select tests.set_clock('2026-06-10 12:00:00+00');

-- fee_status_list ---------------------------------------------------------------------------------------
select public.record_fee_payment(:'t_bob', 200, 'cash', '2026-05-10', '2026-05-01');
select tests.authenticate_as('coach@local.test');
select is(
  (select array_agg(full_name order by ordinality) from public.fee_status_list('2026-06-01') with ordinality),
  array['Bob Bell', 'Zed Zulu', 'amy Adams', 'Cy Child'],
  'unpaid trainees come first, then paid ones, each group by name ignoring case'
);
select is(
  (select array_agg(coalesce(tier_amount::text, 'none') || '/' || paid_amount::text || '/' || coalesce(last_paid_on::text, 'never') order by ordinality)
   from public.fee_status_list('2026-06-01') with ordinality),
  array['none/0/never', '500/0/never', '800/1000/2026-06-09', '500/500/2026-06-10'],
  'tier, summed partial payments and last paid date per trainee'
);
select is((select count(*)::int from public.fee_status_list('2026-06-01') where trainee_id = :'t_dan'), 0, 'inactive trainees are not listed');
select is(
  (select paid_amount from public.fee_status_list('2026-06-01') where trainee_id = :'t_bob'),
  0, 'a payment for another month does not count'
);
select is(
  (select paid_amount from public.fee_status_list('2026-05-01') where trainee_id = :'t_bob'),
  200, 'the same payment counts in its own month'
);
select is(
  (select array_agg(full_name order by ordinality) from public.fee_status_list('2026-05-01') with ordinality),
  array['Cy Child', 'Zed Zulu', 'amy Adams', 'Bob Bell'],
  'May lists unpaid first and paid by name'
);
select is((select tier_amount from public.fee_status_list('2026-06-01') where trainee_id = :'t_cy'), 500, 'Cy is junior on 1 June');
select is((select tier_amount from public.fee_status_list('2026-07-01') where trainee_id = :'t_cy'), 800, 'Cy is senior from the month after turning 15');
select is((select count(*)::int from public.fee_status_list('2026-04-01') where paid_amount = 0), 4, 'a month without payments lists every active trainee as unpaid');
select throws_ok($$select * from public.fee_status_list('2026-06-15')$$, 'BXVAL', 'Period must be a month', 'a mid-month date is refused');
select throws_ok($$select * from public.fee_status_list(null)$$, 'BXVAL', 'Period must be a month', 'a null month is refused');

-- monthly_attendance_summary ---------------------------------------------------------------------------------
select id as s_may from public.ensure_day_sessions('2026-05-29') where slot = 'morning' \gset
select id as s_jul from public.ensure_day_sessions('2026-07-01') where slot = 'morning' \gset
select id as s_jun1 from public.ensure_day_sessions('2026-06-01') where slot = 'morning' \gset
select id as s_jun30_m from public.ensure_day_sessions('2026-06-30') where slot = 'morning' \gset
select id as s_jun30_e from public.ensure_day_sessions('2026-06-30') where slot = 'evening' \gset
select id as s_morning from public.ensure_day_sessions('2026-06-10') where slot = 'morning' \gset
select id as s_evening from public.ensure_day_sessions('2026-06-10') where slot = 'evening' \gset
select (public.add_extra_session('2026-06-10', '13:00', '14:00')).id as s_extra \gset
select public.mark_attendance(:'s_may', :'t_amy', 'present');
select public.mark_attendance(:'s_jul', :'t_amy', 'absent');
select public.mark_attendance(:'s_jun1', :'t_amy', 'present');
select public.mark_attendance(:'s_morning', :'t_amy', 'present');
select public.mark_attendance(:'s_evening', :'t_amy', 'absent');
select public.mark_attendance(:'s_jun30_m', :'t_zed', 'absent');
select public.mark_attendance(:'s_jun30_e', :'t_zed', 'absent');
select public.mark_attendance(:'s_extra', :'t_cy', 'present');
-- A second mark on the 1 June morning; the 1 June evening stays unmarked, so June holds 7 rows and 6 held sessions.
select public.mark_attendance(:'s_jun1', :'t_bob', 'present');
select is(
  (select count(*)::int from public.sessions where session_date >= '2026-06-01' and session_date < '2026-07-01'),
  7, 'June has seven session rows, the unmarked 1 June evening among them'
);
select is(
  (select array_agg(full_name order by ordinality) from public.monthly_attendance_summary('2026-06-01') with ordinality),
  array['amy Adams', 'Bob Bell', 'Cy Child', 'Zed Zulu'],
  'the summary lists active trainees ordered by name ignoring case'
);
select is(
  (select array_agg(present_count::text || '/' || absent_count::text || '/' || session_count::text order by ordinality)
   from public.monthly_attendance_summary('2026-06-01') with ordinality),
  array['2/1/6', '1/0/6', '1/0/6', '0/2/6'],
  'June counts only June sessions, and every row carries the month held session total without the unmarked session'
);
select is(
  (select array_agg(present_count::text || '/' || absent_count::text || '/' || session_count::text order by ordinality)
   from public.monthly_attendance_summary('2026-05-01') with ordinality),
  array['1/0/1', '0/0/1', '0/0/1', '0/0/1'],
  'May counts only the held May session'
);
select is(
  (select present_count::text || '/' || absent_count::text || '/' || session_count::text
   from public.monthly_attendance_summary('2026-07-01') where trainee_id = :'t_amy'),
  '0/1/1', 'July counts only the held July session'
);
select public.ensure_day_sessions('2026-08-03');
select is(
  (select count(*)::int from public.monthly_attendance_summary('2026-08-01') where session_count = 0),
  4, 'a month whose sessions have no marks counts no sessions'
);
select id as s_sep from public.ensure_day_sessions('2026-09-07') where slot = 'morning' \gset
select public.mark_attendance(:'s_sep', :'t_amy', 'present');
select public.mark_attendance(:'s_sep', :'t_bob', 'present');
select public.mark_attendance(:'s_sep', :'t_cy', 'absent');
select public.mark_attendance(:'s_sep', :'t_zed', 'present');
select is(
  (select array_agg(distinct session_count) from public.monthly_attendance_summary('2026-09-01')),
  array[1], 'a session marked for four trainees counts once'
);
select is(
  (select count(*)::int from public.monthly_attendance_summary('2026-04-01') where present_count = 0 and absent_count = 0 and session_count = 0),
  4, 'a month without sessions lists every active trainee with zero counts'
);
select is((select count(*)::int from public.monthly_attendance_summary('2026-06-01') where trainee_id = :'t_dan'), 0, 'inactive trainees are not in the summary');
select throws_ok($$select * from public.monthly_attendance_summary('2026-06-30')$$, 'BXVAL', 'Period must be a month', 'a month end date is refused');
select throws_ok($$select * from public.monthly_attendance_summary(null)$$, 'BXVAL', 'Period must be a month', 'a null month is refused');

-- Deleting a trainee removes their payments ---------------------------------------------------------------------------
select (public.create_trainee('Temp Trainee')).id as t_tmp \gset
select public.record_fee_payment(:'t_tmp', 500, 'cash', '2026-06-10', '2026-06-01');
select tests.clear_auth();
select is((select count(*)::int from public.fee_payments where trainee_id = :'t_tmp'), 1, 'the temporary trainee has a payment');
delete from public.trainees where id = :'t_tmp';
select is((select count(*)::int from public.fee_payments where trainee_id = :'t_tmp'), 0, 'deleting a trainee cascades to their payments');

select * from finish();
rollback;
