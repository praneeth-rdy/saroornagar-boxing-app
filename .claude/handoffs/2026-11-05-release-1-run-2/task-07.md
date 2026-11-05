# Task 07 - Run 2 review fixes and the full proof set

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-2/`
- **Area:** fe
- **Depends on:** task-05
- **Worker:** developer (Opus); proofs by the assistant (Tests: yes)
- **Tests:** yes (assistant: proofs for every screen, see Verification)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
Four small behaviours decided at review, then a complete set of screen proofs so the
Architect can look at every screen in three states before the release build.

## Context the worker needs
`fe/CLAUDE.md`; the run-2 packages 01 to 05 and the workers' notes in
`docs/memory/notes/fe-*.md`. Read each file before editing it.

## Files
- `fe/lib/features/today/presentation/roster_row.dart` - modify - status line flexible
- `fe/lib/features/trials/presentation/trial_booked_screen.dart` (and the provider or router piece that knows the session) - modify - Done returns to the Trials tab when signed in
- `fe/lib/features/fees/presentation/fee_status_screen.dart` - modify - Record link rule
- `fe/lib/features/fees/presentation/record_payment_screen.dart` (+ `month_navigator.dart` if it needs a `maxMonth` parameter) - modify - period month may be next month
- `docs/fe/architecture.md` - modify only if a signature changes

## Spec
1. `RosterRow`: the status line (`_StatusLine` or equivalent) sits in an `Expanded`/`Flexible` with `overflow: TextOverflow.ellipsis`, so a long name or status never overflows at 360 px logical width.
2. `TrialBookedScreen` Done: when `sessionProvider` is true (staff signed in), `go(Routes.trials)`; otherwise `go(Routes.trial)` as now. "Book another day" unchanged.
3. `FeeStatusScreen`: the trailing `Record` link shows whenever `outstanding == null ? !isPaid : outstanding > 0` (partly paid rows keep it); the caption counts stay as they are.
4. `RecordPaymentScreen`: the period `MonthNavigator` may advance to the month after the current one (advance payment), never further; `FeeStatusScreen` and `AttendanceSummaryScreen` keep the current-month limit.

## Out of scope
Anything else the workers flagged (orphan photos, self rename refresh, caller 401 mapping): backlog items, not this package.

## Acceptance criteria
- [ ] `flutter analyze` 0 issues; `dart format` clean; the existing suite passes (update the fee status and record payment tests that assert the old rules).
- [ ] The four behaviours above have a widget test each (developer writes these four, since they replace existing assertions).

## Verification
Developer: `flutter analyze`, `flutter test`, `dart format --output=none --set-exit-if-changed <touched files>`.
Assistant (Tests: yes step): write `test/proofs/*_proofs_test.dart` files that render, through `renderProof` with `interact` where a state needs input, PNGs under `test/proofs/out/` for: sign-in (empty, filled, wrong-password error, offline error), More (admin, coach), blocked, not-staff, Today (no trainees, typical 20 with 14 marked and 2 trial visitors, heavy 60, Sunday, extra-session sheet, mark error banner), Trainees list (empty, 12, 80), trainee detail (no optional data, typical with fees, heavy notes), trainee form (empty, filled with a server error), attendance history (empty, typical), book trial (empty, filled, duplicate error, with "Your bookings"), booked, Trials tab (empty, 2 days, 10 days), fee status (empty, mixed, heavy 60), record payment (prefilled, error), attendance summary (empty, typical, heavy), staff list (typical, heavy 15 with blocked), staff form (empty, error), staff detail (coach viewed by admin, admin viewing self), coach More without the Staff card. Use the fixtures under `test/support/fixtures/`, pin `clockProvider` to a weekday morning, and set Riverpod `retry` to null. Run `flutter test test/proofs` and report the count of PNGs written and any screen that could not be rendered, with the reason.
