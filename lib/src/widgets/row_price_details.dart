import 'package:code_warriors/src/utils/colors.dart';
import 'package:flutter/material.dart';

class RowPriceDetails extends StatelessWidget {
  final IconData icon;
  final String text;
  final String price;
  final bool isDarkMode;
  const RowPriceDetails({
    super.key,
    required this.icon,
    required this.text,
    required this.price,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.red,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(text,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
                fontFamily: "CB",
              )),
        ),
        const SizedBox(width: 5),
        Text(
          price,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
            fontFamily: "CB",
          ),
        ),
      ],
    );
  }
}
