import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saroornagar_boxing/app.dart';
import 'package:saroornagar_boxing/core/theme/app_theme.dart';

/// Pumps [home] in the app theme, or the whole [App] when [home] is null, then settles.
///
/// Pass `settle: false` for a screen that shows an indeterminate spinner, which never
/// settles.
Future<void> pumpApp(
  WidgetTester tester, {
  List<Override> overrides = const [],
  Widget? home,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: home == null
          ? const App()
          : MaterialApp(theme: AppTheme.light(), home: home),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}
