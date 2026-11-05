# Attendance and trial bookings migration: things to know (be, 2026-11-05)

- Choices the package left open, made in `20261105080014_attendance_trials.sql` (the fe mock
  must match): null status in `mark_attendance` fails `BXVAL 'Choose present or absent'` (after
  the existence and inactive checks); null `p_from`/`p_to` fails `BXVAL 'Choose a start and an
  end date'`; `book_trial` trims name and note, stores a blank note as null, and adds
  `BXVAL 'Enter a valid date of birth'` (DOB on/before 1900-01-01), `'Enter an age between 3 and
  99'`, `'Keep the note to 300 characters or fewer'`; null slot or date fail like 'extra' / past.
- `book_trial` checks in the package's order, so a call missing both age and DOB reports that
  before a bad device key. Duplicates use `on conflict on constraint ... do nothing` then BXDUP.
- Extra indexes beyond the package: `attendance_marked_by_idx` (FK on profile delete) and
  `trial_bookings_device_key_idx` (anon `my_trial_bookings` lookups).
- Read functions are volatile, not stable: `stable` plus `private.fail` adds `db lint` warnings.
- Open for the Architect: `session_roster` lists active trainees only, so a trainee marked and
  later set inactive drops off that past session's roster (history still shows the mark);
  `book_trial` accepts today's morning batch after it has ended; anon booking has no rate limit
  beyond one booking per phone, date and batch.
- `npx supabase db reset` wipes the `tests` schema; `test db` reinstalls it from `000_helpers`.
