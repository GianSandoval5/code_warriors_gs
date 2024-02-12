import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrientationResetObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.didPop(route, previousRoute);
  }
}
