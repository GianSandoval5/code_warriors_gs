import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_warriors/src/pages/inicio_page.dart';
import 'package:code_warriors/src/pages/register/register_page.dart';
import 'package:code_warriors/src/providers/login_provider.dart';
import 'package:code_warriors/src/services/local_storage.dart';
import 'package:code_warriors/src/services/push_notification_service.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/utils_snackbar.dart';
import 'package:code_warriors/src/widgets/circularprogress_widget.dart';
import 'package:code_warriors/src/widgets/input_decoration_widget.dart';
import 'package:code_warriors/src/widgets/materialbuttom_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailOrUserController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscureText = true;
  bool isLoading = false;

  static String? token;

  @override
  void initState() {
    super.initState();
    // en LocalStorage para mostrarlos en los campos de texto
    emailOrUserController.text = LocalStorage().getEmailOrUsername();
    passwordController.text = LocalStorage().getPassword();
    token = PushNotificationService.token;
  }

  void onFormSubmit() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    if (!formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
    });
    // Cerrar el teclado
    FocusScope.of(context).unfocus();
    // Obtener la referencia a la colección de usuarios
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');
    // Obtener el usuario que coincida con el email o nombre de usuario
    final QuerySnapshot resultUsername = await users
        .where('username_lowercase',
            isEqualTo: emailOrUserController.text.toLowerCase())
        .limit(1)
        .get();

    final QuerySnapshot resultEmail = await users
        .where('email', isEqualTo: emailOrUserController.text.toLowerCase())
        .limit(1)
        .get();

    QuerySnapshot result = resultUsername;

    if (resultUsername.docs.isEmpty && resultEmail.docs.isNotEmpty) {
      result = resultEmail;
    }

    if (result.docs.isNotEmpty) {
      // Si existe el usuario, obtener el email
      //final String email = result.docs.first.get('email');
      try {
        // Iniciar sesión con el email y la contraseña
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailOrUserController.text,
          password: passwordController.text,
        );
        // Obtener el usuario actual
        final User? user = FirebaseAuth.instance.currentUser;
        // Si el usuario es diferente de null
        if (user != null) {
          // Verificar si el usuario ha verificado su correo electrónico
          if (!user.emailVerified) {
            // Si el usuario no ha verificado su correo electrónico, mostrar un mensaje de error
            showSnackbar(context, "Por favor, verifica tu correo electrónico");
            setState(() {
              isLoading = false;
            });
            return;
          }

          // Obtener el token del dispositivo
          token = PushNotificationService.token;
          // Actualizar el token del usuario
          await users.doc(user.uid).update({'token': token});

          // Obtener los datos del usuario desde la base de datos
          dynamic userData = await loginProvider.getUserData(user.email!);
          // Guardar datos del usuario en LocalStorage
          await LocalStorage().saveUserData(
              emailOrUserController.text, passwordController.text);
          // Guardar el estado de inicio de sesión en LocalStorage
          await LocalStorage().setIsSignedIn(true);

          // Cambiar el estado de la autenticación
          loginProvider.checkAuthStatus();
          // Navegar a la página de inicio
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => InicioPage(
                  userData: userData,
                ),
              ),
            );
          });
        }
      } catch (e) {
        // Si hay un error al iniciar sesión, mostrar un mensaje de error
        showSnackbar(context, "Contraseña incorrecta");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Si no existe el usuario, mostrar un mensaje de error
      showSnackbar(context, "El usuario no existe");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/cine2.png"),
                fit: BoxFit.contain,
              ),
            ),
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkColor.withOpacity(0.6),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 50,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                " ",
                //"Bienvenido a \nCode Warriors",
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontFamily: "CB",
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.lightColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Login",
                          style: TextStyle(
                            color: AppColors.darkColor,
                            fontSize: 30,
                            fontFamily: "CB",
                          ),
                        ),
                        const SizedBox(height: 20),
                        InputDecorationWidget(
                          hintText: "CodeWarrios@gmail.com",
                          labelText: "Ingresa tu email o usuario",
                          suffixIcon: const Icon(
                            Icons.person,
                            color: AppColors.darkColor,
                          ),
                          controller: emailOrUserController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "El campo no puede estar vacio";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        InputDecorationWidget(
                          hintText: "********",
                          labelText: "Ingresa tu contraseña",
                          maxLines: 1,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.darkColor,
                            ),
                          ),
                          controller: passwordController,
                          obscureText: obscureText,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "El campo no puede estar vacio";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildLoginButton(),
                        const SizedBox(height: 10),
                        // ignore: prefer_const_constructors
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //iniciar con google
                            IconButton(
                              onPressed: () {},
                              icon: Image.asset(
                                "assets/icons/google.png",
                                height: 40,
                                width: 40,
                              ),
                            ),
                            const SizedBox(width: 15),
                            IconButton(
                              onPressed: () {},
                              icon: Image.asset(
                                "assets/icons/facebook.png",
                                height: 40,
                                width: 40,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'No tienes cuenta ??   ',
                            style: const TextStyle(
                              fontFamily: "CM",
                              color: AppColors.darkColor,
                            ),
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Registrate",
                                    style: TextStyle(
                                      fontFamily: "CB",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return isLoading
        ? const CircularProgressWidget(text: "Validando..")
        : MaterialButtomWidget(
            title: "Iniciar sesión",
            color: AppColors.darkColor,
            onPressed: onFormSubmit,
          );
  }
}
