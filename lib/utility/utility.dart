import 'package:flutter/material.dart';

import '../const/const.dart';
import '../models/race_result_model.dart';

class Utility {
  ///
  void showError(String msg) {
    final ScaffoldMessengerState? messenger = NavigationService.scaffoldMessengerKey.currentState;
    if (messenger == null) {
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 5)));
  }

  ///
  Map<int, Color> getHorseWakuColorMap() => _horseWakuColorMap;

  // 20260925: 呼ぶたびに作り直さないよう定数にした（読み取り専用）
  static const Map<int, Color> _horseWakuColorMap = <int, Color>{
    1: Color(0xFFFFFFFF),
    2: Color(0xFF000000),
    3: Color(0xFFFF0000),
    4: Color(0xFF0000FF),
    5: Color(0xFFFFFF00),
    6: Color(0xFF008000),
    7: Color(0xFFFFA500),
    8: Color(0xFFFFC0CB),
  };

  ///
  Map<String, dynamic> judgeOdds({
    required double before30,
    required double before6,
    required double rateHonmei,
    required double rateChuAna,
  }) {
    if (before6 / before30 >= kOddsNoDropRatio) {
      return <String, dynamic>{'display': false, 'message': '急落なし', 'description': '', 'flag': -1};
    }

    if (before6 < kOddsHonmeiMax) {
      return <String, dynamic>{
        'display': true,
        'message': '本命急落 → 買い推奨',
        'description': '発走6分前に30%以上オッズが下がった、5倍未満の馬です。過去データでは$rateHonmei%が3着以内に入っています。',
        'flag': 0,
      };
    } else if (before6 < kOddsChuAnaMax) {
      return <String, dynamic>{
        'display': true,
        'message': '中穴急落 → 様子見',
        'description': '発走6分前に30%以上オッズが下がった、5〜15倍の馬です。過去データでは$rateChuAna%が3着以内に入っています。',
        'flag': 1,
      };
    }

    return <String, dynamic>{'display': false, 'message': '大穴急落 → 対象外', 'description': '', 'flag': -1};
  }

  ///
  Map<int, int> buildNumToRankMap(List<RaceResultModel> results, int raceNumber) => <int, int>{
    for (final RaceResultModel r in results.where(
      (RaceResultModel r) => r.race == raceNumber && r.result <= kRaceTopFinishers,
    ))
      r.num: r.result,
  };
}

class NavigationService {
  const NavigationService._();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// MaterialApp.scaffoldMessengerKey に設定する（Utility.showError の SnackBar 表示用）
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
}
