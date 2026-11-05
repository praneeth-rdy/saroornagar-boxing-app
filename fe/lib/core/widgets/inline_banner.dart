import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'link_button.dart';

enum InlineBannerTone { info, error }

/// A short notice inside a screen (up to three lines), with an optional retry.
class InlineBanner extends StatelessWidget {
  const InlineBanner({
    super.key,
    required this.message,
    this.tone = InlineBannerTone.info,
    this.onRetry,
  });

  final String message;
  final InlineBannerTone tone;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isError = tone == InlineBannerTone.error;
    final retry = onRetry;
    return Semantics(
      liveRegion: isError,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isError ? AppColors.negativeSoft : AppColors.accentSoft,
          borderRadius: AppRadius.controlAll,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: retry == null ? AppSpacing.lg : AppSpacing.xs,
            top: AppSpacing.xs,
            bottom: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label.copyWith(
                      color: isError ? AppColors.negative : AppColors.ink,
                    ),
                  ),
                ),
              ),
              if (retry != null) LinkButton(label: 'Retry', onPressed: retry),
            ],
          ),
        ),
      ),
    );
  }
}
