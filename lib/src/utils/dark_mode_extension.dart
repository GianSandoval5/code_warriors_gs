import 'package:flutter/material.dart' show BuildContext, ThemeData, Brightness, Theme;

extension DarkModeExtension on BuildContext {
  bool get isDarkMode {
    final ThemeData theme = Theme.of(this);
    return theme.brightness == Brightness.dark;
  }
}
