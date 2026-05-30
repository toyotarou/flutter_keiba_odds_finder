import 'package:flutter/material.dart';

class Utility {
  // /// 背景取得
  // // ignore: always_specify_types
  // Widget getBackGround({context}) {
  //   return Image.asset(
  //     'assets/images/bg.jpg',
  //     fit: BoxFit.fitHeight,
  //     color: Colors.black.withOpacity(0.7),
  //     colorBlendMode: BlendMode.darken,
  //   );
  // }

  ///
  void showError(String msg) {
    final BuildContext? context = NavigationService.navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 5)));
  }
}

class NavigationService {
  const NavigationService._();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
