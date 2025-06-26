import 'package:code_warriors/src/providers/theme_controller.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:code_warriors/src/widgets/logout_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final dynamic userData;
  const ProfilePage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    'Perfil',
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: "CB",
                      color: isDarkMode ? AppColors.text : AppColors.darkColor,
                    ),
                  ),
                ),
                const Spacer(),
                const LogoutWidget(),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.red.withAlpha(55),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color:
                            isDarkMode ? AppColors.text : AppColors.acentColor,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: FadeInImage(
                        placeholder: const AssetImage('assets/gif/loading.gif'),
                        image: NetworkImage(userData['imageUser']),
                        imageErrorBuilder: (context, error, stackTrace) =>
                            const Image(
                          image: AssetImage('assets/images/avatar3.png'),
                          fit: BoxFit.cover,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['username'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: "CB",
                          ),
                        ),
                        Text(
                          userData['biografia'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.red,
                            fontFamily: "CM",
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Preferencias",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "CB",
                  color: isDarkMode ? AppColors.text : AppColors.darkColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                leading: isDarkMode
                    ? Image.asset(
                        'assets/icons/noche2.png',
                        height: 30,
                        color:
                            isDarkMode ? AppColors.text : AppColors.darkColor,
                      )
                    : Image.asset(
                        'assets/icons/dia1.png',
                        height: 30,
                        color:
                            isDarkMode ? AppColors.text : AppColors.darkColor,
                      ),
                title: Text(
                  isDarkMode ? "Modo Oscuro" : "Modo Claro",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "CB",
                    color: isDarkMode ? AppColors.text : AppColors.darkColor,
                  ),
                ),
                trailing: Consumer<ThemeController>(
                  builder: (_, controller, _) => Switch(
                    value: controller.isDarkMode,
                    onChanged: (value) {
                      controller.toggle();
                    },
                    activeColor: AppColors.text,
                    activeTrackColor: AppColors.red,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: isDarkMode ? AppColors.text : AppColors.darkColor,
                ),
                title: Text(
                  "Notificaciones",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "CB",
                    color: isDarkMode ? AppColors.text : AppColors.darkColor,
                  ),
                ),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: AppColors.text,
                  activeTrackColor: AppColors.red,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListTile(
                leading: Icon(
                  Icons.language,
                  color: isDarkMode ? AppColors.text : AppColors.darkColor,
                ),
                title: Text(
                  "Idioma",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "CB",
                    color: isDarkMode ? AppColors.text : AppColors.darkColor,
                  ),
                ),
                trailing: Text(
                  "Español",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "CB",
                    color: isDarkMode ? AppColors.text : AppColors.darkColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
