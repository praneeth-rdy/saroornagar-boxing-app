# fe compact record-payment screen (2026-11-05, run 3 task-09)

- Tier amounts are public constants `juniorFee` / `seniorFee` in `trainee.dart`; the record
  screen's pills read them, so a future tier change is one edit there plus the mock fixtures.
- The "For month" row shows `MMM yyyy` (not `MMMM yyyy` as `MonthNavigator`) so the label,
  two 44 px chevrons and the month fit one ListRow at 360 dp; checked at 360 x 640 with no overflow.
- With pills there is no client amount range check; the mock still enforces the server's
  1..100000 bound. A trainee without a date of birth gets no preselection and the client
  message "Choose 500 or 800" (not a server message).
- The Record button lives in a bottom bar outside the ListView (Column + Expanded), not a
  Positioned overlay as on Today, so the list never scrolls under it.
