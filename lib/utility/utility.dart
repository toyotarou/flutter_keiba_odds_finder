import 'package:flutter/material.dart';

class Utility {
  ///
  void showError(String msg) {
    final BuildContext? context = NavigationService.navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 5)));
  }

  ///
  Map<int, Color> getHorseWakuColorMap() {
    return <int, Color>{
      1: const Color(0xFFFFFFFF),
      2: const Color(0xFF000000),
      3: const Color(0xFFFF0000),
      4: const Color(0xFF0000FF),
      5: const Color(0xFFFFFF00),
      6: const Color(0xFF008000),
      7: const Color(0xFFFFA500),
      8: const Color(0xFFFFC0CB),
    };
  }
}

class NavigationService {
  const NavigationService._();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
