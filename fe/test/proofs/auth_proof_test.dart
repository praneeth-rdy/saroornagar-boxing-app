import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/features/auth/presentation/blocked_screen.dart';
import 'package:saroornagar_boxing/features/auth/presentation/sign_in_screen.dart';
import 'package:saroornagar_boxing/features/more/presentation/more_screen.dart';

import '../support/mocks/mock_auth_repository.dart';
import 'proof_harness.dart';

void main() {
  testWidgets('sign-in empty proof', (tester) async {
    final file = await renderProof(
      tester,
      'sign_in_empty',
      const SignInScreen(),
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
    );
    expect(file.existsSync(), isTrue);
  });

  testWidgets('more admin proof', (tester) async {
    final file = await renderProof(
      tester,
      'more_admin',
      const MoreScreen(),
      overrides: [
        authRepositoryProvider.overrideWithValue(
          MockAuthRepository(signedIn: true),
        ),
      ],
    );
    expect(file.existsSync(), isTrue);
  });

  testWidgets('blocked proof', (tester) async {
    final file = await renderProof(
      tester,
      'blocked',
      const BlockedScreen(),
      overrides: [
        authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      ],
    );
    expect(file.existsSync(), isTrue);
  });
}
