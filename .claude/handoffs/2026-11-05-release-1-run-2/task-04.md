# Task 04 - Fees and reports

- **Run:** `.claude/handoffs/2026-11-05-release-1-run-2/`
- **Area:** fe
- **Depends on:** task-03
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)
- **Schema change approved by the owner:** n/a
- **Hosted apply:** n/a

## Goal
Staff record a monthly fee payment for a trainee, see who has paid for a month and who has
not, read a trainee's payment history, and read the monthly attendance summary.

## Context the worker needs
- `fe/CLAUDE.md`; both `plan.md` files. Server rows in `docs/be/architecture.md`:
  `record_fee_payment`, `delete_fee_payment` (7-day window), `trainee_fee_history`,
  `fee_status_list(p_month)` -> `{trainee_id, full_name, photo_path, tier_amount?, paid_amount,
  last_paid_on?}`, `monthly_attendance_summary(p_month)` -> `{trainee_id, full_name,
  photo_path, present_count, absent_count, session_count}`; messages in
  `docs/memory/notes/be-fees-reports.md`.
- `Trainee.feeTier` from task-02 for the prefilled amount.

## Files
- `fe/lib/features/fees/domain/{fee_payment,fee_status,attendance_summary_row}.dart` (+ generated) - create
- `fe/lib/features/fees/data/{fee_repository,supabase_fee_repository}.dart` - create
- `fe/lib/features/fees/presentation/{fee_providers,fee_status_screen,record_payment_screen,fee_history_section,attendance_summary_screen,month_navigator}.dart` - create
- `fe/lib/features/trainees/presentation/trainee_detail_screen.dart` - modify - Fees section
- `fe/lib/features/more/presentation/more_screen.dart` - modify - "Reports" card with Fee status and Monthly attendance rows
- `fe/lib/core/router/{routes,app_router}.dart`, `fe/lib/core/di/repository_providers.dart` - modify
- `fe/test/support/mocks/mock_fee_repository.dart`, `fe/test/support/fixtures/fees.dart` - create
- `docs/fe/architecture.md` - modify

## Spec
### Models
`FeePayment(id, traineeId, amount: int, method: PaymentMethod, paidOn, periodMonth, note?, recordedBy?, createdAt)` with `bool canDeleteAt(DateTime now)` (within 7 days of `createdAt`); `FeeStatus(traineeId, fullName, photoPath?, tierAmount?, paidAmount, lastPaidOn?)` with `bool get isPaid` (`paidAmount > 0`) and `int? get outstanding` (`tierAmount - paidAmount`, floored at 0, null without a tier); `AttendanceSummaryRow(traineeId, fullName, photoPath?, presentCount, absentCount, sessionCount)`.

### Repository
```dart
abstract class FeeRepository {
  Future<FeePayment> record({required String traineeId, required int amount, required PaymentMethod method, required DateTime paidOn, required DateTime periodMonth, String? note});
  Future<void> delete(String paymentId);
  Future<List<FeePayment>> history(String traineeId);
  Future<List<FeeStatus>> statusFor(DateTime month);
  Future<List<AttendanceSummaryRow>> attendanceSummary(DateTime month);
}
```
Mock mirrors the check order, messages, the 7-day delete window and the unpaid-first ordering.

### Routes and screens
- `Routes.feeStatus = '/more/fees'`, `Routes.attendanceSummary = '/more/attendance'`, `Routes.recordPayment = '/trainees/:id/pay'` (pushed from the trainee detail and from a fee status row).
- `MonthNavigator`: `AppCard` row with chevron buttons (44 px) and the month label `MMMM yyyy`; next is disabled beyond the current month.
- `FeeStatusScreen`: `AppBar` "Fee status", `MonthNavigator`, counts caption "6 unpaid · 14 paid", `AppCard` of rows: avatar, name, subtitle "Paid 1000 on 3 Nov" / "Partly paid 500 of 1000" / "Unpaid · 1000 due" / "No date of birth, tier unknown"; unpaid rows show a trailing `LinkButton('Record')`; every row -> `Routes.recordPayment` with the month prefilled. Empty: `EmptyView(title: 'No active trainees', message: 'Fee status lists active trainees.', actionLabel: 'Go to Trainees')`.
- `RecordPaymentScreen`: `AppBar` "Record payment", trainee header row, amount (numeric, prefilled with `feeTier` when known), method `ChoiceRow` Cash / UPI, paid on (date picker, default today, not in the future), period month (`MonthNavigator`, default the selected or current month), note (300 max), `PrimaryButton('Record payment')`; server messages in a banner; success pops with a snackbar "Payment recorded".
- `FeeHistorySection` inside `TraineeDetailScreen` under the attendance section: eyebrow "FEES", `PrimaryButton('Record payment')` (expanded, above the list), rows per payment (`MMMM yyyy` period as title, subtitle "1000 · Cash · paid 3 Nov", note caption), trailing remove action only while `canDeleteAt(now)`, with a confirm dialog. Empty: "No payments recorded yet".
- `AttendanceSummaryScreen`: `AppBar` "Monthly attendance", `MonthNavigator`, caption "24 sessions this month", rows: avatar, name, subtitle "18 present · 3 absent", trailing "18/24"; empty "No sessions this month" when `sessionCount == 0`, "No active trainees" when the list is empty.
- `MoreScreen` gains an `AppCard` "Reports" with two `ListRow`s (Fee status, Monthly attendance, chevron trailing).

## Out of scope
Due or overdue logic, reminders, receipts, exports.

## Acceptance criteria
- [ ] Analyzer, format, codegen clean; generated files committed.
- [ ] Unit: `isPaid`, `outstanding`, `canDeleteAt` boundaries; mock messages equal the backend notes.
- [ ] Widget: fee status subtitle variants; record form prefill and validation; delete action hidden after 7 days; month navigator cannot pass the current month.
- [ ] Flow: from a trainee's detail record a payment, see it in the history and in the fee status for that month.
- [ ] Proofs: fee status (empty, typical mixed, heavy 60), record payment (prefilled, error), trainee detail with fees (none, several), attendance summary (empty, typical, heavy).

## Verification
As task-01.
