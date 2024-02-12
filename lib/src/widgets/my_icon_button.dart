import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:flutter/material.dart';


class MyIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ImageProvider imageIcon;
  const MyIconButton({
    Key? key,
    required this.onPressed,
    required this.imageIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    return Container(
        width: 50,
      child: MaterialButton(
        height: 50,
        //minWidth: 40,
        onPressed: onPressed,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
        child: ImageIcon(
          imageIcon,
          size: 30,
          color: isDarkMode ? AppColors.darkColor : AppColors.text,
        ),
      ),
    );
  }
}
