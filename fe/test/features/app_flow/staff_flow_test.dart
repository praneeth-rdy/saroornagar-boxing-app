import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/router/routes.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';

import '../../helpers/pump_app.dart';
import '../../support/fixtures/profiles.dart';
import '../../support/mocks/mock_attendance_repository.dart';
import '../../support/mocks/mock_auth_repository.dart';
import '../../support/mocks/mock_staff_repository.dart';

void main() {
  testWidgets('admin adds a coach, resets the password and blocks them', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 3600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final auth = MockAuthRepository(signedIn: true);
    addTearDown(auth.dispose);
    final staff = MockStaffRepository(staff: [adminProfile]);
    await pumpApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        attendanceRepositoryProvider.overrideWithValue(
          MockAttendanceRepository(),
        ),
        staffRepositoryProvider.overrideWithValue(staff),
      ],
    );

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Staff'));
    await tester.pumpAndSettle();
    expect(find.text('Ravi Kumar'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Asha Rao');
    await tester.enterText(find.byType(TextField).at(1), 'asha@local.test');
    await tester.enterText(find.byType(TextField).at(2), 'long-enough-1');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(find.text('Asha Rao'), findsOneWidget);
    expect(find.text('Coach · asha@local.test'), findsOneWidget);
    final asha = staff.stored.firstWhere((m) => m.fullName == 'Asha Rao');
    final ashaId = asha.id;
    expect(asha.phone, isNull);

    await tester.tap(find.text('Asha Rao'));
    await tester.pumpAndSettle();
    expect(find.text('asha@local.test'), findsOneWidget);
    expect(find.text('No phone'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), '9876500001');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(staff.memberFor(ashaId)!.phone, '919876500001');
    expect(find.text('No phone'), findsNothing);

    // Emptying the field clears the phone again.
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(1), '');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(staff.memberFor(ashaId)!.phone, isNull);
    expect(find.text('No phone'), findsOneWidget);

    await tester.tap(find.text('Reset password'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'fresh-pass-99');
    await tester.enterText(find.byType(TextField).at(1), 'fresh-pass-99');
    await tester.tap(find.text('Reset').last);
    await tester.pumpAndSettle();
    expect(staff.passwords[ashaId], 'fresh-pass-99');
    expect(find.text('Password reset'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block access'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block access').last);
    await tester.pumpAndSettle();
    expect(staff.memberFor(ashaId)!.isBlocked, isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Asha Rao'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
  });

  testWidgets('an admin who renames themselves sees the new name on More', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 3600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final auth = MockAuthRepository(signedIn: true);
    addTearDown(auth.dispose);
    final staff = MockStaffRepository(staff: [adminProfile])
      ..onStored = (saved) {
        if (saved.id == auth.profile.id) auth.profile = saved;
      };
    await pumpApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        attendanceRepositoryProvider.overrideWithValue(
          MockAttendanceRepository(),
        ),
        staffRepositoryProvider.overrideWithValue(staff),
      ],
    );

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Staff'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ravi Kumar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Ravi K');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pump();

    // The profile reloads behind the tabs instead of blanking the shell.
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Ravi K'), findsOneWidget);
    expect(find.text('Ravi Kumar'), findsNothing);
  });

  testWidgets('an expired session on a staff action signs the admin out', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 3600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final auth = MockAuthRepository(signedIn: true);
    addTearDown(auth.dispose);
    final staff = MockStaffRepository();
    await pumpApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        attendanceRepositoryProvider.overrideWithValue(
          MockAttendanceRepository(),
        ),
        staffRepositoryProvider.overrideWithValue(staff),
      ],
    );
    GoRouter.of(tester.element(find.byType(NavigationBar)))
        .go(Routes.staffDetailOf(coachProfile.id));
    await tester.pumpAndSettle();
    staff.isSessionExpired = true;

    await tester.tap(find.text('Block access'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Block access').last);
    await tester.pumpAndSettle();

    expect(auth.isSignedIn, isFalse);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('a coach has no Staff card on More', (tester) async {
    final auth = MockAuthRepository(signedIn: true, profile: coachProfile);
    addTearDown(auth.dispose);
    await pumpApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        attendanceRepositoryProvider.overrideWithValue(
          MockAttendanceRepository(),
        ),
        staffRepositoryProvider.overrideWithValue(
          MockStaffRepository(caller: coachProfile),
        ),
      ],
    );

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    expect(find.text('Sana Begum'), findsOneWidget);
    expect(find.text('Staff'), findsNothing);
  });

  testWidgets('a coach opening a staff route sees the permission view', (
    tester,
  ) async {
    final auth = MockAuthRepository(signedIn: true, profile: coachProfile);
    addTearDown(auth.dispose);
    await pumpApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        attendanceRepositoryProvider.overrideWithValue(
          MockAttendanceRepository(),
        ),
        staffRepositoryProvider.overrideWithValue(
          MockStaffRepository(caller: coachProfile),
        ),
      ],
    );

    for (final route in [
      Routes.staff,
      Routes.staffNew,
      Routes.staffDetailOf(coachProfile.id),
    ]) {
      GoRouter.of(tester.element(find.byType(NavigationBar))).go(route);
      await tester.pumpAndSettle();
      expect(find.text('Only an admin can manage staff.'), findsOneWidget);
    }
  });
}
