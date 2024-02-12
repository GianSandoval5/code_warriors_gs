import 'package:code_warriors/src/pages/admin/producto_page.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:code_warriors/src/widgets/materialbuttom_widget.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  final dynamic userData;
  const AdminPage({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkColor : AppColors.acentColor,
        centerTitle: true,
        title: const Text(
          'Administración',
          style: TextStyle(
            fontFamily: "CB",
            color: AppColors.text,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          MaterialButtomWidget(
            title: "Productos",
            color:
                isDarkMode ? AppColors.acentColor : AppColors.darkAcentsColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductosPage(userData: userData),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
