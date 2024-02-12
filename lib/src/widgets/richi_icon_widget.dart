import 'package:code_warriors/src/utils/colors.dart';
import 'package:flutter/material.dart';

class RichiIconTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDarkMode;
  const RichiIconTextWidget({
    super.key,
    required this.icon,
    required this.isDarkMode,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: Icon(icon, color: AppColors.red),
          ),
          const TextSpan(text: '  '),
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
              fontFamily: "CB",
            ),
          ),
        ],
      ),
    );
  }
}
