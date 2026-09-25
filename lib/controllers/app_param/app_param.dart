import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../utility/utility.dart';
import '../../models/ai_analysis_model.dart';
import '../../models/developer_news_model.dart';
import '../../models/horse_model.dart';
import '../../models/login_user_model.dart';
import '../../models/odds_model.dart';

import '../../models/popularity_rank_odds_median_model.dart';
import '../../models/push_notifier_user_model.dart';
import '../../models/race_introspection_model.dart';
import '../../models/race_model.dart';
import '../../models/schedule_model.dart';
import '../../models/score_model.dart';
import '../../models/summary_model.dart';

part 'app_param.freezed.dart';

part 'app_param.g.dart';

@freezed
class AppParamState with _$AppParamState {
  const factory AppParamState({
    @Default(<String, List<ScheduleModel>>{}) Map<String, List<ScheduleModel>> keepScheduleDateBashoMap,

    @Default(<String, List<RaceModel>>{}) Map<String, List<RaceModel>> keepRaceMap,

    @Default(<String, List<HorseModel>>{}) Map<String, List<HorseModel>> keepHorseMap,

    @Default(<String, List<OddsModel>>{}) Map<String, List<OddsModel>> keepOddsMap,

    @Default(<String, List<SummaryModel>>{}) Map<String, List<SummaryModel>> keepSummaryMap,

    @Default(<String, List<String>>{}) Map<String, List<String>> keepSummaryDateBashoMap,

    @Default(<String, LoginUserModel>{}) Map<String, LoginUserModel> keepLoginUserMap,

    @Default(<PushNotifierUserModel>[]) List<PushNotifierUserModel> keepPushNotifierUserList,

    @Default(<String, List<PopularityRankOddsMedianModel>>{})
    Map<String, List<PopularityRankOddsMedianModel>> keepPopularityRankOddsMedianMap,

    @Default(<String, ScoreModel>{}) Map<String, ScoreModel> keepHorseScoreMap,

    @Default(<String, ScoreModel>{}) Map<String, ScoreModel> keepJockeyScoreMap,

    @Default(<String, RaceIntrospectionModel>{}) Map<String, RaceIntrospectionModel> keepRaceIntrospectionMap,

    @Default(<String, List<DeveloperNewsModel>>{}) Map<String, List<DeveloperNewsModel>> keepDeveloperNewsKindMap,
    @Default(<String, List<DeveloperNewsModel>>{}) Map<String, List<DeveloperNewsModel>> keepDeveloperNewsTimeMap,

    @Default(<String, List<AiAnalysisModel>>{}) Map<String, List<AiAnalysisModel>> keepAiAnalysisMap,
    @Default(<String, List<AiAnalysisModel>>{}) Map<String, List<AiAnalysisModel>> keepAiAnalysisMap2,

    ///
    @Default('') String configOddsGetTiming,
    @Default('') String configOddsDropRateHonmei,
    @Default('') String configOddsDropRateChuana,
    @Default('') String configOddsDropRateDaiana,

    @Default('') String configBaganrikiBrain,

    ///
    @Default('') String selectedScheduleDate,

    @Default('') String selectedScheduleKaisuuBashoDay,

    @Default('') String selectedScheduleKaisuuBashoDayName,

    @Default(0) int selectedRaceNumber,

    @Default('') String selectedTiming,

    @Default('') String selectedTiming2,

    @Default('') String queryUser,

    @Default(true) bool isShowUpperBox,

    @Default(true) bool isShowUpperBox2,

    @Default('') String selectedDrawerRace,

    @Default(false) bool isZoomed,

    @Default(0) int selectedUpsetBoxNum,

    @Default(0) int selectedPopularityRank,

    @Default('') String selectedPopularityRankYear,

    @Default('') String selectedHistoryYear,

    @Default('') String selectedHorseNameChar1,
    @Default('') String selectedHorseNameChar2,

    @Default(false) bool allExpanded,

    @Default(false) bool isShowSideTabPanel,

    @Default(null) int? selectedHorseLineNum,
  }) = _AppParamState;
}

@riverpod
class AppParam extends _$AppParam {
  final Utility utility = Utility();

  ///
  @override
  AppParamState build() => const AppParamState();

  // 20260925: 各 setter は値が変わらない場合は state を更新しない。
  // Notifier は同値でも別インスタンスを代入すると通知するため、
  // build 中の postFrame から同じ値を毎回セットすると再描画が止まらなくなる（race_content_page の selectedTiming2 など）。

  ///
  void setKeepScheduleDateBashoMap({required Map<String, List<ScheduleModel>> map}) {
    if (identical(state.keepScheduleDateBashoMap, map)) {
      return;
    }
    state = state.copyWith(keepScheduleDateBashoMap: map);
  }

  ///
  void setKeepRaceMap({required Map<String, List<RaceModel>> map}) {
    if (identical(state.keepRaceMap, map)) {
      return;
    }
    state = state.copyWith(keepRaceMap: map);
  }

  ///
  void setKeepHorseMap({required Map<String, List<HorseModel>> map}) {
    if (identical(state.keepHorseMap, map)) {
      return;
    }
    state = state.copyWith(keepHorseMap: map);
  }

  ///
  void setKeepOddsMap({required Map<String, List<OddsModel>> map}) {
    if (identical(state.keepOddsMap, map)) {
      return;
    }
    state = state.copyWith(keepOddsMap: map);
  }

  ///
  void setKeepSummaryMap({required Map<String, List<SummaryModel>> map}) {
    if (identical(state.keepSummaryMap, map)) {
      return;
    }
    state = state.copyWith(keepSummaryMap: map);
  }

  ///
  void setKeepSummaryDateBashoMap({required Map<String, List<String>> map}) {
    if (identical(state.keepSummaryDateBashoMap, map)) {
      return;
    }
    state = state.copyWith(keepSummaryDateBashoMap: map);
  }

  ///
  void setKeepLoginUserMap({required Map<String, LoginUserModel> map}) {
    if (identical(state.keepLoginUserMap, map)) {
      return;
    }
    state = state.copyWith(keepLoginUserMap: map);
  }

  ///
  void setKeepPushNotifierUserList({required List<PushNotifierUserModel> list}) {
    if (identical(state.keepPushNotifierUserList, list)) {
      return;
    }
    state = state.copyWith(keepPushNotifierUserList: list);
  }

  ///
  void setKeepPopularityRankOddsMedianMap({required Map<String, List<PopularityRankOddsMedianModel>> map}) {
    if (identical(state.keepPopularityRankOddsMedianMap, map)) {
      return;
    }
    state = state.copyWith(keepPopularityRankOddsMedianMap: map);
  }

  ///
  void setKeepHorseScoreMap({required Map<String, ScoreModel> map}) {
    if (identical(state.keepHorseScoreMap, map)) {
      return;
    }
    state = state.copyWith(keepHorseScoreMap: map);
  }

  ///
  void setKeepJockeyScoreMap({required Map<String, ScoreModel> map}) {
    if (identical(state.keepJockeyScoreMap, map)) {
      return;
    }
    state = state.copyWith(keepJockeyScoreMap: map);
  }

  ///
  void setKeepRaceIntrospectionMap({required Map<String, RaceIntrospectionModel> map}) {
    if (identical(state.keepRaceIntrospectionMap, map)) {
      return;
    }
    state = state.copyWith(keepRaceIntrospectionMap: map);
  }

  ///
  void setKeepDeveloperNews({
    required Map<String, List<DeveloperNewsModel>> map,
    required Map<String, List<DeveloperNewsModel>> map2,
  }) {
    if (identical(state.keepDeveloperNewsKindMap, map) && identical(state.keepDeveloperNewsTimeMap, map2)) {
      return;
    }
    state = state.copyWith(keepDeveloperNewsKindMap: map, keepDeveloperNewsTimeMap: map2);
  }

  ///
  void setKeepAiAnalysisMap({required Map<String, List<AiAnalysisModel>> map}) {
    if (identical(state.keepAiAnalysisMap, map)) {
      return;
    }
    state = state.copyWith(keepAiAnalysisMap: map);
  }

  ///
  void setKeepAiAnalysisMap2({required Map<String, List<AiAnalysisModel>> map}) {
    if (identical(state.keepAiAnalysisMap2, map)) {
      return;
    }
    state = state.copyWith(keepAiAnalysisMap2: map);
  }

  //////////////

  void setConfigOddsGetTiming({required String oddsGetTiming}) {
    if (state.configOddsGetTiming == oddsGetTiming) {
      return;
    }
    state = state.copyWith(configOddsGetTiming: oddsGetTiming);
  }

  ///
  void setConfigOddsDropRate({
    required String oddsDropRateHonmei,
    required String oddsDropRateChuana,
    required String oddsDropRateDaiana,
  }) {
    if (state.configOddsDropRateHonmei == oddsDropRateHonmei &&
        state.configOddsDropRateChuana == oddsDropRateChuana &&
        state.configOddsDropRateDaiana == oddsDropRateDaiana) {
      return;
    }
    state = state.copyWith(
      configOddsDropRateHonmei: oddsDropRateHonmei,
      configOddsDropRateChuana: oddsDropRateChuana,
      configOddsDropRateDaiana: oddsDropRateDaiana,
    );
  }

  ///
  void setConfigBaganrikiBrain({required String str}) {
    if (state.configBaganrikiBrain == str) {
      return;
    }
    state = state.copyWith(configBaganrikiBrain: str);
  }

  //////////////

  ///
  void setSelectedScheduleDate({required String date}) {
    if (state.selectedScheduleDate == date) {
      return;
    }
    state = state.copyWith(selectedScheduleDate: date);
  }

  ///
  void setSelectedScheduleKaisuuBashoDay({required String kbd, required String name}) {
    if (state.selectedScheduleKaisuuBashoDay == kbd && state.selectedScheduleKaisuuBashoDayName == name) {
      return;
    }
    state = state.copyWith(selectedScheduleKaisuuBashoDay: kbd, selectedScheduleKaisuuBashoDayName: name);
  }

  ///
  void setSelectedRaceNumber({required int num}) {
    if (state.selectedRaceNumber == num) {
      return;
    }
    state = state.copyWith(selectedRaceNumber: num);
  }

  ///
  void setSelectedTiming({required String timing}) {
    if (state.selectedTiming == timing) {
      return;
    }
    state = state.copyWith(selectedTiming: timing);
  }

  ///
  void setSelectedTiming2({required String timing2}) {
    if (state.selectedTiming2 == timing2) {
      return;
    }
    state = state.copyWith(selectedTiming2: timing2);
  }

  ///
  void setQueryUser({required String user}) {
    if (state.queryUser == user) {
      return;
    }
    state = state.copyWith(queryUser: user);
  }

  ///
  void setIsShowUpperBox({required bool flag}) {
    if (state.isShowUpperBox == flag) {
      return;
    }
    state = state.copyWith(isShowUpperBox: flag);
  }

  ///
  void setIsShowUpperBox2({required bool flag}) {
    if (state.isShowUpperBox2 == flag) {
      return;
    }
    state = state.copyWith(isShowUpperBox2: flag);
  }

  ///
  void setSelectedDrawerRace({required String race}) {
    if (state.selectedDrawerRace == race) {
      return;
    }
    state = state.copyWith(selectedDrawerRace: race);
  }

  ///
  void setIsZoomed({required bool flag}) {
    if (state.isZoomed == flag) {
      return;
    }
    state = state.copyWith(isZoomed: flag);
  }

  ///
  void setSelectedUpsetBoxNum({required int num}) {
    if (state.selectedUpsetBoxNum == num) {
      return;
    }
    state = state.copyWith(selectedUpsetBoxNum: num);
  }

  ///
  void setSelectedPopularityRank({required int rank}) {
    if (state.selectedPopularityRank == rank) {
      return;
    }
    state = state.copyWith(selectedPopularityRank: rank);
  }

  ///
  void setSelectedPopularityRankYear({required String year}) {
    if (state.selectedPopularityRankYear == year) {
      return;
    }
    state = state.copyWith(selectedPopularityRankYear: year);
  }

  ///
  void setSelectedHistoryYear({required String year}) {
    if (state.selectedHistoryYear == year) {
      return;
    }
    state = state.copyWith(selectedHistoryYear: year);
  }

  ///
  void setSelectedHorseNameChar1({required String char}) {
    if (state.selectedHorseNameChar1 == char) {
      return;
    }
    state = state.copyWith(selectedHorseNameChar1: char);
  }

  ///
  void setSelectedHorseNameChar2({required String char}) {
    if (state.selectedHorseNameChar2 == char) {
      return;
    }
    state = state.copyWith(selectedHorseNameChar2: char);
  }

  ///
  void setAllExpanded() => state = state.copyWith(allExpanded: !state.allExpanded);

  ///
  void setIsShowSideTabPanel({required bool flag}) {
    if (state.isShowSideTabPanel == flag) {
      return;
    }
    state = state.copyWith(isShowSideTabPanel: flag);
  }

  ///
  void setSelectedHorseLineNum({required int? num}) {
    if (state.selectedHorseLineNum == num) {
      return;
    }
    state = state.copyWith(selectedHorseLineNum: num);
  }
}
