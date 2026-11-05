import 'package:flutter/material.dart';

import '../errors/app_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// A centred spinner while the first load is in flight.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Loading',
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

/// Nothing to show yet, with the next action when there is one.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    return _StateLayout(
      title: title,
      message: message,
      action: label == null || onAction == null
          ? null
          : PrimaryButton(label: label, onPressed: onAction, isExpanded: false),
    );
  }
}

/// A failed load, with a retry when the caller can offer one.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return _StateLayout(
      title: 'Could not load',
      message: message,
      action: retry == null
          ? null
          : PrimaryButton(
              label: 'Try again',
              onPressed: retry,
              isExpanded: false,
            ),
    );
  }
}

/// The server refused access; offers a way back when there is one.
class PermissionDeniedView extends StatelessWidget {
  const PermissionDeniedView({
    super.key,
    this.message = PermissionException.defaultMessage,
    this.onBack,
  });

  final String message;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final back = onBack;
    return _StateLayout(
      title: 'No access',
      message: message,
      action: back == null
          ? null
          : SecondaryButton(
              label: 'Go back',
              onPressed: back,
              isExpanded: false,
            ),
    );
  }
}

class _StateLayout extends StatelessWidget {
  const _StateLayout({required this.title, required this.message, this.action});

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final actionWidget = action;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSizes.stateViewMaxWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTypography.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTypography.body.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              if (actionWidget != null) ...[
                const SizedBox(height: AppSpacing.xl),
                actionWidget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
