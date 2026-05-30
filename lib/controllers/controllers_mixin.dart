import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_param/app_param.dart';
import 'horse/horse.dart';
import 'laravel_config/laravel_config.dart';
import 'odds/odds.dart';
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
  HorseState get horoState => ref.watch(horseProvider);

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
}
