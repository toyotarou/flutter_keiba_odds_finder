import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_param/app_param.dart';
import 'horse/horse.dart';
import 'laravel_config/laravel_config.dart';
import 'netkeiba_odds/netkeiba_odds.dart';
import 'netkeiba_race/netkeiba_race.dart';
import 'odds/odds.dart';
import 'odds_get_timing/odds_get_timing.dart';
import 'race/race.dart';
import 'schedule/schedule.dart';

mixin ControllersMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  //==========================================//

  AppParamState get appParamState => ref.watch(appParamProvider);

  AppParam get appParamNotifier => ref.read(appParamProvider.notifier);

  //==========================================//

  //==========================================//
  ScheduleState get scheduleState => ref.watch(scheduleProvider);

  Schedule get scheduleNotifier => ref.read(scheduleProvider.notifier);

  //==========================================//

  //==========================================//
  RaceState get raceState => ref.watch(raceProvider);

  Race get raceNotifier => ref.read(raceProvider.notifier);

  //==========================================//

  //==========================================//
  HorseState get horseState => ref.watch(horseProvider);

  Horse get horseNotifier => ref.read(horseProvider.notifier);

  //==========================================//

  //==========================================//
  OddsState get oddsState => ref.watch(oddsProvider);

  Odds get oddsNotifier => ref.read(oddsProvider.notifier);

  //==========================================//

  //==========================================//

  LaravelConfigState get laravelConfigState => ref.watch(laravelConfigProvider);

  LaravelConfig get laravelConfigNotifier => ref.read(laravelConfigProvider.notifier);

  //==========================================//

  //==========================================//

  NetkeibaOddsState get netkeibaOddsState => ref.watch(netkeibaOddsProvider);

  NetkeibaOdds get netkeibaOddsNotifier => ref.read(netkeibaOddsProvider.notifier);

  //==========================================//

  //==========================================//

  NetkeibaRaceState get netkeibaRaceState => ref.watch(netkeibaRaceProvider);

  NetkeibaRace get netkeibaRaceNotifier => ref.read(netkeibaRaceProvider.notifier);

  //==========================================//

  //==========================================//

  OddsGetTimingState get oddsGetTimingState => ref.watch(oddsGetTimingProvider);

  OddsGetTiming get oddsGetTimingNotifier => ref.read(oddsGetTimingProvider.notifier);

  //==========================================//
}
