import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// One pill in a [ChoiceRow].
class ChoiceOption<T> {
  const ChoiceOption({required this.value, required this.label, this.caption});

  final T value;
  final String label;
  final String? caption;
}

/// Single-choice pills that wrap onto new lines; the selected pill takes the accent.
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<ChoiceOption<T>> options;
  final T? selected;
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          _ChoicePill<T>(
            option: option,
            isSelected: option.value == selected,
            onSelected: onSelected,
          ),
      ],
    );
  }
}

class _ChoicePill<T> extends StatelessWidget {
  const _ChoicePill({
    required this.option,
    required this.isSelected,
    required this.onSelected,
  });

  final ChoiceOption<T> option;
  final bool isSelected;
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? AppColors.onAccent : AppColors.ink;
    final caption = option.caption;
    final select = onSelected;
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? AppColors.accent : AppColors.surface,
        borderRadius: AppRadius.chipAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: select == null ? null : () => select(option.value),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    option.label,
                    style: AppTypography.label.copyWith(
                      color: foreground,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  ),
                  if (caption != null)
                    Text(
                      caption,
                      style: AppTypography.caption.copyWith(
                        color: isSelected ? AppColors.onAccent : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
