# fe run 2 review fixes (2026-11-05, run 2 task-07)

- `RecordPaymentScreen` pops with `context.pop()` (go_router) after a successful record, so a
  widget test that pumps it as `home:` without a GoRouter throws "No GoRouter found" on a
  successful submit; assert success paths through a `MaterialApp.router` or a flow test.
- `TrialBookedScreen` now watches `sessionProvider`; a widget test must override it (for
  example `sessionProvider.overrideWith((ref) => Stream.value(true))`), else it reaches the
  Supabase auth repository.
- The server sets no upper bound on `p_period_month`; the next-month cap is client only
  (`RecordPaymentScreen.latestMonth`). A `?month=` beyond next month falls back to the current one.
- `docs/fe/architecture.md` still describes the old rules (Done -> `/trial`, Record on unpaid
  rows only, period up to the current month); the package allowed edits there only for a
  signature change, so the Architect updates those rows.
