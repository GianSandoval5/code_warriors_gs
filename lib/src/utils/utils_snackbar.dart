import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void showSnackbar(BuildContext context, String message) {
    final bool isDarkMode = context.isDarkMode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: isDarkMode ? AppColors.lightColor : AppColors.red,
        content: Text(
          message,
          style: TextStyle(
              color: isDarkMode ? AppColors.text : AppColors.darkColor,
              fontFamily: "CB"),
        ),
      ),
    );
  }
}

void showSnackbar(BuildContext context, String message) {
  final bool isDarkMode = context.isDarkMode;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 3),
      backgroundColor: isDarkMode ? AppColors.lightColor : AppColors.acentColor,
      content: Text(
        message,
        style: TextStyle(
            color: isDarkMode ? AppColors.darkColor : AppColors.text,
            fontFamily: "CB"),
      ),
    ),
  );
}
