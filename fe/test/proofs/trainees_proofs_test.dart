import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee.dart';
import 'package:saroornagar_boxing/features/trainees/domain/trainee_input.dart';
import 'package:saroornagar_boxing/features/trainees/presentation/attendance_history_screen.dart';
import 'package:saroornagar_boxing/features/trainees/presentation/trainee_detail_screen.dart';
import 'package:saroornagar_boxing/features/trainees/presentation/trainee_form_screen.dart';
import 'package:saroornagar_boxing/features/trainees/presentation/trainees_screen.dart';

import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/features/trainees/domain/attendance_record.dart';

import '../support/fixtures/fees.dart';
import '../support/fixtures/sessions.dart';
import '../support/fixtures/trainees.dart';
import '../support/mocks/mock_fee_repository.dart';
import '../support/mocks/mock_trainee_repository.dart';
import 'proof_harness.dart';
import 'proof_support.dart';

class _RejectingRepository extends MockTraineeRepository {
  @override
  Future<Trainee> create(TraineeInput input) =>
      Future.error(const ValidationException('Enter a valid date of birth'));
}

Future<void> _proof(
  WidgetTester tester,
  String name,
  Widget screen,
  MockTraineeRepository repository, {
  List<Trainee> feeTrainees = const [],
  Size size = tallProofSize,
  Future<void> Function(WidgetTester tester)? interact,
}) async {
  final file = await renderProof(
    tester,
    name,
    routed(screen),
    size: size,
    overrides: [
      traineeRepositoryProvider.overrideWithValue(repository),
      feeRepositoryProvider.overrideWithValue(
        MockFeeRepository(
          trainees: feeTrainees,
          payments: detailTraineePayments,
          clock: proofClock,
        ),
      ),
      clockProvider.overrideWithValue(proofClock),
    ],
    interact: interact,
  );
  expect(file.existsSync(), isTrue);
}

// Morning marks plus evening and extra present marks on the newest date, so one row
// reads "Morning, evening and extra 4:00 pm".
List<AttendanceRecord> _historyWithEvening({int days = 60}) {
  final records = fixtureAttendanceHistory(days: days);
  final first = records.first;
  return [
    first.copyWith(status: AttendanceStatus.present),
    AttendanceRecord(
      sessionId: regularSessionId(first.sessionDate, SessionSlot.evening),
      sessionDate: first.sessionDate,
      slot: SessionSlot.evening,
      status: AttendanceStatus.present,
      markedAt: first.markedAt.add(const Duration(hours: 10)),
      startsAt: '17:30:00',
      endsAt: '20:00:00',
    ),
    AttendanceRecord(
      sessionId: 'extra-${first.sessionDate.day}',
      sessionDate: first.sessionDate,
      slot: SessionSlot.extra,
      status: AttendanceStatus.present,
      markedAt: first.markedAt.add(const Duration(hours: 9)),
      startsAt: '16:00:00',
      endsAt: '17:00:00',
    ),
    ...records.skip(1),
  ];
}

void main() {
  testWidgets('trainees empty proof', (tester) async {
    await _proof(
      tester,
      'trainees_empty',
      const TraineesScreen(),
      MockTraineeRepository(),
    );
  });

  testWidgets('trainees typical proof', (tester) async {
    await _proof(
      tester,
      'trainees_typical',
      const TraineesScreen(),
      MockTraineeRepository(trainees: typicalTraineeRows),
    );
  });

  testWidgets('trainees heavy proof', (tester) async {
    await _proof(
      tester,
      'trainees_heavy',
      const TraineesScreen(),
      MockTraineeRepository(trainees: heavyTraineeRows),
    );
  });

  testWidgets('trainee detail bare proof', (tester) async {
    await _proof(
      tester,
      'trainee_detail_bare',
      TraineeDetailScreen(traineeId: bareTrainee.id),
      MockTraineeRepository(trainees: [bareTrainee]),
      feeTrainees: [bareTrainee],
    );
  });

  testWidgets('trainee detail typical proof', (tester) async {
    await _proof(
      tester,
      'trainee_detail_typical',
      TraineeDetailScreen(traineeId: detailTrainee.id),
      MockTraineeRepository(
        trainees: [detailTrainee],
        history: {detailTrainee.id: _historyWithEvening(days: 10)},
      ),
      feeTrainees: [detailTrainee],
    );
  });

  testWidgets('trainee detail heavy notes proof', (tester) async {
    await _proof(
      tester,
      'trainee_detail_heavy_notes',
      TraineeDetailScreen(traineeId: longNotesTrainee.id),
      MockTraineeRepository(
        trainees: [longNotesTrainee],
        history: {longNotesTrainee.id: fixtureAttendanceHistory()},
      ),
      feeTrainees: [longNotesTrainee],
    );
  });

  testWidgets('trainee form empty proof', (tester) async {
    await _proof(
      tester,
      'trainee_form_empty',
      const TraineeFormScreen(),
      MockTraineeRepository(),
    );
  });

  testWidgets('trainee form expanded proof', (tester) async {
    await _proof(
      tester,
      'trainee_form_expanded',
      const TraineeFormScreen(),
      MockTraineeRepository(),
      interact: (tester) async {
        await tester.ensureVisible(find.text('Add more details'));
        await tester.tap(find.text('Add more details'));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('trainee form server error proof', (tester) async {
    await _proof(
      tester,
      'trainee_form_error',
      const TraineeFormScreen(),
      _RejectingRepository(),
      interact: (tester) async {
        await tester.enterText(find.byType(TextField).at(0), 'Asha Rao');
        await tester.enterText(find.byType(TextField).at(1), '9876501234');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('attendance history empty proof', (tester) async {
    await _proof(
      tester,
      'attendance_history_empty',
      AttendanceHistoryScreen(traineeId: detailTrainee.id),
      MockTraineeRepository(trainees: [detailTrainee]),
    );
  });

  testWidgets('attendance history typical proof', (tester) async {
    await _proof(
      tester,
      'attendance_history_typical',
      AttendanceHistoryScreen(traineeId: detailTrainee.id),
      MockTraineeRepository(
        trainees: [detailTrainee],
        history: {detailTrainee.id: _historyWithEvening()},
      ),
    );
  });
}
