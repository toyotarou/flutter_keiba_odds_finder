enum APIPath {
  getHorseOddsFinderSchedules,
  getHorseOddsFinderRaces,
  getHorseOddsFinderHorses,
  getHorseOddsFinderOdds,
  getHorseOddsFinderConfigs,
  // getHorseOddsFinderNetkeibaRaces,
  // getHorseOddsFinderNetkeibaOdds,
  getHorseOddsFinderOddsGetTiming,
  getHorseDetail,
  getHorseOddsFinderOddsWide,
  getHorseOddsFinderSummary,
  getHorseOddsFinderSummaryOneRace,
  getHorseOddsFinderRaceOneResult,
  signup,
  signin,
  getHorseOddsFinderLoginUsers,
  changeAdmin,
  changeDelete,
  saveFcmToken,
}

extension APIPathExtension on APIPath {
  String? get value {
    switch (this) {
      case APIPath.getHorseOddsFinderSchedules:
        return 'getHorseOddsFinderSchedules';

      case APIPath.getHorseOddsFinderRaces:
        return 'getHorseOddsFinderRaces';

      case APIPath.getHorseOddsFinderHorses:
        return 'getHorseOddsFinderHorses';

      case APIPath.getHorseOddsFinderOdds:
        return 'getHorseOddsFinderOdds';

      case APIPath.getHorseOddsFinderConfigs:
        return 'getHorseOddsFinderConfigs';

      // case APIPath.getHorseOddsFinderNetkeibaRaces:
      //   return 'getHorseOddsFinderNetkeibaRaces';
      //
      // case APIPath.getHorseOddsFinderNetkeibaOdds:
      //   return 'getHorseOddsFinderNetkeibaOdds';

      case APIPath.getHorseOddsFinderOddsGetTiming:
        return 'getHorseOddsFinderOddsGetTiming';

      case APIPath.getHorseDetail:
        return 'getHorseDetail';

      case APIPath.getHorseOddsFinderOddsWide:
        return 'getHorseOddsFinderOddsWide';

      case APIPath.getHorseOddsFinderSummary:
        return 'getHorseOddsFinderSummary';

      case APIPath.getHorseOddsFinderSummaryOneRace:
        return 'getHorseOddsFinderSummaryOneRace';

      case APIPath.getHorseOddsFinderRaceOneResult:
        return 'getHorseOddsFinderRaceOneResult';

      case APIPath.signup:
        return 'signup';

      case APIPath.signin:
        return 'signin';

      case APIPath.getHorseOddsFinderLoginUsers:
        return 'getHorseOddsFinderLoginUsers';

      case APIPath.changeAdmin:
        return 'changeAdmin';

      case APIPath.changeDelete:
        return 'changeDelete';

      case APIPath.saveFcmToken:
        return 'fcm-token';
    }
  }
}
