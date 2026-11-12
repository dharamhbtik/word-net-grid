import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  
  ThemeService() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme == 'light') {
      state = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      await prefs.setString(_themeKey, 'dark');
    } else {
      state = ThemeMode.light;
      await prefs.setString(_themeKey, 'light');
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeService, ThemeMode>((ref) {
  return ThemeService();
});
