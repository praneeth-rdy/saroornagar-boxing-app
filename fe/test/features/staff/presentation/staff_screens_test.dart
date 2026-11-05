import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';
import 'package:saroornagar_boxing/features/auth/domain/staff_profile.dart';
import 'package:saroornagar_boxing/features/staff/presentation/staff_detail_screen.dart';
import 'package:saroornagar_boxing/features/staff/presentation/staff_form_screen.dart';
import 'package:saroornagar_boxing/features/staff/presentation/staff_list_screen.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/fixtures/profiles.dart';
import '../../../support/mocks/mock_auth_repository.dart';
import '../../../support/mocks/mock_staff_repository.dart';

Future<MockStaffRepository> _pump(
  WidgetTester tester,
  Widget home, {
  StaffProfile? caller,
}) async {
  tester.view.physicalSize = const Size(1600, 3600);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final me = caller ?? adminProfile;
  final auth = MockAuthRepository(signedIn: true, profile: me);
  addTearDown(auth.dispose);
  final staff = MockStaffRepository(caller: me);
  await pumpApp(
    tester,
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      staffRepositoryProvider.overrideWithValue(staff),
    ],
    home: home,
  );
  return staff;
}

void main() {
  group('admin list', () {
    testWidgets('shows rows, the Blocked chip and the You caption', (
      tester,
    ) async {
      await _pump(tester, const StaffListScreen());

      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text('Sana Begum'), findsOneWidget);
      expect(find.text('Arjun Reddy'), findsOneWidget);
      expect(find.text('Blocked'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
    });
  });

  group('admin form', () {
    testWidgets('empty submit shows field errors and sends nothing', (
      tester,
    ) async {
      final staff = await _pump(tester, const StaffFormScreen());

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a name between 2 and 80 characters'),
        findsOneWidget,
      );
      expect(find.text('Enter a 10-digit mobile number'), findsOneWidget);
      expect(
        find.text('Enter a password of 8 to 72 characters'),
        findsOneWidget,
      );
      expect(staff.stored, hasLength(3));
    });

    testWidgets('a duplicate phone shows the banner message', (tester) async {
      await _pump(tester, const StaffFormScreen());

      await tester.enterText(find.byType(TextField).at(0), 'Asha Rao');
      await tester.enterText(find.byType(TextField).at(1), '9000000002');
      await tester.enterText(find.byType(TextField).at(2), 'long-enough-1');
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(
        find.text('A staff member with this number already exists'),
        findsOneWidget,
      );
    });

    testWidgets('editing yourself locks the role chips', (tester) async {
      await _pump(tester, StaffFormScreen(userId: adminProfile.id));

      expect(find.text('You cannot change your own role'), findsOneWidget);
      // Phone and password are not editable.
      expect(find.text('Password'), findsNothing);
    });

    testWidgets('editing another member keeps the role chips enabled', (
      tester,
    ) async {
      await _pump(tester, StaffFormScreen(userId: coachProfile.id));

      expect(find.text('You cannot change your own role'), findsNothing);
    });
  });

  group('admin detail', () {
    testWidgets('block asks for confirmation and cancel changes nothing', (
      tester,
    ) async {
      final staff = await _pump(
        tester,
        StaffDetailScreen(userId: coachProfile.id),
      );

      await tester.tap(find.text('Block access'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'They will be signed out and cannot use the app until unblocked.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(staff.memberFor(coachProfile.id)!.isBlocked, isFalse);
      expect(find.text('Block access'), findsOneWidget);
    });

    testWidgets('confirming blocks the member and offers Unblock', (
      tester,
    ) async {
      final staff = await _pump(
        tester,
        StaffDetailScreen(userId: coachProfile.id),
      );

      await tester.tap(find.text('Block access'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Block access').last);
      await tester.pumpAndSettle();

      expect(staff.memberFor(coachProfile.id)!.isBlocked, isTrue);
      expect(find.text('Unblock'), findsOneWidget);
    });

    testWidgets('own profile hides Block access', (tester) async {
      await _pump(tester, StaffDetailScreen(userId: adminProfile.id));

      expect(find.text('Block access'), findsNothing);
      expect(find.text('Unblock'), findsNothing);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('reset sheet rejects a mismatch and a short password', (
      tester,
    ) async {
      final staff = await _pump(
        tester,
        StaffDetailScreen(userId: coachProfile.id),
      );

      await tester.tap(find.text('Reset password'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a password of 8 to 72 characters'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField).at(0), 'long-enough-1');
      await tester.enterText(find.byType(TextField).at(1), 'different-one');
      await tester.tap(find.text('Reset').last);
      await tester.pumpAndSettle();

      expect(find.text('The passwords do not match'), findsOneWidget);
      expect(staff.passwords, isEmpty);
    });
  });
}
