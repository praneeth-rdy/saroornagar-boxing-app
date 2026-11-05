import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../../../core/widgets/inline_banner.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../auth/domain/staff_profile.dart';
import 'reset_password_sheet.dart';
import 'staff_admin_gate.dart';
import 'staff_chip.dart';
import 'staff_providers.dart';

/// One staff member: who they are, and an admin's edit, reset and block actions.
class StaffDetailScreen extends ConsumerWidget {
  const StaffDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff member')),
      body: StaffAdminGate(
        builder: (me) => AsyncValueView<StaffProfile>(
          value: ref.watch(staffMemberProvider(userId)),
          onRetry: () => ref.invalidate(staffListProvider),
          data: (member) =>
              _StaffDetail(member: member, isSelf: member.id == me.id),
        ),
      ),
    );
  }
}

class _StaffDetail extends ConsumerWidget {
  const _StaffDetail({required this.member, required this.isSelf});

  final StaffProfile member;
  final bool isSelf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockChange = ref.watch(staffBlockControllerProvider(member.id));
    final failure = blockChange.isLoading ? null : blockChange.error;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        _HeaderCard(member: member, isSelf: isSelf),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Edit',
          onPressed: () => context.push(Routes.staffEditOf(member.id)),
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Reset password',
          onPressed: () => showResetPasswordSheet(context, member),
        ),
        // The server refuses a self-block, so the action is not offered.
        if (!isSelf) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: blockChange.isLoading
                ? Semantics(
                    label: member.isBlocked ? 'Unblocking' : 'Blocking',
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: SizedBox.square(
                        dimension: AppSizes.spinner,
                        child: CircularProgressIndicator(
                          strokeWidth: AppSizes.spinnerStroke,
                        ),
                      ),
                    ),
                  )
                : LinkButton(
                    label: member.isBlocked ? 'Unblock' : 'Block access',
                    onPressed: () => _confirmBlock(context, ref),
                  ),
          ),
        ],
        if (failure != null) ...[
          const SizedBox(height: AppSpacing.md),
          InlineBanner(
            message: failure is AppException
                ? failure.message
                : UnknownException.defaultMessage,
            tone: InlineBannerTone.error,
          ),
        ],
      ],
    );
  }

  Future<void> _confirmBlock(BuildContext context, WidgetRef ref) async {
    final willBlock = !member.isBlocked;
    final action = willBlock ? 'Block access' : 'Unblock';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          willBlock
              ? 'Block ${member.fullName}?'
              : 'Unblock ${member.fullName}?',
        ),
        content: Text(
          willBlock
              ? 'They will be signed out and cannot use the app until unblocked.'
              : 'They can sign in and use the app again.',
        ),
        actions: [
          LinkButton(
            label: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          LinkButton(
            label: action,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(staffBlockControllerProvider(member.id).notifier)
        .setBlocked(willBlock);
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.member, required this.isSelf});

  final StaffProfile member;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          AvatarInitials(name: member.fullName, size: AppSizes.avatarLarge),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName, style: AppTypography.title),
                const SizedBox(height: AppSpacing.xs),
                Text(member.email, style: AppTypography.caption),
                Text(_phoneLabel(member.phone), style: AppTypography.caption),
                if (isSelf)
                  const Text('This is you', style: AppTypography.caption),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StaffChip(label: staffRoleLabel(member.role)),
                    if (member.isBlocked) const StaffChip.blocked(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _phoneLabel(String? phone) =>
    phone == null ? 'No phone' : formatPhone(phone);
