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

  ///
  Map<String, dynamic> judgeOdds({
    required double before24,
    required double before3,
    required double rateHonmei,
    required double rateChuAna,
  }) {
    if (before3 / before24 >= 0.7) {
      return <String, dynamic>{'display': false, 'message': '急落なし', 'description': '', 'flag': -1};
    }

    if (before3 < 5.0) {
      return <String, dynamic>{
        'display': true,
        'message': '本命急落 → 買い推奨',
        'description': '発走3分前に30%以上オッズが下がった、5倍未満の馬です。過去データでは$rateHonmei%が3着以内に入っています。',
        'flag': 0,
      };
    } else if (before3 < 15.0) {
      return <String, dynamic>{
        'display': true,
        'message': '中穴急落 → 様子見',
        'description': '発走3分前に30%以上オッズが下がった、5〜15倍の馬です。過去データでは$rateChuAna%が3着以内に入っています。',
        'flag': 1,
      };
    }

    return <String, dynamic>{'display': false, 'message': '大穴急落 → 対象外', 'description': '', 'flag': -1};
  }
}

class NavigationService {
  const NavigationService._();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
