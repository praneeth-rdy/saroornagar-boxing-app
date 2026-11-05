import 'package:flutter/material.dart';

import '../../../core/models/staff_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum StaffChipTone { neutral, negative }

/// A small status pill: a role in neutral, "Blocked" in the negative tone.
class StaffChip extends StatelessWidget {
  const StaffChip({
    super.key,
    required this.label,
    this.tone = StaffChipTone.neutral,
    this.isCompact = false,
  });

  const StaffChip.blocked({super.key, this.isCompact = false})
    : label = 'Blocked',
      tone = StaffChipTone.negative;

  final String label;
  final StaffChipTone tone;

  /// Caption-sized with no vertical padding, to sit beside a list row's title.
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final isNegative = tone == StaffChipTone.negative;
    final textStyle = isCompact
        ? AppTypography.caption.copyWith(fontWeight: FontWeight.w500)
        : AppTypography.label;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isNegative ? AppColors.negativeSoft : AppColors.line,
        borderRadius: AppRadius.chipAll,
      ),
      child: Padding(
        padding: isCompact
            ? const EdgeInsets.symmetric(horizontal: AppSpacing.sm)
            : const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
        child: Text(
          label,
          style: textStyle.copyWith(
            color: isNegative ? AppColors.negative : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

/// `Admin`, `Coach`, or `Staff` for a role the app does not know yet.
String staffRoleLabel(StaffRole role) => switch (role) {
  StaffRole.admin => 'Admin',
  StaffRole.coach => 'Coach',
  StaffRole.unknown => 'Staff',
};
