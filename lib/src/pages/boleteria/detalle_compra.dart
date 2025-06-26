// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_warriors/src/models/movie_models.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:code_warriors/src/utils/export.dart';
import 'package:code_warriors/src/widgets/circularprogress_widget.dart';
import 'package:code_warriors/src/widgets/materialbuttom_widget.dart';
import 'package:code_warriors/src/widgets/richi_icon_widget.dart';
import 'package:code_warriors/src/widgets/row_price_details.dart';
import 'package:flutter/material.dart';

class DetalleCompra extends StatefulWidget {
  const DetalleCompra({super.key});

  @override
  State<DetalleCompra> createState() => _DetalleCompraState();
}

class _DetalleCompraState extends State<DetalleCompra> {
  List<dynamic> productos = [];
  List<Map<String, dynamic>> selectedProducts = [];
  Map<String, int> productCounts = {};
  double productTotalPrice = 0.0;
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    leerProductos();
  }

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

  // Método para agregar un producto seleccionado
  void agregarProducto(int index, String productId) {
    setState(() {
      // Incrementar la cantidad seleccionada del producto en productCounts
      productCounts[productId] = (productCounts[productId] ?? 0) + 1;

      // Agregar el producto a selectedProducts solo una vez
      selectedProducts.add(productos[index]);

      // Actualizar el precio total sumando el precio del producto añadido
      productTotalPrice += productos[index]['precio'];
    });
  }

// Método para eliminar un producto seleccionado
  void eliminarProducto(int index, String productId) {
    setState(() {
      // Decrementar la cantidad seleccionada del producto en productCounts
      productCounts[productId] = (productCounts[productId] ?? 0) - 1;

      // Encontrar el índice del primer producto con el ID especificado
      int productIndexToRemove =
          selectedProducts.indexWhere((product) => product['id'] == productId);

      if (productIndexToRemove != -1) {
        // Eliminar el producto de selectedProducts
        selectedProducts.removeAt(productIndexToRemove);

        // Actualizar el precio total restando el precio del producto eliminado
        productTotalPrice -= productos[index]['precio'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    // Extraer los argumentos pasados a la página
    final Movie movie = arguments['movie'];
    final dynamic userData = arguments['userData'];
    final selectedDay = arguments['selectedDay'];
    final selectedTime = arguments['selectedTime'];
    final selectedSeats = arguments['selectedSeats'];
    final double totalPrice = arguments['totalPrice'];

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkColor : AppColors.lightColor,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkColor : AppColors.lightColor,
        iconTheme: IconThemeData(
            color: isDarkMode ? AppColors.lightColor : AppColors.darkColor),
        centerTitle: true,
        title: Text(
          "Detalle de tu compra",
          style: TextStyle(
            fontSize: 20,
            color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
            fontFamily: "CB",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: FadeInImage(
                        height: 100,
                        placeholder:
                            const AssetImage('assets/gif/vertical.gif'),
                        image: NetworkImage(movie.fullPosterImg),
                        imageErrorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Image.asset('assets/images/noimage.png');
                        },
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            movie.title,
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
                            text: selectedDay,
                          ),
                          RichiIconTextWidget(
                            icon: Icons.access_time,
                            isDarkMode: isDarkMode,
                            text: selectedTime,
                          ),
                          RichiIconTextWidget(
                            icon: Icons.event_seat,
                            isDarkMode: isDarkMode,
                            text: selectedSeats
                                .map((seat) => 'B$seat')
                                .join(', '),
                          ),
                          RowPriceDetails(
                            icon: Icons.confirmation_num_rounded,
                            text: 'Entradas: ',
                            price: 'S/ ${totalPrice.toStringAsFixed(2)}',
                            isDarkMode: isDarkMode,
                          ),
                          RowPriceDetails(
                            icon: Icons.shopping_cart,
                            text: 'Productos: ',
                            price: 'S/ ${productTotalPrice.toStringAsFixed(2)}',
                            isDarkMode: isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Cine Warriors solo esta disponible en\nLima y Piura - Perú",
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isDarkMode ? AppColors.lightColor : AppColors.darkColor,
                  fontFamily: "CM",
                ),
                textAlign: TextAlign.center,
              ),
            ),
            productos.isEmpty
                ? const Expanded(
                    child:
                        CircularProgressWidget(text: "Cargando Productos..."))
                : Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 20),
                        //Drowbuttom para elegir Lima o Piura
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: DropdownButtonFormField(
                            focusColor: isDarkMode
                                ? AppColors.lightColor
                                : AppColors.darkColor,
                            style: TextStyle(
                              color: isDarkMode
                                  ? AppColors.lightColor
                                  : AppColors.darkColor,
                              fontFamily: "CB",
                            ),
                            dropdownColor: AppColors.lightColor,
                            decoration: InputDecoration(
                              labelText: "Selecciona tu ciudad",
                              hintStyle: TextStyle(
                                color: isDarkMode
                                    ? AppColors.lightColor
                                    : AppColors.darkColor,
                                fontFamily: "CB",
                              ),
                              labelStyle: TextStyle(
                                color: isDarkMode
                                    ? AppColors.lightColor
                                    : AppColors.darkColor,
                                fontFamily: "CB",
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? AppColors.lightColor
                                      : AppColors.darkColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(
                                  color: isDarkMode
                                      ? AppColors.lightColor
                                      : AppColors.darkColor,
                                ),
                              ),
                            ),
                            value: selectedCity,
                            items: [
                              DropdownMenuItem(
                                value: "Lima",
                                child: Text(
                                  "Lima",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? AppColors.red
                                        : AppColors.darkColor,
                                    fontFamily: "CB",
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Piura",
                                child: Text(
                                  "Piura",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? AppColors.red
                                        : AppColors.darkColor,
                                    fontFamily: "CB",
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedCity = value.toString();
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Agregar Productos:",
                          style: TextStyle(
                            fontSize: 20,
                            color: isDarkMode
                                ? AppColors.lightColor
                                : AppColors.darkColor,
                            fontFamily: "CB",
                          ),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2 / 3,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: productos.length,
                          itemBuilder: (BuildContext context, int index) {
                            String productId = productos[index]['id'];

                            return Card(
                              color: isDarkMode
                                  ? AppColors.darkColor
                                  : AppColors.text,
                              elevation: 10,
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: FadeInImage(
                                      height: 120,
                                      placeholder: const AssetImage(
                                          'assets/gif/animc.gif'),
                                      image: NetworkImage(
                                          productos[index]['imagen']),
                                      imageErrorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        return Image.asset(
                                            'assets/images/noimage.png');
                                      },
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    productos[index]['nombre'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkMode
                                          ? AppColors.lightColor
                                          : AppColors.darkColor,
                                      fontFamily: "CB",
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'S/ ${productos[index]['precio']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDarkMode
                                          ? AppColors.lightColor
                                          : AppColors.darkColor,
                                      fontFamily: "CB",
                                    ),
                                  ),
                                  Divider(
                                    color: isDarkMode
                                        ? AppColors.lightColor
                                        : AppColors.darkColor,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        iconSize: 30,
                                        onPressed: () {
                                          // //solo se muestra cuando hay un valor mayor a 0
                                          if (productCounts
                                                  .containsKey(productId) &&
                                              productCounts[productId]! > 0)
                                            //se resta el valor de la cantidad y el precio del producto
                                            eliminarProducto(index, productId);
                                        },
                                        icon: Icon(
                                          Icons.remove_circle,
                                          color: //solo se muestra cuando hay un valor mayor a 0
                                              productCounts.containsKey(
                                                          productId) &&
                                                      productCounts[
                                                              productId]! >
                                                          0
                                                  ? AppColors.red
                                                  : AppColors.darkAcentsColor
                                                      .withAlpha(120)
                                        ),
                                      ),
                                      Text(
                                        productCounts.containsKey(productId)
                                            ? productCounts[productId]
                                                .toString()
                                            : '0',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: "CB",
                                        ),
                                      ),
                                      IconButton(
                                        iconSize: 30,
                                        onPressed: () {
                                          //se suma el valor de la cantidad y el precio del producto
                                          agregarProducto(index, productId);
                                        },
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: AppColors.greenColor2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButtomWidget(
                title: "Pagar",
                onPressed: () {
                  //verifica que se haya seleccionado una ciudad
                  if (selectedCity == null) {
                    showSnackbar(context, "Selecciona una ciudad");
                    return;
                  }

                  // Navegar a la página de pago
                  Navigator.pushNamed(context, '/payment', arguments: {
                    'movie': movie,
                    'userData': userData,
                    'selectedDay': selectedDay,
                    'selectedTime': selectedTime,
                    'selectedSeats': selectedSeats,
                    'totalPrice': totalPrice,
                    'productTotalPrice': productTotalPrice,
                    'selectedProducts': selectedProducts,
                    'selectedCity': selectedCity,
                  });
                },
                color: AppColors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
