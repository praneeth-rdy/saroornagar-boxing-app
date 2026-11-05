import 'package:flutter/material.dart';

import '../../../core/models/attendance_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/india_date.dart';
import '../domain/roster_entry.dart';

const _statusIconSize = 14.0;
const _toggleIconSize = 22.0;

/// One trainee in the roster with a present toggle; the whole row toggles too.
///
/// Only a present mark counts: a legacy absent or unknown mark shows as unmarked.
class RosterRow extends StatelessWidget {
  const RosterRow({
    super.key,
    required this.entry,
    required this.onMarkPresent,
    required this.onRemoveMark,
  });

  final RosterEntry entry;
  final VoidCallback onMarkPresent;

  /// Called on a tap while present; the caller confirms before removing.
  final VoidCallback onRemoveMark;

  @override
  Widget build(BuildContext context) {
    final isPresent = entry.status == AttendanceStatus.present;
    final onTap = isPresent ? onRemoveMark : onMarkPresent;
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
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
                _RollBadge(rollNo: entry.rollNo),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.fullName,
                        style: AppTypography.bodyStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isPresent) _PresentLine(markedAt: entry.markedAt),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _PresentToggle(
                  key: Key('present-${entry.traineeId}'),
                  label: isPresent
                      ? 'Remove the mark for ${entry.fullName}'
                      : 'Mark ${entry.fullName} present',
                  isPresent: isPresent,
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The roll number called out at roll call, in place of the avatar.
class _RollBadge extends StatelessWidget {
  const _RollBadge({required this.rollNo});

  final int rollNo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Roll number $rollNo',
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: AppSizes.avatar,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.accentSoft,
            shape: BoxShape.circle,
          ),
          // Shrinks a long number or a large text scale to fit the circle.
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$rollNo',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.accent,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PresentLine extends StatelessWidget {
  const _PresentLine({required this.markedAt});

  final DateTime? markedAt;

  @override
  Widget build(BuildContext context) {
    final time = markedAt;
    return Row(
      children: [
        const Icon(
          Icons.check,
          size: _statusIconSize,
          color: AppColors.positive,
        ),
        const SizedBox(width: AppSpacing.xs),
        // Ellipsize at 360 px or a large text scale instead of overflowing.
        Flexible(
          child: Text(
            time == null
                ? 'Present'
                : 'Present, ${formatClockTime(toIndiaTime(time))}',
            style: AppTypography.caption.copyWith(color: AppColors.ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// A round 44 px check: outlined while unmarked, accent filled while present.
class _PresentToggle extends StatelessWidget {
  const _PresentToggle({
    super.key,
    required this.label,
    required this.isPresent,
    required this.onPressed,
  });

  final String label;
  final bool isPresent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: isPresent,
      label: label,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: AppSizes.minTapTarget,
        child: Material(
          color: isPresent ? AppColors.accent : AppColors.surface,
          shape: CircleBorder(
            side: isPresent
                ? BorderSide.none
                : const BorderSide(
                    color: AppColors.line,
                    width: AppSizes.focusBorder,
                  ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Icon(
              Icons.check,
              size: _toggleIconSize,
              color: isPresent ? AppColors.onAccent : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
