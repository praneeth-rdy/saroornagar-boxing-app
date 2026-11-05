import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';
import 'app_text_field.dart';
import 'list_row.dart';

/// A labelled date row that opens a picker; empty, it shows a hint like a text field.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.date,
    required this.onPick,
    this.onClear,
    this.clearLabel = 'Clear date',
    this.helper,
    this.errorText,
    this.isRequired = false,
  });

  static const placeholder = 'Choose a date';

  final String label;
  final DateTime? date;
  final VoidCallback onPick;

  /// Offers a clear button once a date is chosen; leave null for a required date.
  final VoidCallback? onClear;
  final String clearLabel;
  final String? helper;

  /// Shown in place of [helper] when set.
  final String? errorText;

  /// Appends ` *` to the label, as [AppTextField] does.
  final bool isRequired;

  // The same look as the theme's text field hint.
  static final _hintStyle = AppTypography.body.copyWith(color: AppColors.muted);

  @override
  Widget build(BuildContext context) {
    final chosen = date;
    final clear = onClear;
    final error = errorText;
    final helperText = helper;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isRequired ? '$label$requiredMark' : label,
          style: AppTypography.label,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListRow(
            title: chosen == null
                ? placeholder
                : DateFormat('d MMM yyyy').format(chosen),
            titleStyle: chosen == null ? _hintStyle : AppTypography.bodyStrong,
            trailing: chosen == null || clear == null
                ? const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.muted,
                  )
                : IconButton(
                    tooltip: clearLabel,
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    onPressed: clear,
                  ),
            onTap: onPick,
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error,
            style: AppTypography.caption.copyWith(color: AppColors.negative),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(helperText, style: AppTypography.caption),
        ],
      ],
    );
  }
}
