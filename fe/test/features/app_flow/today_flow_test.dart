import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/app.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/errors/app_exception.dart';
import 'package:saroornagar_boxing/core/models/attendance_status.dart';
import 'package:saroornagar_boxing/features/auth/domain/staff_profile.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';

import '../../helpers/pump_app.dart';
import '../../support/fixtures/roster.dart';
import '../../support/fixtures/sessions.dart';
import '../../support/mocks/mock_attendance_repository.dart';
import '../../support/mocks/mock_auth_repository.dart';

class _NoProfileAuthRepository extends MockAuthRepository {
  _NoProfileAuthRepository() : super(signedIn: true);

  @override
  Future<StaffProfile> currentProfile() async =>
      throw const NotFoundException();
}

void main() {
  testWidgets('sign in, mark two trainees present, then undo one', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 3000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final auth = MockAuthRepository();
    addTearDown(auth.dispose);
    final attendance = MockAttendanceRepository(trainees: fixtureTrainees(5));
    await pumpApp(
      tester,
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        attendanceRepositoryProvider.overrideWithValue(attendance),
        clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 5, 7)),
      ],
    );

    await tester.enterText(find.byType(TextField).at(0), 'admin@local.test');
    await tester.enterText(find.byType(TextField).at(1), 'admin-local-1234');
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Tap the students who are here.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('present-trainee-001')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('present-trainee-002')));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('of 5 students'), findsOneWidget);

    await tester.tap(find.byKey(const Key('present-trainee-002')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    final morningId = morningSession(fixtureDay).id;
    expect(
      attendance.markFor(morningId, 'trainee-001')!.status,
      AttendanceStatus.present,
    );
    expect(attendance.markFor(morningId, 'trainee-002'), isNull);
    expect(attendance.markFor(morningId, 'trainee-005'), isNull);
  });

  testWidgets('an account without a profile sees the not-staff screen', (
    tester,
  ) async {
    final auth = _NoProfileAuthRepository();
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          attendanceRepositoryProvider.overrideWithValue(
            MockAttendanceRepository(),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This account is not set up for staff.'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
