import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/eyebrow.dart';

const _barHeight = 6.0;

/// How many of the roster are marked present; counts come from the roster only.
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.present, required this.total});

  final int present;
  final int total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Eyebrow('Present'),
          const SizedBox(height: AppSpacing.xs),
          Text('$present', style: AppTypography.title),
          Text(
            present == 0
                ? 'Tap the students who are here.'
                : 'of $total ${total == 1 ? 'student' : 'students'}',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.chipAll,
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : present / total,
              minHeight: _barHeight,
              color: AppColors.accent,
              backgroundColor: AppColors.line,
            ),
          ),
        ],
      ),
    );
  }
}
