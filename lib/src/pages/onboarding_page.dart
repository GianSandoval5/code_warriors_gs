// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unrelated_type_equality_checks

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_warriors/src/pages/inicio_page.dart';
import 'package:code_warriors/src/pages/login/login_page.dart';
import 'package:code_warriors/src/providers/login_provider.dart';
import 'package:code_warriors/src/services/local_storage.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/widgets/circularprogress_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:provider/provider.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  int page = 0;
  final LiquidController liquidController = LiquidController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkPreviousSession();
  }

  void checkPreviousSession() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final emailOrUserController = LocalStorage().getEmailOrUsername();
    final passwordController = LocalStorage().getPassword();
    setState(() {
      isLoading = true;
    });

    if (emailOrUserController.isEmpty || passwordController.isEmpty) {
      setState(() {
        isLoading = false;
      });
      // Si no existe emailOrUsername o password, navegar al onboarding
      return;
    }

    // Obtener la referencia a la colección de users
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');

    // Obtener el usuario que coincida con el email o username
    final QuerySnapshot resultUsername = await users
        .where('username_lowercase',
            isEqualTo: emailOrUserController.toLowerCase())
        .limit(1)
        .get();

    final QuerySnapshot resultEmail = await users
        .where('email', isEqualTo: emailOrUserController.toLowerCase())
        .limit(1)
        .get();

    QuerySnapshot result = resultUsername;

    if (resultUsername.docs.isEmpty && resultEmail.docs.isNotEmpty) {
      result = resultEmail;
    }

    // Verificar si ya ha iniciado sesión
    final isLoggedIn = LocalStorage().setIsLoggedIn(true);

    if (result.docs.isNotEmpty) {
      // Si existe el usuario, obtener el email
      final String email = result.docs.first.get('email');
      final UserCredential? userCredential =
          await loginProvider.loginUser(email, passwordController);
      final User? user = userCredential?.user;

      if (isLoggedIn != false && user != null) {
        // Si ya ha iniciado sesión, obtener datos del usuario y navegar a InicioPage
        // Obtener los datos del usuario desde la base de datos
        dynamic userData = await loginProvider.getUserData(user.email!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InicioPage(
              userData: userData,
            ),
          ),
        );
      } else {
        // Si no es la primera vez, navegar a LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressWidget(
                text: "Cargando...",
              ),
            )
          : Stack(
              children: [
                LiquidSwipe(
                  liquidController: liquidController,
                  waveType: WaveType.liquidReveal,
                  enableLoop: false,
                  enableSideReveal: true,
                  preferDragFromRevealedArea: true,
                  ignoreUserGestureWhileAnimating: true,
                  fullTransitionValue: 500,
                  onPageChangeCallback: (index) => setState(() => page = index),
                  positionSlideIcon: 0.92,
                  slideIconWidget: page == 2
                      // Widget vacío cuando page == 2
                      ? const SizedBox.shrink()
                      : const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 30,
                          color: AppColors.text,
                        ),
                  pages: [
                    buildPage(
                      "Bienvenido a\nCode Warriors",
                      "Descubre y disfruta de las mejores películas. ¡Compra tus entradas y vive la experiencia en el cine!",
                      "assets/images/peli1.jpg",
                    ),
                    buildPage(
                      "Explora",
                      "Explora entre miles de películas de diferentes géneros. Encuentra la película perfecta para tu próxima salida al cine.",
                      "assets/images/peli2.jpg",
                    ),
                    buildPage(
                      "Guarda tus favoritos",
                      "Guarda tus películas favoritas y míralas cuando quieras. ¡Compra tus entradas online y ahorra tiempo en la cola del cine!",
                      "assets/images/peli3.jpg",
                    ),
                  ],
                ),
                if (page != 0)
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: MaterialButton(
                      color: AppColors.greenColor2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Atrás",
                            style: TextStyle(
                                color: AppColors.text,
                                fontSize: 16,
                                fontFamily: "CB")),
                      ),
                      onPressed: () => liquidController.animateToPage(
                          page: page - 1, duration: 350),
                    ),
                  ),
                if (page == 2)
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: InkWell(
                      child: MaterialButton(
                        color: AppColors.acentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Continuar",
                            style: TextStyle(
                                fontSize: 16,
                                color: AppColors.text,
                                fontFamily: "CB"),
                          ),
                        ),
                        onPressed: () {
                          if (page == 2) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                              (Route<dynamic> route) => false,
                            );
                          } else {
                            liquidController.animateToPage(
                                page: page + 1, duration: 350);
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget buildPage(String title, String subtitle, String imagePath) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  stops: const [0.6, 1.0],
                  colors: [
                    AppColors.darkColor.withAlpha(220),
                    AppColors.darkColor.withAlpha(0),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 30,
                          fontFamily: "CB",
                          color: AppColors.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "CM",
                          color: AppColors.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
        //bottom de omitir
        Positioned(
          top: 25,
          right: 10,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: MaterialButton(
              color: AppColors.acentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Omitir",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.text,
                      fontFamily: "CB",
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
