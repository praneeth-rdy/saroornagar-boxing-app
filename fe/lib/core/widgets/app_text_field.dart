import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A labelled input: label above, filled field, error text below in the negative colour.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.prefixText,
    this.suffix,
    this.textInputAction,
    this.onSubmitted,
    this.maxLength,
    this.maxLines = 1,
    this.showCounter = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final String? prefixText;

  /// A trailing control inside the field, such as a show-password toggle.
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;

  /// More than 1 for a multiline field such as notes.
  final int maxLines;

  /// Shows the `n/max` counter; worth it on long fields only.
  final bool showCounter;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final prefix = prefixText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: maxLines > 1 ? maxLines ~/ 2 : null,
          enabled: enabled,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            // prefixText hides until focus; a country code must stay visible.
            prefixIcon: prefix == null
                ? null
                : Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: AppSpacing.lg,
                    ),
                    child: Text(prefix, style: AppTypography.body),
                  ),
            prefixIconConstraints: const BoxConstraints(),
            suffixIcon: suffix,
            contentPadding: prefix == null
                ? null
                : const EdgeInsetsDirectional.only(
                    start: AppSpacing.xs,
                    end: AppSpacing.lg,
                    top: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                  ),
            // The limit is enforced; a running counter is noise on short fields.
            counterText: showCounter ? null : '',
          ),
        ),
      ],
    );
  }
}
