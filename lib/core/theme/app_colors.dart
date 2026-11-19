import 'package:flutter/material.dart';

/// Centralized brand palette with adaptive surfaces for light and dark modes.
class AppColors {
  AppColors._();

  static bool isDarkMode = false;

  // ---- Brand palette (exact) ----
  static const Color black = Color(0xFF000000);
  static const Color forestGreen = Color(0xFF44693D);
  static const Color warmBeige = Color(0xFFD5C2A5);
  static const Color burgundy = Color(0xFF7D221D);

  // ---- Derived neutrals (tints of the palette) ----
  static Color get background =>
      isDarkMode ? const Color(0xFF121512) : const Color(0xFFF6F0E6);
  static Color get surface =>
      isDarkMode ? const Color(0xFF1D231F) : const Color(0xFFFBF8F2);
  static Color get border =>
      isDarkMode ? const Color(0xFF3C4740) : const Color(0xFFE6DCC8);
  static Color get chipBackground =>
      isDarkMode ? const Color(0xFF2C342E) : const Color(0xFFEADFCB);
  static const Color gray = Color(0xFFA3A3A8);
  static Color get mutedText =>
      isDarkMode ? const Color(0xFFB5B9B5) : const Color(0xFF77766F);
  static Color get brandForeground =>
      isDarkMode ? const Color(0xFF9DBA92) : forestGreen;
  static Color get danger => isDarkMode ? const Color(0xFFE69A91) : burgundy;
  static Color get textPrimary =>
      isDarkMode ? const Color(0xFFF2F2EE) : const Color(0xFF1A1A1A);
  static const Color textSecondary = gray;
  static const Color darkPanel = Color(0xFF0E1A0F); // dark green-black (drawer)
}
