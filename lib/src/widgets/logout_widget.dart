// ignore_for_file: use_build_context_synchronously

import 'package:code_warriors/src/pages/login/login_page.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:code_warriors/src/utils/export.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogoutWidget extends StatelessWidget {
  const LogoutWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: MaterialButton(
        child: Icon(
          Icons.logout,
          color: isDarkMode ? AppColors.darkColor : AppColors.lightColor,
        ),
        onPressed: () async {
          final confirm = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor:
                  isDarkMode ? AppColors.darkColor : AppColors.lightColor,
              title: const Text(
                "Cerrar sesión",
                style: TextStyle(
                  fontFamily: "CB",
                  color: AppColors.deepOrange,
                ),
                textAlign: TextAlign.center,
              ),
              content: Text(
                "¿Estás seguro de que deseas cerrar sesión?",
                style: TextStyle(
                  fontFamily: "CM",
                  color:
                      isDarkMode ? AppColors.lightColor : AppColors.darkColor,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      color: AppColors.acentColor,
                      splashColor: AppColors.deepOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () {
                        Navigator.of(context).pop(false); // No confirmado
                      },
                      child: const Text(
                        "No",
                        style: TextStyle(
                          fontFamily: "CB",
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    MaterialButton(
                      color: AppColors.deepOrange.withAlpha(200),
                      splashColor: AppColors.acentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () {
                        Navigator.of(context).pop(true); // Confirmado
                      },
                      child: const Text(
                        "Sí",
                        style: TextStyle(
                          fontFamily: "CB",
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );

          if (confirm == true) {
            await Provider.of<LoginProvider>(context, listen: false)
                .logoutApp();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          }
        },
      ),
    );
  }
}
