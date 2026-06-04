enum APIPath {
  getHorseOddsFinderSchedules,
  getHorseOddsFinderRaces,
  getHorseOddsFinderHorses,
  getHorseOddsFinderOdds,
  getHorseOddsFinderConfigs,
  getHorseOddsFinderNetkeibaRaces,
  getHorseOddsFinderNetkeibaOdds,
  getHorseOddsFinderOddsGetTiming,
  getHorseDetail,
  getHorseOddsFinderOddsWide,
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

      case APIPath.getHorseOddsFinderNetkeibaRaces:
        return 'getHorseOddsFinderNetkeibaRaces';

      case APIPath.getHorseOddsFinderNetkeibaOdds:
        return 'getHorseOddsFinderNetkeibaOdds';

      case APIPath.getHorseOddsFinderOddsGetTiming:
        return 'getHorseOddsFinderOddsGetTiming';

      case APIPath.getHorseDetail:
        return 'getHorseDetail';

      case APIPath.getHorseOddsFinderOddsWide:
        return 'getHorseOddsFinderOddsWide';
    }
  }
}
