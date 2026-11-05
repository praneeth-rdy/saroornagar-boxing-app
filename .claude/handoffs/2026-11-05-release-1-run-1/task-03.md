# Task 03 - Attendance and trial bookings

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-1/`
- **Area:** be
- **Depends on:** task-02
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** 2026-11-05, "Consider my approval. Proceed with the implementation."
- **Hosted apply:** on the owner's say-so, migration `<timestamp>_attendance_trials.sql`

## Goal
A coach marks each trainee present or absent for a session, can mark everyone left as
absent in one tap, and can correct a mark. A visitor books a trial slot without an account
and the coach sees who is coming.

## Context the worker needs
- `be/CLAUDE.md`; `plan.md` (upsert semantics for marks, `BXDUP` only for bookings, phone
  format, India dates). Tables from task-02: `trainees`, `sessions`.
- Load the `supabase-postgres-best-practices` skill before writing SQL.

## Files
- `be/supabase/migrations/<timestamp>_attendance_trials.sql` - create
- `docs/be/architecture.md` - modify

## Spec

### `public.attendance_status` enum: `present`, `absent`.

### `public.attendance`
`session_id uuid not null references public.sessions(id) on delete cascade`, `trainee_id uuid not null references public.trainees(id) on delete cascade`, `status public.attendance_status not null`, `marked_by uuid null references public.profiles(id) on delete set null`, `marked_at timestamptz not null default private.clock()`, `primary key (session_id, trainee_id)`. Index `attendance_trainee_idx (trainee_id, session_id)`.
RLS: `attendance_select_staff`. Revoke writes.
- `public.mark_attendance(p_session_id uuid, p_trainee_id uuid, p_status public.attendance_status) returns public.attendance`: staff check (`BXPRM`); session exists (`BXNTF 'Session not found'`); trainee exists (`BXNTF 'Trainee not found'`); trainee inactive -> `BXVAL 'This trainee is inactive'`; `insert ... on conflict (session_id, trainee_id) do update set status = excluded.status, marked_by = excluded.marked_by, marked_at = excluded.marked_at where attendance.status is distinct from excluded.status`; return the current row (select after the upsert so a no-op still returns it).
- `public.mark_remaining_absent(p_session_id uuid) returns integer`: staff check; `BXNTF`; inserts `absent` for every `active` trainee without a row for the session; returns the number inserted.
- `public.session_roster(p_session_id uuid) returns table (trainee_id uuid, full_name text, photo_path text, status public.attendance_status, marked_at timestamptz)`: staff check; `BXNTF`; every active trainee left-joined with their mark for that session, ordered by `lower(full_name)`. `status` null means not marked.
- `public.trainee_attendance_history(p_trainee_id uuid, p_from date, p_to date) returns table (session_id uuid, session_date date, slot public.session_slot, status public.attendance_status, marked_at timestamptz)`: staff check; `BXNTF`; `p_to < p_from` -> `BXVAL 'The end date is before the start date'`; newest first.
- Add to `delete_extra_session` (new `create or replace` in this migration, same signature): `BXVAL 'This session already has attendance'` when rows exist.

### `public.trial_bookings`
`id uuid primary key default gen_random_uuid()`, `full_name text not null check (length(trim(full_name)) between 2 and 80)`, `phone text not null` (normalized), `date_of_birth date null`, `age integer null check (age between 3 and 99)`, `session_date date not null`, `slot public.session_slot not null check (slot in ('morning','evening'))`, `note text null check (note is null or length(note) <= 300)`, `device_key text not null check (length(device_key) between 16 and 128)`, `created_at timestamptz not null default private.clock()`, `check (date_of_birth is not null or age is not null)`. Unique `trial_bookings_phone_slot_key (phone, session_date, slot)`. Index `trial_bookings_date_idx (session_date, slot)`.
RLS: `trial_bookings_select_staff` (select, authenticated, `using (private.is_staff())`). No anon policy. Revoke writes from anon, authenticated.
- `public.book_trial(p_full_name text, p_phone text, p_session_date date, p_slot public.session_slot, p_device_key text, p_date_of_birth date default null, p_age integer default null, p_note text default null) returns public.trial_bookings`: `security definer set search_path = ''`, granted to `anon` and `authenticated`. Order: name -> `BXVAL 'Enter your name'`; phone via `private.normalize_phone`; `p_slot = 'extra'` -> `BXVAL 'Pick the morning or the evening batch'`; `p_session_date < private.today()` -> `BXVAL 'Pick today or a later day'`; `p_session_date > private.today() + 30` -> `BXVAL 'Trials can be booked up to 30 days ahead'`; Sunday -> `BXVAL 'The club is closed on Sundays'`; neither dob nor age -> `BXVAL 'Tell us your age or date of birth'`; dob in the future -> `BXVAL`; device key length -> `BXVAL 'Invalid device key'`; insert; `unique_violation` -> `BXDUP 'This number already has a trial booked for that batch'`.
- `public.my_trial_bookings(p_device_key text) returns setof public.trial_bookings`: `security definer`, granted to `anon` and `authenticated`; rows with that `device_key` and `session_date >= private.today()`, soonest first. Nothing else is readable by anon.
- `public.trial_bookings_between(p_from date, p_to date) returns setof public.trial_bookings`: staff check; `BXVAL` when `p_to < p_from`; ordered by `session_date, slot, created_at`.

## App impact
- Coach: `rpc('session_roster', {p_session_id})`, `rpc('mark_attendance', {p_session_id, p_trainee_id, p_status})`, `rpc('mark_remaining_absent', {p_session_id})` -> int, `rpc('trainee_attendance_history', {p_trainee_id, p_from, p_to})`, `rpc('trial_bookings_between', {p_from, p_to})`.
- Visitor (anon key, no session): `rpc('book_trial', {...})` -> booking row; `rpc('my_trial_bookings', {p_device_key})`. The app generates a random 32-char device key once and keeps it in local storage.
- SQLSTATEs: `BXPRM`, `BXNTF`, `BXVAL`, `BXDUP` with the messages above (the app may show them as given).

## Out of scope
Fees and reports (task-04). Capacity, cancellation, confirmation of trials (open product points). Any hosted apply.

## Acceptance criteria
- [ ] RLS and revokes on both tables; anon cannot select `trial_bookings` directly but `book_trial` and `my_trial_bookings` work for anon; another device key sees nothing.
- [ ] `mark_attendance` inserts, then updates on a different status, is a no-op on the same status, and fails `BXVAL` for an inactive trainee.
- [ ] `mark_remaining_absent` returns the inserted count and leaves existing marks untouched.
- [ ] `book_trial` enforces each `BXVAL` rule and `BXDUP` on a duplicate; `delete_extra_session` refuses a session with attendance.
- [ ] `npx supabase db reset` and `npx supabase test db` pass; architecture rows updated.

## Verification
As task-01, with `tests.set_clock` pinning the date for the booking window tests. Assistant writes `tests/030_attendance_trials.sql`.
