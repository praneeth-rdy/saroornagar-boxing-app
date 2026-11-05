# Backend architecture (be)

The schema map. Whoever adds a table, policy, function or SQLSTATE updates it in the same
change. Hosted applies are recorded here with the date.

## State (2026-11-05)

Migration `20261105074646_identity.sql` (local only, not applied to hosted): schema `private`
with the shared helpers, enum `staff_role`, table `profiles`, the auth triggers, `update_staff`
and `current_profile`. Migration `20261105075401_trainees_sessions.sql` (local only): enums
`trainee_status` and `session_slot`, tables `trainees` and `sessions`, bucket `trainee-photos`,
the trainee and session functions. Migration `20261105080014_attendance_trials.sql` (local only):
enum `attendance_status`, tables `attendance` and `trial_bookings`, the attendance and trial
functions, and `delete_extra_session` replaced with the attendance check. Migration
`20261105080602_fees_reports.sql` (local only): enum `payment_method`, table `fee_payments`,
`private.fee_tier_amount`, the fee functions and the two monthly reports. Migration
`20261105081756_harden_profiles.sql` (local only): `private.handle_new_user` takes the role from
`app_metadata` only, and `anon` loses table-level `select` on all six tables. Migration
`20261105105121_email_sign_in.sql` (local only): `profiles.email` (required, unique, lower-cased),
`profiles.phone` optional, `private.normalize_email`, the profile trigger keyed on the auth email,
trigger `on_auth_user_email_changed`, and `update_staff` with `p_phone` (the 3-argument form is
dropped). Migration `20261105110147_profile_on_metadata.sql` (local only): `private.ensure_profile`
shared by `on_auth_user_created` and the new trigger `on_auth_user_app_metadata_changed`, so a
profile is made when `app_metadata.role` arrives in the update Auth admin `createUser` runs after
its insert. Migration `20261105111738_fee_tier_800.sql` (local only): `private.fee_tier_amount`
replaced with 800 for seniors, same signature and grants. Migration
`20261105114039_summary_held_sessions.sql` (local only): `monthly_attendance_summary` replaced so
`session_count` counts held sessions only, same signature and grants. Migration
`20261105114625_unmark_attendance.sql` (local only): `unmark_attendance` and
`reset_session_attendance` for presence-only marking. Migration `20261105154420_roll_numbers.sql`
(local only): `trainees.roll_no` (backfilled 1, 2, 3 in `created_at, id` order), the partial unique
index over active students, `private.next_roll_no`, `private.check_roll_no`, `public.next_roll_no`,
`create_trainee` and `update_trainee` with `p_roll_no` (old forms dropped), `set_trainee_status`
with the reactivation clash check, and `session_roster` with `roll_no`. Migration
`20261105160639_backlog_sweep.sql` (local only): server messages say student (`Student not found`,
`This student is inactive`, `Photo path must be inside the student folder`) in `update_trainee`,
`set_trainee_status`, `set_trainee_photo`, `mark_attendance`, `record_fee_payment`,
`trainee_fee_history` and `trainee_attendance_history` (same signatures); `trainee_attendance_history`
recreated with `starts_at`, `ends_at`; `book_trial` refuses a batch that has ended today;
`monthly_attendance_summary` keeps inactive students with marks that month; `profiles_select_own`
and `profiles_select_staff` merged into `profiles_select_staff_or_own`. `seed.sql` adds a local admin `admin@local.test` and coach `coach@local.test` (email
provider and identities, role in `raw_app_meta_data`; passwords in the file). pgTAP helpers live in
`supabase/tests/000_helpers.sql` (schema `tests`, local stack only). `config.toml` enables the
phone provider (`[auth.sms] enabled = true`). Hosted project `qgqmnaxdxuezjlexlfpw` in
ap-northeast-1 (Tokyo), empty; not yet linked (backlog S-04).

## Staff creation rule

A profile (and with it any staff right) exists only for an auth user that has an email and
whose `app_metadata.role` is `admin` or `coach` at insert time or in a later `app_metadata` update
(Auth admin `createUser` inserts first and writes `app_metadata` after). Only the service role can write `app_metadata`
(`admin-staff` `create`, `seed.sql`, `tests.create_user`), so a self sign-up gets no profile
whatever user metadata it sends, and `current_profile` returns `BXNTF` for it.
`app_metadata.role` is read only until the profile exists; afterwards `profiles.role` is the source of truth
and `update_staff` changes it there.

`anon` has no table-level privilege on any table in `public`; it reaches data only through the
security definer functions `book_trial` and `my_trial_bookings`. A direct anon `select` raises
`42501`.

## Tables

| Table | Purpose | RLS policies | Direct writes |
|---|---|---|---|
| `profiles` | One row per staff auth user: `full_name`, `email` (not null, unique `profiles_email_key`, trimmed and lower-cased, check `profiles_email_check`), `phone` (nullable, unique, `91` + 10 digits), `role` (`staff_role`: `admin`, `coach`), `is_blocked`, timestamps. Created by `on_auth_user_created` or `on_auth_user_app_metadata_changed` (both through `private.ensure_profile`) only when the auth user has an email and `app_metadata.role` is set (see Staff creation rule); email kept in sync by `on_auth_user_email_changed`, phone by `on_auth_user_phone_changed`, `updated_at` by `profiles_set_updated_at`. | `profiles_select_staff_or_own` (own row, even when blocked, or all rows for unblocked staff; merged in `20261105160639`) | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via `update_staff`, the auth triggers, or `service_role` |
| `trainees` | The roster: `full_name` (2-80 chars), `phone` (normalized, nullable, not unique), `photo_path` (object name in `trainee-photos`), `date_of_birth`, `joined_on`, `status` (`trainee_status`: `active`, `inactive`), `notes` (<= 500), `roll_no` (integer > 0, not null, unique among active students through partial index `trainees_roll_no_active_key ... where status = 'active'`; kept for life but an inactive student's number may be reused, no sequence), `created_by` (profile, set null on delete), timestamps; `updated_at` by `trainees_set_updated_at`. Indexes `trainees_status_full_name_idx (status, lower(full_name))`, `trainees_created_by_idx`. | `trainees_select_staff` (unblocked staff) | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via the trainee functions |
| `attendance` | One mark per trainee per session: `session_id` (cascade), `trainee_id` (cascade), `status` (`attendance_status`: `present`, `absent`), `marked_by` (profile, set null on delete), `marked_at`. Primary key `(session_id, trainee_id)`; indexes `attendance_trainee_idx (trainee_id, session_id)`, `attendance_marked_by_idx`. | `attendance_select_staff` (unblocked staff) | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via `mark_attendance`, `mark_remaining_absent`, `unmark_attendance`, `reset_session_attendance` |
| `trial_bookings` | Visitor trial bookings: `full_name` (2-80 chars, trimmed), `phone` (normalized), `date_of_birth`, `age` (3-99), at least one of the two; `session_date`, `slot` (`morning` or `evening` only), `note` (<= 300), `device_key` (16-128 chars, the visitor's only credential), `created_at`. Unique `trial_bookings_phone_slot_key (phone, session_date, slot)`; indexes `trial_bookings_date_idx (session_date, slot)`, `trial_bookings_device_key_idx (device_key, session_date)`. | `trial_bookings_select_staff` (unblocked staff); no anon policy | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via `book_trial` |
| `fee_payments` | Monthly fee payments, record only: `trainee_id` (cascade), `amount` (1-100000), `method` (`payment_method`: `cash`, `upi`), `paid_on`, `period_month` (first of a month), `note` (<= 300, trimmed, blank stored as null), `recorded_by` (profile, set null on delete), `created_at`. Several rows per trainee and month are allowed (partial payments). Indexes `fee_payments_trainee_idx (trainee_id, period_month desc)`, `fee_payments_period_idx (period_month)`, `fee_payments_recorded_by_idx`. | `fee_payments_select_staff` (unblocked staff) | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via `record_fee_payment`, `delete_fee_payment` |
| `sessions` | One row per session: `session_date` (India date), `slot` (`session_slot`: `morning`, `evening`, `extra`), `starts_at`, `ends_at` (> start), `created_by` (null for auto-created batches), `created_at`. Unique `sessions_regular_slot_key (session_date, slot) where slot <> 'extra'`; indexes `sessions_date_idx`, `sessions_created_by_idx`. | `sessions_select_staff` (unblocked staff) | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via the session functions |

Attendance is presence-only (owner, 2026-11-05): coaches mark only the present, and absence is implicit, meaning no mark in a held session (one with at least one mark). `absent` rows are legacy from the first build.

## Storage

| Bucket | Holds | Policies on `storage.objects` |
|---|---|---|
| `trainee-photos` | Private; 2 MiB; jpeg, png, webp. Objects at `<trainee_id>/<file>`, linked by `set_trainee_photo`. | `trainee_photos_select_staff`, `_insert_staff`, `_update_staff`, `_delete_staff`: `bucket_id = 'trainee-photos'` and unblocked staff |

## Functions

| Function | Who | Does | Fails with |
|---|---|---|---|
| `public.update_staff(p_user_id, p_full_name, p_role, p_phone)` | authenticated (admin) | Renames a staff member, sets their role and phone (null or blank clears it, otherwise `private.normalize_phone`); returns the `profiles` row. Name is trimmed. Replaces the 3-argument form (`20261105105121`). | `BXPRM` not an unblocked admin; `BXNTF` no such profile; `BXVAL` own role change, name not 2-80 chars, null role, `Enter a 10-digit mobile number`; `BXDUP` `This number belongs to another staff member` |
| `public.current_profile()` | authenticated | Returns the caller's own `profiles` row (with `email`), blocked or not. | `BXNTF` no profile |
| `public.create_trainee(p_full_name, p_phone default null, p_date_of_birth default null, p_joined_on default null, p_notes default null, p_roll_no integer default null)` | authenticated (staff) | Inserts a trainee with `created_by = auth.uid()`; returns the row. Name and notes trimmed, blank phone or notes stored as null; a null roll number takes `private.next_roll_no()`. 5-argument form dropped in `20261105154420`. | `BXPRM` not unblocked staff; `BXVAL` name not 2-80 chars, bad phone, date of birth in the future or on/before 1900-01-01, `joined_on` after today + 1, notes over 500 chars, `Enter a roll number above 0`; `BXDUP` `Roll number N is already in use` (an active student holds it) |
| `public.update_trainee(p_trainee_id, p_full_name, p_phone, p_date_of_birth, p_joined_on, p_notes, p_roll_no integer default null)` | authenticated (staff) | Replaces every editable field (null clears, except a null roll number, which keeps the current one); returns the row. The clash check runs only for an active student (an inactive one may hold a number in use). 6-argument form dropped in `20261105154420`. | `BXPRM`; `BXNTF` `Student not found`; `BXVAL` as `create_trainee`; `BXDUP` as `create_trainee`, ignoring the row itself |
| `public.set_trainee_status(p_trainee_id, p_status)` | authenticated (staff) | Sets `active`/`inactive`; same status returns the row unchanged. Reactivating checks the roll number is still free. | `BXPRM`; `BXNTF`; `BXVAL` null status; `BXDUP` `Roll number N is already in use` on reactivation |
| `public.next_roll_no()` | authenticated (staff) | The form's default roll number: `private.next_roll_no()`. Added in `20261105154420`. | `BXPRM` |
| `public.set_trainee_photo(p_trainee_id, p_photo_path)` | authenticated (staff) | Sets or (null) clears `photo_path`; returns the row. Does not touch the stored object. | `BXPRM`; `BXNTF`; `BXVAL` path not `<trainee_id>/<file>` (or has a `..` segment) |
| `public.ensure_day_sessions(p_date)` | authenticated (staff) | Creates the morning (06:00-08:30) and evening (17:30-20:00) batches for a non-Sunday date if missing (idempotent, concurrency safe through the partial unique index); returns every session of the date by start time. | `BXPRM`; `BXVAL` null date |
| `public.add_extra_session(p_date, p_starts_at, p_ends_at)` | authenticated (staff) | Inserts an `extra` session with `created_by = auth.uid()`; returns the row. | `BXPRM`; `BXVAL` null date or time, end not after start |
| `public.delete_extra_session(p_session_id)` | authenticated (staff) | Deletes an extra session that has no attendance (replaced in `20261105080014`). | `BXPRM`; `BXNTF` no such session; `BXVAL` not an extra session, or `This session already has attendance` |
| `public.mark_attendance(p_session_id, p_trainee_id, p_status)` | authenticated (staff) | Upsert of one mark: inserts, corrects on another status (new `marked_by`, `marked_at`), no-op on the same status; returns the stored `attendance` row. | `BXPRM`; `BXNTF` `Session not found`, `Student not found`; `BXVAL` `This student is inactive`, null status |
| `public.mark_remaining_absent(p_session_id)` | authenticated (staff) | Inserts `absent` for every active trainee without a mark for the session; existing marks untouched; returns the count inserted. | `BXPRM`; `BXNTF` |
| `public.unmark_attendance(p_session_id, p_trainee_id)` | authenticated (staff) | Deletes the trainee's mark for the session (any trainee status); removing a session's only mark returns it to not held. Added in `20261105114625`. | `BXPRM`; `BXNTF` `Session not found`, `No mark to remove` |
| `public.reset_session_attendance(p_session_id)` | authenticated (staff) | Deletes every mark of the session; returns the count removed (0 when none). Added in `20261105114625`. | `BXPRM`; `BXNTF` `Session not found` |
| `public.session_roster(p_session_id)` | authenticated (staff) | Every active trainee (`trainee_id`, `roll_no`, `full_name`, `photo_path`) with their `status` and `marked_at` for the session (null = not marked), by `roll_no`. Recreated with `roll_no` in `20261105154420`. | `BXPRM`; `BXNTF` |
| `public.trainee_attendance_history(p_trainee_id, p_from, p_to)` | authenticated (staff) | The trainee's marks with `session_id`, `session_date`, `slot`, `status`, `marked_at`, `starts_at`, `ends_at` (the session's times; the last two added in `20261105160639`) for sessions dated `p_from`..`p_to` (inclusive), newest first. | `BXPRM`; `BXNTF` `Student not found`; `BXVAL` null date, `The end date is before the start date` |
| `public.book_trial(p_full_name, p_phone, p_session_date, p_slot, p_device_key, p_date_of_birth default null, p_age default null, p_note default null)` | anon, authenticated | Books a trial for a non-Sunday India date from today to today + 30 in the morning or evening batch, but not today's batch once it has ended (morning 08:30, evening 20:00, India time); name and note trimmed, blank note stored as null; returns the `trial_bookings` row. | `BXVAL` (in order) name, phone, slot, past date, `That batch has already ended today`, over 30 days ahead, Sunday, neither age nor DOB, DOB in the future or on/before 1900-01-01, age not 3-99, note over 300, device key not 16-128 chars; `BXDUP` same phone, date and batch |
| `public.my_trial_bookings(p_device_key)` | anon, authenticated | Bookings with that device key dated today or later, soonest first. An unknown key returns nothing. | |
| `public.trial_bookings_between(p_from, p_to)` | authenticated (staff) | Every booking dated `p_from`..`p_to` (inclusive) by date, batch, `created_at`. | `BXPRM`; `BXVAL` null date, end before start |
| `public.record_fee_payment(p_trainee_id, p_amount, p_method, p_paid_on, p_period_month, p_note default null)` | authenticated (staff) | Inserts a payment with `recorded_by = auth.uid()`; any trainee status; note trimmed, blank stored as null; returns the `fee_payments` row. | `BXPRM`; `BXNTF` `Student not found`; `BXVAL` (in order) `Enter the payment date` (null), `The payment date cannot be in the future`, `Period must be a month` (null or not the 1st), `Enter an amount between 1 and 100000`, `Choose cash or UPI` (null), `Keep the note to 300 characters or fewer` |
| `public.delete_fee_payment(p_payment_id)` | authenticated (staff) | Deletes a payment up to exactly 7 days after its `created_at`. | `BXPRM`; `BXNTF` `Payment not found`; `BXVAL` `Payments older than 7 days cannot be removed` |
| `public.trainee_fee_history(p_trainee_id)` | authenticated (staff) | The trainee's payments, newest `period_month` first, then `paid_on` desc, `created_at` desc. | `BXPRM`; `BXNTF` `Student not found` |
| `public.fee_status_list(p_month)` | authenticated (staff) | Every active trainee with `tier_amount` (tier on the month's first day, null without a date of birth), `paid_amount` (sum for that `period_month`, 0 when none), `last_paid_on`; unpaid (`paid_amount = 0`) first, then `lower(full_name)`. | `BXPRM`; `BXVAL` `Period must be a month` |
| `public.monthly_attendance_summary(p_month)` | authenticated (staff) | Every active trainee, plus any inactive one with at least one mark that month (B-06), with `present_count`, `absent_count` over sessions dated in the month, and `session_count` (held sessions that month: sessions with at least one attendance mark, same on every row); by `lower(full_name)`. | `BXPRM`; `BXVAL` `Period must be a month` |
| `private.fee_tier_amount(p_date_of_birth, p_on)` | internal | 500 when age on `p_on` is under 15 (`age()` years), else 800 (owner, 2026-11-05; was 1000 before `20261105111738_fee_tier_800.sql`); null when either date is null. Immutable. | |
| `private.next_roll_no()` | internal | Smallest positive number not held by an active student (gaps first), else the highest plus one; 1 when no student is active. | none |
| `private.check_roll_no(p_roll_no, p_trainee_id)` | internal | Shared roll number rule for the trainee functions; `p_trainee_id` is the row to ignore (null on create). | `BXVAL`; `BXDUP` |
| `private.clean_trainee_input(...)` | internal | Shared validation and normalization for `create_trainee` and `update_trainee`; returns `o_full_name`, `o_phone`, `o_notes`. | `BXVAL` as above |
| `private.is_staff()` / `private.is_admin()` | authenticated (RLS) | Caller has an unblocked profile / an unblocked admin profile. Security definer. | |
| `private.fail(p_code, p_message)` | internal | Raises with the given SQLSTATE; the only failure path. | the code passed |
| `private.clock()` / `private.today()` | internal | Server time, overridable per transaction through the `private.clock` setting; India calendar date. | |
| `private.normalize_phone(p_phone)` | internal | Digits only; 10 digits -> `91` prefix; 12 digits starting `91` kept. | `BXVAL` otherwise |
| `private.normalize_email(p_email)` | internal | Trim and lower-case; must match `^[^@\s]+@[^@\s]+\.[^@\s]+$`. Immutable. | `BXVAL` `Enter a valid email address` |
| `private.set_updated_at()` | trigger | Sets `updated_at = private.clock()`. Security definer so `service_role` writes work. | |
| `private.ensure_profile(p_user auth.users)` | internal | The profile insert shared by `handle_new_user` and `handle_user_app_metadata_change` (`20261105110147`): returns without inserting when the user already has a profile, so a later `app_metadata.role` change never alters `profiles.role`; otherwise the rules in the next row, `on conflict (id) do nothing`. Security definer. | `BXVAL` bad email or phone |
| `private.handle_new_user()` / `private.handle_user_app_metadata_change()` / `private.handle_user_phone_change()` / `private.handle_user_email_change()` | trigger on `auth.users` (`on_auth_user_created` after insert; `on_auth_user_app_metadata_changed` after update of `raw_app_meta_data` when it changed; phone and email sync) | Insert the profile only when `raw_app_meta_data.role` is `admin` or `coach` and the user has an email (replaced in `20261105105121`; `raw_user_meta_data` is never read for the role); `email` through `private.normalize_email`, `phone` from `auth.users.phone`, else `app_metadata.phone`, normalized when present; name from `app_metadata.full_name`, then `user_metadata.full_name`, then the phone, then `Staff`. Keep `profiles.phone` and `profiles.email` in step (a cleared auth email leaves the profile email). | `BXVAL` bad email or phone aborts the auth insert; any other role or no email makes no profile |

## Edge Functions

| Function | Who | Does | Fails with |
|---|---|---|---|
| `admin-staff` (`supabase/functions/admin-staff`, `verify_jwt = true`, not deployed to hosted) | authenticated (unblocked admin, checked against `profiles` with the service role) | POST only, JSON `{ "action": ... }`, called with `supabase.functions.invoke('admin-staff', body: ...)`. `create` (`full_name` 2-80 trimmed, `email` trimmed and lower-cased like `private.normalize_email`, optional `phone` (absent, null or blank means none) normalized like `private.normalize_phone`, `password` 8-72 chars and at most 72 bytes, `role` `admin`/`coach`): phone clash checked against `profiles` first, then Auth admin `createUser` with `email_confirm: true`, `app_metadata: { role, full_name, phone? }` and `user_metadata: { full_name }`, so `on_auth_user_created` makes the profile; returns `{ "profile" }` (with `email`, `phone` may be null). `reset_password` (`user_id`, `password`): returns `{ "ok": true }`. `set_blocked` (`user_id`, `blocked` boolean): auth ban (`876000h`, or `none` to lift) then `profiles.is_blocked`; returns `{ "profile" }`. Errors are `{ "code", "message" }`. | 401 `BXPRM` `Sign in again`; 403 `BXPRM` `Only an admin can manage staff`; 400 `BXVAL` (`Use POST` is 405) `Send a JSON body`, `Unknown action`, `Enter a name between 2 and 80 characters`, `Enter a valid email address`, `Enter a 10-digit mobile number`, `Enter a password of 8 to 72 characters`, `Choose a role`, `Choose a staff member`, `Choose block or unblock`, `You cannot block yourself`; 404 `BXNTF` `Staff member not found`; 409 `BXDUP` `A staff member with this email already exists`, `This number belongs to another staff member`; 500 `BXERR` `Something went wrong` (cause in the function log only) |

## Hosted applies

Hosted versions are the MCP's own timestamps, not the file names (the MCP records
`name` = file name minus `.sql`). Apply through the MCP only; `npx supabase db push` would
see the files as unapplied unless `supabase migration repair` is run first.

| Date | Migration | By |
|---|---|---|
| 2026-11-05 | `20261105074646_identity` (hosted version 20261105093210) | assistant through the MCP, on the owner's word |
| 2026-11-05 | `20261105075401_trainees_sessions` (hosted version 20261105093241) | assistant through the MCP |
| 2026-11-05 | `20261105080014_attendance_trials` | Architect through the MCP |
| 2026-11-05 | `20261105080602_fees_reports` | Architect through the MCP |
| 2026-11-05 | `20261105081756_harden_profiles` | Architect through the MCP |
| 2026-11-05 | Edge Function `admin-staff` version 1 deployed (verify_jwt on) | Architect through the MCP |
| 2026-11-05 | First admin user inserted (phone identity, app_metadata role admin); login in `creds.md` | Architect through the MCP |
| 2026-11-05 | `20261105105121_email_sign_in` and `20261105110147_profile_on_metadata` applied; the phone-based admin user deleted first (no email to backfill) | Architect through the MCP, on the owner's word |
| 2026-11-05 | Edge Function `admin-staff` version 2 (create by email) | Architect through the MCP |
| 2026-11-05 | First admin re-created with an email identity (login in `creds.md`) | Architect through the MCP |
| 2026-11-05 | `20261105111738_fee_tier_800`, `20261105114039_summary_held_sessions`, `20261105114625_unmark_attendance` applied | Architect through the MCP, on the owner's "retry now" |
| 2026-11-05 | `20261105154420_roll_numbers` applied (backfill gave the one existing student roll 1; the owner then set it to 10 through the MCP) | Architect through the MCP |
