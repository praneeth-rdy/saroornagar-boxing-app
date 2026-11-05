import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';

import '../../helpers/pump_app.dart';
import '../../support/fixtures/profiles.dart';
import '../../support/mocks/mock_auth_repository.dart';

void main() {
  testWidgets('sign in lands on Today and sign out returns to sign-in', (
    tester,
  ) async {
    final repository = MockAuthRepository();
    addTearDown(repository.dispose);
    await pumpApp(
      tester,
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    expect(find.text('Staff and coaches only.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), '9000000001');
    await tester.enterText(find.byType(TextField).at(1), 'admin-local-1234');
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('Coming next'), findsOneWidget);
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
