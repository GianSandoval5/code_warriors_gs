import 'package:code_warriors/src/utils/colors.dart';
import 'package:flutter/material.dart';

class InputDecorationWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry? margin;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final String? initialValue;
  final bool obscureText;
  final bool autofocus;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool readOnly;
  final bool? showCursor;
  final bool? enabled;
  final Function()? onTap;
  final Function(String?)? onSaved;
  final int? maxLines;
  final Color color;
  final BorderRadius borderRadius;

  const InputDecorationWidget({
    super.key,
    this.controller,
    this.validator,
    required this.hintText,
    this.labelText,
    this.margin,
    this.keyboardType,
    this.onFieldSubmitted,
    this.onChanged,
    this.initialValue,
    this.obscureText = false,
    this.autofocus = false,
    this.suffixIcon,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.enabled,
    this.onSaved,
    this.maxLines,
    this.color = AppColors.darkColor,
    this.showCursor,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: TextFormField(
        autocorrect: true,
        onTap: onTap,
        onSaved: onSaved,
        enabled: enabled,
        readOnly: readOnly,
        obscureText: obscureText,
        initialValue: initialValue,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        keyboardType: keyboardType,
        autofocus: autofocus,
        validator: validator,
        controller: controller,
        maxLines: maxLines,
        scrollPadding: EdgeInsets.zero,
        style: TextStyle(
          fontSize: 15,
          color: color,
          fontFamily: "CM",
        ),
        textAlign: TextAlign.justify,
        cursorColor: color,
        decoration: InputDecoration(
          errorStyle: const TextStyle(
            color: AppColors.deepOrange,
            fontSize: 13,
            fontFamily: "CM",
          ),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          hintText: hintText,
          labelText: labelText,
          hintStyle: TextStyle(
              color: color.withAlpha(120), fontSize: 15, fontFamily: "CM"),
          labelStyle: TextStyle(color: color, fontSize: 15, fontFamily: "CB"),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            //AQUI LE CAMBIO EL COLOR DEL BORDE DONDE ESTA EL CALENDARIO
            borderSide: BorderSide(
              color: color,
              width: 2,
            ),
          ),
          //MANTIENE EL COLOR CUANDO EL ENABLED ESTA EN FALSE
          disabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: color,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: const BorderSide(
              color: AppColors.acentColor,
              width: 2,
            ),
          ),
          //MANTIENE BORDE CUANDO NO SE ESCRIBE NADA
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: color,
              width: 2,
            ),
          ),
          //COLOR DEL BORDE EN GENERAL
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: color,
              width: 2,
            ),
          ),
          //MANTIENE EL COLOR DEL BORDE
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(
              color: color,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
