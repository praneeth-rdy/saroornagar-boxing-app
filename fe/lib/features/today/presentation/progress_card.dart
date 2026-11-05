import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/eyebrow.dart';

const _barHeight = 6.0;

/// How much of the roster is marked; counts come from the roster only.
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.marked, required this.total});

  final int marked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final remaining = total - marked;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(child: Eyebrow('Marked')),
              Text(
                remaining > 0 ? '$remaining to go' : 'Everyone marked',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('$marked of $total', style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.chipAll,
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : marked / total,
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
