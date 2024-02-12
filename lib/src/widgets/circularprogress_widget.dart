// ignore_for_file: library_private_types_in_public_api

import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:flutter/material.dart';

class CircularProgressWidget extends StatefulWidget {
  final String text;

  const CircularProgressWidget({Key? key, required this.text})
      : super(key: key);

  @override
  _CircularProgressWidgetState createState() => _CircularProgressWidgetState();
}

class _CircularProgressWidgetState extends State<CircularProgressWidget> {
  @override
  void initState() {
    super.initState();
    // Retrasar la finalización de la tarea durante 3 segundos
    Future.delayed(const Duration(seconds: 4), () {
      // Notificar a la aplicación que la tarea ha finalizado
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
            //strokeWidth: 2.5,
          ),
          const SizedBox(width: 15),
          Text(
            widget.text,
            style: TextStyle(
              fontFamily: "CB",
              color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
