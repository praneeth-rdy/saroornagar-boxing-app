# Task 14 - Today marks presence only

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** fe
- **Depends on:** task-10 (same files), task-13 (contract below)
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates tests; assistant renders proofs)
- **Owner request this serves:** "user need not manually mark absent. They'll only mark people who are present & rest to be considered absent if attendance is taken for at least 1 in the given session. If no attendance is taken on a session - ignore that session" (2026-11-05).

## Goal
On Today the coach taps the students who are present and nothing else. A tap can be undone.
No absent marking exists in the app.

## Context the worker needs
`fe/CLAUDE.md`; `features/today/*` after task-10; the mock attendance repository; server
contract: `rpc('unmark_attendance', {p_session_id, p_trainee_id})` -> void, `BXNTF 'No mark
to remove'` (task-13); `mark_attendance` unchanged; `rpc('reset_session_attendance', {p_session_id})` -> int (task-13).

## Spec
- `AttendanceRepository`: add `Future<void> unmark(String sessionId, String traineeId)`;
  remove `markRemainingAbsent` from the interface, the Supabase implementation, the mock and
  the providers (the server function stays, unused).
- `RosterRow`: one trailing 44 px toggle (check). Unmarked: outlined; present: accent fill.
  Tapping an unmarked row or its toggle marks present at once. Tapping a present one opens
  a confirm dialog "Remove the mark for <name>?" (Cancel / Remove); on Remove, `unmark`
  (optimistic, rollback on error). Owner, 2026-11-05: every removal asks first. Subtitle: "Present, 6:02 am" when present,
  nothing when unmarked. Rows never show "Absent" or "Not marked".
- `ProgressCard`: eyebrow "PRESENT", `title` "14", caption "of 20 students" (roster size).
  When no one is marked: caption "Tap the students who are here."
- Session header: when the roster has at least one present mark, a `LinkButton('Reset
  attendance')` next to the time line (replacing nothing else); dialog "Remove all N marks
  for this session?" (Cancel / Reset); on Reset call `resetSession(sessionId)` ->
  `rpc('reset_session_attendance')`, then invalidate the roster; snackbar "Attendance
  reset". Add `Future<int> resetSession(String sessionId)` to the repository and the mock.
- Remove the sticky "Mark the remaining N absent" bar and its dialog, and the related
  bottom padding logic.
- Legacy `absent` rows from the server render as unmarked.
- Mock: `unmark` removes the row; `BXNTF` when none.
- Tests: update the Today widget and flow tests; add unmark (confirm and cancel), rollback, and reset (confirm and cancel) tests.

## Out of scope
Reports and logs (task-12); backend.

## Acceptance criteria
- [ ] `grep -n "absent" fe/lib/features/today` matches only the enum handling of legacy rows.
- [ ] `flutter analyze` 0, `dart format` clean, suite passes.
- [ ] Proofs (assistant): `today_typical` (14 of 20 present), `today_no_trainees`, `today_heavy`, `today_mark_error`.
