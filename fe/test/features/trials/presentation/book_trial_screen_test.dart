import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/models/session_slot.dart';
import 'package:saroornagar_boxing/core/router/routes.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';
import 'package:saroornagar_boxing/features/trials/domain/trial_booking.dart';
import 'package:saroornagar_boxing/features/trials/presentation/trial_booked_screen.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';
import 'package:saroornagar_boxing/features/trials/presentation/book_trial_screen.dart';
import 'package:saroornagar_boxing/features/trials/presentation/trial_providers.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/fixtures/trials.dart';
import '../../../support/mocks/mock_device_key_store.dart';
import '../../../support/mocks/mock_trial_repository.dart';

// Thursday 5 November 2026.
DateTime _clock() => DateTime.utc(2026, 11, 5, 7);

// The form needs a router for canPop and the booked screen.
Widget _router() {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const BookTrialScreen()),
      GoRoute(
        path: Routes.trialBooked,
        builder: (_, state) =>
            TrialBookedScreen(booking: state.extra! as TrialBooking),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (_, _) => const Text('Sign in page'),
      ),
    ],
  );
  addTearDown(router.dispose);
  return Router(
    routeInformationProvider: router.routeInformationProvider,
    routeInformationParser: router.routeInformationParser,
    routerDelegate: router.routerDelegate,
    backButtonDispatcher: RootBackButtonDispatcher(),
  );
}

Future<void> _pump(WidgetTester tester, MockTrialRepository repository) {
  tester.view.physicalSize = const Size(1600, 4000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  return pumpApp(
    tester,
    home: _router(),
    overrides: [
      trialRepositoryProvider.overrideWithValue(repository),
      deviceKeyStoreProvider.overrideWithValue(MockDeviceKeyStore()),
      clockProvider.overrideWithValue(_clock),
    ],
  );
}

Future<void> _fillValid(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'Rahul Verma');
  await tester.enterText(find.byType(TextField).at(1), '9876543210');
  await tester.tap(find.text('Fri 6'));
  await tester.tap(find.text('Morning'));
  await tester.enterText(find.byType(TextField).at(2), '14');
  await tester.pump();
}

void main() {
  testWidgets('shows the new subtitle and hint-only age and note fields', (
    tester,
  ) async {
    await _pump(tester, MockTrialRepository(clock: _clock));

    expect(
      find.text('Pick a day and a batch. The coach will expect you.'),
      findsOneWidget,
    );
    expect(find.text('Age in years'), findsOneWidget);
    expect(find.text('Anything the coach should know'), findsOneWidget);
    expect(find.text('Age'), findsNothing);
    expect(find.text('Note'), findsNothing);
    expect(find.text('Name *'), findsOneWidget);
    expect(find.text('Phone *'), findsOneWidget);
  });

  test('trialDaysFrom skips Sundays and returns seven days', () {
    final days = trialDaysFrom(DateTime(2026, 11, 5));

    expect(days, hasLength(7));
    expect(days.every((d) => d.weekday != DateTime.sunday), isTrue);
    expect(days.first, DateTime(2026, 11, 5));
    expect(days.last, DateTime(2026, 11, 12));
  });

  testWidgets('day chips start today and skip Sunday', (tester) async {
    await _pump(tester, MockTrialRepository(clock: _clock));

    for (final label in ['Thu 5', 'Fri 6', 'Sat 7', 'Mon 9', 'Thu 12']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Sun 8'), findsNothing);
    expect(find.text('6:00 to 8:30 am'), findsOneWidget);
    expect(find.text('5:30 to 8:00 pm'), findsOneWidget);
    expect(find.text('Your bookings'), findsNothing);
  });

  testWidgets('empty submit shows field errors and books nothing', (
    tester,
  ) async {
    final repository = MockTrialRepository(clock: _clock);
    await _pump(tester, repository);

    await tester.tap(find.text('Book trial'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your name'), findsOneWidget);
    expect(find.text('Pick a day'), findsOneWidget);
    expect(find.text('Pick the morning or the evening batch'), findsOneWidget);
    expect(find.text('Tell us your age or date of birth'), findsOneWidget);
    expect(repository.stored, isEmpty);
  });

  testWidgets('age outside 3 to 99 is rejected on the form', (tester) async {
    await _pump(tester, MockTrialRepository(clock: _clock));
    await _fillValid(tester);
    await tester.enterText(find.byType(TextField).at(2), '2');
    await tester.tap(find.text('Book trial'));
    await tester.pumpAndSettle();

    expect(find.text('Enter an age between 3 and 99'), findsOneWidget);
  });

  testWidgets(
    'swapping to date of birth replaces the age field and requires one',
    (tester) async {
      final repository = MockTrialRepository(clock: _clock);
      await _pump(tester, repository);
      await _fillValid(tester);

      await tester.tap(find.text('Use date of birth instead'));
      await tester.pumpAndSettle();
      // Name, phone and note remain; the age field is gone.
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Choose a date'), findsOneWidget);
      expect(find.text('Use age instead'), findsOneWidget);

      await tester.tap(find.text('Book trial'));
      await tester.pumpAndSettle();
      expect(find.text('Tell us your age or date of birth'), findsOneWidget);
      expect(repository.stored, isEmpty);

      await tester.tap(find.text('Use age instead'));
      await tester.pumpAndSettle();
      final age = tester.widget<TextField>(find.byType(TextField).at(2));
      expect(age.controller!.text, isEmpty);
    },
  );

  testWidgets('a date of birth satisfies the requirement', (tester) async {
    final repository = MockTrialRepository(clock: _clock);
    await _pump(tester, repository);
    await _fillValid(tester);
    await tester.tap(find.text('Use date of birth instead'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choose a date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book trial'));
    await tester.pumpAndSettle();

    expect(repository.stored.single.dateOfBirth, isNotNull);
    expect(repository.stored.single.age, isNull);
  });

  testWidgets('a duplicate booking shows the server message', (tester) async {
    final repository = MockTrialRepository(
      clock: _clock,
      myBookings: [
        fixtureTrials(DateTime(2026, 11, 6)).first
            .copyWith(phone: '919876543210'),
      ],
    );
    await _pump(tester, repository);
    await _fillValid(tester);

    await tester.tap(find.text('Book trial'));
    await tester.pumpAndSettle();

    expect(
      find.text('This number already has a trial booked for that batch'),
      findsOneWidget,
    );
    expect(repository.stored, hasLength(1));
  });

  testWidgets('success books once and opens the booked screen', (tester) async {
    final repository = MockTrialRepository(clock: _clock);
    await _pump(tester, repository);
    await _fillValid(tester);

    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    final booking = repository.stored.single;
    expect(booking.slot, SessionSlot.morning);
    expect(booking.sessionDate, DateTime(2026, 11, 6));
    expect(booking.age, 14);
    expect(find.text("You're booked"), findsOneWidget);
  });

  testWidgets('upcoming bookings of this device appear under the title', (
    tester,
  ) async {
    await _pump(
      tester,
      MockTrialRepository(
        clock: _clock,
        myBookings: [fixtureTrials(DateTime(2026, 11, 7)).last],
      ),
    );

    expect(find.text('Your bookings'), findsOneWidget);
    expect(find.textContaining('Sat 7 Nov, Evening'), findsOneWidget);
  });
}
