import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A row inside a list card; it only ripples when it has an [onTap].
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleStyle = AppTypography.bodyStrong,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// A placeholder title passes a hint style so it does not read as a value.
  final TextStyle titleStyle;

  /// Puts a hairline between rows, for the children of an [AppCard] column.
  static List<Widget> divide(List<Widget> rows) => [
    for (var i = 0; i < rows.length; i++) ...[
      if (i > 0) const Divider(),
      rows[i],
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final leadingWidget = leading;
    final subtitleText = subtitle;
    final trailingWidget = trailing;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.listRowMinHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            if (leadingWidget != null) ...[
              leadingWidget,
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: titleStyle),
                  if (subtitleText != null)
                    Text(subtitleText, style: AppTypography.caption),
                ],
              ),
            ),
            if (trailingWidget != null) ...[
              const SizedBox(width: AppSpacing.md),
              trailingWidget,
            ],
          ],
        ),
      ),
    );
    return Material(
      color: AppColors.surface,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
