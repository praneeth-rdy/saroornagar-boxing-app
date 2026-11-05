# fe Student wording, attendance by date, form expander (2026-11-05, run 3 task-12)

- `trainee_attendance_history` returns no session start time, so an extra session reads
  "extra" (or "2 extras"), not "extra 4:00 pm". Showing the time needs `starts_at` in that
  function's result (a be change).
- `/trainees/:id/history` moved out of the shell (like `/pay`): Monthly attendance (More tab)
  pushes it, and a cross-branch push is unreliable. It now shows without the tab bar from the
  student detail too.
- Server messages still say "trainee" ("This trainee is inactive", "Trainee not found") and
  are shown as given; the mocks keep them. Only the client-authored `byId` miss in
  `SupabaseTraineeRepository` says "Student not found" (the mock's `_trainee` helper does not).
- Required mark: `isRequired` on `AppTextField` / `DateField`, `requiredMark` appended to
  eyebrows of required choice groups (trial DAY, BATCH, YOUR AGE; payment Amount, Method).
  Staff Role and the payment dates always hold a value and are left unmarked. Auth screens
  are not marked.
- Test fixtures (`fixtureAttendanceHistory`, `fixtureMonthAttendance`) hold morning marks
  only, so grouped proofs read "Morning" on every row unless the proofs seed evenings.
