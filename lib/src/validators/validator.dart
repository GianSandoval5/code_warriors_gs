class Validators {
  //CORREO O NOMBRE DE USUARIO
  static String? emailUsernameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa un correo o nombre de usuario';
    }
    if (value.contains(' ')) {
      return "El correo no debe contener espacios";
    }
    return null;
  }

  // PARA VALIDAR EMAIL
  static String? validateEmail(String? value) {
    if (value!.isEmpty) {
      return 'Ingresa un correo';
    }
    if (!value.contains('@')) {
      return "Tu correo debe tener '@'";
    }
    if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value)) {
      return "Ingrese un correo válido";
    }
    if (value.contains(' ')) {
      return "El correo no debe contener espacios";
    }
    return null;
  }

  //PARA VALIDAR CONTRASEÑA
  static String? validatePassword(String? value) {
    if (value!.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (value.contains(' ')) {
      return "La contraseña no debe contener espacios";
    }
    return null;
  }

  //PARA VALIDAR NOMBRE DE USUARIO
  static String? validateUsername(String? value) {
    if (value!.isEmpty) {
      return 'El nombre de usuario es obligatorio';
    }
    if (value.contains(' ')) {
      return "El nombre de usuario no debe contener espacios";
    }

    //el nombre de usuario tiene que tener maximo 15 caracteres
    if (value.length > 15) {
      return 'El nombre de usuario debe tener máximo 15 caracteres';
    }

    return null;
  }

  //PARA VALIDAR FECHA DE NACIMIENTO

//FECHA DE NACIMIENTO
  static String? birthValidator(value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese tu fecha de nacimiento';
    }

    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Ingrese una fecha válida en formato DD/MM/AAAA';
    }

    final parts = value.split('/');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return 'Ingrese una fecha válida en formato DD/MM/AAAA';
    }

    if (day < 1 || day > 31) {
      return 'El día debe estar entre 1 y 31';
    }

    if (month < 1 || month > 12) {
      return 'El mes debe estar entre 1 y 12';
    }

    if (year < 1900 || year > DateTime.now().year) {
      return 'Ingrese un año válido';
    }

    //debe ser mayor de edad
    DateTime birthDate = DateTime(year, month, day);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (birthDate.isAfter(today)) {
      return 'La fecha de nacimiento no puede ser posterior a la fecha actual';
    } else if (birthDate
        .isAfter(today.subtract(const Duration(days: 365 * 18)))) {
      return 'Debes ser mayor de edad para registrarte';
    }

    return null;
  }

}
