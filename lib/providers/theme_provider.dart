import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  SharedPreferences? _prefs;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final SharedPreferences prefs = await _preferences();
    final String savedThemeMode = prefs.getString(_themeKey) ?? 'system';
    _themeMode = _themeModeFromName(savedThemeMode);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    final SharedPreferences prefs = await _preferences();
    _themeMode = themeMode;
    await prefs.setString(_themeKey, themeMode.name);
    notifyListeners();
  }

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  ThemeMode _themeModeFromName(String name) {
    for (final ThemeMode themeMode in ThemeMode.values) {
      if (themeMode.name == name) return themeMode;
    }
    return ThemeMode.system;
  }
}
