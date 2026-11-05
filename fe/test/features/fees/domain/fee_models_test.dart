import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/models/payment_method.dart';
import 'package:saroornagar_boxing/features/fees/domain/attendance_summary_row.dart';
import 'package:saroornagar_boxing/features/fees/domain/fee_payment.dart';
import 'package:saroornagar_boxing/features/fees/domain/fee_status.dart';

import '../../../support/fixtures/fees.dart';

FeeStatus _status({int? tier, int paid = 0}) => FeeStatus(
  traineeId: 't',
  fullName: 'Arjun Reddy',
  tierAmount: tier,
  paidAmount: paid,
);

void main() {
  group('FeeStatus', () {
    test('isPaid is true for any payment', () {
      expect(_status(tier: 1000).isPaid, isFalse);
      expect(_status(tier: 1000, paid: 1).isPaid, isTrue);
      expect(_status(paid: 500).isPaid, isTrue);
    });

    test('outstanding is the tier less the paid amount, floored at 0', () {
      expect(_status(tier: 1000).outstanding, 1000);
      expect(_status(tier: 1000, paid: 400).outstanding, 600);
      expect(_status(tier: 1000, paid: 1000).outstanding, 0);
      expect(_status(tier: 500, paid: 900).outstanding, 0);
    });

    test('outstanding is null without a tier', () {
      expect(_status(paid: 300).outstanding, isNull);
    });

    test('parses the function row', () {
      final status = FeeStatus.fromJson({
        'trainee_id': 'abc',
        'full_name': 'Sana Khan',
        'photo_path': null,
        'tier_amount': 500,
        'paid_amount': 200,
        'last_paid_on': '2026-11-03',
      });
      expect(status.tierAmount, 500);
      expect(status.paidAmount, 200);
      expect(status.lastPaidOn, DateTime(2026, 11, 3));
    });
  });

  group('FeePayment.canDeleteAt', () {
    // Created 2026-11-03 13:00 UTC, which is 18:30 in India.
    final payment = fixturePayment(
      id: 'p',
      traineeId: 't',
      createdAt: DateTime.utc(2026, 11, 3, 13),
    );
    final deadline = DateTime.utc(2026, 11, 10, 18, 30);

    test('is allowed just after recording', () {
      expect(payment.canDeleteAt(DateTime.utc(2026, 11, 3, 18, 30)), isTrue);
    });

    test('is allowed up to exactly 7 days after recording', () {
      expect(payment.canDeleteAt(deadline), isTrue);
      expect(
        payment.canDeleteAt(deadline.subtract(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('is refused one second past 7 days', () {
      expect(
        payment.canDeleteAt(deadline.add(const Duration(seconds: 1))),
        isFalse,
      );
    });
  });

  test('FeePayment round-trips through json', () {
    final payment = fixturePayment(
      id: 'p',
      traineeId: 't',
      method: PaymentMethod.upi,
      note: 'Late',
    );
    expect(FeePayment.fromJson(payment.toJson()), payment);
    expect(payment.toJson()['method'], 'upi');
  });

  test('paymentMethodLabel names each method', () {
    expect(paymentMethodLabel(PaymentMethod.cash), 'Cash');
    expect(paymentMethodLabel(PaymentMethod.upi), 'UPI');
    expect(paymentMethodLabel(PaymentMethod.unknown), 'Other');
  });

  test('AttendanceSummaryRow parses the function row', () {
    final row = AttendanceSummaryRow.fromJson({
      'trainee_id': 'abc',
      'full_name': 'Sana Khan',
      'photo_path': null,
      'present_count': 18,
      'absent_count': 3,
      'session_count': 24,
    });
    expect(row.presentCount, 18);
    expect(row.absentCount, 3);
    expect(row.sessionCount, 24);
  });
}
