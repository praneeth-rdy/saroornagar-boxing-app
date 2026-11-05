import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/features/auth/presentation/auth_providers.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';
import 'package:saroornagar_boxing/features/trials/presentation/book_trial_screen.dart';
import 'package:saroornagar_boxing/features/trials/presentation/trial_booked_screen.dart';
import 'package:saroornagar_boxing/features/trials/presentation/trials_screen.dart';

import '../support/fixtures/trials.dart';
import '../support/mocks/mock_device_key_store.dart';
import '../support/mocks/mock_trial_repository.dart';
import 'proof_harness.dart';
import 'proof_support.dart';

Future<void> _proof(
  WidgetTester tester,
  String name,
  Widget screen,
  MockTrialRepository repository, {
  Future<void> Function(WidgetTester tester)? interact,
}) async {
  final file = await renderProof(
    tester,
    name,
    routed(screen),
    size: tallProofSize,
    overrides: [
      trialRepositoryProvider.overrideWithValue(repository),
      deviceKeyStoreProvider.overrideWithValue(MockDeviceKeyStore()),
      clockProvider.overrideWithValue(proofClock),
      sessionProvider.overrideWith((ref) => Stream.value(false)),
    ],
    interact: interact,
  );
  expect(file.existsSync(), isTrue);
}

Future<void> _fill(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'Rahul Verma');
  await tester.enterText(find.byType(TextField).at(1), '9876543210');
  await tester.tap(find.text('Fri 6'));
  await tester.tap(find.text('Morning'));
  await tester.enterText(find.byType(TextField).at(2), '14');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('book trial empty proof', (tester) async {
    await _proof(
      tester,
      'book_trial_empty',
      const BookTrialScreen(),
      MockTrialRepository(clock: proofClock),
    );
  });

  testWidgets('book trial filled proof', (tester) async {
    await _proof(
      tester,
      'book_trial_filled',
      const BookTrialScreen(),
      MockTrialRepository(clock: proofClock),
      interact: _fill,
    );
  });

  testWidgets('book trial duplicate error proof', (tester) async {
    await _proof(
      tester,
      'book_trial_duplicate',
      const BookTrialScreen(),
      MockTrialRepository(
        clock: proofClock,
        myBookings: [fixtureTrials(DateTime(2026, 11, 6)).first],
      ),
      interact: (tester) async {
        await _fill(tester);
        await tester.tap(find.text('Book trial'));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('book trial with your bookings proof', (tester) async {
    await _proof(
      tester,
      'book_trial_your_bookings',
      const BookTrialScreen(),
      MockTrialRepository(
        clock: proofClock,
        myBookings: [
          fixtureTrials(DateTime(2026, 11, 6)).first,
          fixtureTrials(DateTime(2026, 11, 9))[2],
        ],
      ),
    );
  });

  testWidgets('trial booked proof', (tester) async {
    await _proof(
      tester,
      'trial_booked',
      TrialBookedScreen(booking: fixtureTrials(DateTime(2026, 11, 6)).first),
      MockTrialRepository(clock: proofClock),
    );
  });

  testWidgets('trials tab empty proof', (tester) async {
    await _proof(
      tester,
      'trials_empty',
      const TrialsScreen(),
      MockTrialRepository(clock: proofClock),
    );
  });

  testWidgets('trials tab two days proof', (tester) async {
    await _proof(
      tester,
      'trials_two_days',
      const TrialsScreen(),
      MockTrialRepository(
        clock: proofClock,
        bookings: [
          ...fixtureTrials(DateTime(2026, 11, 5)),
          ...fixtureTrials(DateTime(2026, 11, 7)).take(1),
        ],
      ),
    );
  });

  testWidgets('trials tab ten days proof', (tester) async {
    await _proof(
      tester,
      'trials_ten_days',
      const TrialsScreen(),
      MockTrialRepository(
        clock: proofClock,
        bookings: [
          for (var day = 5; day < 15; day++)
            ...fixtureTrials(DateTime(2026, 11, day))
                .map((booking) => booking.copyWith(id: '${booking.id}-$day')),
        ],
      ),
    );
  });
}
