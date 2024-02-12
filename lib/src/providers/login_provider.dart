// ignore_for_file: unused_local_variable

import 'package:code_warriors/src/services/local_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AuthStatus {
  notAuthenticated,
  checking,
  authenticated,
}

class LoginProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthStatus authStatus = AuthStatus.notAuthenticated;

  String? _errorMessage;
  String get errorMessage => _errorMessage ?? '';

  bool obscureText = true;

  bool isLoggedIn = false;

//para el login
  Future<UserCredential?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      print(e);
      return null;
    }
  }

//VERIFICAR AUTENTICIDAD DEL ROL
  Future<void> checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    isLoggedIn = user != null;

    if (isLoggedIn) {
      final tokenResult = await user!.getIdTokenResult();
      try {
        final decodedToken = tokenResult.claims;
        final rol = decodedToken!['rol'];

        // Verificar permisos de usuario según las reglas de Firestore
        final firestore = FirebaseFirestore.instance;
        final userDoc = firestore.collection('users').doc(user.uid);
        final userDocSnapshot = await userDoc.get();
        final userDocData = userDocSnapshot.data();
        final userRol = userDocData?['rol'];

        if (userRol == 'admin' || userRol == 'manager') {
          // El usuario tiene permisos de administrador o manager, puede hacer lo que quiera
        } else if (userRol == 'user') {
          // El usuario tiene permisos de usuario, puede leer pero no escribir
          // en las colecciones según las reglas de Firestore
        } else {
          // El usuario no tiene un rol válido, cerrar sesión
          FirebaseAuth.instance.signOut();
        }
      } catch (e) {
        // Aquí puedes hacer algo en caso de un error al verificar el token, como cerrar la sesión del usuario.
      }
    }
  }

  void getObscureText() {
    obscureText == true ? obscureText = false : obscureText = true;
    notifyListeners();
  }

  //SALIR DE LA APP
  Future<void> logoutApp() async {
    await _auth.signOut();
    authStatus = AuthStatus.notAuthenticated;
    isLoggedIn = false;
    notifyListeners();
    // Elimina la clave 'is_signedin' de la caja usando LocalStorage
    await LocalStorage().deleteIsSignedIn();
    //cambiar a false el valor de isLoggedIn
    await LocalStorage().setIsLoggedIn(false);
    //limpiar la caja
    await LocalStorage().clear();
  }

  //PARA OBTENER LOS DATOS DEL USUARIO
  Future<dynamic> getUserData(String email) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs[0].data();
      return userData;
    }

    return null;
  }
}
