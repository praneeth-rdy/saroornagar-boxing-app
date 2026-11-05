import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Direction A as Material 3 theme data: flat surfaces, one accent, no shadows.
abstract final class AppTheme {
  static const _disabledAlpha = 0.4;
  static const _overlayAlpha = 0.08;

  static ThemeData light() {
    const controlShape = RoundedRectangleBorder(
      borderRadius: AppRadius.controlAll,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.ground,
      canvasColor: AppColors.ground,
      shadowColor: AppColors.transparent,
      splashFactory: InkRipple.splashFactory,
      colorScheme: _colorScheme,
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ground,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.transparent,
        centerTitle: false,
        titleTextStyle: AppTypography.heading,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: AppColors.transparent,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: AppSizes.hairline,
        space: AppSizes.hairline,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.transparent,
        elevation: 0,
        indicatorColor: AppColors.accentSoft,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.caption.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.muted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(AppColors.transparent),
          minimumSize: const WidgetStatePropertyAll(
            Size(AppSizes.minTapTarget, AppSizes.controlHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          ),
          shape: const WidgetStatePropertyAll(controlShape),
          textStyle: const WidgetStatePropertyAll(AppTypography.bodyStrong),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.accent.withValues(alpha: _disabledAlpha);
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accentPressed;
            }
            return AppColors.accent;
          }),
          foregroundColor: const WidgetStatePropertyAll(AppColors.onAccent),
          overlayColor: const WidgetStatePropertyAll(AppColors.transparent),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
            Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          shape: const WidgetStatePropertyAll(controlShape),
          textStyle: const WidgetStatePropertyAll(AppTypography.label),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.muted;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accentPressed;
            }
            return AppColors.accent;
          }),
          overlayColor: WidgetStatePropertyAll(
            AppColors.accent.withValues(alpha: _overlayAlpha),
          ),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accent,
        disabledColor: AppColors.ground,
        labelStyle: AppTypography.label,
        secondaryLabelStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          color: AppColors.onAccent,
        ),
        side: BorderSide.none,
        shape: StadiumBorder(),
        showCheckmark: false,
        elevation: 0,
        pressElevation: 0,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        circularTrackColor: AppColors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardAll),
        titleTextStyle: AppTypography.heading,
        contentTextStyle: AppTypography.body,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        modalElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTypography.label.copyWith(
          color: AppColors.onAccent,
        ),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.controlAll),
      ),
    );
  }

  static const _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    primaryContainer: AppColors.accentSoft,
    onPrimaryContainer: AppColors.accent,
    secondary: AppColors.accent,
    onSecondary: AppColors.onAccent,
    secondaryContainer: AppColors.accentSoft,
    onSecondaryContainer: AppColors.accent,
    tertiary: AppColors.positive,
    onTertiary: AppColors.onAccent,
    error: AppColors.negative,
    onError: AppColors.onAccent,
    errorContainer: AppColors.negativeSoft,
    onErrorContainer: AppColors.negative,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.surface,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.surface,
    surfaceContainerHighest: AppColors.ground,
    outline: AppColors.line,
    outlineVariant: AppColors.line,
    shadow: AppColors.transparent,
    scrim: AppColors.ink,
    surfaceTint: AppColors.transparent,
    inverseSurface: AppColors.ink,
    onInverseSurface: AppColors.surface,
    inversePrimary: AppColors.accentSoft,
  );

  static const _textTheme = TextTheme(
    displaySmall: AppTypography.title,
    headlineMedium: AppTypography.title,
    headlineSmall: AppTypography.heading,
    titleLarge: AppTypography.heading,
    titleMedium: AppTypography.bodyStrong,
    titleSmall: AppTypography.label,
    bodyLarge: AppTypography.body,
    bodyMedium: AppTypography.body,
    bodySmall: AppTypography.caption,
    labelLarge: AppTypography.bodyStrong,
    labelMedium: AppTypography.label,
    labelSmall: AppTypography.eyebrow,
  );

  static final _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.lg,
    ),
    hintStyle: AppTypography.body.copyWith(color: AppColors.muted),
    prefixStyle: AppTypography.body,
    errorStyle: AppTypography.caption.copyWith(color: AppColors.negative),
    border: _border(null),
    enabledBorder: _border(null),
    disabledBorder: _border(null),
    focusedBorder: _border(AppColors.accent),
    errorBorder: _border(AppColors.negative),
    focusedErrorBorder: _border(AppColors.negative),
  );

  static OutlineInputBorder _border(Color? color) => OutlineInputBorder(
    borderRadius: AppRadius.controlAll,
    borderSide: color == null
        ? BorderSide.none
        : BorderSide(color: color, width: AppSizes.focusBorder),
  );
}
