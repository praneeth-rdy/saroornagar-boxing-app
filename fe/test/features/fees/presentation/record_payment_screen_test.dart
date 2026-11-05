import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/widgets/inline_banner.dart';
import 'package:saroornagar_boxing/core/widgets/primary_button.dart';
import 'package:saroornagar_boxing/features/fees/presentation/record_payment_screen.dart';
import 'package:saroornagar_boxing/features/today/presentation/today_providers.dart';

import '../../../helpers/pump_app.dart';
import '../../../support/fixtures/trainees.dart';
import '../../../support/mocks/mock_fee_repository.dart';
import '../../../support/mocks/mock_trainee_repository.dart';
import '../../../support/scenario.dart';

final _clock = DateTime.utc(2026, 11, 5, 7);
const _amountMessage = 'Enter an amount between 1 and 100000';

Future<MockFeeRepository> _pump(
  WidgetTester tester, {
  required String traineeId,
  DateTime? month,
  MockScenario scenario = MockScenario.success,
}) async {
  tester.view.physicalSize = const Size(1600, 3000);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final fees = MockFeeRepository(
    scenario: scenario,
    trainees: [detailTrainee, bareTrainee],
    clock: () => _clock,
  );
  await pumpApp(
    tester,
    overrides: [
      feeRepositoryProvider.overrideWithValue(fees),
      traineeRepositoryProvider.overrideWithValue(
        MockTraineeRepository(trainees: [detailTrainee, bareTrainee]),
      ),
      clockProvider.overrideWithValue(() => _clock),
    ],
    home: RecordPaymentScreen(traineeId: traineeId, month: month),
  );
  return fees;
}

String _amountText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).first).controller!.text;

void main() {
  testWidgets('prefills the tier amount and the current month', (tester) async {
    await _pump(tester, traineeId: detailTrainee.id);
    expect(find.text('Record payment'), findsNWidgets(2));
    expect(find.text('Arjun Reddy'), findsOneWidget);
    expect(find.text('Junior, 500 per month'), findsOneWidget);
    expect(_amountText(tester), '500');
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('UPI'), findsOneWidget);
    expect(find.text('5 Nov 2026'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);
  });

  testWidgets('leaves the amount empty when the tier is unknown', (
    tester,
  ) async {
    await _pump(tester, traineeId: bareTrainee.id);
    expect(find.text('No date of birth, tier unknown'), findsOneWidget);
    expect(_amountText(tester), '');
  });

  testWidgets('a month argument preselects the period', (tester) async {
    await _pump(tester, traineeId: detailTrainee.id, month: DateTime(2026, 10));
    expect(find.text('October 2026'), findsOneWidget);
  });

  testWidgets('next month as the argument preselects it', (tester) async {
    await _pump(tester, traineeId: detailTrainee.id, month: DateTime(2026, 12));
    expect(find.text('December 2026'), findsOneWidget);
  });

  testWidgets('a month past next falls back to the current month', (
    tester,
  ) async {
    await _pump(tester, traineeId: detailTrainee.id, month: DateTime(2027, 2));
    expect(find.text('November 2026'), findsOneWidget);
  });

  testWidgets('the period may advance to next month, never further', (
    tester,
  ) async {
    await _pump(tester, traineeId: detailTrainee.id);
    IconButton next() => tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip('Next month'),
        matching: find.byType(IconButton),
      ),
    );
    expect(next().onPressed, isNotNull);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('December 2026'), findsOneWidget);
    expect(next().onPressed, isNull);
  });

  testWidgets('submitting without a method shows the method message only', (
    tester,
  ) async {
    final fees = await _pump(tester, traineeId: detailTrainee.id);
    expect(find.text('Choose cash or UPI'), findsNothing);
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('Choose cash or UPI'), findsOneWidget);
    expect(find.text(_amountMessage), findsNothing);
    expect(fees.stored, isEmpty);
  });

  testWidgets('an empty, zero or oversized amount is rejected', (tester) async {
    final fees = await _pump(tester, traineeId: detailTrainee.id);
    await tester.tap(find.text('Cash'));
    for (final text in ['', '0', '100001', 'abc']) {
      await tester.enterText(find.byType(TextField).first, text);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      expect(find.text(_amountMessage), findsOneWidget, reason: 'for "$text"');
    }
    expect(fees.stored, isEmpty);
  });

  testWidgets('a server failure shows in a banner and stores nothing', (
    tester,
  ) async {
    final fees = await _pump(
      tester,
      traineeId: detailTrainee.id,
      scenario: MockScenario.permissionDenied,
    );
    await tester.tap(find.text('UPI'));
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.byType(InlineBanner), findsOneWidget);
    expect(fees.stored, isEmpty);
    expect(find.text('Payment recorded'), findsNothing);
  });
}
