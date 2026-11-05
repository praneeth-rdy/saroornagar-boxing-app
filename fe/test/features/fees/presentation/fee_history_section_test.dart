import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/widgets/inline_banner.dart';
import 'package:saroornagar_boxing/features/fees/presentation/fee_history_section.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/fixtures/fees.dart';
import '../../../support/fixtures/trainees.dart';
import '../../../support/mocks/mock_fee_repository.dart';
import '../../../support/scenario.dart';

Future<MockFeeRepository> _pump(
  WidgetTester tester, {
  DateTime? now,
  bool withPayments = true,
  MockScenario scenario = MockScenario.success,
}) async {
  tester.view.physicalSize = const Size(1600, 3000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final clock = now ?? DateTime.utc(2026, 11, 5, 7);
  final fees = MockFeeRepository(
    scenario: scenario,
    trainees: [detailTrainee],
    payments: withPayments ? detailTraineePayments : const [],
    clock: () => clock,
  );
  await pumpApp(
    tester,
    overrides: [
      feeRepositoryProvider.overrideWithValue(fees),
      clockProvider.overrideWithValue(() => clock),
    ],
    home: Scaffold(
      body: SingleChildScrollView(
        child: FeeHistorySection(traineeId: detailTrainee.id),
      ),
    ),
  );
  return fees;
}

void main() {
  testWidgets('shows the empty state under the record button', (tester) async {
    await _pump(tester, withPayments: false);
    expect(find.text('FEES'), findsOneWidget);
    expect(find.text('Record payment'), findsOneWidget);
    expect(find.text('No payments recorded yet'), findsOneWidget);
    expect(find.byTooltip('Remove payment'), findsNothing);
  });

  testWidgets('lists each payment with period, details and note', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('October 2026'), findsNWidgets(2));
    expect(find.text('September 2026'), findsOneWidget);
    expect(
      find.text(
        '500 · Cash · paid 3 Nov\nPaid by his father at the evening batch.',
      ),
      findsOneWidget,
    );
    expect(find.text('300 · UPI · paid 20 Oct'), findsOneWidget);
    expect(find.text('200 · Cash · paid 6 Oct'), findsOneWidget);
    expect(find.text('500 · UPI · paid 2 Sep'), findsOneWidget);
  });

  testWidgets('only a payment inside 7 days can be removed', (tester) async {
    await _pump(tester);
    expect(find.byTooltip('Remove payment'), findsOneWidget);
  });

  testWidgets('the remove action disappears after the window', (tester) async {
    // The November payment was recorded 2026-11-03 18:30 India; 7 days end 10 Nov 18:30.
    await _pump(tester, now: DateTime.utc(2026, 11, 10, 18, 30));
    expect(find.byTooltip('Remove payment'), findsOneWidget);

    await _pump(tester, now: DateTime.utc(2026, 11, 10, 18, 31));
    expect(find.byTooltip('Remove payment'), findsNothing);
  });

  testWidgets('cancel keeps the payment, confirm removes it', (tester) async {
    final fees = await _pump(tester);
    await tester.tap(find.byTooltip('Remove payment'));
    await tester.pumpAndSettle();
    expect(find.text('Remove this payment?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(fees.stored, hasLength(4));

    await tester.tap(find.byTooltip('Remove payment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(fees.stored.any((p) => p.id == 'payment-detail-nov'), isFalse);
    expect(find.text('November 2026'), findsNothing);
    expect(find.byTooltip('Remove payment'), findsNothing);
  });

  testWidgets('a failed load shows a banner with retry', (tester) async {
    await _pump(tester, scenario: MockScenario.offline);
    expect(find.byType(InlineBanner), findsOneWidget);
  });
}
