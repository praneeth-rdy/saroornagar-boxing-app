import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/blocked_screen.dart';

/// The four-tab staff shell; shows the blocked screen instead when the server says so,
/// or its not-staff variant for an account without a profile.
class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    // A retry shows the spinner again instead of keeping the old error on screen.
    return profile.when(
      skipLoadingOnRefresh: false,
      loading: () => const Scaffold(body: LoadingView()),
      error: (error, _) => switch (error) {
        PermissionException() => const BlockedScreen(),
        NotFoundException() => const BlockedScreen.notStaff(),
        _ => Scaffold(
          body: ErrorView(
            message: error is AppException
                ? error.message
                : UnknownException.defaultMessage,
            onRetry: () => ref.invalidate(currentProfileProvider),
          ),
        ),
      },
      data: (staff) => staff.isBlocked
          ? const BlockedScreen()
          : _TabScaffold(navigationShell: navigationShell),
    );
  }
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        // Tapping the open tab again returns it to its root.
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            label: 'Trials',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
