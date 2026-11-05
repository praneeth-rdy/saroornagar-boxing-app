import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/theme/app_typography.dart';
import 'package:saroornagar_boxing/core/utils/phone_format.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';
import 'package:saroornagar_boxing/core/widgets/secondary_button.dart';
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
  Size surface = const Size(800, 1800),
}) async {
  tester.view.physicalSize = surface * 2;
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

// Widths only match a device with the real font; the test font is much wider.
Future<void> _loadInter() async {
  final loader = FontLoader(AppTypography.fontFamily);
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/Inter-$weight.ttf'));
  }
  await loader.load();
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

  group('admin list layout', () {
    testWidgets('a blocked row is as tall as an unblocked one', (tester) async {
      await _pump(tester, const StaffListScreen());

      final blocked = tester.getSize(
        find.ancestor(of: find.text('Blocked'), matching: find.byType(InkWell)),
      );
      final other = tester.getSize(
        find.ancestor(
          of: find.text('Sana Begum'),
          matching: find.byType(InkWell),
        ),
      );
      expect(blocked.height, other.height);
    });

    testWidgets('a blocked row shows the full email at 390 px', (tester) async {
      await tester.runAsync(_loadInter);
      await _pump(
        tester,
        const StaffListScreen(),
        surface: const Size(390, 844),
      );

      final subtitle = find.text('Coach · ${blockedCoachProfile.email}');
      expect(subtitle, findsOneWidget);
      expect(
        tester.renderObject<RenderParagraph>(subtitle).didExceedMaxLines,
        isFalse,
      );
      expect(tester.takeException(), isNull);
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
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(
        find.text('Enter a password of 8 to 72 characters'),
        findsOneWidget,
      );
      // The phone is optional, so blank is not an error.
      expect(find.text('Enter a 10-digit mobile number'), findsNothing);
      expect(staff.stored, hasLength(3));
    });

    testWidgets('a malformed email and a short phone are flagged', (
      tester,
    ) async {
      final staff = await _pump(tester, const StaffFormScreen());

      await tester.enterText(find.byType(TextField).at(0), 'Asha Rao');
      await tester.enterText(find.byType(TextField).at(1), 'asha@');
      await tester.enterText(find.byType(TextField).at(2), 'long-enough-1');
      await tester.enterText(find.byType(TextField).at(3), '12345');
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(find.text('Enter a 10-digit mobile number'), findsOneWidget);
      expect(staff.stored, hasLength(3));
    });

    testWidgets('a duplicate email shows the banner message', (tester) async {
      final staff = await _pump(tester, const StaffFormScreen());

      await tester.enterText(find.byType(TextField).at(0), 'Asha Rao');
      await tester.enterText(find.byType(TextField).at(1), coachProfile.email);
      await tester.enterText(find.byType(TextField).at(2), 'long-enough-1');
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(
        find.text('A staff member with this email already exists'),
        findsOneWidget,
      );
      expect(staff.stored, hasLength(3));
    });

    testWidgets('a duplicate phone shows the banner message', (tester) async {
      await _pump(tester, const StaffFormScreen());

      await tester.enterText(find.byType(TextField).at(0), 'Asha Rao');
      await tester.enterText(find.byType(TextField).at(1), 'asha@local.test');
      await tester.enterText(find.byType(TextField).at(2), 'long-enough-1');
      await tester.enterText(find.byType(TextField).at(3), '9000000003');
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(
        find.text('This number belongs to another staff member'),
        findsOneWidget,
      );
    });

    testWidgets('editing offers name, role and phone only', (tester) async {
      await _pump(tester, StaffFormScreen(userId: coachProfile.id));

      expect(find.text('Email'), findsNothing);
      expect(find.text('Password'), findsNothing);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('editing yourself locks the role chips', (tester) async {
      await _pump(tester, StaffFormScreen(userId: adminProfile.id));

      expect(find.text('You cannot change your own role'), findsOneWidget);
      // Password is not editable.
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
    testWidgets('shows the email, then No phone when there is none', (
      tester,
    ) async {
      await _pump(tester, StaffDetailScreen(userId: coachProfile.id));

      expect(find.text(coachProfile.email), findsOneWidget);
      expect(find.text('No phone'), findsOneWidget);
    });

    testWidgets('shows the formatted phone when present', (tester) async {
      await _pump(tester, StaffDetailScreen(userId: adminProfile.id));

      expect(find.text(adminProfile.email), findsOneWidget);
      expect(find.text(formatPhone(adminProfile.phone!)), findsOneWidget);
      expect(find.text('No phone'), findsNothing);
    });

    testWidgets('Edit and Reset password stack full width, 12 px apart', (
      tester,
    ) async {
      await _pump(tester, StaffDetailScreen(userId: coachProfile.id));

      final edit = tester.getRect(find.widgetWithText(SecondaryButton, 'Edit'));
      final reset = tester.getRect(
        find.widgetWithText(SecondaryButton, 'Reset password'),
      );
      expect(reset.left, edit.left);
      expect(reset.width, edit.width);
      expect(reset.top - edit.bottom, 12);
    });

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
