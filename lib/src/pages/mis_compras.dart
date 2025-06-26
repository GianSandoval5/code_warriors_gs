import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:code_warriors/src/widgets/circularprogress_widget.dart';
import 'package:code_warriors/src/widgets/richi_icon_widget.dart';
import 'package:code_warriors/src/widgets/row_price_details.dart';
import 'package:flutter/material.dart';

class MisComprasPage extends StatefulWidget {
  final dynamic userData;
  const MisComprasPage({super.key, this.userData});

  @override
  State<MisComprasPage> createState() => _MisComprasPageState();
}

class _MisComprasPageState extends State<MisComprasPage> {
  Future<List<Map<String, dynamic>>> leerCompras() async {
    try {
      // Obtener la referencia a la colección "compras"
      CollectionReference comprasCollection =
          FirebaseFirestore.instance.collection('compras');

      // Realizar la consulta para obtener solo las compras del usuario actual
      QuerySnapshot querySnapshot = await comprasCollection
          .where('id_usuario', isEqualTo: widget.userData['id'])
          .orderBy('created_at', descending: true)
          .get();

      // Crear una lista vacía para almacenar las compras
      List<Map<String, dynamic>> compras = [];

      // Iterar sobre los documentos y agregar los datos a la lista
      for (var doc in querySnapshot.docs) {
        // Convertir los datos a un Map<String, dynamic>
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        // Verificar si los datos no son nulos antes de agregarlos
        if (data != null) {
          compras.add(data);
        }
      }

      // Retornar la lista de compras del usuario
      return compras;
    } catch (e) {
      //print('Error al leer las compras: $e');
      return []; // Retornar una lista vacía en caso de error
    }
  }

  //actualizar la pagina
  Future<void> onRefresh() async {
    //espera de 2 segundos
    await Future.delayed(const Duration(seconds: 2));
    //actualiza la pagina
    setState(() {
      leerCompras();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: leerCompras(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Error"),
              );
            } else if (snapshot.hasData) {
              List<Map<String, dynamic>> compras = snapshot.data!;
              return Column(
                children: [
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          'Mis Compras',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: "CB",
                            color: isDarkMode
                                ? AppColors.text
                                : AppColors.darkColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.shopping_cart,
                        color: isDarkMode
                            ? AppColors.lightColor
                            : AppColors.darkColor,
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: compras.length,
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final comp = compras[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 15,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: FadeInImage(
                                      height: 100,
                                      placeholder: const AssetImage(
                                          'assets/gif/vertical.gif'),
                                      image: NetworkImage(
                                        comp['posterPelicula'],
                                      ),
                                      imageErrorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        return Image.asset(
                                            'assets/images/noimage.png');
                                      },
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Película: ${compras[index]['nombrePelicula']}",
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: isDarkMode
                                                ? AppColors.lightColor
                                                : AppColors.darkColor,
                                            fontFamily: "CB",
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        RichiIconTextWidget(
                                          icon: Icons.calendar_month_outlined,
                                          isDarkMode: isDarkMode,
                                          text: compras[index]['fechaCine'],
                                        ),
                                        RichiIconTextWidget(
                                          icon: Icons.access_time,
                                          isDarkMode: isDarkMode,
                                          text: compras[index]['horaCine'],
                                        ),
                                        RichiIconTextWidget(
                                          icon: Icons.event_seat,
                                          isDarkMode: isDarkMode,
                                          text: compras[index]['butacas']
                                              .map((seat) => 'B$seat')
                                              .join(', '),
                                        ),
                                        RowPriceDetails(
                                          icon: Icons.confirmation_num_rounded,
                                          text: 'Entradas: ',
                                          price:
                                              'S/ ${compras[index]['precioEntradas'].toStringAsFixed(2)}',
                                          isDarkMode: isDarkMode,
                                        ),
                                        RowPriceDetails(
                                          icon: Icons.shopping_cart_outlined,
                                          text: 'Productos: ',
                                          price:
                                              'S/ ${compras[index]['precioProductos'].toStringAsFixed(2)}',
                                          isDarkMode: isDarkMode,
                                        ),
                                        RowPriceDetails(
                                          icon: Icons.monetization_on_outlined,
                                          text: 'Total: ',
                                          price:
                                              'S/ ${compras[index]['precioTotal'].toStringAsFixed(2)}',
                                          isDarkMode: isDarkMode,
                                        ),
                                        //cine
                                        RichiIconTextWidget(
                                          icon: Icons.location_on,
                                          isDarkMode: isDarkMode,
                                          text:
                                              "CineWarriors - ${compras[index]['selectedCity']}",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
              child: CircularProgressWidget(
                text: "Cargando...",
              ),
            );
          },
        ),
      ),
    );
  }
}
