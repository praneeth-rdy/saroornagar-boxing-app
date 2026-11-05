import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/core/theme/app_colors.dart';
import 'package:saroornagar_boxing/core/theme/app_typography.dart';
import 'package:saroornagar_boxing/core/widgets/date_field.dart';

import '../../helpers/pump_app.dart';

Future<void> _pump(
  WidgetTester tester, {
  DateTime? date,
  VoidCallback? onClear,
  String? errorText,
}) {
  return pumpApp(
    tester,
    home: Scaffold(
      body: DateField(
        label: 'Date of birth',
        date: date,
        onPick: () {},
        onClear: onClear,
        errorText: errorText,
      ),
    ),
  );
}

TextStyle? _styleOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style;

void main() {
  testWidgets('empty shows the placeholder in the muted hint style', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Date of birth'), findsOneWidget);
    final style = _styleOf(tester, 'Choose a date');
    expect(style?.color, AppColors.muted);
    expect(style?.fontWeight, AppTypography.body.fontWeight);
  });

  testWidgets('a chosen date keeps the ink style', (tester) async {
    await _pump(tester, date: DateTime(2000, 3, 7));

    expect(find.text('Choose a date'), findsNothing);
    final style = _styleOf(tester, '7 Mar 2000');
    expect(style?.color, AppTypography.bodyStrong.color);
    expect(style?.fontWeight, AppTypography.bodyStrong.fontWeight);
  });

  testWidgets('clear button only appears for a chosen date with onClear', (
    tester,
  ) async {
    await _pump(tester, onClear: () {});
    expect(find.byIcon(Icons.close), findsNothing);

    await _pump(tester, date: DateTime(2000, 3, 7), onClear: () {});
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('error text is shown', (tester) async {
    await _pump(tester, errorText: 'Choose a date of birth');
    expect(find.text('Choose a date of birth'), findsOneWidget);
  });
}
