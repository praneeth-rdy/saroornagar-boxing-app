import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saroornagar_boxing/core/router/routes.dart';
import 'package:saroornagar_boxing/core/theme/app_theme.dart';
import 'package:saroornagar_boxing/features/auth/presentation/auth_providers.dart';
import 'package:saroornagar_boxing/features/trials/domain/trial_booking.dart';
import 'package:saroornagar_boxing/features/trials/presentation/trial_booked_screen.dart';

import '../../../support/fixtures/trials.dart';

TrialBooking get _booking => fixtureTrials(DateTime(2026, 11, 6)).first;

Future<void> _pump(WidgetTester tester, {required bool isSignedIn}) async {
  final router = GoRouter(
    initialLocation: '/booked',
    routes: [
      GoRoute(
        path: '/booked',
        builder: (context, state) => TrialBookedScreen(booking: _booking),
      ),
      GoRoute(
        path: Routes.trial,
        builder: (context, state) => const Text('Trial form'),
      ),
      GoRoute(
        path: Routes.trials,
        builder: (context, state) => const Text('Trials tab'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionProvider.overrideWith((ref) => Stream.value(isSignedIn)),
      ],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tells the visitor the day, batch and hours', (tester) async {
    await _pump(tester, isSignedIn: false);

    expect(find.text("You're booked"), findsOneWidget);
    expect(
      find.text(
        'Come to the club on Friday 6 November for the Morning batch '
        '(6:00 to 8:30 am). Ask for the coach when you arrive.',
      ),
      findsOneWidget,
    );
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Book another day'), findsOneWidget);
  });

  testWidgets('Done opens a fresh trial form for a visitor', (tester) async {
    await _pump(tester, isSignedIn: false);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Trial form'), findsOneWidget);
  });

  testWidgets('Done returns signed-in staff to the Trials tab', (tester) async {
    await _pump(tester, isSignedIn: true);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Trials tab'), findsOneWidget);
  });
}
