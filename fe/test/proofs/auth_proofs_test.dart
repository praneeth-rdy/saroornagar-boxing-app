import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/features/auth/presentation/blocked_screen.dart';
import 'package:saroornagar_boxing/features/auth/presentation/sign_in_screen.dart';
import 'package:saroornagar_boxing/features/more/presentation/more_screen.dart';

import '../support/fixtures/profiles.dart';
import '../support/mocks/mock_auth_repository.dart';
import '../support/scenario.dart';
import 'proof_harness.dart';
import 'proof_support.dart';

Future<void> _fill(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'admin@local.test');
  await tester.enterText(find.byType(TextField).at(1), 'wrong-password-1');
  await tester.pump();
}

Future<void> _submit(WidgetTester tester) async {
  await _fill(tester);
  await tester.tap(find.text('Sign in').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sign-in filled proof', (tester) async {
    final file = await renderProof(
      tester,
      'sign_in_filled',
      routed(const SignInScreen()),
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
      interact: _fill,
    );
    expect(file.existsSync(), isTrue);
  });

  testWidgets('sign-in wrong password proof', (tester) async {
    final file = await renderProof(
      tester,
      'sign_in_wrong_password',
      routed(const SignInScreen()),
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
      interact: _submit,
    );
    expect(file.existsSync(), isTrue);
  });

  testWidgets('sign-in offline proof', (tester) async {
    final file = await renderProof(
      tester,
      'sign_in_offline',
      routed(const SignInScreen()),
      overrides: [
        authRepositoryProvider.overrideWithValue(
          MockAuthRepository(scenario: MockScenario.offline),
        ),
      ],
      interact: (tester) async {
        await tester.enterText(
          find.byType(TextField).at(0),
          'admin@local.test',
        );
        await tester.enterText(
          find.byType(TextField).at(1),
          'admin-local-1234',
        );
        await tester.tap(find.text('Sign in').last);
        await tester.pumpAndSettle();
      },
    );
    expect(file.existsSync(), isTrue);
  });

  testWidgets('more coach proof', (tester) async {
    final file = await renderProof(
      tester,
      'more_coach',
      routed(const MoreScreen()),
      overrides: [
        authRepositoryProvider.overrideWithValue(
          MockAuthRepository(signedIn: true, profile: coachProfile),
        ),
      ],
    );
    expect(file.existsSync(), isTrue);
  });

  testWidgets('not staff proof', (tester) async {
    final file = await renderProof(
      tester,
      'not_staff',
      routed(const BlockedScreen.notStaff()),
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
    );
    expect(file.existsSync(), isTrue);
  });
}
