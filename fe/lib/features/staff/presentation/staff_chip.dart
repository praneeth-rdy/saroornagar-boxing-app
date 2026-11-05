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
  });

  const StaffChip.blocked({super.key})
    : label = 'Blocked',
      tone = StaffChipTone.negative;

  final String label;
  final StaffChipTone tone;

  @override
  Widget build(BuildContext context) {
    final isNegative = tone == StaffChipTone.negative;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isNegative ? AppColors.negativeSoft : AppColors.line,
        borderRadius: AppRadius.chipAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
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
