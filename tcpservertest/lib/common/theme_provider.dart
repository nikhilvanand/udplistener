import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required this.isDark});
  bool isDark;
  bool changeTheme() {
    isDark = !isDark;
    notifyListeners();
    return isDark;
  }
}
