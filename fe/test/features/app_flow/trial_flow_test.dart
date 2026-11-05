import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';

import '../../helpers/pump_app.dart';
import '../../support/mocks/mock_attendance_repository.dart';
import '../../support/mocks/mock_auth_repository.dart';
import '../../support/mocks/mock_device_key_store.dart';
import '../../support/mocks/mock_trial_repository.dart';

DateTime _clock() => DateTime.utc(2026, 11, 5, 7);

void main() {
  testWidgets(
    'a visitor books from sign-in, then staff see the booking in Trials',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 4000);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final auth = MockAuthRepository();
      addTearDown(auth.dispose);
      final trials = MockTrialRepository(clock: _clock);
      await pumpApp(
        tester,
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          attendanceRepositoryProvider.overrideWithValue(
            MockAttendanceRepository(),
          ),
          trialRepositoryProvider.overrideWithValue(trials),
          deviceKeyStoreProvider.overrideWithValue(MockDeviceKeyStore()),
          clockProvider.overrideWithValue(_clock),
        ],
      );

      expect(find.text('Staff and coaches only.'), findsOneWidget);
      await tester.tap(find.text('Want to try a session? Book a trial'));
      await tester.pumpAndSettle();
      expect(find.text('Try a session'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'Rahul Verma');
      await tester.enterText(find.byType(TextField).at(1), '9876543210');
      await tester.tap(find.text('Fri 6'));
      await tester.tap(find.text('Morning'));
      await tester.enterText(find.byType(TextField).at(2), '14');
      await tester.tap(find.text('Book trial'));
      await tester.pumpAndSettle();

      expect(find.text("You're booked"), findsOneWidget);
      expect(find.textContaining('Friday 6 November'), findsOneWidget);
      expect(
        find.textContaining('Morning batch (6:00 to 8:30 am)'),
        findsOneWidget,
      );

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Try a session'), findsOneWidget);
      expect(find.text('Your bookings'), findsOneWidget);

      // Staff signs in and sees the booking in the Trials tab.
      await tester.tap(find.text('Already train here? Sign in'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), '9000000001');
      await tester.enterText(find.byType(TextField).at(1), 'admin-local-1234');
      await tester.tap(find.text('Sign in').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trials').last);
      await tester.pumpAndSettle();

      expect(find.text('FRIDAY 6 NOVEMBER'), findsOneWidget);
      expect(find.text('Rahul Verma'), findsOneWidget);
    },
  );
}
