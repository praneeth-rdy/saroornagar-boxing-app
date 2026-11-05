import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/models/trainee_status.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';

import '../../helpers/pump_app.dart';
import '../../support/mocks/mock_attendance_repository.dart';
import '../../support/mocks/mock_auth_repository.dart';
import '../../support/mocks/mock_trainee_repository.dart';

void main() {
  testWidgets(
    'add a trainee, edit the name, set inactive, find it under Inactive',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 3000);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final auth = MockAuthRepository(signedIn: true);
      addTearDown(auth.dispose);
      final trainees = MockTraineeRepository(
        now: () => DateTime.utc(2026, 11, 5, 7),
      );
      await pumpApp(
        tester,
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          attendanceRepositoryProvider.overrideWithValue(
            MockAttendanceRepository(),
          ),
          traineeRepositoryProvider.overrideWithValue(trainees),
          clockProvider.overrideWithValue(() => DateTime.utc(2026, 11, 5, 7)),
        ],
      );

      await tester.tap(find.text('Students').last);
      await tester.pumpAndSettle();
      expect(find.text('No students yet'), findsOneWidget);

      await tester.tap(find.text('Add').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Asha Rao');
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      // Lands on the new trainee's detail.
      expect(find.text('Asha Rao'), findsOneWidget);
      expect(find.text('Set inactive'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Asha Reddy');
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      expect(find.text('Asha Reddy'), findsOneWidget);
      expect(trainees.traineeFor('trainee-new-1')!.fullName, 'Asha Reddy');

      await tester.tap(find.text('Set inactive'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Set inactive').last);
      await tester.pumpAndSettle();
      expect(
        trainees.traineeFor('trainee-new-1')!.status,
        TraineeStatus.inactive,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Asha Reddy'), findsNothing);

      await tester.tap(find.text('Inactive'));
      await tester.pumpAndSettle();
      expect(find.text('Asha Reddy'), findsOneWidget);
    },
  );
}
