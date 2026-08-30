import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_analysis/ai_analysis.dart';
import 'ai_analysis2/ai_analysis2.dart';
import 'app_param/app_param.dart';
import 'developer_news/developer_news.dart';
import 'horse/horse.dart';
import 'horse_best_weight/horse_best_weight.dart';
import 'horse_score/horse_score.dart';
import 'jockey_score/jockey_score.dart';
import 'laravel_config/laravel_config.dart';
import 'login_user/login_user.dart';

// import 'netkeiba_odds/netkeiba_odds.dart';
// import 'netkeiba_race/netkeiba_race.dart';
import 'odds/odds.dart';
import 'odds_get_timing/odds_get_timing.dart';

// import 'odds_wide/odds_wide.dart';
//
//
//

import 'popularity_rank_odds_median/popularity_rank_odds_median.dart';
import 'push_notifier_user/push_notifier_user.dart';
import 'race/race.dart';
import 'race_introspection/race_introspection.dart';
import 'race_result/race_result.dart';
import 'schedule/schedule.dart';
import 'summary/summary.dart';

mixin ControllersMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  //==========================================//

  AppParamState get appParamState => ref.watch(appParamProvider);

  AppParam get appParamNotifier => ref.read(appParamProvider.notifier);

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

  OddsGetTimingState get oddsGetTimingState => ref.watch(oddsGetTimingProvider);

  OddsGetTiming get oddsGetTimingNotifier => ref.read(oddsGetTimingProvider.notifier);

  //==========================================//

  //==========================================//
  // OddsWideState get oddsWideState => ref.watch(oddsWideProvider);
  //
  // OddsWide get oddsWideNotifier => ref.read(oddsWideProvider.notifier);

  //==========================================//

  //==========================================//

  SummaryState get summaryState => ref.watch(summaryProvider);

  Summary get summaryNotifier => ref.read(summaryProvider.notifier);

  //==========================================//

  //==========================================//

  RaceResultState get raceResultState => ref.watch(raceResultProvider);

  RaceResult get raceResultNotifier => ref.read(raceResultProvider.notifier);

  //==========================================//

  //==========================================//

  LoginUserState get loginUserState => ref.watch(loginUserProvider);

  LoginUser get loginUserNotifier => ref.read(loginUserProvider.notifier);

  //==========================================//

  //==========================================//
  PushNotifierUserState get pushNotifierUserState => ref.watch(pushNotifierUserProvider);

  PushNotifierUser get pushNotifierUserNotifier => ref.read(pushNotifierUserProvider.notifier);

  //==========================================//

  //==========================================//

  PopularityRankOddsMedianState get popularityRankOddsMedianState => ref.watch(popularityRankOddsMedianProvider);

  PopularityRankOddsMedian get popularityRankOddsMedianNotifier => ref.read(popularityRankOddsMedianProvider.notifier);

  //==========================================//

  //==========================================//

  HorseBestWeightState get horseBestWeightState => ref.watch(horseBestWeightProvider);

  HorseBestWeight get horseBestWeightNotifier => ref.read(horseBestWeightProvider.notifier);

  //==========================================//

  //==========================================//
  HorseScoreState get horseScoreState => ref.watch(horseScoreProvider);

  HorseScore get horseScoreNotifier => ref.read(horseScoreProvider.notifier);

  //==========================================//

  //==========================================//

  JockeyScoreState get jockeyScoreState => ref.watch(jockeyScoreProvider);

  JockeyScore get jockeyScoreNotifier => ref.read(jockeyScoreProvider.notifier);

  //==========================================//

  //==========================================//

  RaceIntrospectionState get raceIntrospectionState => ref.watch(raceIntrospectionProvider);

  RaceIntrospection get raceIntrospectionNotifier => ref.read(raceIntrospectionProvider.notifier);

  //==========================================//

  //==========================================//
  DeveloperNewsState get developerNewsState => ref.watch(developerNewsProvider);

  DeveloperNews get developerNewsNotifier => ref.read(developerNewsProvider.notifier);

  //==========================================//

  //==========================================//
  AiAnalysisState get aiAnalysisState => ref.watch(aiAnalysisProvider);

  AiAnalysis get aiAnalysisNotifier => ref.read(aiAnalysisProvider.notifier);

  //==========================================//

  //==========================================//
  AiAnalysisState2 get aiAnalysisState2 => ref.watch(aiAnalysis2Provider);

  AiAnalysis2 get aiAnalysisNotifier2 => ref.read(aiAnalysis2Provider.notifier);

  //==========================================//
}
