import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';
import 'package:saroornagar_boxing/features/trials/presentation/trials_screen.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/fixtures/trials.dart';
import '../../../support/mocks/mock_device_key_store.dart';
import '../../../support/mocks/mock_trial_repository.dart';
import '../../../support/scenario.dart';

DateTime _clock() => DateTime.utc(2026, 11, 5, 7);

Future<void> _pump(WidgetTester tester, MockTrialRepository repository) {
  tester.view.physicalSize = const Size(1600, 4000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  return pumpApp(
    tester,
    overrides: [
      trialRepositoryProvider.overrideWithValue(repository),
      deviceKeyStoreProvider.overrideWithValue(MockDeviceKeyStore()),
      clockProvider.overrideWithValue(_clock),
    ],
    home: const TrialsScreen(),
  );
}

void main() {
  testWidgets('empty window shows the empty state with an action', (
    tester,
  ) async {
    await _pump(tester, MockTrialRepository(clock: _clock));

    expect(find.text('No trials booked'), findsOneWidget);
    expect(
      find.text('Bookings made in the app appear here for the next 30 days.'),
      findsOneWidget,
    );
    expect(find.text('Book for someone'), findsNWidgets(2));
  });

  testWidgets('groups bookings by day with TODAY and details', (tester) async {
    await _pump(
      tester,
      MockTrialRepository(
        clock: _clock,
        bookings: [
          ...fixtureTrials(DateTime(2026, 11, 5)),
          ...fixtureTrials(DateTime(2026, 11, 7)).take(1),
          ...fixtureTrials(DateTime(2026, 12, 30)),
        ],
      ),
    );

    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('SATURDAY 7 NOVEMBER'), findsOneWidget);
    expect(find.text('Rahul Verma'), findsNWidgets(2));
    expect(find.text('Faisal Ahmed'), findsOneWidget);
    expect(
      find.textContaining('Morning · +91 98765 43210\nAge 14'),
      findsNWidgets(2),
    );
    expect(
      find.textContaining('Has done some kickboxing before'),
      findsWidgets,
    );
    expect(find.textContaining('Born 5 Mar 2012'), findsOneWidget);
    expect(find.textContaining('Evening · +91 97000 00003'), findsOneWidget);
    // Beyond the 30 day window.
    expect(find.textContaining('DECEMBER'), findsNothing);
  });

  testWidgets('an error offers a retry', (tester) async {
    await _pump(
      tester,
      MockTrialRepository(clock: _clock, scenario: MockScenario.error),
    );

    expect(find.text('Try again'), findsOneWidget);
  });
}
