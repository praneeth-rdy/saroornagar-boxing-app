import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/models/trainee_status.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';
import 'package:saroornagar_boxing/features/fees/presentation/attendance_summary_screen.dart';
import 'package:saroornagar_boxing/features/fees/presentation/fee_status_screen.dart';
import 'package:saroornagar_boxing/features/fees/presentation/record_payment_screen.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';

import '../support/fixtures/fees.dart';
import '../support/fixtures/sessions.dart';
import '../support/fixtures/trainees.dart';
import '../support/mocks/mock_fee_repository.dart';
import '../support/mocks/mock_trainee_repository.dart';
import '../support/scenario.dart';
import 'proof_harness.dart';
import 'proof_support.dart';

// 28 on the fixture day, so the senior fee is preselected.
final _seniorTrainee = Trainee(
  id: 'trainee-senior',
  rollNo: 87,
  fullName: 'Rohit Verma',
  phone: '919876500001',
  dateOfBirth: DateTime(1998, 6, 2),
  joinedOn: DateTime(2026, 2, 1),
  status: TraineeStatus.active,
  createdAt: detailTrainee.createdAt,
  updatedAt: detailTrainee.updatedAt,
);

Future<void> _proof(
  WidgetTester tester,
  String name,
  Widget screen,
  MockFeeRepository fees, {
  Future<void> Function(WidgetTester tester)? interact,
}) async {
  final file = await renderProof(
    tester,
    name,
    routed(screen),
    size: tallProofSize,
    overrides: [
      feeRepositoryProvider.overrideWithValue(fees),
      traineeRepositoryProvider.overrideWithValue(
        MockTraineeRepository(
          trainees: [detailTrainee, bareTrainee, _seniorTrainee],
        ),
      ),
      clockProvider.overrideWithValue(proofClock),
    ],
    interact: interact,
  );
  expect(file.existsSync(), isTrue);
}

MockFeeRepository _statusRepository(int count) {
  final trainees = fixtureTraineeRows(count);
  return MockFeeRepository(
    trainees: trainees,
    payments: fixtureFeePayments(trainees),
    clock: proofClock,
  );
}

MockFeeRepository _summaryRepository(int count) {
  final trainees = fixtureTraineeRows(count);
  return MockFeeRepository(
    trainees: trainees,
    attendance: fixtureMonthAttendance(trainees, last: fixtureDay),
    sessionCounts: {DateTime(2026, 11): 4},
    clock: proofClock,
  );
}

void main() {
  testWidgets('fee status empty proof', (tester) async {
    await _proof(
      tester,
      'fee_status_empty',
      const FeeStatusScreen(),
      MockFeeRepository(scenario: MockScenario.empty, clock: proofClock),
    );
  });

  testWidgets('fee status mixed proof', (tester) async {
    await _proof(
      tester,
      'fee_status_mixed',
      const FeeStatusScreen(),
      _statusRepository(10),
    );
  });

  testWidgets('fee status heavy proof', (tester) async {
    await _proof(
      tester,
      'fee_status_heavy',
      const FeeStatusScreen(),
      _statusRepository(60),
    );
  });

  testWidgets('record payment prefilled proof', (tester) async {
    await _proof(
      tester,
      'record_payment_prefilled',
      RecordPaymentScreen(traineeId: _seniorTrainee.id),
      MockFeeRepository(
        trainees: [detailTrainee, bareTrainee, _seniorTrainee],
        clock: proofClock,
      ),
    );
  });

  testWidgets('record payment junior proof', (tester) async {
    await _proof(
      tester,
      'record_payment_junior',
      RecordPaymentScreen(traineeId: detailTrainee.id),
      MockFeeRepository(
        trainees: [detailTrainee, bareTrainee, _seniorTrainee],
        clock: proofClock,
      ),
    );
  });

  testWidgets('record payment note open proof', (tester) async {
    await _proof(
      tester,
      'record_payment_note_open',
      RecordPaymentScreen(traineeId: _seniorTrainee.id),
      MockFeeRepository(
        trainees: [detailTrainee, bareTrainee, _seniorTrainee],
        clock: proofClock,
      ),
      interact: (tester) async {
        await tester.tap(find.text('Add a note'));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('record payment error proof', (tester) async {
    final fees = MockFeeRepository(
      trainees: [detailTrainee, bareTrainee, _seniorTrainee],
      clock: proofClock,
    );
    await _proof(
      tester,
      'record_payment_error',
      RecordPaymentScreen(traineeId: detailTrainee.id),
      fees,
      interact: (tester) async {
        fees.scenario = MockScenario.permissionDenied;
        await tester.tap(find.byType(PrimaryButton));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('attendance summary empty proof', (tester) async {
    await _proof(
      tester,
      'attendance_summary_empty',
      const AttendanceSummaryScreen(),
      MockFeeRepository(trainees: fixtureTraineeRows(2), clock: proofClock),
    );
  });

  testWidgets('attendance summary typical proof', (tester) async {
    await _proof(
      tester,
      'attendance_summary_typical',
      const AttendanceSummaryScreen(),
      _summaryRepository(8),
    );
  });

  testWidgets('attendance summary heavy proof', (tester) async {
    await _proof(
      tester,
      'attendance_summary_heavy',
      const AttendanceSummaryScreen(),
      _summaryRepository(60),
    );
  });
}
