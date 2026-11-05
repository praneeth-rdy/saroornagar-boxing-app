import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';

import '../../helpers/pump_app.dart';
import '../../support/fixtures/trainees.dart';
import '../../support/mocks/mock_attendance_repository.dart';
import '../../support/mocks/mock_auth_repository.dart';
import '../../support/mocks/mock_fee_repository.dart';
import '../../support/mocks/mock_trainee_repository.dart';

void main() {
  testWidgets(
    'record a payment from the trainee, see it in history and in fee status',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 3600);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final clock = DateTime.utc(2026, 11, 5, 7);
      final auth = MockAuthRepository(signedIn: true);
      addTearDown(auth.dispose);
      final fees = MockFeeRepository(
        trainees: [detailTrainee],
        clock: () => clock,
      );
      await pumpApp(
        tester,
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          attendanceRepositoryProvider.overrideWithValue(
            MockAttendanceRepository(),
          ),
          traineeRepositoryProvider.overrideWithValue(
            MockTraineeRepository(trainees: [detailTrainee], now: () => clock),
          ),
          feeRepositoryProvider.overrideWithValue(fees),
          clockProvider.overrideWithValue(() => clock),
        ],
      );

      await tester.tap(find.text('Students').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Arjun Reddy'));
      await tester.pumpAndSettle();

      expect(find.text('FEES'), findsOneWidget);
      expect(find.text('No payments recorded yet'), findsOneWidget);

      await tester.tap(find.text('Record payment'));
      await tester.pumpAndSettle();
      // The junior fee is prefilled; pick the method and submit.
      expect(find.text('Junior, 500 per month'), findsOneWidget);
      await tester.tap(find.text('UPI'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PrimaryButton).last);
      // Pump in steps: settling would outlast the snackbar.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Back on the detail with the snackbar and the new row.
      expect(find.text('Payment recorded'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('No payments recorded yet'), findsNothing);
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('500 · UPI · paid 5 Nov'), findsOneWidget);
      expect(fees.stored.single.amount, 500);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('More').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fee status'));
      await tester.pumpAndSettle();

      expect(find.text('November 2026'), findsOneWidget);
      expect(find.text('0 unpaid · 1 paid'), findsOneWidget);
      expect(find.text('Paid 500 on 5 Nov'), findsOneWidget);
    },
  );
}
