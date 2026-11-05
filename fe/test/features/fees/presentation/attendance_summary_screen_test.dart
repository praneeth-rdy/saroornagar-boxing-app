import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/features/fees/presentation/attendance_summary_screen.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/fixtures/fees.dart';
import '../../../support/fixtures/trainees.dart';
import '../../../support/mocks/mock_fee_repository.dart';
import '../../../support/scenario.dart';

final _clock = DateTime.utc(2026, 11, 5, 7);

Future<void> _pump(WidgetTester tester, MockFeeRepository repository) {
  tester.view.physicalSize = const Size(1600, 3000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  return pumpApp(
    tester,
    overrides: [
      feeRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(() => _clock),
    ],
    home: const AttendanceSummaryScreen(),
  );
}

void main() {
  testWidgets('lists present and absent counts over the session count', (
    tester,
  ) async {
    final trainees = fixtureTraineeRows(3);
    final repository = MockFeeRepository(
      trainees: trainees,
      attendance: fixtureMonthAttendance(trainees, last: DateTime(2026, 11, 5)),
      sessionCounts: {DateTime(2026, 11): 24},
      clock: () => _clock,
    );
    final rows = await repository.attendanceSummary(DateTime(2026, 11));
    await _pump(tester, repository);

    expect(find.text('Monthly attendance'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('24 sessions this month'), findsOneWidget);
    final first = rows.first;
    expect(
      find.text('${first.presentCount} present · ${first.absentCount} absent'),
      findsWidgets,
    );
    expect(find.text('${first.presentCount}/24'), findsWidgets);
  });

  testWidgets('no sessions in the month shows its empty state', (tester) async {
    await _pump(
      tester,
      MockFeeRepository(trainees: fixtureTraineeRows(2), clock: () => _clock),
    );
    expect(find.text('No sessions this month'), findsOneWidget);
    expect(find.text('Previous month'), findsWidgets);
  });

  testWidgets('no active trainees shows its empty state', (tester) async {
    await _pump(
      tester,
      MockFeeRepository(scenario: MockScenario.empty, clock: () => _clock),
    );
    expect(find.text('No active trainees'), findsOneWidget);
    expect(find.text('Go to Trainees'), findsOneWidget);
  });

  testWidgets('next month is disabled on the current month', (tester) async {
    await _pump(
      tester,
      MockFeeRepository(trainees: fixtureTraineeRows(1), clock: () => _clock),
    );
    final next = tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Next month'),
        matching: find.byType(IconButton),
      ),
    );
    expect(next.onPressed, isNull);
  });
}
