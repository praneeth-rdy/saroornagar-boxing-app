import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/domain/staff_profile.dart';
import '../../auth/presentation/auth_providers.dart';
import 'staff_admin_gate.dart';
import 'staff_chip.dart';
import 'staff_providers.dart';

/// Every staff account, for an admin to open, add or block.
class StaffListScreen extends ConsumerWidget {
  const StaffListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(currentProfileProvider).value?.isAdmin ?? false;
    void addStaff() => context.push(Routes.staffNew);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff'),
        actions: [if (isAdmin) LinkButton(label: 'Add', onPressed: addStaff)],
      ),
      body: StaffAdminGate(
        builder: (me) => AsyncValueView<List<StaffProfile>>(
          value: ref.watch(staffListProvider),
          onRetry: () => ref.invalidate(staffListProvider),
          isEmpty: (staff) => staff.isEmpty,
          empty: EmptyView(
            title: 'No staff yet',
            message: 'Add a coach or an admin so they can sign in.',
            actionLabel: 'Add staff',
            onAction: addStaff,
          ),
          data: (staff) => ListView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            children: [
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: ListRow.divide([
                    for (final member in staff)
                      _StaffRow(
                        key: ValueKey(member.id),
                        member: member,
                        isSelf: member.id == me.id,
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffRow extends StatelessWidget {
  const _StaffRow({super.key, required this.member, required this.isSelf});

  final StaffProfile member;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: () => context.push(Routes.staffDetailOf(member.id)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.listRowMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                AvatarInitials(name: member.fullName),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _NameAndRole(member: member)),
                if (member.isBlocked) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const StaffChip.blocked(),
                ],
                if (isSelf) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Text('You', style: AppTypography.caption),
                ],
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NameAndRole extends StatelessWidget {
  const _NameAndRole({required this.member});

  final StaffProfile member;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          member.fullName,
          style: member.isBlocked
              ? AppTypography.bodyStrong.copyWith(color: AppColors.muted)
              : AppTypography.bodyStrong,
        ),
        Text(
          '${staffRoleLabel(member.role)} · ${formatPhone(member.phone)}',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}
