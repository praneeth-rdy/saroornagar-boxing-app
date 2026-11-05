# fe Fees and reports (2026-11-05, run 2 task-04)

- `/trainees/:id/pay` is a top-level route listed before the shell, not nested in the
  Trainees branch: it is pushed from the More branch too (fee status), and a cross-branch push
  into a `StatefulShellRoute` branch is unreliable. It shows without the tab bar. The month
  travels as `?month=YYYY-MM-01`.
- `FeePayment.canDeleteAt(now)` takes India wall clock (as `clockProvider`), not a real
  instant; it compares against `toIndiaTime(createdAt) + 7 days`. `MockFeeRepository.clock`
  is the same kind of clock, so tests pass one function to both.
- Open for the Architect: the period month cannot go past the current month (the package's
  `MonthNavigator` rule), so advance payments are not possible; paid-on is limited to one
  year back in the picker (the server has no lower bound); the method has no default.
- `AppTextField` has no `inputFormatters`, so the amount field accepts any text on a
  hardware keyboard; the client check rejects non-numbers with the server's message.
- `trainee_detail_screen_test` passes but now renders the Fees section in an error state:
  it needs a `feeRepositoryProvider` override (same for any test that opens the detail).
- Partly paid rows count as paid ("n paid") and have no Record link, because `isPaid` is
  `paidAmount > 0`, matching the server's unpaid-first order.
