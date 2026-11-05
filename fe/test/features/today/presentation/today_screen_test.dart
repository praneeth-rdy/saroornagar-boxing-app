import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/core/theme/app_theme.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_screen.dart';

import '../../../support/fixtures/roster.dart';
import '../../../support/fixtures/sessions.dart';
import '../../../support/fixtures/trials.dart';
import '../../../support/mocks/mock_attendance_repository.dart';
import '../../../support/scenario.dart';

final _morningId = morningSession(fixtureDay).id;
final _morningClock = DateTime.utc(2026, 11, 5, 7);
final _eveningClock = DateTime.utc(2026, 11, 5, 16, 45);
final _previousDay = DateTime(2026, 11, 4);

Future<void> _pump(
  WidgetTester tester,
  MockAttendanceRepository repository, {
  DateTime? clock,
}) async {
  tester.view.physicalSize = const Size(1600, 3000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        attendanceRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => clock ?? _morningClock),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: const TodayScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('marking a trainee updates the progress count', (tester) async {
    final repository = MockAttendanceRepository(trainees: fixtureTrainees(4));
    await _pump(tester, repository);

    expect(find.text('0 of 4'), findsOneWidget);
    expect(find.text('Mark the remaining 4 absent'), findsOneWidget);

    await tester.tap(find.byKey(const Key('present-trainee-001')));
    await tester.pumpAndSettle();

    expect(find.text('1 of 4'), findsOneWidget);
    expect(find.text('3 to go'), findsOneWidget);
    expect(
      repository.markFor(_morningId, 'trainee-001')!.status.name,
      'present',
    );
  });

  testWidgets('a failed mark rolls back and shows a banner', (tester) async {
    final repository = MockAttendanceRepository(trainees: fixtureTrainees(4));
    await _pump(tester, repository);

    repository.scenario = MockScenario.offline;
    await tester.tap(find.byKey(const Key('present-trainee-001')));
    await tester.pumpAndSettle();

    expect(find.text('0 of 4'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('the sticky button hides once everyone is marked', (
    tester,
  ) async {
    final trainees = fixtureTrainees(3);
    final repository = MockAttendanceRepository(
      trainees: trainees,
      marks: fixtureMarks(_morningId, trainees, present: 2),
    );
    await _pump(tester, repository);

    expect(find.text('Mark the remaining 1 absent'), findsOneWidget);
    await tester.tap(find.byKey(Key('absent-${trainees[2].id}')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Mark the remaining'), findsNothing);
    expect(find.text('Everyone marked'), findsOneWidget);
  });

  testWidgets('mark the remaining absent confirms then reports the count', (
    tester,
  ) async {
    final trainees = fixtureTrainees(5);
    final repository = MockAttendanceRepository(
      trainees: trainees,
      marks: fixtureMarks(_morningId, trainees, present: 2),
    );
    await _pump(tester, repository);

    await tester.tap(find.text('Mark the remaining 3 absent'));
    await tester.pumpAndSettle();
    expect(find.text('Mark 3 trainees absent?'), findsOneWidget);

    await tester.tap(find.text('Mark absent'));
    await tester.pumpAndSettle();

    expect(find.text('3 marked absent'), findsOneWidget);
    expect(find.text('Everyone marked'), findsOneWidget);
    expect(find.textContaining('Mark the remaining'), findsNothing);
  });

  testWidgets('a Sunday with no sessions shows the closed state', (
    tester,
  ) async {
    await _pump(
      tester,
      MockAttendanceRepository(),
      clock: DateTime.utc(2026, 11, 8, 7),
    );

    expect(find.text('Closed today'), findsOneWidget);
    expect(find.text('The club does not train on Sundays.'), findsOneWidget);
    expect(find.text('Add an extra session'), findsOneWidget);
  });

  testWidgets('an empty roster points to Trainees', (tester) async {
    await _pump(tester, MockAttendanceRepository(trainees: const []));

    expect(find.text('No active trainees'), findsOneWidget);
    expect(find.text('Go to Trainees'), findsOneWidget);
  });

  testWidgets('trial visitors show for the matching slot only', (tester) async {
    final repository = MockAttendanceRepository(
      trainees: fixtureTrainees(3),
      trials: fixtureTrials(fixtureDay),
    );
    await _pump(tester, repository);

    expect(find.text('TRIAL VISITORS'), findsOneWidget);
    expect(find.text('Rahul Verma'), findsOneWidget);
    expect(find.text('Priya Nair'), findsOneWidget);
    expect(find.text('Faisal Ahmed'), findsNothing);

    await tester.tap(find.text('Evening'));
    await tester.pumpAndSettle();

    expect(find.text('Faisal Ahmed'), findsOneWidget);
    expect(find.text('Rahul Verma'), findsNothing);
  });

  testWidgets('a mark after changing the date lands on that date\'s session', (
    tester,
  ) async {
    final repository = MockAttendanceRepository(trainees: fixtureTrainees(3));
    await _pump(tester, repository, clock: _eveningClock);
    final todayEveningId = eveningSession(fixtureDay).id;
    final previousEveningId = eveningSession(_previousDay).id;

    await tester.tap(find.byKey(const Key('present-trainee-001')));
    await tester.pumpAndSettle();
    expect(repository.markCalls.single.sessionId, todayEveningId);

    // The hosted database answers slowly enough for a frame to show the day loading.
    repository.scenario = MockScenario.slow;
    ProviderScope.containerOf(tester.element(find.byType(TodayScreen)))
        .read(selectedDateProvider.notifier)
        .select(_previousDay);
    await tester.pump();
    // Sessions, then the roster and trials, each wait one slow delay.
    await tester.pump(slowScenarioDelay * 3);
    repository.scenario = MockScenario.success;
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('present-trainee-001')));
    await tester.pumpAndSettle();

    expect(repository.markCalls, hasLength(2));
    expect(repository.markCalls.last.sessionId, previousEveningId);
    expect(
      repository.markFor(previousEveningId, 'trainee-001')!.status,
      AttendanceStatus.present,
    );
    expect(
      repository.markCalls.where((call) => call.sessionId == todayEveningId),
      hasLength(1),
    );
  });
}
