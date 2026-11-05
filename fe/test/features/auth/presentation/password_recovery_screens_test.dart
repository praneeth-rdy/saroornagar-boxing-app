import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/router/routes.dart';
import 'package:saroornagar_boxing/core/theme/app_theme.dart';
import 'package:saroornagar_boxing/features/auth/presentation/forgot_password_screen.dart';
import 'package:saroornagar_boxing/features/auth/presentation/reset_password_screen.dart';

import '../../../support/mocks/mock_auth_repository.dart';
import '../../../support/scenario.dart';

const _email = 'admin@local.test';

/// The recovery screens call `context.canPop`, so they need a router above them.
Future<void> pumpScreen(
  WidgetTester tester,
  MockAuthRepository repository,
  Widget screen,
) async {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => screen),
      GoRoute(
        path: Routes.signIn,
        builder: (_, _) => const Scaffold(body: Text('sign-in route')),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, _) => const Scaffold(body: Text('reset route')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpForgot(
  WidgetTester tester,
  MockAuthRepository repository, {
  String? initialEmail,
}) => pumpScreen(
  tester,
  repository,
  ForgotPasswordScreen(initialEmail: initialEmail),
);

Future<void> pumpReset(WidgetTester tester, MockAuthRepository repository) =>
    pumpScreen(tester, repository, const ResetPasswordScreen(email: _email));

Future<void> fillReset(
  WidgetTester tester, {
  String code = mockRecoveryCode,
  String password = 'new-password-1',
  String confirm = 'new-password-1',
}) async {
  await tester.enterText(find.byType(TextField).at(0), code);
  await tester.enterText(find.byType(TextField).at(1), password);
  await tester.enterText(find.byType(TextField).at(2), confirm);
  await tester.tap(find.text('Set new password'));
  await tester.pumpAndSettle();
}

void main() {
  group('ForgotPasswordScreen', () {
    testWidgets('shows the title, caption and a prefilled email', (
      tester,
    ) async {
      await pumpForgot(tester, MockAuthRepository(), initialEmail: _email);

      expect(find.text('Reset password'), findsOneWidget);
      expect(find.text('We will email you a 6-digit code.'), findsOneWidget);
      expect(find.text(_email), findsOneWidget);
    });

    testWidgets('a bad email shows validation and sends nothing', (
      tester,
    ) async {
      final repository = MockAuthRepository();
      await pumpForgot(tester, repository);

      await tester.enterText(find.byType(TextField), 'nope');
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(repository.resetRequests, isEmpty);
    });

    testWidgets('sends the code to the normalized email', (tester) async {
      final repository = MockAuthRepository();
      await pumpForgot(tester, repository);

      await tester.enterText(find.byType(TextField), '  Admin@Local.Test ');
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();

      expect(repository.resetRequests, [_email]);
      expect(repository.lastCode, mockRecoveryCode);
      expect(find.text('reset route'), findsOneWidget);
    });

    testWidgets('an offline failure shows a banner', (tester) async {
      final repository = MockAuthRepository(scenario: MockScenario.offline);
      await pumpForgot(tester, repository, initialEmail: _email);

      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();

      expect(find.text(OfflineException.defaultMessage), findsOneWidget);
      expect(repository.resetRequests, isEmpty);
    });

    testWidgets('Back to sign in goes to the sign-in route', (tester) async {
      await pumpForgot(tester, MockAuthRepository());

      await tester.tap(find.text('Back to sign in'));
      await tester.pumpAndSettle();

      expect(find.text('sign-in route'), findsOneWidget);
    });
  });

  group('ResetPasswordScreen', () {
    testWidgets('shows the caption and the three fields', (tester) async {
      await pumpReset(tester, MockAuthRepository());

      expect(
        find.text('Enter the code from the email and choose a new password.'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Send a new code'), findsOneWidget);
    });

    testWidgets('rejects a short code', (tester) async {
      final repository = MockAuthRepository();
      await pumpReset(tester, repository);

      await fillReset(tester, code: '123');

      expect(
        find.text('Enter the 6-digit code from the email'),
        findsOneWidget,
      );
      expect(repository.isSignedIn, isFalse);
    });

    testWidgets('rejects mismatched passwords', (tester) async {
      final repository = MockAuthRepository();
      await pumpReset(tester, repository);
      await repository.requestPasswordReset(_email);

      await fillReset(tester, confirm: 'different-pass-2');

      expect(find.text('The passwords do not match'), findsOneWidget);
      expect(repository.isSignedIn, isFalse);
    });

    testWidgets('rejects a weak password', (tester) async {
      await pumpReset(tester, MockAuthRepository());

      await fillReset(tester, password: 'short', confirm: 'short');

      expect(
        find.text('Enter a password of 8 to 72 characters'),
        findsOneWidget,
      );
    });

    testWidgets('a wrong code shows the banner and does not sign in', (
      tester,
    ) async {
      final repository = MockAuthRepository();
      await pumpReset(tester, repository);
      await repository.requestPasswordReset(_email);

      await fillReset(tester, code: '000000');

      expect(find.text('That code is wrong or has expired.'), findsOneWidget);
      expect(repository.isSignedIn, isFalse);
    });

    testWidgets('the right code signs in and sets the new password', (
      tester,
    ) async {
      final repository = MockAuthRepository();
      addTearDown(repository.dispose);
      await pumpReset(tester, repository);
      await repository.requestPasswordReset(_email);

      await fillReset(tester);

      expect(repository.isSignedIn, isTrue);
      expect(repository.validPassword, 'new-password-1');
      expect(find.text('Password updated'), findsOneWidget);
    });

    testWidgets('Send a new code requests again and confirms', (tester) async {
      final repository = MockAuthRepository();
      await pumpReset(tester, repository);

      await tester.tap(find.text('Send a new code'));
      await tester.pumpAndSettle();

      expect(repository.resetRequests, [_email]);
      expect(find.text('Code sent'), findsOneWidget);
    });

    testWidgets('Back to sign in goes to the sign-in route', (tester) async {
      await pumpReset(tester, MockAuthRepository());

      await tester.ensureVisible(find.text('Back to sign in'));
      await tester.tap(find.text('Back to sign in'));
      await tester.pumpAndSettle();

      expect(find.text('sign-in route'), findsOneWidget);
    });
  });
}
