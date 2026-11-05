# Schema proposal, release 1 (sent in chat 2026-11-05, awaiting the owner's yes)

Approve as a whole or with edits before the `be` package is written. Codes: BXVAL, BXPRM,
BXNTF, BXDUP.

- `profiles`: id (= auth user), full_name, phone, role enum admin | coach, is_blocked,
  timestamps. Created by `create_staff` (admin only). First admin seeded by a migration with a
  password the owner changes (recorded in creds.md).
- `trainees`: id, full_name, phone (null), photo_path (null; Storage bucket `trainee-photos`),
  date_of_birth (null; drives the fee tier 500 under 15 / 1000 at 15 and above), joined_on
  (null), status enum active | inactive, notes (null), timestamps.
- `sessions`: id, session_date, slot enum morning | evening | extra, starts_at, ends_at,
  created_by. Morning (06:00-08:30) and evening (17:30-20:00) rows created on demand for any
  non-Sunday date; staff add `extra` with their own times.
- `attendance`: session_id, trainee_id, status enum present | absent, marked_by, marked_at;
  unique (session_id, trainee_id). Written only via `mark_attendance` and
  `mark_remaining_absent`.
- `trial_bookings`: id, full_name, phone, date_of_birth or age, session_date, slot, note
  (null), device_key, created_at. Inserted by anon through `book_trial`; staff read all; the
  booking device reads its own by device_key. No confirmation, no arrived tick, no capacity,
  no cancel (open points).
- `fee_payments`: id, trainee_id, amount, method enum cash | upi, paid_on, period_month,
  note (null), recorded_by. Tier suggested from date_of_birth, editable.
- Admin functions: `create_staff`, `update_staff`, `set_staff_blocked`; `reset_staff_password`
  as an Edge Function using the service role, admin only.
- RLS: staff read everything; anon only `book_trial` and own-booking read; all writes through
  functions; pgTAP per policy and transition.
