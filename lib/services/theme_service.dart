import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  final SharedPreferences sharedPreferences;
  ThemeService(this.sharedPreferences);

  static const darkThemeKey = "dark_theme";
  bool _darktheme = true;

  bool get darkTheme => sharedPreferences.getBool(darkThemeKey) ?? _darktheme;

  set darkTheme(bool value) {
    _darktheme = value;
    sharedPreferences.setBool(darkThemeKey, value);
    notifyListeners();
  }
}
