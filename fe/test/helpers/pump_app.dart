import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saroornagar_boxing/app.dart';
import 'package:saroornagar_boxing/core/theme/app_theme.dart';

/// Pumps [home] in the app theme, or the whole [App] when [home] is null, then settles.
///
/// With [routes], [home] sits at `/` of a [GoRouter] beside them, for screens that call
/// `context.canPop`, `push` or `go`. Pass `settle: false` for a screen that shows an indeterminate spinner, which never settles.
Future<void> pumpApp(
  WidgetTester tester, {
  List<Override> overrides = const [],
  Widget? home,
  List<GoRoute>? routes,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: switch ((home, routes)) {
        (null, _) => const App(),
        (final screen?, null) => MaterialApp(
          theme: AppTheme.light(),
          home: screen,
        ),
        (final screen?, final extra?) => MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: _router(screen, extra),
        ),
      },
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

GoRouter _router(Widget home, List<GoRoute> routes) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => home),
      ...routes,
    ],
  );
  addTearDown(router.dispose);
  return router;
}
