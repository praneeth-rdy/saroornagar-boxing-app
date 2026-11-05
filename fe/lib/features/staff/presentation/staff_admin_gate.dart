import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/domain/staff_profile.dart';
import '../../auth/presentation/auth_providers.dart';

/// The copy every staff screen shows to someone who is not an admin.
const staffAdminOnlyMessage = 'Only an admin can manage staff.';

/// Builds [builder] for an admin; everyone else sees the permission view.
class StaffAdminGate extends ConsumerWidget {
  const StaffAdminGate({super.key, required this.builder});

  /// Receives the signed-in admin's own profile.
  final Widget Function(StaffProfile me) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView<StaffProfile>(
      value: ref.watch(currentProfileProvider),
      onRetry: () => ref.invalidate(currentProfileProvider),
      data: (me) => me.isAdmin
          ? builder(me)
          : PermissionDeniedView(
              message: staffAdminOnlyMessage,
              onBack: context.canPop() ? context.pop : null,
            ),
    );
  }
}
