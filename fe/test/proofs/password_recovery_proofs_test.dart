import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/router/routes.dart';
import 'package:saroornagar_boxing/features/auth/presentation/forgot_password_screen.dart';
import 'package:saroornagar_boxing/features/auth/presentation/reset_password_screen.dart';
import 'package:saroornagar_boxing/features/auth/presentation/sign_in_screen.dart';

import '../support/mocks/mock_auth_repository.dart';
import 'proof_harness.dart';

const _email = 'admin@local.test';

// Mirrors the app router's recovery routes so the forgot screen can move on to reset.
Widget _recoveryRouter({required String initialLocation}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, state) =>
            ResetPasswordScreen(email: state.extra as String? ?? _email),
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

Future<void> _proof(
  WidgetTester tester,
  String name,
  String location, {
  Future<void> Function(WidgetTester tester)? interact,
}) async {
  final file = await renderProof(
    tester,
    name,
    _recoveryRouter(initialLocation: location),
    overrides: [authRepositoryProvider.overrideWithValue(MockAuthRepository())],
    interact: interact,
  );
  expect(file.existsSync(), isTrue);
}

void main() {
  testWidgets('sign-in bad email proof', (tester) async {
    await _proof(
      tester,
      'sign_in_bad_email',
      '/',
      interact: (tester) async {
        await tester.enterText(find.byType(TextField).at(0), 'not-an-email');
        await tester.tap(find.text('Sign in').last);
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('forgot password empty proof', (tester) async {
    await _proof(tester, 'forgot_password_empty', Routes.forgotPassword);
  });

  testWidgets('forgot password sent proof', (tester) async {
    await _proof(
      tester,
      'forgot_password_sent',
      Routes.forgotPassword,
      interact: (tester) async {
        await tester.enterText(find.byType(TextField).at(0), _email);
        await tester.tap(find.text('Send code'));
        await tester.pumpAndSettle();
        expect(find.text('Set new password'), findsOneWidget);
      },
    );
  });

  testWidgets('reset password empty proof', (tester) async {
    await _proof(tester, 'reset_password_empty', Routes.resetPassword);
  });

  testWidgets('reset password wrong code proof', (tester) async {
    await _proof(
      tester,
      'reset_password_wrong_code',
      Routes.resetPassword,
      interact: (tester) async {
        await tester.enterText(find.byType(TextField).at(0), '000000');
        await tester.enterText(find.byType(TextField).at(1), 'new-password-1');
        await tester.enterText(find.byType(TextField).at(2), 'new-password-1');
        await tester.tap(find.text('Set new password'));
        await tester.pumpAndSettle();
      },
    );
  });
}
