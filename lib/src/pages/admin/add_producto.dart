// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:code_warriors/src/utils/export.dart';
import 'package:code_warriors/src/widgets/circularprogress_widget.dart';
import 'package:code_warriors/src/widgets/input_decoration_widget.dart';
import 'package:code_warriors/src/widgets/materialbuttom_widget.dart';
import 'package:code_warriors/src/widgets/upload_image_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddProducto extends StatefulWidget {
  final dynamic userData;
  const AddProducto({super.key, this.userData});

  @override
  State<AddProducto> createState() => _AddProductoState();
}

class _AddProductoState extends State<AddProducto> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameProductController = TextEditingController();
  final TextEditingController priceProductController = TextEditingController();
  File? image;
  bool isLoading = false;

  void selectedImage() async {
    image = await pickImageUser(context);
    setState(() {});
  }

  void subirProducto() async {
    final registerProvider =
        Provider.of<RegisterProvider>(context, listen: false);

    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      //cerrar el teclado
      FocusScope.of(context).unfocus();

      String imageUrl = '';
      if (image != null) {
        // Construir el nuevo nombre de la imagen usando el ID del usuario
        String newImageName = 'productos/${nameProductController.text}.jpg';
        // Guardar la imagen con el nuevo nombre
        imageUrl =
            await registerProvider.storeFileStorage(newImageName, image!);
      }

      //obtener la ref a la coleccion productos
      final ref = registerProvider.firestore.collection('productos');
      //obtener el id del documento
      final id = ref.doc().id;

      //fecha
      final date = DateTime.now();

      //convertir el precio a double
      final price = double.parse(priceProductController.text);

      // Crear el producto
      final datos = {
        "id": id,
        "created_at": date,
        "id_usuario": widget.userData['id'],
        "nombre": nameProductController.text,
        "precio": price,
        "imagen": imageUrl,
      };

      try {
        //subir el producto a la coleccion
        await ref.doc(id).set(datos);

        // Mostrar un SnackBar con un mensaje de éxito
        showSnackbar(context, "Producto agregado correctamente");
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
      } catch (e) {
        // Mostrar un SnackBar con un mensaje de error
        showSnackbar(context, "Error al agregar el producto");
        setState(() {
          isLoading = false;
        });
      } finally {
        //subir producto
        setState(() {
          isLoading = false;
        });
      }

      //subir producto
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkColor : AppColors.acentColor,
        centerTitle: true,
        title: const Text(
          'Agregar Producto',
          style: TextStyle(
            color: AppColors.text,
            fontFamily: "CB",
          ),
        ),
      ),
      body: isLoading
          ? const CircularProgressWidget(text: "Agregando producto...")
          : SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          selectedImage();
                        },
                        child: image == null
                            ? Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppColors.acentColor
                                      : AppColors.darkAcentsColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: isDarkMode
                                      ? AppColors.darkColor
                                      : AppColors.acentColor,
                                  size: 50,
                                ),
                              )
                            : Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? AppColors.acentColor
                                      : AppColors.darkAcentsColor,
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: FileImage(image!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      InputDecorationWidget(
                        color: isDarkMode
                            ? AppColors.acentColor
                            : AppColors.darkAcentsColor,
                        hintText: "Canchita dulce",
                        labelText: "Nombre del producto",
                        suffixIcon: const Icon(Icons.add),
                        controller: nameProductController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor ingrese el nombre del producto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      //precio
                      InputDecorationWidget(
                        color: isDarkMode
                            ? AppColors.acentColor
                            : AppColors.darkAcentsColor,
                        hintText: "S/ 5.00",
                        labelText: "Precio",
                        suffixIcon: const Icon(Icons.attach_money),
                        controller: priceProductController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor ingrese el precio del producto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      MaterialButtomWidget(
                        title: "Agregar Producto",
                        color: isDarkMode
                            ? AppColors.acentColor
                            : AppColors.darkAcentsColor,
                        onPressed: subirProducto,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
