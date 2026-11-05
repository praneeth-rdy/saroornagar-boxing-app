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
`app_metadata` only, and `anon` loses table-level `select` on all six tables. `seed.sql` adds a local admin and coach (role in `raw_app_meta_data`). pgTAP helpers live in
`supabase/tests/000_helpers.sql` (schema `tests`, local stack only). `config.toml` enables the
phone provider (`[auth.sms] enabled = true`). Hosted project `qgqmnaxdxuezjlexlfpw` in
ap-northeast-1 (Tokyo), empty; not yet linked (backlog S-04).

## Staff creation rule

A profile (and with it any staff right) exists only for an auth user whose `app_metadata.role`
is `admin` or `coach` at insert time. Only the service role can write `app_metadata`
(`admin-staff` `create`, `seed.sql`, `tests.create_user`), so a self sign-up gets no profile
whatever user metadata it sends, and `current_profile` returns `BXNTF` for it.
`app_metadata.role` is read only at sign-up; afterwards `profiles.role` is the source of truth
and `update_staff` changes it there.

`anon` has no table-level privilege on any table in `public`; it reaches data only through the
security definer functions `book_trial` and `my_trial_bookings`. A direct anon `select` raises
`42501`.

## Tables

| Table | Purpose | RLS policies | Direct writes |
|---|---|---|---|
| `profiles` | One row per staff auth user: `full_name`, `phone` (unique, `91` + 10 digits), `role` (`staff_role`: `admin`, `coach`), `is_blocked`, timestamps. Created by `on_auth_user_created` only when `app_metadata.role` is set (see Staff creation rule), phone kept in sync by `on_auth_user_phone_changed`, `updated_at` by `profiles_set_updated_at`. | `profiles_select_own` (own row, even when blocked), `profiles_select_staff` (all rows for unblocked staff) | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via `update_staff`, the auth triggers, or `service_role` |
| `trainees` | The roster: `full_name` (2-80 chars), `phone` (normalized, nullable, not unique), `photo_path` (object name in `trainee-photos`), `date_of_birth`, `joined_on`, `status` (`trainee_status`: `active`, `inactive`), `notes` (<= 500), `created_by` (profile, set null on delete), timestamps; `updated_at` by `trainees_set_updated_at`. Indexes `trainees_status_full_name_idx (status, lower(full_name))`, `trainees_created_by_idx`. | `trainees_select_staff` (unblocked staff) | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via the trainee functions |
| `attendance` | One mark per trainee per session: `session_id` (cascade), `trainee_id` (cascade), `status` (`attendance_status`: `present`, `absent`), `marked_by` (profile, set null on delete), `marked_at`. Primary key `(session_id, trainee_id)`; indexes `attendance_trainee_idx (trainee_id, session_id)`, `attendance_marked_by_idx`. | `attendance_select_staff` (unblocked staff) | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via `mark_attendance`, `mark_remaining_absent` |
| `trial_bookings` | Visitor trial bookings: `full_name` (2-80 chars, trimmed), `phone` (normalized), `date_of_birth`, `age` (3-99), at least one of the two; `session_date`, `slot` (`morning` or `evening` only), `note` (<= 300), `device_key` (16-128 chars, the visitor's only credential), `created_at`. Unique `trial_bookings_phone_slot_key (phone, session_date, slot)`; indexes `trial_bookings_date_idx (session_date, slot)`, `trial_bookings_device_key_idx (device_key, session_date)`. | `trial_bookings_select_staff` (unblocked staff); no anon policy | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via `book_trial` |
| `fee_payments` | Monthly fee payments, record only: `trainee_id` (cascade), `amount` (1-100000), `method` (`payment_method`: `cash`, `upi`), `paid_on`, `period_month` (first of a month), `note` (<= 300, trimmed, blank stored as null), `recorded_by` (profile, set null on delete), `created_at`. Several rows per trainee and month are allowed (partial payments). Indexes `fee_payments_trainee_idx (trainee_id, period_month desc)`, `fee_payments_period_idx (period_month)`, `fee_payments_recorded_by_idx`. | `fee_payments_select_staff` (unblocked staff) | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via `record_fee_payment`, `delete_fee_payment` |
| `sessions` | One row per session: `session_date` (India date), `slot` (`session_slot`: `morning`, `evening`, `extra`), `starts_at`, `ends_at` (> start), `created_by` (null for auto-created batches), `created_at`. Unique `sessions_regular_slot_key (session_date, slot) where slot <> 'extra'`; indexes `sessions_date_idx`, `sessions_created_by_idx`. | `sessions_select_staff` (unblocked staff) | insert, update, delete, truncate revoked from `anon`, `authenticated`, select revoked from `anon`; writes via the session functions |

## Storage

| Bucket | Holds | Policies on `storage.objects` |
|---|---|---|
| `trainee-photos` | Private; 2 MiB; jpeg, png, webp. Objects at `<trainee_id>/<file>`, linked by `set_trainee_photo`. | `trainee_photos_select_staff`, `_insert_staff`, `_update_staff`, `_delete_staff`: `bucket_id = 'trainee-photos'` and unblocked staff |

## Functions

| Function | Who | Does | Fails with |
|---|---|---|---|
| `public.update_staff(p_user_id, p_full_name, p_role)` | authenticated (admin) | Renames a staff member and sets their role; returns the `profiles` row. Name is trimmed. | `BXPRM` not an unblocked admin; `BXNTF` no such profile; `BXVAL` own role change, name not 2-80 chars, null role |
| `public.current_profile()` | authenticated | Returns the caller's own `profiles` row, blocked or not. | `BXNTF` no profile |
| `public.create_trainee(p_full_name, p_phone default null, p_date_of_birth default null, p_joined_on default null, p_notes default null)` | authenticated (staff) | Inserts a trainee with `created_by = auth.uid()`; returns the row. Name and notes trimmed, blank phone or notes stored as null. | `BXPRM` not unblocked staff; `BXVAL` name not 2-80 chars, bad phone, date of birth in the future or on/before 1900-01-01, `joined_on` after today + 1, notes over 500 chars |
| `public.update_trainee(p_trainee_id, p_full_name, p_phone, p_date_of_birth, p_joined_on, p_notes)` | authenticated (staff) | Replaces every editable field (null clears); returns the row. | `BXPRM`; `BXNTF` no such trainee; `BXVAL` as `create_trainee` |
| `public.set_trainee_status(p_trainee_id, p_status)` | authenticated (staff) | Sets `active`/`inactive`; same status returns the row unchanged. | `BXPRM`; `BXNTF`; `BXVAL` null status |
| `public.set_trainee_photo(p_trainee_id, p_photo_path)` | authenticated (staff) | Sets or (null) clears `photo_path`; returns the row. Does not touch the stored object. | `BXPRM`; `BXNTF`; `BXVAL` path not `<trainee_id>/<file>` (or has a `..` segment) |
| `public.ensure_day_sessions(p_date)` | authenticated (staff) | Creates the morning (06:00-08:30) and evening (17:30-20:00) batches for a non-Sunday date if missing (idempotent, concurrency safe through the partial unique index); returns every session of the date by start time. | `BXPRM`; `BXVAL` null date |
| `public.add_extra_session(p_date, p_starts_at, p_ends_at)` | authenticated (staff) | Inserts an `extra` session with `created_by = auth.uid()`; returns the row. | `BXPRM`; `BXVAL` null date or time, end not after start |
| `public.delete_extra_session(p_session_id)` | authenticated (staff) | Deletes an extra session that has no attendance (replaced in `20261105080014`). | `BXPRM`; `BXNTF` no such session; `BXVAL` not an extra session, or `This session already has attendance` |
| `public.mark_attendance(p_session_id, p_trainee_id, p_status)` | authenticated (staff) | Upsert of one mark: inserts, corrects on another status (new `marked_by`, `marked_at`), no-op on the same status; returns the stored `attendance` row. | `BXPRM`; `BXNTF` `Session not found`, `Trainee not found`; `BXVAL` `This trainee is inactive`, null status |
| `public.mark_remaining_absent(p_session_id)` | authenticated (staff) | Inserts `absent` for every active trainee without a mark for the session; existing marks untouched; returns the count inserted. | `BXPRM`; `BXNTF` |
| `public.session_roster(p_session_id)` | authenticated (staff) | Every active trainee (`trainee_id`, `full_name`, `photo_path`) with their `status` and `marked_at` for the session (null = not marked), by `lower(full_name)`. | `BXPRM`; `BXNTF` |
| `public.trainee_attendance_history(p_trainee_id, p_from, p_to)` | authenticated (staff) | The trainee's marks with `session_id`, `session_date`, `slot`, `status`, `marked_at` for sessions dated `p_from`..`p_to` (inclusive), newest first. | `BXPRM`; `BXNTF` no such trainee; `BXVAL` null date, `The end date is before the start date` |
| `public.book_trial(p_full_name, p_phone, p_session_date, p_slot, p_device_key, p_date_of_birth default null, p_age default null, p_note default null)` | anon, authenticated | Books a trial for a non-Sunday India date from today to today + 30 in the morning or evening batch; name and note trimmed, blank note stored as null; returns the `trial_bookings` row. | `BXVAL` (in order) name, phone, slot, past date, over 30 days ahead, Sunday, neither age nor DOB, DOB in the future or on/before 1900-01-01, age not 3-99, note over 300, device key not 16-128 chars; `BXDUP` same phone, date and batch |
| `public.my_trial_bookings(p_device_key)` | anon, authenticated | Bookings with that device key dated today or later, soonest first. An unknown key returns nothing. | |
| `public.trial_bookings_between(p_from, p_to)` | authenticated (staff) | Every booking dated `p_from`..`p_to` (inclusive) by date, batch, `created_at`. | `BXPRM`; `BXVAL` null date, end before start |
| `public.record_fee_payment(p_trainee_id, p_amount, p_method, p_paid_on, p_period_month, p_note default null)` | authenticated (staff) | Inserts a payment with `recorded_by = auth.uid()`; any trainee status; note trimmed, blank stored as null; returns the `fee_payments` row. | `BXPRM`; `BXNTF` `Trainee not found`; `BXVAL` (in order) `Enter the payment date` (null), `The payment date cannot be in the future`, `Period must be a month` (null or not the 1st), `Enter an amount between 1 and 100000`, `Choose cash or UPI` (null), `Keep the note to 300 characters or fewer` |
| `public.delete_fee_payment(p_payment_id)` | authenticated (staff) | Deletes a payment up to exactly 7 days after its `created_at`. | `BXPRM`; `BXNTF` `Payment not found`; `BXVAL` `Payments older than 7 days cannot be removed` |
| `public.trainee_fee_history(p_trainee_id)` | authenticated (staff) | The trainee's payments, newest `period_month` first, then `paid_on` desc, `created_at` desc. | `BXPRM`; `BXNTF` `Trainee not found` |
| `public.fee_status_list(p_month)` | authenticated (staff) | Every active trainee with `tier_amount` (tier on the month's first day, null without a date of birth), `paid_amount` (sum for that `period_month`, 0 when none), `last_paid_on`; unpaid (`paid_amount = 0`) first, then `lower(full_name)`. | `BXPRM`; `BXVAL` `Period must be a month` |
| `public.monthly_attendance_summary(p_month)` | authenticated (staff) | Every active trainee with `present_count`, `absent_count` over sessions dated in the month, and `session_count` (sessions that month, same on every row); by `lower(full_name)`. | `BXPRM`; `BXVAL` `Period must be a month` |
| `private.fee_tier_amount(p_date_of_birth, p_on)` | internal | 500 when age on `p_on` is under 15 (`age()` years), else 1000; null when either date is null. Immutable. | |
| `private.clean_trainee_input(...)` | internal | Shared validation and normalization for `create_trainee` and `update_trainee`; returns `o_full_name`, `o_phone`, `o_notes`. | `BXVAL` as above |
| `private.is_staff()` / `private.is_admin()` | authenticated (RLS) | Caller has an unblocked profile / an unblocked admin profile. Security definer. | |
| `private.fail(p_code, p_message)` | internal | Raises with the given SQLSTATE; the only failure path. | the code passed |
| `private.clock()` / `private.today()` | internal | Server time, overridable per transaction through the `private.clock` setting; India calendar date. | |
| `private.normalize_phone(p_phone)` | internal | Digits only; 10 digits -> `91` prefix; 12 digits starting `91` kept. | `BXVAL` otherwise |
| `private.set_updated_at()` | trigger | Sets `updated_at = private.clock()`. Security definer so `service_role` writes work. | |
| `private.handle_new_user()` / `private.handle_user_phone_change()` | trigger on `auth.users` | Insert the profile only when `raw_app_meta_data.role` is `admin` or `coach` (replaced in `20261105081756`; `raw_user_meta_data` is never read for the role), name from `app_metadata.full_name`, then `user_metadata.full_name`, then the phone, then `Staff`; keep `profiles.phone` in step. | none: any other role makes no profile |

## Edge Functions

| Function | Who | Does | Fails with |
|---|---|---|---|
| `admin-staff` (`supabase/functions/admin-staff`, `verify_jwt = true`, not deployed to hosted) | authenticated (unblocked admin, checked against `profiles` with the service role) | POST only, JSON `{ "action": ... }`, called with `supabase.functions.invoke('admin-staff', body: ...)`. `create` (`full_name` 2-80 trimmed, `phone` normalized like `private.normalize_phone`, `password` 8-72 chars and at most 72 bytes, `role` `admin`/`coach`): Auth admin `createUser` with `phone_confirm: true`, `app_metadata: { role, full_name }` and `user_metadata: { full_name }`, so `on_auth_user_created` makes the profile; returns `{ "profile" }`. `reset_password` (`user_id`, `password`): returns `{ "ok": true }`. `set_blocked` (`user_id`, `blocked` boolean): auth ban (`876000h`, or `none` to lift) then `profiles.is_blocked`; returns `{ "profile" }`. Errors are `{ "code", "message" }`. | 401 `BXPRM` `Sign in again`; 403 `BXPRM` `Only an admin can manage staff`; 400 `BXVAL` (`Use POST` is 405) `Send a JSON body`, `Unknown action`, `Enter a name between 2 and 80 characters`, `Enter a 10-digit mobile number`, `Enter a password of 8 to 72 characters`, `Choose a role`, `Choose a staff member`, `Choose block or unblock`, `You cannot block yourself`; 404 `BXNTF` `Staff member not found`; 409 `BXDUP` `A staff member with this number already exists`; 500 `BXERR` `Something went wrong` (cause in the function log only) |

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
