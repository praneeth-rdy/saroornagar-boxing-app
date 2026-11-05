# fe Today: presence-only marking (2026-11-05, run 3 task-14)

- `MarkController.mark(sessionId, traineeId)` lost its status argument and always sends
  `present`; the repository `mark` still takes a status because `mark_attendance` does.
- The only "absent" left in `lib/features/today` is the unknown-status guard message in
  `SupabaseAttendanceRepository.mark` (mirrors the server) and two comments on legacy rows.
- Reset dialog counts the present marks on screen; the server also deletes legacy absent rows,
  so its returned count can be higher. The snackbar does not show the count.
- The session time line is now a `Wrap`, so "Reset attendance", the extra-session delete icon
  and "Add extra session" drop under the times when they do not fit at 360 px.
- Proofs in `test/proofs/today_proofs_test.dart` still seed absent marks; they render as unmarked.
