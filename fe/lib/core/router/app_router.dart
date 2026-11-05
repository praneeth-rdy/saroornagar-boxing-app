import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/shell/presentation/shell_screen.dart';
import '../../features/today/presentation/today_screen.dart';
import '../../features/trainees/presentation/trainees_screen.dart';
import '../../features/trials/presentation/trials_screen.dart';
import '../di/repository_providers.dart';
import 'route_guards.dart';
import 'routes.dart';

/// The app's router; built once and re-run through the guard on every session change.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<bool>(
    ref.read(authRepositoryProvider).hasSession,
  );
  ref.listen<AsyncValue<bool>>(sessionProvider, (_, next) {
    final hasSession = next.value;
    if (hasSession != null) session.value = hasSession;
  });

  final router = GoRouter(
    initialLocation: Routes.today,
    refreshListenable: session,
    redirect: (_, state) =>
        redirectFor(hasSession: session.value, location: state.uri.path),
    routes: [
      GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            ShellScreen(navigationShell: navigationShell),
        branches: [
          _branch(Routes.today, const TodayScreen()),
          _branch(Routes.trainees, const TraineesScreen()),
          _branch(Routes.trials, const TrialsScreen()),
          _branch(Routes.more, const MoreScreen()),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    session.dispose();
  });
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (_, _) => screen)],
);
