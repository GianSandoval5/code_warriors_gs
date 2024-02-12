import 'package:code_warriors/src/pages/boleteria/boleteria_page.dart';
import 'package:code_warriors/src/pages/boleteria/detalle_compra.dart';
import 'package:code_warriors/src/pages/boleteria/payment_page.dart';
import 'package:code_warriors/src/pages/details_movie.dart';
import 'package:code_warriors/src/pages/onboarding_page.dart';
import 'package:code_warriors/src/routes/routes.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext)> get appRoutes {
  return {
    Routes.onboard: (_) => const OnBoardingPage(),
    Routes.details: (_) => const DetailsMoviePage(),
    Routes.boleteria: (_) => const BoleteriaPage(),
    Routes.detalleCompra: (_) => const DetalleCompra(),
    Routes.payment: (_) => const PaymentPage(),
  };
}
