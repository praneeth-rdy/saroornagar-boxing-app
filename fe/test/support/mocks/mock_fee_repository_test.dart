import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/payment_method.dart';

import '../fixtures/fees.dart';
import '../fixtures/trainees.dart';
import '../scenario.dart';
import 'mock_fee_repository.dart';

final _now = DateTime.utc(2026, 11, 5, 7);

MockFeeRepository _repo({MockScenario scenario = MockScenario.success}) =>
    MockFeeRepository(
      scenario: scenario,
      trainees: [detailTrainee, bareTrainee],
      payments: [...detailTraineePayments],
      clock: () => _now,
    );

Future<void> _expectMessage(Future<Object?> call, String message) async {
  await expectLater(
    call,
    throwsA(isA<AppException>().having((e) => e.message, 'message', message)),
  );
}

Future<Object?> _record(
  MockFeeRepository repo, {
  String traineeId = 'trainee-detail',
  int amount = 500,
  PaymentMethod method = PaymentMethod.cash,
  DateTime? paidOn,
  DateTime? periodMonth,
  String? note,
}) => repo.record(
  traineeId: traineeId,
  amount: amount,
  method: method,
  paidOn: paidOn ?? DateTime(2026, 11, 5),
  periodMonth: periodMonth ?? DateTime(2026, 11),
  note: note,
);

void main() {
  group('record', () {
    test('stores a trimmed note and the India paid date', () async {
      final repo = _repo();
      final payment = await repo.record(
        traineeId: 'trainee-bare',
        amount: 500,
        method: PaymentMethod.upi,
        paidOn: DateTime(2026, 11, 5),
        periodMonth: DateTime(2026, 11),
        note: '  hello  ',
      );
      expect(payment.note, 'hello');
      expect(payment.method, PaymentMethod.upi);
      expect(repo.stored.last.id, payment.id);
    });

    test('a blank note is stored as null', () async {
      final payment = await _record(_repo(), note: '   ') as dynamic;
      expect(payment.note, isNull);
    });

    test('unknown trainee', () async {
      await _expectMessage(
        _record(_repo(), traineeId: 'nobody'),
        'Student not found',
      );
    });

    test('future paid date', () async {
      await _expectMessage(
        _record(_repo(), paidOn: DateTime(2026, 11, 6)),
        'The payment date cannot be in the future',
      );
    });

    test('period that is not a first of month', () async {
      await _expectMessage(
        _record(_repo(), periodMonth: DateTime(2026, 11, 2)),
        'Period must be a month',
      );
    });

    test('amount out of range', () async {
      await _expectMessage(
        _record(_repo(), amount: 0),
        'Enter an amount between 1 and 100000',
      );
      await _expectMessage(
        _record(_repo(), amount: 100001),
        'Enter an amount between 1 and 100000',
      );
    });

    test('unknown method', () async {
      await _expectMessage(
        _record(_repo(), method: PaymentMethod.unknown),
        'Choose cash or UPI',
      );
    });

    test('note over 300 characters', () async {
      await _expectMessage(
        _record(_repo(), note: 'x' * 301),
        'Keep the note to 300 characters or fewer',
      );
      expect(await _record(_repo(), note: 'x' * 300), isNotNull);
    });

    test('checks run in the server order', () async {
      // Trainee first, then date, period, amount.
      await _expectMessage(
        _record(
          _repo(),
          traineeId: 'nobody',
          amount: 0,
          paidOn: DateTime(2026, 11, 6),
        ),
        'Student not found',
      );
      await _expectMessage(
        _record(
          _repo(),
          amount: 0,
          paidOn: DateTime(2026, 11, 6),
          periodMonth: DateTime(2026, 11, 2),
        ),
        'The payment date cannot be in the future',
      );
    });
  });

  group('delete', () {
    test('removes a payment inside the window', () async {
      final repo = _repo();
      await repo.delete('payment-detail-nov');
      expect(repo.stored.any((p) => p.id == 'payment-detail-nov'), isFalse);
    });

    test('refuses a payment older than 7 days', () async {
      await _expectMessage(
        _repo().delete('payment-detail-sep'),
        'Payments older than 7 days cannot be removed',
      );
    });

    test('unknown payment', () async {
      await _expectMessage(_repo().delete('nope'), 'Payment not found');
    });
  });

  group('history', () {
    test('is newest period first, then paid date', () async {
      final history = await _repo().history('trainee-detail');
      expect(history.map((p) => p.id), [
        'payment-detail-nov',
        'payment-detail-oct-2',
        'payment-detail-oct-1',
        'payment-detail-sep',
      ]);
    });

    test('unknown trainee', () async {
      await _expectMessage(_repo().history('nobody'), 'Student not found');
    });
  });

  group('statusFor', () {
    test('sums the month and lists unpaid first, then by name', () async {
      final repo = _repo();
      final statuses = await repo.statusFor(DateTime(2026, 11));
      expect(statuses.map((s) => s.fullName), ['Kiran Rao', 'Arjun Reddy']);
      expect(statuses.first.isPaid, isFalse);
      expect(statuses.first.tierAmount, isNull);
      expect(statuses.last.paidAmount, 500);
      expect(statuses.last.tierAmount, 500);
      expect(statuses.last.lastPaidOn, DateTime(2026, 11, 3));

      final october = await repo.statusFor(DateTime(2026, 10));
      final arjun = october.firstWhere((s) => s.traineeId == 'trainee-detail');
      expect(arjun.paidAmount, 500);
      expect(arjun.lastPaidOn, DateTime(2026, 10, 20));
    });

    test('rejects a month that is not a first of month', () async {
      await _expectMessage(
        _repo().statusFor(DateTime(2026, 11, 3)),
        'Period must be a month',
      );
    });
  });

  group('scenarios', () {
    test('error, permission denied and offline are thrown', () async {
      await expectLater(
        _repo(scenario: MockScenario.error).statusFor(DateTime(2026, 11)),
        throwsA(isA<UnknownException>()),
      );
      await expectLater(
        _repo(scenario: MockScenario.permissionDenied)
            .history('trainee-detail'),
        throwsA(isA<PermissionException>()),
      );
      await expectLater(
        _repo(scenario: MockScenario.offline)
            .attendanceSummary(DateTime(2026, 11)),
        throwsA(isA<OfflineException>()),
      );
    });

    test('empty returns no rows', () async {
      final repo = _repo(scenario: MockScenario.empty);
      expect(await repo.statusFor(DateTime(2026, 11)), isEmpty);
      expect(await repo.attendanceSummary(DateTime(2026, 11)), isEmpty);
      expect(await repo.history('trainee-detail'), isEmpty);
    });
  });

  test(
    'attendanceSummary counts marks and uses the seeded session count',
    () async {
      final trainees = fixtureTraineeRows(3);
      final repo = MockFeeRepository(
        trainees: trainees,
        attendance: fixtureMonthAttendance(
          trainees,
          last: DateTime(2026, 11, 5),
        ),
        sessionCounts: {DateTime(2026, 11): 24},
        clock: () => _now,
      );
      final rows = await repo.attendanceSummary(DateTime(2026, 11));
      expect(rows, hasLength(3));
      expect(rows.every((r) => r.sessionCount == 24), isTrue);
      expect(rows.every((r) => r.presentCount + r.absentCount <= 4), isTrue);
      expect(rows.first.presentCount + rows.first.absentCount, 4);
      await _expectMessage(
        repo.attendanceSummary(DateTime(2026, 11, 2)),
        'Period must be a month',
      );
    },
  );
}
