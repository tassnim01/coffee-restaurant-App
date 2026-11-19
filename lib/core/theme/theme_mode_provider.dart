import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

class ThemeModeProvider extends ChangeNotifier {
  static const _preferenceKey = 'app_dark_mode_enabled';

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  ThemeModeProvider() {
    _load();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    _setMode(preferences.getBool(_preferenceKey) ?? false);
  }

  Future<void> setDarkMode(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_preferenceKey, enabled);
    _setMode(enabled);
  }

  void _setMode(bool enabled) {
    final mode = enabled ? ThemeMode.dark : ThemeMode.light;
    if (_themeMode == mode) return;
    _themeMode = mode;
    AppColors.isDarkMode = enabled;
    notifyListeners();
  }
}
