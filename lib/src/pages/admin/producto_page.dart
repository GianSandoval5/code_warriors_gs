import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_warriors/src/pages/admin/add_producto.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:code_warriors/src/widgets/circularprogress_widget.dart';
import 'package:code_warriors/src/widgets/materialbuttom_widget.dart';
import 'package:flutter/material.dart';

class ProductosPage extends StatefulWidget {
  final dynamic userData;
  const ProductosPage({super.key, this.userData});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  List<dynamic> productos = [];

  // Método para leer posts desde Firestore
  Future<List<dynamic>> leerProductos() async {
    try {
      QuerySnapshot<Map<String, dynamic>> productSnapshot =
          await FirebaseFirestore.instance
              .collection('productos')
              .orderBy('created_at', descending: true)
              .get();

      // Mapea los documentos a una lista de productos
      List<dynamic> product =
          productSnapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        // Actualiza la lista de productos en el estado
        productos = product;
      });

      return product;
    } catch (e) {
      // Manejar errores al leer productos desde Firestore
      return [];
    }
  }

  //refresh
  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      leerProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkColor : AppColors.acentColor,
        centerTitle: true,
        title: const Text('Productos',
            style: TextStyle(color: AppColors.text, fontFamily: "CB")),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: FutureBuilder(
          future: leerProductos(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error"),
              );
            } else if (snapshot.hasData) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  MaterialButtomWidget(
                    title: "Agregar Producto",
                    color: isDarkMode
                        ? AppColors.acentColor
                        : AppColors.darkAcentsColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddProducto(userData: widget.userData),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: productos.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            elevation: 10,
                            child: ListTile(
                              leading: FadeInImage(
                                placeholder:
                                    const AssetImage('assets/gif/loading.gif'),
                                imageErrorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return Image.asset(
                                      'assets/images/noimage.png');
                                },
                                image: NetworkImage(productos[index]['imagen']),
                                width: 80,
                                fit: BoxFit.contain,
                              ),
                              title: Text(productos[index]['nombre']),
                              subtitle: Text(
                                productos[index]['precio'].toString(),
                              ),
                              //eliminar
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  dialogoDeleteProduct(
                                      context, isDarkMode, index);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(
              child: CircularProgressWidget(text: "Cargando productos..."),
            );
          },
        ),
      ),
    );
  }

  Future<dynamic> dialogoDeleteProduct(
      BuildContext context, bool isDarkMode, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor:
              isDarkMode ? AppColors.darkAcentsColor : AppColors.darkColor,
          title: const Text(
            "Eliminar Producto",
            style: TextStyle(color: AppColors.deepOrange, fontFamily: "CB"),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            "¿Estás seguro de eliminar este producto?",
            style: TextStyle(color: AppColors.text, fontFamily: "CM"),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: AppColors.acentColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar",
                      style:
                          TextStyle(color: AppColors.text, fontFamily: "CB")),
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: AppColors.deepOrange,
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('productos')
                        .doc(productos[index]['id'])
                        .delete();
                    Navigator.pop(context);
                    setState(() {
                      leerProductos();
                    });
                  },
                  child: const Text("Eliminar",
                      style:
                          TextStyle(color: AppColors.text, fontFamily: "CB")),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
