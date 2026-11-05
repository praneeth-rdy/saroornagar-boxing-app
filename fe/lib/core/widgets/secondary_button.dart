import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

/// A quieter action beside or below a [PrimaryButton]: surface fill, ink text; a spinner
/// replaces the label while busy.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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

  static final _style = ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.pressed)
          ? AppColors.line
          : AppColors.surface,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? AppColors.muted
          : AppColors.ink,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      style: _style,
      onPressed: isBusy ? null : onPressed,
      child: isBusy
          ? Semantics(
              label: label,
              child: const SizedBox.square(
                dimension: AppSizes.spinner,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizes.spinnerStroke,
                  color: AppColors.ink,
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
