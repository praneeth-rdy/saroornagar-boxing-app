import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

/// The one accent action on a screen; a spinner replaces the label while busy.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isBusy = false,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: isBusy ? null : onPressed,
      child: isBusy
          ? Semantics(
              label: label,
              child: const SizedBox.square(
                dimension: AppSizes.spinner,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizes.spinnerStroke,
                  color: AppColors.onAccent,
                ),
              ),
            )
          : Text(label),
    );
    return isExpanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
