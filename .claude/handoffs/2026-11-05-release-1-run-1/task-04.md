# Task 04 - Fee payments and staff reports

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-1/`
- **Area:** be
- **Depends on:** task-03
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** 2026-11-05, "Consider my approval. Proceed with the implementation."
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_fees_reports.sql`

## Goal
Staff record monthly fee payments (cash or UPI) against a trainee, see which trainees have
paid for which month, and get the monthly attendance summary.

## Context the worker needs
- `be/CLAUDE.md`; `plan.md` (fee tier rule, record only, no due logic); `docs/product.md`
  fees and reports sections.
- Load the `supabase-postgres-best-practices` skill before writing SQL.

## Files
- `be/supabase/migrations/<timestamp>_fees_reports.sql` - create
- `docs/be/architecture.md` - modify

## Spec

### `public.payment_method` enum: `cash`, `upi`.

### `private.fee_tier_amount(p_date_of_birth date, p_on date) returns integer immutable`
null when `p_date_of_birth` is null; `500` when age on `p_on` < 15; else `1000`.

### `public.fee_payments`
`id uuid primary key default gen_random_uuid()`, `trainee_id uuid not null references public.trainees(id) on delete cascade`, `amount integer not null check (amount > 0 and amount <= 100000)`, `method public.payment_method not null`, `paid_on date not null`, `period_month date not null check (period_month = date_trunc('month', period_month)::date)`, `note text null check (note is null or length(note) <= 300)`, `recorded_by uuid null references public.profiles(id) on delete set null`, `created_at timestamptz not null default private.clock()`. Indexes `fee_payments_trainee_idx (trainee_id, period_month desc)`, `fee_payments_period_idx (period_month)`.
RLS: `fee_payments_select_staff`. Revoke writes.
- `public.record_fee_payment(p_trainee_id uuid, p_amount integer, p_method public.payment_method, p_paid_on date, p_period_month date, p_note text default null) returns public.fee_payments`: staff check; trainee `BXNTF`; `p_paid_on > private.today()` -> `BXVAL 'The payment date cannot be in the future'`; `p_period_month` not the first of a month -> `BXVAL 'Period must be a month'`; amount check -> `BXVAL 'Enter an amount between 1 and 100000'`; `recorded_by = auth.uid()`. Several payments for the same month are allowed (partial payments).
- `public.delete_fee_payment(p_payment_id uuid) returns void`: staff check; `BXNTF 'Payment not found'`; only within 7 days of `created_at` else `BXVAL 'Payments older than 7 days cannot be removed'`.
- `public.trainee_fee_history(p_trainee_id uuid) returns setof public.fee_payments`: staff check; `BXNTF`; newest `period_month` first, then `paid_on` desc.
- `public.fee_status_list(p_month date) returns table (trainee_id uuid, full_name text, photo_path text, tier_amount integer, paid_amount integer, last_paid_on date)`: staff check; `p_month` must be a month start (`BXVAL`); every `active` trainee with `tier_amount = private.fee_tier_amount(date_of_birth, p_month)`, `paid_amount = coalesce(sum(amount) for period_month = p_month, 0)`, `last_paid_on = max(paid_on)` for that month; ordered by unpaid first (`paid_amount = 0`), then `lower(full_name)`.
- `public.monthly_attendance_summary(p_month date) returns table (trainee_id uuid, full_name text, photo_path text, present_count integer, absent_count integer, session_count integer)`: staff check; month start check; every `active` trainee; counts over sessions whose `session_date` falls in the month (`session_count` = number of sessions that month, the same for every row); ordered by `lower(full_name)`.

## App impact
- `rpc('record_fee_payment', {...})` -> `{id, trainee_id, amount, method, paid_on, period_month, note, recorded_by, created_at}`; `rpc('delete_fee_payment')`; `rpc('trainee_fee_history', {p_trainee_id})`; `rpc('fee_status_list', {p_month})`; `rpc('monthly_attendance_summary', {p_month})`.
- `period_month` is sent as `YYYY-MM-01`.
- SQLSTATEs: `BXPRM`, `BXNTF`, `BXVAL`.

## Out of scope
Due or overdue logic, reminders, receipts. Any hosted apply.

## Acceptance criteria
- [ ] RLS and revokes; anon and blocked staff read nothing.
- [ ] Tier helper: 14 years and 364 days -> 500; 15 years -> 1000; null dob -> null.
- [ ] `record_fee_payment` enforces each `BXVAL`; `delete_fee_payment` refuses after 7 days (pin the clock).
- [ ] `fee_status_list` puts unpaid trainees first and sums partial payments; `monthly_attendance_summary` counts only that month's sessions.
- [ ] `npx supabase db reset` and `npx supabase test db` pass; architecture rows updated.

## Verification
As task-01. Assistant writes `tests/040_fees_reports.sql`.
