import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet_test/core/theme/app_colors.dart';
import 'package:projet_test/core/theme/theme_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists dark mode and updates the app color palette', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ThemeModeProvider();
    addTearDown(provider.dispose);

    await provider.setDarkMode(true);
    final preferences = await SharedPreferences.getInstance();

    expect(provider.themeMode, ThemeMode.dark);
    expect(preferences.getBool('app_dark_mode_enabled'), isTrue);
    expect(AppColors.background, const Color(0xFF121512));
    expect(AppColors.surface, const Color(0xFF1D231F));
    expect(AppColors.chipBackground, const Color(0xFF2C342E));

    await provider.setDarkMode(false);
    expect(provider.themeMode, ThemeMode.light);
    expect(AppColors.background, const Color(0xFFF6F0E6));
    expect(AppColors.chipBackground, const Color(0xFFEADFCB));
  });
}
