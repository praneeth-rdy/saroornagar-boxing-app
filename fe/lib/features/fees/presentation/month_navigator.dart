import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

/// Steps a month back or forward, never past [latest].
class MonthNavigator extends StatelessWidget {
  const MonthNavigator({
    super.key,
    required this.month,
    required this.latest,
    required this.onChanged,
  });

  /// The first day of the month on show.
  final DateTime month;

  /// The first day of the last month the user may reach, usually the current one.
  final DateTime latest;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = IconButton.styleFrom(
      backgroundColor: AppColors.ground,
      foregroundColor: AppColors.ink,
      disabledBackgroundColor: AppColors.surface,
      disabledForegroundColor: AppColors.line,
      fixedSize: const Size.square(AppSizes.minTapTarget),
    );
    final hasNext = month.isBefore(latest);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous month',
            style: buttonStyle,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onChanged(DateTime(month.year, month.month - 1)),
          ),
          Expanded(
            child: Text(
              DateFormat('MMMM yyyy').format(month),
              style: AppTypography.heading,
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            tooltip: 'Next month',
            style: buttonStyle,
            icon: const Icon(Icons.chevron_right),
            onPressed: hasNext
                ? () => onChanged(DateTime(month.year, month.month + 1))
                : null,
          ),
        ],
      ),
    );
  }
}
