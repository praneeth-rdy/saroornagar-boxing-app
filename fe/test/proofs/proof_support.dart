import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saroornagar_boxing/core/router/routes.dart';

/// A weekday morning (Thursday 5 November 2026), the day the design artboards show.
DateTime proofClock() => DateTime.utc(2026, 11, 5, 7);

/// The Sunday of the same week.
DateTime proofSundayClock() => DateTime.utc(2026, 11, 8, 7);

/// A tall phone, for screens whose proof needs more than one screenful.
const tallProofSize = Size(390, 1400);

/// Wraps [child] in a router so screens that read the route (back button, go) render.
Widget routed(Widget child) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => child),
      GoRoute(path: Routes.signIn, builder: (_, _) => const SizedBox()),
    ],
  );
  addTearDown(router.dispose);
  return Router(
    routeInformationProvider: router.routeInformationProvider,
    routeInformationParser: router.routeInformationParser,
    routerDelegate: router.routerDelegate,
    backButtonDispatcher: RootBackButtonDispatcher(),
  );
}
