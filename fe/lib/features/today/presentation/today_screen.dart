import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/state_views.dart';
import '../../auth/presentation/auth_providers.dart';

// Temporary stub: release 1 run 2 replaces it with the real Today tab.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: EmptyView(
        title: 'Coming next',
        message: 'Today arrives with the next update.',
        actionLabel: 'Sign out',
        // More reports a failed sign-out; the stub only offers the way out.
        onAction: () => ref.read(signOutProvider)().ignore(),
      ),
    );
  }
}
