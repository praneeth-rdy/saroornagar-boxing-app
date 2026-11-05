import 'package:flutter/material.dart';

import '../../../core/models/attendance_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/india_date.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../domain/roster_entry.dart';

const _statusIconSize = 14.0;
const _toggleIconSize = 22.0;

/// One trainee in the roster with present and absent toggles.
class RosterRow extends StatelessWidget {
  const RosterRow({super.key, required this.entry, required this.onMark});

  final RosterEntry entry;
  final ValueChanged<AttendanceStatus> onMark;

  @override
  Widget build(BuildContext context) {
    final status = entry.status;
    return Material(
      color: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.listRowMinHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              AvatarInitials(name: entry.fullName),
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
                    _StatusLine(entry: entry),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _MarkToggle(
                key: Key('present-${entry.traineeId}'),
                icon: Icons.check,
                label: 'Mark ${entry.fullName} present',
                isSelected: status == AttendanceStatus.present,
                selectedFill: AppColors.accent,
                selectedForeground: AppColors.onAccent,
                onPressed: () => onMark(AttendanceStatus.present),
              ),
              const SizedBox(width: AppSpacing.sm),
              _MarkToggle(
                key: Key('absent-${entry.traineeId}'),
                icon: Icons.close,
                label: 'Mark ${entry.fullName} absent',
                isSelected: status == AttendanceStatus.absent,
                selectedFill: AppColors.line,
                selectedForeground: AppColors.ink,
                onPressed: () => onMark(AttendanceStatus.absent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.entry});

  final RosterEntry entry;

  @override
  Widget build(BuildContext context) {
    final markedStyle = AppTypography.caption.copyWith(color: AppColors.ink);
    final markedAt = entry.markedAt;
    switch (entry.status) {
      case null:
        return const _StatusText('Not marked', style: AppTypography.caption);
      case AttendanceStatus.present:
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
              child: _StatusText(
                markedAt == null
                    ? 'Present'
                    : 'Present, ${formatClockTime(toIndiaTime(markedAt))}',
                style: markedStyle,
              ),
            ),
          ],
        );
      case AttendanceStatus.absent:
        return _StatusText('Absent', style: markedStyle);
      case AttendanceStatus.unknown:
        return _StatusText('Marked', style: markedStyle);
    }
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// A round 44 px toggle; the selected one is filled and taps on it do nothing.
class _MarkToggle extends StatelessWidget {
  const _MarkToggle({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedFill,
    required this.selectedForeground,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedFill;
  final Color selectedForeground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: AppSizes.minTapTarget,
        child: Material(
          color: isSelected ? selectedFill : AppColors.surface,
          shape: CircleBorder(
            side: isSelected
                ? BorderSide.none
                : const BorderSide(
                    color: AppColors.line,
                    width: AppSizes.focusBorder,
                  ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isSelected ? null : onPressed,
            child: Icon(
              icon,
              size: _toggleIconSize,
              color: isSelected ? selectedForeground : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
