import 'package:code_warriors/src/models/movie_models.dart';
import 'package:code_warriors/src/utils/colors.dart';
import 'package:code_warriors/src/utils/dark_mode_extension.dart';
import 'package:code_warriors/src/widgets/materialbuttom_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BoleteriaPage extends StatefulWidget {
  const BoleteriaPage({super.key});

  @override
  State<BoleteriaPage> createState() => _BoleteriaPageState();
}

class _BoleteriaPageState extends State<BoleteriaPage> {
  int selectedDay = DateTime.now().day;
  String selectedTime = '';
  List<int> selectedSeats = [];
  double ticketPrice = 9.90; // Precio de la entrada
  double totalPrice = 0.0; // Precio total inicial

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = context.isDarkMode;
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final Movie movie = arguments['movie'];
    final dynamic userData = arguments['userData'];

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final mes = DateFormat('MMMM', 'es_ES').format(now);
    //primera letra en mayuscula
    final capitalizedDate = mes[0].toUpperCase() + mes.substring(1);

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkColor : AppColors.lightColor,
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? AppColors.darkColor
            : AppColors.lightColor,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppColors.lightColor : AppColors.darkColor,
        ),
        centerTitle: true,
        title: Text(
          movie.title,
          style: const TextStyle(fontSize: 19, fontFamily: "CB"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //mostrar el mes actual
            Row(
              children: [
                Text(
                  capitalizedDate,
                  style: const TextStyle(fontSize: 28, fontFamily: "CB"),
                ),
                const Spacer(),
                //icono de informacion
                DialogoInfoCine(isDarkMode: isDarkMode),
              ],
            ),
            const Text(
              'Selecciona el día y horario.',
              style: TextStyle(fontSize: 16, fontFamily: "CM"),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: daysInMonth - DateTime.now().day + 1,
                itemBuilder: (context, index) {
                  final date = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day + index,
                  );
                  final weekDay = DateFormat('EEE', 'es_ES').format(date);
                  final capitalizedWeekDay =
                      weekDay[0].toUpperCase() + weekDay.substring(1);
                  final isToday = DateTime.now().day + index == selectedDay;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = DateTime.now().day + index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.red : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isToday
                              ? AppColors.darkAcentsColor
                              : AppColors.red.withAlpha(120)
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              '${DateTime.now().day + index}',
                              style: TextStyle(
                                fontFamily: "CB",
                                color: isDarkMode || isToday
                                    ? AppColors.lightColor
                                    : AppColors.darkColor,
                              ),
                            ),
                            Text(
                              capitalizedWeekDay,
                              style: TextStyle(
                                fontFamily: "CM",
                                color: isDarkMode || isToday
                                    ? AppColors.lightColor
                                    : AppColors.darkColor,
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

            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount:
                    11, // Horarios cada dos horas desde la 1 PM hasta las 11 PM
                itemBuilder: (context, index) {
                  final time = DateFormat('h:mm a').format(
                    DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      13 + index,
                    ),
                  );
                  final isSelected = time == selectedTime;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTime = time;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.red : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.darkAcentsColor
                              : AppColors.red.withAlpha(120),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontFamily: "CS",
                            color: isDarkMode || isSelected
                                ? AppColors.lightColor
                                : AppColors.darkColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Text(
                  'Selecciona tus butacas',
                  style: TextStyle(fontSize: 17, fontFamily: "CB"),
                ),
                const Spacer(),
                //Precio de la entrada
                Text(
                  'S/ ${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    color: isDarkMode
                        ? AppColors.lightColor
                        : AppColors.darkColor,
                    fontFamily: "CB",
                  ),
                ),
              ],
            ),
            //const SizedBox(height: 10),
            const VisionScreen(),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Pantalla del cine",
                style: TextStyle(fontSize: 17, fontFamily: "CS"),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: 6,
                itemBuilder: (context, i) {
                  int seatsInRow = i < 1
                      ? 5
                      : i < 2
                      ? 6
                      : i < 3
                      ? 7
                      : i < 4
                      ? 8
                      : 9;
                  int seatsInPreviousRows = i < 1
                      ? 0
                      : i < 2
                      ? 5
                      : i < 3
                      ? 11
                      : i < 4
                      ? 18
                      : i < 5
                      ? 26
                      : 34;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 5,
                      children: List.generate(seatsInRow, (j) {
                        int seatNumber = seatsInPreviousRows + j + 1;
                        return _Seat(
                          seatNumber: seatNumber,
                          onSelected: (isSelected) {
                            setState(() {
                              if (isSelected) {
                                selectedSeats.add(seatNumber);
                                // Aumentar el precio total
                                totalPrice += ticketPrice;
                              } else {
                                selectedSeats.remove(seatNumber);
                                // Disminuir el precio total
                                totalPrice -= ticketPrice;
                              }
                              // Redondear el precio total a dos decimales
                              totalPrice = double.parse(
                                totalPrice.toStringAsFixed(2),
                              );
                            });
                          },
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Precio por butaca: S/ $ticketPrice",
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: "CB",
                  color: isDarkMode
                      ? AppColors.lightColor
                      : AppColors.darkColor,
                ),
              ),
            ),
            const SizedBox(height: 5),
            //row con bolas de colores indicando el estado de las butacas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Disponible',
                      style: TextStyle(fontFamily: "CM"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Seleccionado',
                      style: TextStyle(fontFamily: "CM"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            MaterialButtomWidget(
              color: AppColors.red,
              title: 'Continuar',
              onPressed: () {
                //validar que se haya selecionado asientos

                if (selectedSeats.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          'Code Warriors',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "CB",
                            color: AppColors.red,
                          ),
                        ),
                        content: const Text(
                          "Por favor selecciona al menos un asiento para continuar",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontFamily: "CM"),
                        ),
                        actions: [
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: AppColors.acentColor,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Aceptar',
                              style: TextStyle(color: AppColors.text),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                //transforma el selectedDay a Lun 12, Feb 2022
                final day = DateFormat('E d, MMM yyyy', 'es_ES').format(
                  DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    selectedDay,
                  ),
                );
                //primer letra en mayuscula
                final newDay = day[0].toUpperCase() + day.substring(1);

                if (selectedTime.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    '/detalleCompra',
                    arguments: {
                      'movie': movie,
                      'userData': userData,
                      'selectedDay': newDay,
                      'selectedTime': selectedTime,
                      'selectedSeats': selectedSeats,
                      'totalPrice': totalPrice,
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          'Code Warriors',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "CB",
                            color: AppColors.red,
                          ),
                        ),
                        content: const Text(
                          "Por favor selecciona un horario para continuar",
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontFamily: "CM"),
                        ),
                        actions: [
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: AppColors.acentColor,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Aceptar',
                              style: TextStyle(color: AppColors.text),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class DialogoInfoCine extends StatelessWidget {
  const DialogoInfoCine({super.key, required this.isDarkMode});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Code Warriors',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: "CB", color: AppColors.red),
              ),
              content: const Text(
                "El horario de apertura es a la 1:00 PM y el de cierre y venta de boletos a las 11:00 PM\n\n",
                textAlign: TextAlign.justify,
                style: TextStyle(fontFamily: "CM"),
              ),
              actions: [
                MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: AppColors.acentColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(color: AppColors.text),
                  ),
                ),
              ],
            );
          },
        );
      },
      icon: Icon(Icons.info, color: isDarkMode ? Colors.white : Colors.black),
    );
  }
}

class _Seat extends StatefulWidget {
  final int seatNumber;
  final ValueChanged<bool> onSelected;

  const _Seat({required this.seatNumber, required this.onSelected});

  @override
  _SeatState createState() => _SeatState();
}

class _SeatState extends State<_Seat> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
        widget.onSelected(isSelected);
      },
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/icons/butaca.png',
              height: 30,
              color: Colors.white,
              width: 30,
            ),
            Center(
              child: Text(
                'B${widget.seatNumber}',
                style: const TextStyle(
                  color: AppColors.darkColor,
                  fontSize: 10,
                  fontFamily: "CS",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VisionScreen extends StatelessWidget {
  const VisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: 50,
      child: ClipPath(
        clipper: _VisionClipper(),
        child: CustomPaint(painter: _VisionPainter()),
      ),
    );
  }
}

class _VisionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    // Dibuja una curva que simula la pantalla del cine
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height);

    canvas.drawPath(path, paint);

    final screenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Colors.white.withAlpha(120), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), screenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _VisionClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
