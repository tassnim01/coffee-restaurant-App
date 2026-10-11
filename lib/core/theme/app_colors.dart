import 'package:flutter/material.dart';

/// Centralized color palette. The five brand colors are exact.
/// Derived tints are only lighter versions of the beige so surfaces
/// look like the mockup's cream background.
class AppColors {
  AppColors._();

  // ---- Brand palette (exact) ----
  static const Color black = Color(0xFF000000);
  static const Color forestGreen = Color(0xFF44693D);
  static const Color warmBeige = Color(0xFFD5C2A5);
  static const Color burgundy = Color(0xFF7D221D);
  static const Color gray = Color(0xFFA3A3A8);

  // ---- Derived neutrals (tints of the palette) ----
  static const Color background = Color(0xFFF6F0E6); // light beige tint
  static const Color surface = Color(0xFFFBF8F2); // card surface
  static const Color border = Color(0xFFE6DCC8); // soft beige border
  static const Color chipBackground = Color(0xFFEADFCB); // beige tint
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = gray;
  static const Color darkPanel = Color(0xFF0E1A0F); // dark green-black (drawer)
}