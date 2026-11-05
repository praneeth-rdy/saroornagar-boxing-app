import '../../../core/models/payment_method.dart';
import '../domain/attendance_summary_row.dart';
import '../domain/fee_payment.dart';
import '../domain/fee_status.dart';

/// Fee payments and the monthly reports; failures surface as `AppException`s.
abstract class FeeRepository {
  /// [periodMonth] must be the first day of a month.
  Future<FeePayment> record({
    required String traineeId,
    required int amount,
    required PaymentMethod method,
    required DateTime paidOn,
    required DateTime periodMonth,
    String? note,
  });

  /// Removes a payment up to 7 days after it was recorded.
  Future<void> delete(String paymentId);

  /// The trainee's payments, newest period first.
  Future<List<FeePayment>> history(String traineeId);

  /// Every active trainee's position for [month] (a first of the month), unpaid first.
  Future<List<FeeStatus>> statusFor(DateTime month);

  /// Every active trainee's marks for [month] (a first of the month), by name.
  Future<List<AttendanceSummaryRow>> attendanceSummary(DateTime month);
}
