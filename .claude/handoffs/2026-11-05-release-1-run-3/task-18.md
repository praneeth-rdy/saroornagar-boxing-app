# Task 18 - Backlog sweep (A-08, A-09, A-10, A-11, B-13 app side)

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-3/`
- **Area:** fe
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates tests)
- **Owner request this serves:** "Proceed with the remaining work." (2026-11-05), `docs/backlog.md` items A-08 to A-11 and B-13.

## Context
`fe/CLAUDE.md`; `docs/backlog.md`; the trainee repository (photo upload), `auth_providers.dart`
and `shell_screen.dart` (profile refresh), `supabase_errors.dart` and the staff repository
(gateway 401), `test/helpers/pump_app.dart`, `attendance_day.dart` grouping. Backend task-17
(parallel): `trainee_attendance_history` rows gain `starts_at` and `ends_at` (`HH:mm:ss`);
server messages now say "student" (`'This student is inactive'`, `'Student not found'`).

## Spec
- B-13: `AttendanceRecord` gains optional `startsAt`/`endsAt`; grouped log subtitles name an
  extra session by its start time ("Morning and extra 4:00 pm"); mock and fixtures updated.
  Mocks mirror the new server messages.
- A-08: on photo replace or remove, delete the previous storage object after the new path is
  saved (best effort: a failed delete is logged with `debugPrint`, never shown).
- A-09: after `update_staff` on the own profile, refresh `currentProfileProvider` without
  blanking the shell (keep the previous value while reloading: `skipLoadingOnRefresh: true`
  on that read, or a `refresh` that preserves the data).
- A-10: a `FunctionsHttpException` with status 401 and no `code` maps to
  `AuthFailedException('Your session expired. Sign in again.')`; the shell signs the user
  out when it sees that from the staff actions (or shows a banner with a sign-out action;
  pick the simpler and say which).
- A-11: `pumpApp` gains an optional `routes` parameter (list of `GoRoute`) and wraps `home`
  in a `GoRouter` when given; migrate the tests that built their own local router to it
  (at least the three recovery and staff tests).
- `docs/backlog.md` statuses (A-08..A-11, B-13 app side done, date); `docs/fe/architecture.md`.

## Acceptance criteria
- [ ] Analyzer, format clean; suite passes with tests for each item.
