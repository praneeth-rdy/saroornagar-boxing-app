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
    await tester.enterText(find.byType(TextField).at(1), '9876500001');
    await tester.enterText(find.byType(TextField).at(2), 'long-enough-1');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(find.text('Asha Rao'), findsOneWidget);
    final ashaId = staff.stored.firstWhere((m) => m.fullName == 'Asha Rao').id;

    await tester.tap(find.text('Asha Rao'));
    await tester.pumpAndSettle();
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
