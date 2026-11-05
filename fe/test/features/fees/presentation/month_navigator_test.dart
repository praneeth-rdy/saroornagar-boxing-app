import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/features/fees/presentation/month_navigator.dart';

import '../../../helpers/pump_app.dart';

IconButton _button(WidgetTester tester, String tooltip) => tester.widget(
  find
      .ancestor(of: find.byTooltip(tooltip), matching: find.byType(IconButton))
      .first,
);

void main() {
  testWidgets('shows the month and steps back', (tester) async {
    DateTime? changed;
    await pumpApp(
      tester,
      home: Scaffold(
        body: MonthNavigator(
          month: DateTime(2026, 11),
          latest: DateTime(2026, 11),
          onChanged: (month) => changed = month,
        ),
      ),
    );
    expect(find.text('November 2026'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous month'));
    expect(changed, DateTime(2026, 10));
  });

  testWidgets('previous wraps across the year', (tester) async {
    DateTime? changed;
    await pumpApp(
      tester,
      home: Scaffold(
        body: MonthNavigator(
          month: DateTime(2026, 1),
          latest: DateTime(2026, 11),
          onChanged: (month) => changed = month,
        ),
      ),
    );
    await tester.tap(find.byTooltip('Previous month'));
    expect(changed, DateTime(2025, 12));
  });

  testWidgets('next is disabled on the latest month', (tester) async {
    DateTime? changed;
    await pumpApp(
      tester,
      home: Scaffold(
        body: MonthNavigator(
          month: DateTime(2026, 11),
          latest: DateTime(2026, 11),
          onChanged: (month) => changed = month,
        ),
      ),
    );
    expect(_button(tester, 'Next month').onPressed, isNull);
    await tester.tap(find.byTooltip('Next month'), warnIfMissed: false);
    expect(changed, isNull);
  });

  testWidgets('next is enabled before the latest month', (tester) async {
    DateTime? changed;
    await pumpApp(
      tester,
      home: Scaffold(
        body: MonthNavigator(
          month: DateTime(2026, 10),
          latest: DateTime(2026, 11),
          onChanged: (month) => changed = month,
        ),
      ),
    );
    await tester.tap(find.byTooltip('Next month'));
    expect(changed, DateTime(2026, 11));
  });
}
