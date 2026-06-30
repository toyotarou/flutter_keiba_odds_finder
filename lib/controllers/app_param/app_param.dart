import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../utility/utility.dart';
import '../../models/horse_model.dart';
import '../../models/login_user_model.dart';
import '../../models/odds_model.dart';
import '../../models/odds_wide_model.dart';
import '../../models/popularity_rank_odds_average_model.dart';
import '../../models/push_notifier_user_model.dart';
import '../../models/race_model.dart';
import '../../models/schedule_model.dart';
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

    @Default(<String, List<OddsWideModel>>{}) Map<String, List<OddsWideModel>> keepOddsWideMap,

    @Default(<String, List<SummaryModel>>{}) Map<String, List<SummaryModel>> keepSummaryMap,

    @Default(<String, List<String>>{}) Map<String, List<String>> keepSummaryDateBashoMap,

    @Default(<String, LoginUserModel>{}) Map<String, LoginUserModel> keepLoginUserMap,

    @Default(<PushNotifierUserModel>[]) List<PushNotifierUserModel> keepPushNotifierUserList,

    @Default(<int, PopularityRankOddsAverageModel>{})
    Map<int, PopularityRankOddsAverageModel> keepPopularityRankOddsAverageMap,

    ///
    @Default('') String configOddsGetTiming,

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
  }) = _AppParamState;
}

@riverpod
class AppParam extends _$AppParam {
  final Utility utility = Utility();

  ///
  @override
  AppParamState build() => const AppParamState();

  ///
  void setKeepScheduleDateBashoMap({required Map<String, List<ScheduleModel>> map}) =>
      state = state.copyWith(keepScheduleDateBashoMap: map);

  ///
  void setKeepRaceMap({required Map<String, List<RaceModel>> map}) => state = state.copyWith(keepRaceMap: map);

  ///
  void setKeepHorseMap({required Map<String, List<HorseModel>> map}) => state = state.copyWith(keepHorseMap: map);

  ///
  void setKeepOddsMap({required Map<String, List<OddsModel>> map}) => state = state.copyWith(keepOddsMap: map);

  ///
  void setKeepOddsWideMap({required Map<String, List<OddsWideModel>> map}) =>
      state = state.copyWith(keepOddsWideMap: map);

  ///
  void setKeepSummaryMap({required Map<String, List<SummaryModel>> map}) => state = state.copyWith(keepSummaryMap: map);

  ///
  void setKeepSummaryDateBashoMap({required Map<String, List<String>> map}) =>
      state = state.copyWith(keepSummaryDateBashoMap: map);

  ///
  void setKeepLoginUserMap({required Map<String, LoginUserModel> map}) => state = state.copyWith(keepLoginUserMap: map);

  ///
  void setKeepPushNotifierUserList({required List<PushNotifierUserModel> list}) =>
      state = state.copyWith(keepPushNotifierUserList: list);

  ///
  void setKeepPopularityRankOddsAverageMap({required Map<int, PopularityRankOddsAverageModel> map}) =>
      state = state.copyWith(keepPopularityRankOddsAverageMap: map);

  //////////////

  void setConfigOddsGetTiming({required String oddsGetTiming}) =>
      state = state.copyWith(configOddsGetTiming: oddsGetTiming);

  //////////////

  ///
  void setSelectedScheduleDate({required String date}) => state = state.copyWith(selectedScheduleDate: date);

  ///
  void setSelectedScheduleKaisuuBashoDay({required String kbd, required String name}) =>
      state = state.copyWith(selectedScheduleKaisuuBashoDay: kbd, selectedScheduleKaisuuBashoDayName: name);

  ///
  void setSelectedRaceNumber({required int num}) => state = state.copyWith(selectedRaceNumber: num);

  ///
  void setSelectedTiming({required String timing}) => state = state.copyWith(selectedTiming: timing);

  ///
  void setSelectedTiming2({required String timing2}) => state = state.copyWith(selectedTiming2: timing2);

  ///
  void setQueryUser({required String user}) => state = state.copyWith(queryUser: user);

  ///
  void setIsShowUpperBox({required bool flag}) => state = state.copyWith(isShowUpperBox: flag);

  ///
  void setIsShowUpperBox2({required bool flag}) => state = state.copyWith(isShowUpperBox2: flag);

  ///
  void setSelectedDrawerRace({required String race}) => state = state.copyWith(selectedDrawerRace: race);

  ///
  void setIsZoomed({required bool flag}) => state = state.copyWith(isZoomed: flag);

  ///
  void setSelectedUpsetBoxNum({required int num}) => state = state.copyWith(selectedUpsetBoxNum: num);

  ///
  void setSelectedPopularityRank({required int rank}) => state = state.copyWith(selectedPopularityRank: rank);

  ///
  void setSelectedPopularityRankYear({required String year}) =>
      state = state.copyWith(selectedPopularityRankYear: year);
}
