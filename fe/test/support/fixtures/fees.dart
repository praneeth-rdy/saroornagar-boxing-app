import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/core/models/payment_method.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/features/fees/domain/fee_payment.dart';
import 'package:saroornagar_boxing/features/trainees/domain/attendance_record.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee.dart';

import 'sessions.dart';
import 'trainees.dart';

/// The month of the fixture day (Thu 2026-11-05).
final fixtureMonth = DateTime(fixtureDay.year, fixtureDay.month);

/// A payment recorded at [createdAt] (an instant; default the fixture day, 9:00 am India).
FeePayment fixturePayment({
  required String id,
  required String traineeId,
  int amount = 800,
  PaymentMethod method = PaymentMethod.cash,
  DateTime? paidOn,
  DateTime? periodMonth,
  String? note,
  DateTime? createdAt,
}) => FeePayment(
  id: id,
  traineeId: traineeId,
  amount: amount,
  method: method,
  paidOn: paidOn ?? fixtureDay,
  periodMonth: periodMonth ?? fixtureMonth,
  note: note,
  recordedBy: 'profile-admin',
  createdAt: createdAt ?? DateTime.utc(2026, 11, 5, 3, 30),
);

/// Payments for [month] that leave every third trainee unpaid, every fifth partly paid
/// and the rest paid in full (800 when the tier is unknown); cash and UPI alternate.
List<FeePayment> fixtureFeePayments(List<Trainee> trainees, {DateTime? month}) {
  final period = month ?? fixtureMonth;
  return [
    for (final (i, trainee) in trainees.indexed)
      if (i % 3 != 0)
        fixturePayment(
          id: 'payment-${trainee.id}',
          traineeId: trainee.id,
          amount: i % 5 == 1
              ? (trainee.feeTierOn(period) ?? 800) ~/ 2
              : trainee.feeTierOn(period) ?? 800,
          method: i.isEven ? PaymentMethod.cash : PaymentMethod.upi,
          paidOn: DateTime(period.year, period.month, 1 + i % 4),
          periodMonth: period,
          createdAt: DateTime.utc(period.year, period.month, 1 + i % 4, 4),
        ),
  ];
}

/// [detailTrainee]'s payments over four months: November (two days old, so removable,
/// with a note), October in two parts, September by UPI, all older ones locked.
final detailTraineePayments = [
  fixturePayment(
    id: 'payment-detail-nov',
    traineeId: detailTrainee.id,
    amount: 500,
    paidOn: DateTime(2026, 11, 3),
    periodMonth: DateTime(2026, 11),
    note: 'Paid by his father at the evening batch.',
    createdAt: DateTime.utc(2026, 11, 3, 13),
  ),
  fixturePayment(
    id: 'payment-detail-oct-2',
    traineeId: detailTrainee.id,
    amount: 300,
    method: PaymentMethod.upi,
    paidOn: DateTime(2026, 10, 20),
    periodMonth: DateTime(2026, 10),
    createdAt: DateTime.utc(2026, 10, 20, 12),
  ),
  fixturePayment(
    id: 'payment-detail-oct-1',
    traineeId: detailTrainee.id,
    amount: 200,
    paidOn: DateTime(2026, 10, 6),
    periodMonth: DateTime(2026, 10),
    createdAt: DateTime.utc(2026, 10, 6, 1),
  ),
  fixturePayment(
    id: 'payment-detail-sep',
    traineeId: detailTrainee.id,
    amount: 500,
    method: PaymentMethod.upi,
    paidOn: DateTime(2026, 9, 2),
    periodMonth: DateTime(2026, 9),
    createdAt: DateTime.utc(2026, 9, 2, 2),
  ),
];

/// Morning marks for [trainees] on every non-Sunday of [month] up to [last] (default the
/// month's end); each trainee misses a few sessions and some are left unmarked.
Map<String, List<AttendanceRecord>> fixtureMonthAttendance(
  List<Trainee> trainees, {
  DateTime? month,
  DateTime? last,
}) {
  final first = month ?? fixtureMonth;
  final end = last ?? DateTime(first.year, first.month + 1, 0);
  final days = [
    for (var day = 1; day <= end.day; day++)
      if (DateTime(first.year, first.month, day).weekday != DateTime.sunday)
        DateTime(first.year, first.month, day),
  ];
  return {
    for (final (i, trainee) in trainees.indexed)
      trainee.id: [
        for (final (n, date) in days.indexed)
          if (i == 0 || (n + i) % 7 != 0)
            AttendanceRecord(
              sessionId: regularSessionId(date, SessionSlot.morning),
              sessionDate: date,
              slot: SessionSlot.morning,
              status: (n + i) % (3 + i % 4) == 0
                  ? AttendanceStatus.absent
                  : AttendanceStatus.present,
              markedAt: DateTime.utc(date.year, date.month, date.day, 0, 32),
            ),
      ],
  };
}
