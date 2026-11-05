import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/features/auth/presentation/sign_in_screen.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/mocks/mock_auth_repository.dart';
import '../../../support/scenario.dart';

Future<void> pumpSignIn(WidgetTester tester, MockAuthRepository repository) =>
    pumpApp(
      tester,
      home: const SignInScreen(),
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

Future<void> fillAndSubmit(
  WidgetTester tester, {
  String phone = '9000000001',
  String password = 'admin-local-1234',
}) async {
  await tester.enterText(find.byType(TextField).at(0), phone);
  await tester.enterText(find.byType(TextField).at(1), password);
  await tester.tap(find.text('Sign in').last);
}

void main() {
  testWidgets('empty fields show validation and do not call the server', (
    tester,
  ) async {
    await pumpSignIn(tester, MockAuthRepository());

    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('Enter a 10-digit mobile number'), findsOneWidget);
    expect(find.text('Enter a password of 8 to 72 characters'), findsOneWidget);
  });

  testWidgets('wrong credentials show the mismatch banner', (tester) async {
    await pumpSignIn(tester, MockAuthRepository());

    await fillAndSubmit(tester, password: 'not-the-password');
    await tester.pumpAndSettle();

    expect(
      find.text('That phone number and password do not match.'),
      findsOneWidget,
    );
  });

  testWidgets('offline scenario shows the offline banner', (tester) async {
    await pumpSignIn(
      tester,
      MockAuthRepository(scenario: MockScenario.offline),
    );

    await fillAndSubmit(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('You are offline. Check the connection and try again.'),
      findsOneWidget,
    );
  });

  testWidgets('button is busy while the slow scenario runs', (tester) async {
    await pumpSignIn(tester, MockAuthRepository(scenario: MockScenario.slow));

    await fillAndSubmit(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );

    await tester.pump(slowScenarioDelay);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('password visibility toggles', (tester) async {
    await pumpSignIn(tester, MockAuthRepository());

    expect(find.byTooltip('Show password'), findsOneWidget);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });
}
