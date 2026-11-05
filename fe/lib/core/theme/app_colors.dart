import 'package:flutter/painting.dart';

/// Design direction A colour tokens; nothing outside lib/core/theme names a colour.
abstract final class AppColors {
  static const ground = Color(0xFFF5F5F7);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1D1D1F);
  static const muted = Color(0xFF6E6E73);

  /// Hairline between rows inside a list card only.
  static const line = Color(0xFFE5E5EA);
  static const accent = Color(0xFF0A5FD6);
  static const accentPressed = Color(0xFF084BAA);

  /// Fill of a selected chip and of soft accent surfaces.
  static const accentSoft = Color(0xFFE8F0FC);
  static const negative = Color(0xFFB3261E);
  static const negativeSoft = Color(0xFFFBEAE8);

  /// Reserved for the present mark.
  static const positive = Color(0xFF1E7F4F);
  static const onAccent = Color(0xFFFFFFFF);
  static const transparent = Color(0x00000000);
}
