import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/router/routes.dart';
import 'package:saroornagar_boxing/features/auth/presentation/sign_in_screen.dart';

import '../../helpers/pump_app.dart';
import '../../support/fixtures/profiles.dart';
import '../../support/mocks/mock_attendance_repository.dart';
import '../../support/mocks/mock_auth_repository.dart';

void main() {
  testWidgets('sign in lands on Today and sign out returns to sign-in', (
    tester,
  ) async {
    final repository = MockAuthRepository();
    addTearDown(repository.dispose);
    await pumpApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        attendanceRepositoryProvider.overrideWithValue(
          MockAttendanceRepository(),
        ),
      ],
    );

    expect(find.text('Staff and coaches only.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'admin@local.test');
    await tester.enterText(find.byType(TextField).at(1), 'admin-local-1234');
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text(adminProfile.fullName), findsOneWidget);
    expect(find.textContaining('Admin'), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Staff and coaches only.'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('forgot password: code and new password land on Today', (
    tester,
  ) async {
    final repository = MockAuthRepository();
    addTearDown(repository.dispose);
    await pumpApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        attendanceRepositoryProvider.overrideWithValue(
          MockAttendanceRepository(),
        ),
      ],
    );

    // Sign-in has no entry point to recovery, so the flow starts on its route.
    GoRouter.of(tester.element(find.byType(SignInScreen)))
        .go(Routes.forgotPassword);
    await tester.pumpAndSettle();

    expect(find.text('Reset password'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Admin@Local.Test');

    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();

    expect(repository.resetRequests, ['admin@local.test']);
    expect(
      find.text('Enter the code from the email and choose a new password.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField).at(0), mockRecoveryCode);
    await tester.enterText(find.byType(TextField).at(1), 'new-password-1');
    await tester.enterText(find.byType(TextField).at(2), 'new-password-1');
    await tester.tap(find.text('Set new password'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Password updated'), findsOneWidget);
  });

  testWidgets('a blocked coach sees the blocked screen', (tester) async {
    final repository = MockAuthRepository(
      signedIn: true,
      profile: blockedCoachProfile,
    );
    addTearDown(repository.dispose);
    await pumpApp(
      tester,
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    expect(find.text('Access blocked'), findsOneWidget);
    expect(
      find.text('Ask the club admin to restore your access.'),
      findsOneWidget,
    );
    expect(find.byType(NavigationBar), findsNothing);
  });
}
