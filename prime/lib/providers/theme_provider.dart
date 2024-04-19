import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType { light, dark }

class ThemeProvider with ChangeNotifier {
  var _themeMode = ThemeModeType.light;
  final String _themeKey = 'theme_mode';

  ThemeModeType get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    int? mode = sharedPreferences.getInt(_themeKey);
    if (mode != null) {
      _themeMode = ThemeModeType.values[mode];
    } else {
      _themeMode = ThemeModeType.light;
      await _saveThemeMode(_themeMode);
    }
    notifyListeners();
  }

  Future<void> _saveThemeMode(ThemeModeType mode) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setInt(_themeKey, mode.index);
  }

  void setThemeMode(ThemeModeType mode) {
    _saveThemeMode(mode);
    _themeMode = mode;
    notifyListeners();
  }
}
