import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/router/routes.dart';
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
  testWidgets('lists classes attended per row and no session total', (
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
    expect(find.textContaining('sessions this month'), findsNothing);
    expect(find.textContaining('/24'), findsNothing);
    expect(find.textContaining('absent'), findsNothing);
    for (final row in rows) {
      expect(find.text('${row.presentCount} classes attended'), findsWidgets);
    }
  });

  testWidgets('tapping a student pushes their history for the month', (
    tester,
  ) async {
    final trainees = fixtureTraineeRows(2);
    final repository = MockFeeRepository(
      trainees: trainees,
      attendance: fixtureMonthAttendance(trainees, last: DateTime(2026, 11, 5)),
      clock: () => _clock,
    );
    final rows = await repository.attendanceSummary(DateTime(2026, 11));
    final pushed = <String>[];
    tester.view.physicalSize = const Size(1600, 3000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      overrides: [
        feeRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => _clock),
      ],
      home: const AttendanceSummaryScreen(),
      routes: [
        GoRoute(
          path: Routes.traineeHistory,
          builder: (_, state) {
            pushed.add(state.uri.toString());
            return const Text('History');
          },
        ),
      ],
    );

    await tester.tap(find.text(rows.first.fullName));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(pushed, [
      Routes.traineeHistoryOf(rows.first.traineeId, month: DateTime(2026, 11)),
    ]);
    expect(pushed.single, endsWith('?month=2026-11-01'));
  });

  testWidgets('no sessions in the month shows its empty state', (tester) async {
    await _pump(
      tester,
      MockFeeRepository(trainees: fixtureTraineeRows(2), clock: () => _clock),
    );
    expect(find.text('No sessions this month'), findsOneWidget);
    expect(find.text('Previous month'), findsWidgets);
  });

  testWidgets('no active students shows its empty state', (tester) async {
    await _pump(
      tester,
      MockFeeRepository(scenario: MockScenario.empty, clock: () => _clock),
    );
    expect(find.text('No active students'), findsOneWidget);
    expect(find.text('Go to Students'), findsOneWidget);
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
