import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/staff_role.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/list_row.dart';
import '../../auth/domain/staff_profile.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../auth/presentation/sign_out_button.dart';

/// The signed-in staff member's profile, reports, staff admin for admins, and sign-out.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: AsyncValueView<StaffProfile>(
        value: ref.watch(currentProfileProvider),
        onRetry: () => ref.invalidate(currentProfileProvider),
        data: (profile) => ListView(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              child: ListRow(
                leading: AvatarInitials(name: profile.fullName),
                title: profile.fullName,
                subtitle:
                    '${formatPhone(profile.phone)} · ${_roleLabel(profile.role)}',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Eyebrow('Reports'),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: ListRow.divide([
                  ListRow(
                    title: 'Fee status',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.muted,
                    ),
                    onTap: () => context.push(Routes.feeStatus),
                  ),
                  ListRow(
                    title: 'Monthly attendance',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.muted,
                    ),
                    onTap: () => context.push(Routes.attendanceSummary),
                  ),
                ]),
              ),
            ),
            if (profile.isAdmin) ...[
              const SizedBox(height: AppSpacing.xl),
              const Eyebrow('Admin'),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                padding: EdgeInsets.zero,
                child: ListRow(
                  title: 'Staff',
                  subtitle: 'Add coaches, reset passwords, block access',
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.muted,
                  ),
                  onTap: () => context.push(Routes.staff),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            const SignOutButton(),
          ],
        ),
      ),
    );
  }
}

String _roleLabel(StaffRole role) => switch (role) {
  StaffRole.admin => 'Admin',
  StaffRole.coach => 'Coach',
  StaffRole.unknown => 'Staff',
};
