import 'package:code_warriors/src/utils/colors.dart';
import 'package:flutter/material.dart';

class MaterialButtomWidget extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onPressed;
  const MaterialButtomWidget(
      {super.key,
      required this.title,
      required this.color,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: MaterialButton(
        height: 50,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontFamily: "CB",
            ),
          ),
        ),
      ),
    );
  }
}
