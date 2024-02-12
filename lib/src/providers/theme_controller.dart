import 'package:code_warriors/src/controllers/settings_repository.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class ThemeController extends ChangeNotifier {
  final SettingsRepository _settings = GetIt.I.get();

  late bool _isDarkMode;
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeController() {
    _isDarkMode = _settings.isDarkMode;
    if (isDarkMode) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.light,
      );
    }
  }

  // TextTheme get _textTheme {
  //   return GoogleFonts.latoTextTheme();
  // }

  ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.lightColor,
        ),
      ),
      //textTheme: _textTheme,
      splashColor: AppColors.text,
      primaryColorLight: AppColors.lightColor,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: MaterialColor(AppColors.lightColor.value, swatch),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkColor,
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkColor,
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: AppColors.darkColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      //textTheme: _textTheme,
      scaffoldBackgroundColor: AppColors.darkColor,
      primaryColorDark: AppColors.darkColor,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.darkColor,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(AppColors.acentColor),
        trackColor: MaterialStateProperty.all(
          AppColors.acentColor.withOpacity(0.6),
        ),
      ),
    );
  }

  void toggle() {
    _isDarkMode = !isDarkMode;
    _settings.updateDarkMode(isDarkMode);
    if (isDarkMode) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.light,
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark,
      );
    }
    notifyListeners();
  }
}
