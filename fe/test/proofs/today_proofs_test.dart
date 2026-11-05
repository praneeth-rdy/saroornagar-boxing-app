import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_screen.dart';

import '../support/fixtures/roster.dart';
import '../support/fixtures/sessions.dart';
import '../support/fixtures/trials.dart';
import '../support/mocks/mock_attendance_repository.dart';
import '../support/scenario.dart';
import 'proof_harness.dart';
import 'proof_support.dart';

final _morningId = morningSession(fixtureDay).id;

Future<void> _proof(
  WidgetTester tester,
  String name,
  MockAttendanceRepository repository, {
  DateTime Function() clock = proofClock,
  Future<void> Function(WidgetTester tester)? interact,
}) async {
  final file = await renderProof(
    tester,
    name,
    routed(const TodayScreen()),
    size: tallProofSize,
    overrides: [
      attendanceRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(clock),
    ],
    interact: interact,
  );
  expect(file.existsSync(), isTrue);
}

void main() {
  testWidgets('today no trainees proof', (tester) async {
    await _proof(
      tester,
      'today_no_trainees',
      MockAttendanceRepository(trainees: const []),
    );
  });

  testWidgets('today typical proof', (tester) async {
    await _proof(
      tester,
      'today_typical',
      MockAttendanceRepository(
        trainees: typicalTrainees,
        marks: fixtureMarks(_morningId, typicalTrainees, present: 14),
        trials: fixtureTrials(fixtureDay).take(2).toList(),
      ),
    );
  });

  testWidgets('today heavy proof', (tester) async {
    await _proof(
      tester,
      'today_heavy',
      MockAttendanceRepository(
        trainees: heavyTrainees,
        marks: fixtureMarks(_morningId, heavyTrainees, present: 30),
        trials: fixtureTrials(fixtureDay),
      ),
    );
  });

  testWidgets('today sunday proof', (tester) async {
    await _proof(
      tester,
      'today_sunday',
      MockAttendanceRepository(),
      clock: proofSundayClock,
    );
  });

  testWidgets('today extra session sheet proof', (tester) async {
    await _proof(
      tester,
      'today_extra_session_sheet',
      MockAttendanceRepository(),
      clock: proofSundayClock,
      interact: (tester) async {
        await tester.tap(find.text('Add an extra session'));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('today mark error proof', (tester) async {
    final repository = MockAttendanceRepository(
      trainees: typicalTrainees,
      marks: fixtureMarks(_morningId, typicalTrainees, present: 4),
    );
    await _proof(
      tester,
      'today_mark_error',
      repository,
      interact: (tester) async {
        repository.scenario = MockScenario.offline;
        await tester.tap(find.byKey(const Key('present-trainee-006')));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('today reset dialog proof', (tester) async {
    await _proof(
      tester,
      'today_reset_dialog',
      MockAttendanceRepository(
        trainees: typicalTrainees,
        marks: fixtureMarks(_morningId, typicalTrainees, present: 14),
      ),
      interact: (tester) async {
        await tester.tap(find.text('Reset attendance'));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('today unmark dialog proof', (tester) async {
    await _proof(
      tester,
      'today_unmark_dialog',
      MockAttendanceRepository(
        trainees: typicalTrainees,
        marks: fixtureMarks(_morningId, typicalTrainees, present: 14),
      ),
      interact: (tester) async {
        await tester.tap(
          find.byKey(Key('present-${typicalTrainees.first.id}')),
        );
        await tester.pumpAndSettle();
      },
    );
  });
}
