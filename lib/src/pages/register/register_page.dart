// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:code_warriors/src/pages/login/login_page.dart';
import 'package:code_warriors/src/providers/register_provider.dart';
import 'package:code_warriors/src/services/push_notification_service.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:code_warriors/src/utils/utils_snackbar.dart';
import 'package:code_warriors/src/validators/validator.dart';
import 'package:code_warriors/src/widgets/circularprogress_widget.dart';
import 'package:code_warriors/src/widgets/input_decoration_widget.dart';
import 'package:code_warriors/src/widgets/materialbuttom_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  File? image;

  bool obscureText = true;
  bool isLoading = false;

  String? username;
  static String? token;
  int? i;

  @override
  void initState() {
    super.initState();
    token = PushNotificationService.token;
    print("token: $token");
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  List<String> usernameSuggestions = [];

//ENVIAR REGISTRO
  void _submitForm() async {
    final registerProvider =
        Provider.of<RegisterProvider>(context, listen: false);
    setState(() {
      isLoading = true; // Establecemos isLoading en true al inicio
    });
    if (!formKey.currentState!.validate()) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    formKey.currentState!.save();

    bool usernameExists = await registerProvider
        .checkUsernameExistsRegister(usernameController.text);
    if (usernameExists) {
      usernameSuggestions =
          generateUsernameSuggestions(usernameController.text);
      showUsernameSuggestionsDialog(context);
      setState(() {
        isLoading = false;
      });
      showSnackbar(context, 'El nombre de usuario se encuentra en uso');
      return;
    }

    // VALIDA SI EL EMAIL YA EXISTE EN LA BD
    bool emailExists =
        await registerProvider.checkEmailExists(emailController.text);
    if (emailExists) {
      setState(() {
        isLoading = false;
      });
      showSnackbar(context, 'El email ya se encuentra en uso');
      return;
    }

    // Obtener la fecha y hora actual
    DateTime now = DateTime.now();

    // Obtener la fecha de nacimiento
    String birthDateStr = birthController.text;
    // Convertir la cadena de fecha de nacimiento a un objeto DateTime
    DateTime birthDate = DateFormat('dd/MM/yyyy').parse(birthDateStr);
    // Calcular la edad a partir de la fecha de nacimiento
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    // Create user account
    try {
      await registerProvider.registerUser(
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        bio: "¡Hola! Soy nuevo en CodeWarriors",
        birth: birthController.text,
        age: age.toString(),
        image: image,
        selectedCiudad: "",
        selectedDepartamento: "",
        token: token!,
        telefono: "",
        rol: "user",
        onError: (errorMessage) {
          setState(() {
            isLoading = false;
            registerProvider.errorMessage = errorMessage;
          });
        },
      );
      // Enviar correo de verificación
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      setState(() {
        isLoading = false;
      });
      showSnackbar(context, "Registro Exitoso, Verifica tu correo electrónico");
      showDialog(
        context: context,
        builder: (_) => WillPopScope(
          onWillPop: () async {
            // Redirigir al usuario a la página de inicio de sesión al presionar "Atrás"
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
            return false; // Impedir el cierre del diálogo
          },
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: AppColors.darkColor,
            title: const Text(
              "Verifica tu correo electrónico",
              style: TextStyle(fontFamily: "CB", color: AppColors.deepOrange),
              textAlign: TextAlign.center,
            ),
            content: Text(
              "Se ha enviado un correo de verificación a ${emailController.text}. Por favor, haz clic en el enlace de verificación en el correo para poder iniciar sesión.",
              style: const TextStyle(fontFamily: "CM", color: AppColors.text),
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: MaterialButton(
                  color: AppColors.acentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () {
                    // Redirigir al usuario a la página de inicio de sesión al presionar "Aceptar"
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    "Aceptar",
                    style:
                        TextStyle(fontFamily: "CB", color: AppColors.darkColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (errorMessage) {
      setState(() {
        isLoading = false;
      });
      // Display error message
      showSnackbar(context, errorMessage.toString());
    }
  }

//LISTA DE SUGERENCIAS DE NOMBRES DE USUARIOS
  List<String> generateUsernameSuggestions(String username) {
    final registerProvider =
        Provider.of<RegisterProvider>(context, listen: false);
    List<String> suggestions = [];
    int suffix1 = 1;
    int suffix2 = 1;
    Set<String> uniqueSuggestions =
        <String>{}; // Utilizamos un conjunto para almacenar sugerencias únicas
    for (int i = 0; i < 3; i++) {
      String suggestedUsername =
          registerProvider.getNextUsername(username, suffix1);
      uniqueSuggestions.add(suggestedUsername);
      suffix1 += 2;

      if (i < 2) {
        String suggestedUsername2 =
            registerProvider.getNextUsername(username, suffix2);
        uniqueSuggestions.add(suggestedUsername2);
        suffix2 += 2;
      }
    }
    suggestions.addAll(uniqueSuggestions
        .toList()); // Convertimos el conjunto a una lista para preservar el orden
    return suggestions;
  }

//SHOWDIALOGO PARA SUGERIR NOMBRES DE USUARIOS
  void showUsernameSuggestionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 15,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Nombre de usuario ya registrado.',
                style: TextStyle(
                    color: AppColors.deepOrange,
                    fontFamily: "CB",
                    fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Estas son algunas sugerencias para tí',
                style: TextStyle(
                    color: AppColors.text, fontFamily: "CB", fontSize: 17),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: usernameSuggestions.length,
              itemBuilder: (BuildContext context, int index) {
                String suggestion = usernameSuggestions[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        color: Colors.primaries[index],
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(
                        suggestion,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontFamily: "CB",
                            letterSpacing: 0.5,
                            fontSize: 17),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        // Cerrar el diálogo y devolver la sugerencia seleccionada
                        Navigator.of(context).pop(suggestion);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    ).then((selectedSuggestion) {
      if (selectedSuggestion != null) {
        // Actualiza el valor del controlador con la sugerencia seleccionada
        setState(() {
          usernameController.text = selectedSuggestion;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = context.isDarkMode;
    final color = isDarkMode ? AppColors.darkColor : AppColors.lightColor;
    final color2 = isDarkMode ? AppColors.lightColor : AppColors.darkColor;
    final color3 = isDarkMode ? AppColors.lightColor : AppColors.text;
    //final color4 = isDarkMode ? AppColors.text : AppColors.lightColor;
    return isLoading
        ? WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                backgroundColor:
                    isDarkMode ? AppColors.darkColor : AppColors.lightColor,
                body: const Center(
                    child: CircularProgressWidget(text: "Registrando..."))))
        : Scaffold(
            backgroundColor: AppColors.lightColor,
            body: CustomScrollView(
              //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: <Widget>[
                const SliverAppBar(
                  iconTheme: IconThemeData(color: Colors.white),
                  backgroundColor: Colors.indigo,
                  expandedHeight: 220,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    //centerTitle: true,
                    //title: Text("hola"),
                    background: FadeInImage(
                      placeholder: AssetImage("assets/gif/loading.gif"),
                      image: AssetImage("assets/images/cine1.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 15),
                      const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: "CB",
                          color: AppColors.darkColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              InputDecorationWidget(
                                hintText: "codeWarrios25",
                                labelText: "Ingresa tu nombre de usuario",
                                suffixIcon: const Icon(
                                  Icons.person,
                                  color: AppColors.darkColor,
                                ),
                                controller: usernameController,
                                keyboardType: TextInputType.text,
                                validator: Validators.validateUsername,
                              ),
                              const SizedBox(height: 20),
                              InputDecorationWidget(
                                hintText: "CodeWarrios@gmail.com",
                                labelText: "Ingresa tu email o usuario",
                                suffixIcon: const Icon(
                                  Icons.email,
                                  color: AppColors.darkColor,
                                ),
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.validateEmail,
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
                                validator: Validators.validatePassword,
                              ),
                              const SizedBox(height: 20),
                              InputDecorationWidget(
                                labelText: "Fecha de nacimiento",
                                hintText: "20/12/2023",
                                suffixIcon: const Icon(
                                  Icons.calendar_month_rounded,
                                  color: AppColors.darkColor,
                                ),
                                controller: birthController,
                                validator: Validators.birthValidator,
                                keyboardType: TextInputType.datetime,
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedData = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2500),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: color2,
                                            onPrimary: color3,
                                            surface: color,
                                            onSurface: color2,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(
                                                color2,
                                              ),
                                              textStyle: MaterialStateProperty
                                                  .all<TextStyle>(
                                                const TextStyle(
                                                  fontFamily: "CB",
                                                ),
                                              ),
                                            ),
                                          ),
                                          //Color de fondo
                                          dialogBackgroundColor: color3,
                                          textTheme: ThemeData.light()
                                              .textTheme
                                              .copyWith(
                                                titleLarge: TextStyle(
                                                  fontFamily: "CB",
                                                  fontSize: 20,
                                                  color: color2,
                                                ),
                                              ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedData != null) {
                                    final DateFormat formatter =
                                        DateFormat('dd/MM/yyyy');
                                    String formattedDate =
                                        formatter.format(pickedData);
                                    setState(() {
                                      birthController.text = formattedDate;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 30),
                              MaterialButtomWidget(
                                title: "Registrate",
                                color: AppColors.darkColor,
                                onPressed: () {
                                  _submitForm();
                                },
                              ),
                              const SizedBox(height: 20),
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
                                  text: 'Ya tienes cuenta ??   ',
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
                                                  const LoginPage(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Inicia Sesión",
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
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
