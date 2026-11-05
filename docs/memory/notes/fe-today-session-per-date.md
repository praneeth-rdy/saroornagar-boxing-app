# fe Today: selection and marks keyed by date (2026-11-05, run 3 task-10)

- `selectedSessionIdProvider` and `markControllerProvider` are families keyed by the date;
  `mark` and `markRemainingAbsent` take the session id and refuse one that is not in
  `daySessionsProvider(date)` (debug `assert`, so a test that trips it throws AssertionError).
- The reproduction (5 Nov 16:45, mark evening, switch to 4 Nov, mark) PASSED on the old code
  in both a screen test and a full-app test with the real date picker and a slow day load,
  so the field mechanism behind the hosted 4 Nov / 5 Nov mark was not reproduced; the
  family keying and the guard make it impossible by construction instead.
- Hosted rows for trainee c06599ac: 5 Nov morning mark 11:14Z, 4 Nov sessions 11:35:36Z,
  5 Nov evening mark 11:35:44Z (today's default session, not the morning one chosen earlier).
- `MockAttendanceRepository.markCalls` records every `mark` call for assertions.
- Mark failures carry `failedSessionId`; the banner shows only on that session's roster.
