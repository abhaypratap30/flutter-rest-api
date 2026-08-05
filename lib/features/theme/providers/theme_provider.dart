import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rest_api/core/config/app_constants.dart';
import 'package:flutter_rest_api/core/providers/core_providers.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final dynamic _prefs;

  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedMode = _prefs.getString(AppConstants.keyThemeMode);
    if (savedMode == 'dark') {
      state = ThemeMode.dark;
    } else if (savedMode == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      _prefs.setString(AppConstants.keyThemeMode, 'light');
    } else {
      state = ThemeMode.dark;
      _prefs.setString(AppConstants.keyThemeMode, 'dark');
    }
  }
}
