import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/payment_method.dart';
import '../../../core/supabase/supabase_errors.dart';
import '../../../core/utils/india_date.dart';
import '../domain/attendance_summary_row.dart';
import '../domain/fee_payment.dart';
import '../domain/fee_status.dart';
import 'fee_repository.dart';

class SupabaseFeeRepository implements FeeRepository {
  SupabaseFeeRepository(this.client);

  final SupabaseClient client;

  @override
  Future<FeePayment> record({
    required String traineeId,
    required int amount,
    required PaymentMethod method,
    required DateTime paidOn,
    required DateTime periodMonth,
    String? note,
  }) => guardSupabase(
    () async => FeePayment.fromJson(
      _row(
        await client.rpc<dynamic>(
          'record_fee_payment',
          params: {
            'p_trainee_id': traineeId,
            'p_amount': amount,
            // Null lets the server answer an unknown method with its own message.
            'p_method': method == PaymentMethod.unknown ? null : method.wire,
            'p_paid_on': wireDate(paidOn),
            'p_period_month': wireDate(periodMonth),
            'p_note': note,
          },
        ),
      ),
    ),
  );

  @override
  Future<void> delete(String paymentId) => guardSupabase(() async {
    await client.rpc<dynamic>(
      'delete_fee_payment',
      params: {'p_payment_id': paymentId},
    );
  });

  @override
  Future<List<FeePayment>> history(String traineeId) => guardSupabase(
    () async => _rows(
      await client.rpc<dynamic>(
        'trainee_fee_history',
        params: {'p_trainee_id': traineeId},
      ),
    ).map(FeePayment.fromJson).toList(),
  );

  @override
  Future<List<FeeStatus>> statusFor(DateTime month) => guardSupabase(
    () async => _rows(
      await client.rpc<dynamic>(
        'fee_status_list',
        params: {'p_month': wireDate(month)},
      ),
    ).map(FeeStatus.fromJson).toList(),
  );

  @override
  Future<List<AttendanceSummaryRow>> attendanceSummary(DateTime month) =>
      guardSupabase(
        () async => _rows(
          await client.rpc<dynamic>(
            'monthly_attendance_summary',
            params: {'p_month': wireDate(month)},
          ),
        ).map(AttendanceSummaryRow.fromJson).toList(),
      );
}

// A set-returning function comes back as a JSON array of row objects.
List<Map<String, dynamic>> _rows(dynamic result) => [
  for (final row in result as List) Map<String, dynamic>.from(row as Map),
];

// A function returning one composite row comes back as a single JSON object.
Map<String, dynamic> _row(dynamic result) =>
    Map<String, dynamic>.from(result as Map);
