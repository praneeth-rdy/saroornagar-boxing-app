import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/di/repository_providers.dart';
import 'package:saroornagar_boxing/core/widgets/app_text_field.dart';
import 'package:saroornagar_boxing/core/widgets/choice_row.dart';
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
final _trainees = [detailTrainee, bareTrainee, longNotesTrainee];

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
    trainees: _trainees,
    clock: () => _clock,
  );
  await pumpApp(
    tester,
    overrides: [
      feeRepositoryProvider.overrideWithValue(fees),
      traineeRepositoryProvider.overrideWithValue(
        MockTraineeRepository(trainees: _trainees),
      ),
      clockProvider.overrideWithValue(() => _clock),
    ],
    home: RecordPaymentScreen(traineeId: traineeId, month: month),
  );
  return fees;
}

int? _selectedAmount(WidgetTester tester) =>
    tester.widget<ChoiceRow<int>>(find.byType(ChoiceRow<int>)).selected;

IconButton _nextMonth(WidgetTester tester) => tester.widget<IconButton>(
  find.ancestor(
    of: find.byTooltip('Next month'),
    matching: find.byType(IconButton),
  ),
);

void main() {
  testWidgets('a junior gets 500 preselected and the current month', (
    tester,
  ) async {
    await _pump(tester, traineeId: detailTrainee.id);
    expect(find.text('Record payment'), findsNWidgets(2));
    expect(find.text('Arjun Reddy'), findsOneWidget);
    expect(find.text('Junior, 500 per month'), findsOneWidget);
    expect(_selectedAmount(tester), 500);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('UPI'), findsOneWidget);
    expect(find.text('5 Nov 2026'), findsOneWidget);
    expect(find.text('Nov 2026'), findsOneWidget);
  });

  testWidgets('a senior gets 800 preselected', (tester) async {
    await _pump(tester, traineeId: longNotesTrainee.id);
    expect(find.text('Senior, 800 per month'), findsOneWidget);
    expect(_selectedAmount(tester), 800);
  });

  testWidgets('no date of birth preselects no amount', (tester) async {
    await _pump(tester, traineeId: bareTrainee.id);
    expect(find.text('No date of birth, tier unknown'), findsOneWidget);
    expect(_selectedAmount(tester), isNull);
  });

  testWidgets('the amount offers only 500 and 800, with no text field', (
    tester,
  ) async {
    await _pump(tester, traineeId: detailTrainee.id);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('800'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('tapping 800 selects it', (tester) async {
    await _pump(tester, traineeId: detailTrainee.id);
    await tester.tap(find.text('800'));
    await tester.pumpAndSettle();
    expect(_selectedAmount(tester), 800);
  });

  testWidgets('submitting without an amount asks for 500 or 800', (
    tester,
  ) async {
    final fees = await _pump(tester, traineeId: bareTrainee.id);
    await tester.tap(find.text('Cash'));
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('Choose 500 or 800'), findsOneWidget);
    expect(fees.stored, isEmpty);
  });

  testWidgets('a month argument preselects the period', (tester) async {
    await _pump(tester, traineeId: detailTrainee.id, month: DateTime(2026, 10));
    expect(find.text('Oct 2026'), findsOneWidget);
  });

  testWidgets('next month as the argument preselects it', (tester) async {
    await _pump(tester, traineeId: detailTrainee.id, month: DateTime(2026, 12));
    expect(find.text('Dec 2026'), findsOneWidget);
  });

  testWidgets('a month past next falls back to the current month', (
    tester,
  ) async {
    await _pump(tester, traineeId: detailTrainee.id, month: DateTime(2027, 2));
    expect(find.text('Nov 2026'), findsOneWidget);
  });

  testWidgets('the period may advance to next month, never further', (
    tester,
  ) async {
    await _pump(tester, traineeId: detailTrainee.id);
    expect(_nextMonth(tester).onPressed, isNotNull);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('Dec 2026'), findsOneWidget);
    expect(_nextMonth(tester).onPressed, isNull);
  });

  testWidgets('the period steps back a month', (tester) async {
    await _pump(tester, traineeId: detailTrainee.id);
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('Oct 2026'), findsOneWidget);
  });

  testWidgets('submitting without a method shows the method message only', (
    tester,
  ) async {
    final fees = await _pump(tester, traineeId: detailTrainee.id);
    expect(find.text('Choose cash or UPI'), findsNothing);
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('Choose cash or UPI'), findsOneWidget);
    expect(find.text('Choose 500 or 800'), findsNothing);
    expect(fees.stored, isEmpty);
  });

  testWidgets('the note field appears after Add a note', (tester) async {
    await _pump(tester, traineeId: detailTrainee.id);
    expect(find.byType(AppTextField), findsNothing);
    await tester.tap(find.text('Add a note'));
    await tester.pumpAndSettle();
    expect(find.byType(AppTextField), findsOneWidget);
    expect(find.text('Add a note'), findsNothing);
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
