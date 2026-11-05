# Unmark and reset attendance (be, 2026-11-05)

- `20261105114625_unmark_attendance.sql` adds `unmark_attendance` and `reset_session_attendance`.
  Choices the package left open (the fe mock must match): `unmark_attendance` does not check the
  trainee's status or existence, so an unknown trainee fails `BXNTF 'No mark to remove'` and a
  mark on a now-inactive trainee can still be undone. Session check runs before the row check.
- `mark_remaining_absent` and the `absent` enum value still exist; presence-only marking makes
  them legacy but nothing was dropped.
- pgTAP for both lives at the end of `tests/030_attendance_trials.sql` on August 2026 sessions,
  a month no other fixture in that file touches, so the summary counts stay isolated.
