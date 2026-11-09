import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _pushNotificationsEnabled = true;
  String _readingTransitionMode = 'Horizontal Swipe'; // 'Horizontal Swipe', 'Vertical Scroll', 'Buttons'

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  String get readingTransitionMode => _readingTransitionMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void togglePushNotifications(bool enabled) {
    _pushNotificationsEnabled = enabled;
    notifyListeners();
  }

  void setReadingTransitionMode(String mode) {
    _readingTransitionMode = mode;
    notifyListeners();
  }
}
