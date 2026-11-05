# Task 10 - Marks must land on the session being shown (R3-03)

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** fe
- **Worker:** developer (Opus)
- **Tests:** yes (developer writes the reproduction test)
- **Owner request this serves:** "the trainee ... got the attendance marked twice for the same session" (2026-11-05). Reproduced from hosted data: 4 Nov sessions were created at 11:35:36Z when the owner opened that date, and a Present tap at 11:35:44Z landed on the 5 Nov evening session.

## Goal
Changing the date on Today can never leave the previous day's session selected; a mark is
always sent for a session that belongs to the date on screen.

## Context the worker needs
`fe/CLAUDE.md`; `features/today/presentation/today_providers.dart` (`SelectedSessionId`,
`defaultSessionIdFor`, the mark controller), `today_screen.dart`, `session_segment.dart`,
`roster_row.dart`; `test/support/mocks/mock_attendance_repository.dart` (records calls);
existing tests under `test/features/today/`.

## Spec
- `selectedSessionIdProvider` becomes a family keyed by the date (`NotifierProvider.
  autoDispose.family<SelectedSessionId, String?, DateTime>`), so each date has its own
  selection and nothing carries over. Drop the "keep the current choice while loading" rule
  for a date that has no loaded sessions; it may stay only when the same date reloads.
- The screen reads the selection for `selectedDateProvider`'s date; the roster, progress
  card, trial visitors and mark controller all derive the session id from that same value.
- The mark controller takes the session id as an argument at call time (from the widget that
  renders the row), and refuses (no call, `assert` in debug) when that id is not among
  `daySessionsProvider(date)`'s loaded sessions.
- Reproduction test (widget, mock repository): open Today on 5 Nov at 16:45 India time
  (`clockProvider`), mark one trainee present on the evening session, pick 4 Nov in the date
  picker (drive `selectedDateProvider` directly), wait for the day's sessions, tap Present on
  the same trainee; assert the mock received the second mark with a 4 Nov session id and
  that the 5 Nov evening session has exactly one mark. Also a unit test that the selection
  for 4 Nov starts null/default and never equals a 5 Nov id.

## Out of scope
Server changes; the monthly summary (task-11).

## Acceptance criteria
- [ ] Reproduction test fails on the current code and passes after the fix (say so).
- [ ] `flutter analyze` 0, `dart format` clean, full suite passes.
- [ ] `docs/fe/architecture.md` provider row updated.
