# fe Today and attendance (2026-11-05, run 2 task-01)

- India time is a fixed +05:30 carried in a UTC `DateTime` (`core/utils/india_date.dart`);
  no timezone package. `clockProvider` returns that wall clock; tests override it
  (`DateTime.utc(2026, 11, 5, 7)` means 7:00 am in India) to pin the day and default session.
- Riverpod 3.4 retries failing providers by default (10 tries, 200 ms to 6.4 s) for any
  `Exception`, including `AppException`. Error-scenario widget tests may leave retry timers
  pending; pass `retry: (_, _) => null` on the test `ProviderScope` if they do.
- Off-screen children of a `ListView` are not built: `find.text('15 of 20')` fails after
  scrolling to a lower roster row until the list is scrolled back. Toggles have keys
  `present-<traineeId>` / `absent-<traineeId>`.
- `auth_flow_test` still expects the removed Today stub ("Coming next") and needs an
  `attendanceRepositoryProvider` override; it fails until the assistant rewrites it.
- Trainee photos are not shown on the roster: `photo_path` is a storage object path and the
  signed URL belongs to task-02.
- `SelectedSessionId` keeps a choice while the day reloads (so a just-added extra stays
  selected); delete selects the next session before invalidating so the removed roster is
  never fetched.
