import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';
import 'package:saroornagar_boxing/features/staff/presentation/staff_detail_screen.dart';
import 'package:saroornagar_boxing/features/staff/presentation/staff_form_screen.dart';
import 'package:saroornagar_boxing/features/staff/presentation/staff_list_screen.dart';

import 'package:saroornagar_boxing/features/auth/domain/staff_profile.dart';

import '../support/fixtures/profiles.dart';
import '../support/mocks/mock_auth_repository.dart';
import '../support/mocks/mock_staff_repository.dart';
import 'proof_harness.dart';
import 'proof_support.dart';

Future<void> _proof(
  WidgetTester tester,
  String name,
  Widget screen, {
  List<List<StaffProfile>> staff = const [],
  Future<void> Function(WidgetTester tester)? interact,
}) async {
  final file = await renderProof(
    tester,
    name,
    routed(screen),
    size: tallProofSize,
    overrides: [
      authRepositoryProvider.overrideWithValue(
        MockAuthRepository(signedIn: true),
      ),
      staffRepositoryProvider.overrideWithValue(
        MockStaffRepository(staff: staff.isEmpty ? null : staff.first),
      ),
    ],
    interact: interact,
  );
  expect(file.existsSync(), isTrue);
}

void main() {
  testWidgets('staff list typical proof', (tester) async {
    await _proof(tester, 'staff_list_typical', const StaffListScreen());
  });

  testWidgets('staff list heavy proof', (tester) async {
    await _proof(
      tester,
      'staff_list_heavy',
      const StaffListScreen(),
      staff: [heavyStaff],
    );
  });

  testWidgets('staff form empty proof', (tester) async {
    await _proof(tester, 'staff_form_empty', const StaffFormScreen());
  });

  testWidgets('staff form error proof', (tester) async {
    await _proof(
      tester,
      'staff_form_error',
      const StaffFormScreen(),
      interact: (tester) async {
        await tester.enterText(find.byType(TextField).at(0), 'Asha Rao');
        await tester.enterText(find.byType(TextField).at(1), '9000000002');
        await tester.enterText(find.byType(TextField).at(2), 'long-enough-1');
        await tester.tap(find.byType(PrimaryButton));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('staff detail coach viewed by admin proof', (tester) async {
    await _proof(
      tester,
      'staff_detail_coach',
      StaffDetailScreen(userId: coachProfile.id),
    );
  });

  testWidgets('staff detail admin viewing self proof', (tester) async {
    await _proof(
      tester,
      'staff_detail_self',
      StaffDetailScreen(userId: adminProfile.id),
    );
  });
}
