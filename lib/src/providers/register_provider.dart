// ignore_for_file: unrelated_type_equality_checks, avoid_print, use_build_context_synchronously, unused_field

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_warriors/src/services/local_storage.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/utils_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum UserRole { admin, manager, user }

class RegisterProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final String _verificationId = '';
  String get verificationId => _verificationId;

  File? _image;
  File? get image => _image;

  set image(File? value) {
    _image = value;
    notifyListeners();
  }

  String? _uid;
  String get uid => _uid!;

  String _errorMessage = '';

  set errorMessage(String errorMessage) {
    _errorMessage = errorMessage;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  int? i;

  RegisterProvider() {
    checkSign();
  }

  Future<void> checkSign() async {
    await LocalStorage().init(); // Inicializar LocalStorage
    _isSignedIn = LocalStorage().getIsSignedIn();
    notifyListeners();
  }

  Future<void> setSignedIn() async {
    await LocalStorage().init(); // Inicializar LocalStorage
    LocalStorage().setIsSignedIn(true);
    _isSignedIn = true;
    notifyListeners();
  }

  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  Future<void> checkLoggedIn() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Simulando tiempo de espera
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Usuario ya ha iniciado sesión
      _isLoading = false;
    } else {
      _isLoading = false;
    }
    notifyListeners();
  }

//PARA REGISTRAR USUARIOS
  Future<void> registerUser({
    required String username,
    required String email,
    required String password,
    required String bio,
    required String token,
    required String selectedCiudad,
    required String selectedDepartamento,
    required String telefono,
    required String birth,
    required String rol,
    required String age,
    required File? image,
    //required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // Convertir el nombre de usuario a minúsculas
      final String usernameLower = username.toLowerCase();
      // Convertir el correo electrónico a minúsculas
      final String emailLower = email.toLowerCase();

      // Verificar si el nombre de usuario en minúsculas ya existe en la base de datos
      final bool usernameExists =
          await checkUsernameExistsRegister(usernameLower);
      if (usernameExists) {
        onError('El nombre de usuario ya está registrado');
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtener la fecha y hora actual
      DateTime now = DateTime.now();
      // Formatear la fecha y hora actual como una cadena
      String createdAt = DateFormat('dd-MM-yyyy HH:mm:ss').format(now);

      final User user = userCredential.user!;
      //IDENTIFICADOR UNICO PARA EL USUARIO
      String userId = user.uid;

      String imageUrl = '';
      if (image != null) {
        // Obtener el ID del usuario
        String userId = user.uid;

        // Construir el nuevo nombre de la imagen usando el ID del usuario
        String newImageName = 'users/$username/$userId.jpg';

        // Guardar la imagen con el nuevo nombre
        imageUrl = await storeFileStorage(newImageName, image);
      }
      

      final userData = {
        'id': userId,
        'username': username,
        'username_lowercase': usernameLower,
        'email': emailLower,
        'password': password,
        'birth': birth,
        'departamento': selectedDepartamento,
        'ciudad': selectedCiudad,
        'imageUser': imageUrl,
        'telefono': telefono,
        'biografia': bio,
        'createdAt': createdAt,
        'edad': age,
        'token': token,
        'estado': true,
        'premium': false,
        'aprobado': false,
        'verificado': false,
        'favoritos': 0,
        'compartidos': 0,
        'favoritosJson': [],
        'compartidosJson': [],
        'rol': rol,
      };

      await firestore.collection('users').doc(user.uid).set(userData);

      if (rol == UserRole.admin) {
        await firestore.collection('users').doc(user.uid).set(
          {'rol': 'admin'},
          SetOptions(merge: true),
        );
      } else if (rol == UserRole.manager) {
        await firestore.collection('users').doc(user.uid).set(
          {'rol': 'manager'},
          SetOptions(merge: true),
        );
      } else if (rol == UserRole.user) {
        await firestore.collection('users').doc(user.uid).set(
          {'rol': 'user'},
          SetOptions(merge: true),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        onError('La contraseña es demasiado débil');
      } else if (e.code == 'email-already-in-use') {
        onError('Ya existe una cuenta con este correo electrónico');
      } else {
        onError('Ha ocurrido un error durante el registro');
      }
    } catch (e) {
      onError('Ha ocurrido un error durante el registro');
    }
  }

//VERIFICA SI EL NOMBRE DE USUARIO EN MINUSCULA YA SE ENCUENTRA EN LA BASE DE DATOS
  Future<bool> checkUsernameExistsRegister(String username) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username_lowercase', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

//VERIFICA SI EL NOMBRE DE USUARIO YA SE ENCUENTRA EN LA BASE DE DATOS
  Future<bool> checkUsernameExists(String username) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

//SUGERIR NOMBRES DE USUARIO
  String getNextUsername(String username, int suffix) {
    // Obtener el último sufijo numérico utilizado en los nombres de usuario
    final lastSuffix = getLastUsernameSuffix(username);

    // Incrementar el sufijo numérico para sugerir un nuevo nombre de usuario
    final nextSuffix = lastSuffix + suffix;

    // Construir el nuevo nombre de usuario sugerido
    final nextUsername = '$username$nextSuffix';

    return nextUsername;
  }

  int getLastUsernameSuffix(String username) {
    final regex = RegExp(r'(\d+)$');
    final match = regex.firstMatch(username);
    if (match != null) {
      final suffix = match.group(1);
      return int.parse(suffix!);
    }
    return 0;
  }

//VERIFICA SI EL EMAIL YA SE ENCUENTRA EN LA BASE DE DATOS
  Future<bool> checkEmailExists(String email) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

//VERIFICA SI EL NUM DE TELEFONO YA SE ENCUENTRA EN LA BASE DE DATOS
  Future<bool> checkPhoneExists(String telefono) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('telefono', whereIn: [telefono, '+51$telefono'])
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

//ELIMINAR CUENTA DE USUARIO
  Future<void> deleteAccount(BuildContext context) async {
    try {
      // Obtén el usuario actual
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        // No hay usuario autenticado
        showSnackbar(context, 'No hay usuario autenticado');
        print('No hay usuario autenticado');
        return;
      }

      // Mostrar un diálogo de confirmación
      bool confirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.darkColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titleTextStyle: const TextStyle(
                fontFamily: "CB",
                color: AppColors.deepOrange,
                fontSize: 20,
                letterSpacing: 0.5),
            contentTextStyle: const TextStyle(
                fontFamily: "CB",
                color: AppColors.text,
                fontSize: 17,
                letterSpacing: 0.5),
            title: const Text(
              'Confirmar eliminación',
              textAlign: TextAlign.center,
            ),
            content: const Text(
              '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    color: AppColors.acentColor,
                    splashColor: AppColors.deepOrange.withAlpha(200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                          fontFamily: "CB",
                          color: AppColors.darkColor,
                          fontSize: 17),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) =>
                      //             const PerfilUsuario()));
                      //Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  const SizedBox(width: 20),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: AppColors.deepOrange.withAlpha(200),
                    splashColor: AppColors.acentColor,
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(
                          fontFamily: "CB",
                          color: AppColors.darkColor,
                          fontSize: 17),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        // El usuario canceló la eliminación
        showSnackbar(context, "Se cancelo la eliminación de la cuenta");
        return;
      }

      final userId = currentUser.uid;

      // Eliminar la imagen del usuario en el almacenamiento
      final firebaseStorageRef =
          FirebaseStorage.instance.ref().child('users').child('$userId.jpg');
      await firebaseStorageRef.delete();

      // Eliminar el documento correspondiente de Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      // Eliminar el usuario de la autenticación
      await currentUser.delete();

      // Mostrar un mensaje de éxito y redirigir a la pantalla de inicio de sesión y registro
      showSnackbar(context, 'Cuenta eliminada exitosamente');
      print('Cuenta eliminada exitosamente');
      Navigator.pushNamedAndRemoveUntil(
          context, '/login_and_register', (route) => false);
    } catch (e) {
      // Mostrar un mensaje de error
      showSnackbar(context, "Se cancelo la eliminación de la cuenta");
      print('Error al eliminar la cuenta: $e');
    }
  }

  //SAVE IMAGE
  Future<String> storeFileStorage(String ref, File file) async {
    UploadTask uploadTask = _storage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
