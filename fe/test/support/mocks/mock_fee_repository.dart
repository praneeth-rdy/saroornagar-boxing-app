import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/core/models/payment_method.dart';
import 'package:saroornagar_boxing/core/utils/india_date.dart';
import 'package:saroornagar_boxing/features/fees/data/fee_repository.dart';
import 'package:saroornagar_boxing/features/fees/domain/attendance_summary_row.dart';
import 'package:saroornagar_boxing/features/fees/domain/fee_payment.dart';
import 'package:saroornagar_boxing/features/fees/domain/fee_status.dart';
import 'package:saroornagar_boxing/features/trainees/domain/attendance_record.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee.dart';

import '../scenario.dart';

// India has no daylight saving; turns the India wall clock back into an instant.
const _indiaOffset = Duration(hours: 5, minutes: 30);

/// The id of the signed-in staff member the mock stores as `recorded_by`.
const mockRecorderId = 'profile-mock-recorder';

/// In-memory [FeeRepository] that follows `20261105080602_fees_reports`: the same order of
/// checks, the same messages, the 7-day delete window and the unpaid-first order.
class MockFeeRepository implements FeeRepository {
  MockFeeRepository({
    this.scenario = MockScenario.success,
    List<Trainee> trainees = const [],
    List<FeePayment> payments = const [],
    Map<String, List<AttendanceRecord>> attendance = const {},
    Map<DateTime, int> sessionCounts = const {},
    DateTime Function()? clock,
  }) : clock = clock ?? indiaNow,
       _sessionCounts = {
         for (final entry in sessionCounts.entries)
           _monthKey(entry.key): entry.value,
       } {
    for (final trainee in trainees) {
      _trainees[trainee.id] = trainee;
    }
    _payments.addAll(payments);
    attendance.forEach((id, records) => _attendance[id] = [...records]);
  }

  MockScenario scenario;

  /// India wall-clock time, as `clockProvider`; decides today and the delete window.
  final DateTime Function() clock;

  final _trainees = <String, Trainee>{};
  final _payments = <FeePayment>[];
  final _attendance = <String, List<AttendanceRecord>>{};
  final Map<String, int> _sessionCounts;
  var _createdCount = 0;

  /// Every stored payment, oldest first, for assertions.
  List<FeePayment> get stored => List.unmodifiable(_payments);

  /// Adds or replaces a trainee, as the trainee repository would after a save.
  void putTrainee(Trainee trainee) => _trainees[trainee.id] = trainee;

  @override
  Future<FeePayment> record({
    required String traineeId,
    required int amount,
    required PaymentMethod method,
    required DateTime paidOn,
    required DateTime periodMonth,
    String? note,
  }) => applyScenario(
    scenario,
    success: () {
      _trainee(traineeId);
      final today = dateOnly(clock());
      if (dateOnly(paidOn).isAfter(today)) {
        throw const ValidationException(
          'The payment date cannot be in the future',
        );
      }
      if (periodMonth.day != 1) {
        throw const ValidationException('Period must be a month');
      }
      if (amount < 1 || amount > 100000) {
        throw const ValidationException('Enter an amount between 1 and 100000');
      }
      if (method == PaymentMethod.unknown) {
        throw const ValidationException('Choose cash or UPI');
      }
      final trimmed = note?.trim() ?? '';
      final cleanNote = trimmed.isEmpty ? null : trimmed;
      if (cleanNote != null && cleanNote.runes.length > 300) {
        throw const ValidationException(
          'Keep the note to 300 characters or fewer',
        );
      }
      _createdCount++;
      final payment = FeePayment(
        id: 'payment-new-$_createdCount',
        traineeId: traineeId,
        amount: amount,
        method: method,
        paidOn: dateOnly(paidOn),
        periodMonth: dateOnly(periodMonth),
        note: cleanNote,
        recordedBy: mockRecorderId,
        createdAt: clock().subtract(_indiaOffset),
      );
      _payments.add(payment);
      return payment;
    },
  );

  @override
  Future<void> delete(String paymentId) => applyScenario(
    scenario,
    success: () {
      final index = _payments.indexWhere((payment) => payment.id == paymentId);
      if (index < 0) throw const NotFoundException('Payment not found');
      if (!_payments[index].canDeleteAt(clock())) {
        throw const ValidationException(
          'Payments older than 7 days cannot be removed',
        );
      }
      _payments.removeAt(index);
    },
  );

  @override
  Future<List<FeePayment>> history(String traineeId) => applyScenario(
    scenario,
    success: () {
      _trainee(traineeId);
      return _payments
          .where((payment) => payment.traineeId == traineeId)
          .toList()
        ..sort(_newestFirst);
    },
    empty: () => const [],
  );

  @override
  Future<List<FeeStatus>> statusFor(DateTime month) => applyScenario(
    scenario,
    success: () {
      _checkMonth(month);
      final first = dateOnly(month);
      final statuses = [
        for (final trainee in _activeTrainees()) _statusOf(trainee, first),
      ];
      // Unpaid first, then by name, as fee_status_list orders.
      return statuses..sort((a, b) {
        if (a.isPaid != b.isPaid) return a.isPaid ? 1 : -1;
        return _compareNames(a.fullName, a.traineeId, b.fullName, b.traineeId);
      });
    },
    empty: () => const [],
  );

  @override
  Future<List<AttendanceSummaryRow>> attendanceSummary(DateTime month) =>
      applyScenario(
        scenario,
        success: () {
          _checkMonth(month);
          final first = dateOnly(month);
          final sessions = _sessionCountFor(first);
          return [
            for (final trainee in _activeTrainees())
              _summaryOf(trainee, first, sessions),
          ];
        },
        empty: () => const [],
      );

  Trainee _trainee(String id) {
    final trainee = _trainees[id];
    if (trainee == null) throw const NotFoundException('Student not found');
    return trainee;
  }

  List<Trainee> _activeTrainees() =>
      _trainees.values.where((trainee) => trainee.isActive).toList()
        ..sort((a, b) => _compareNames(a.fullName, a.id, b.fullName, b.id));

  FeeStatus _statusOf(Trainee trainee, DateTime month) {
    final paid = _payments.where(
      (payment) =>
          payment.traineeId == trainee.id &&
          _isSameMonth(payment.periodMonth, month),
    );
    DateTime? lastPaidOn;
    for (final payment in paid) {
      if (lastPaidOn == null || payment.paidOn.isAfter(lastPaidOn)) {
        lastPaidOn = payment.paidOn;
      }
    }
    return FeeStatus(
      traineeId: trainee.id,
      fullName: trainee.fullName,
      photoPath: trainee.photoPath,
      tierAmount: trainee.feeTierOn(month),
      paidAmount: paid.fold(0, (sum, payment) => sum + payment.amount),
      lastPaidOn: lastPaidOn,
    );
  }

  AttendanceSummaryRow _summaryOf(
    Trainee trainee,
    DateTime month,
    int sessions,
  ) {
    final records = _inMonth(_attendance[trainee.id] ?? const [], month);
    return AttendanceSummaryRow(
      traineeId: trainee.id,
      fullName: trainee.fullName,
      photoPath: trainee.photoPath,
      presentCount: records
          .where((record) => record.status == AttendanceStatus.present)
          .length,
      absentCount: records
          .where((record) => record.status == AttendanceStatus.absent)
          .length,
      sessionCount: sessions,
    );
  }

  // Without a seeded count, the distinct sessions anyone was marked in stand in.
  int _sessionCountFor(DateTime month) =>
      _sessionCounts[_monthKey(month)] ??
      {
        for (final records in _attendance.values)
          for (final record in _inMonth(records, month)) record.sessionId,
      }.length;
}

List<AttendanceRecord> _inMonth(
  List<AttendanceRecord> records,
  DateTime month,
) => [
  for (final record in records)
    if (_isSameMonth(record.sessionDate, month)) record,
];

bool _isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

void _checkMonth(DateTime month) {
  if (month.day != 1) {
    throw const ValidationException('Period must be a month');
  }
}

String _monthKey(DateTime month) => wireDate(DateTime(month.year, month.month));

// lower(full_name), then id, as the server orders.
int _compareNames(String nameA, String idA, String nameB, String idB) {
  final byName = nameA.toLowerCase().compareTo(nameB.toLowerCase());
  return byName != 0 ? byName : idA.compareTo(idB);
}

// period_month desc, paid_on desc, created_at desc, id, as trainee_fee_history orders.
int _newestFirst(FeePayment a, FeePayment b) {
  final byPeriod = b.periodMonth.compareTo(a.periodMonth);
  if (byPeriod != 0) return byPeriod;
  final byPaidOn = b.paidOn.compareTo(a.paidOn);
  if (byPaidOn != 0) return byPaidOn;
  final byCreated = b.createdAt.compareTo(a.createdAt);
  return byCreated != 0 ? byCreated : a.id.compareTo(b.id);
}
