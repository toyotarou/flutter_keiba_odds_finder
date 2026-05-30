enum APIPath {
  getHorseOddsFinderSchedules,
  getHorseOddsFinderRaces,
  getHorseOddsFinderHorses,
  getHorseOddsFinderOdds,
  getHorseOddsFinderConfigs,
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
    }
  }
}
