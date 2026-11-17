// =============================================================================
// ファイル名   : app_param.dart
// 概要         : アプリ全体で共有する値（取得済みデータ・サーバーの設定値・画面の選択状態）を
//                保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-30
// 最終更新日   : 2026-11-17
// =============================================================================

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

/// アプリ全体で共有する値の状態。
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

    // ── サーバーの設定値 ──
    @Default('') String configOddsGetTiming,
    @Default('') String configOddsDropRateHonmei,
    @Default('') String configOddsDropRateChuana,
    @Default('') String configOddsDropRateDaiana,

    @Default('') String configBaganrikiBrain,

    // ── 画面の選択状態 ──
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

/// アプリ全体で共有する値を保持・更新する Notifier。
/// 各 setter は、値が変わらないときは state を更新しない。
@riverpod
class AppParam extends _$AppParam {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  AppParamState build() => const AppParamState();

  // 各 setter は値が変わらない場合は state を更新しない。
  // Notifier は同値でも別インスタンスを代入すると通知するため、
  // build 中の postFrame から同じ値を毎回セットすると再描画が止まらなくなる（race_content_page の selectedTiming2 など）。

  /// 開催日ごとの開催スケジュール（キー: 開催日）を保持する。
  void setKeepScheduleDateBashoMap({required Map<String, List<ScheduleModel>> map}) {
    if (identical(state.keepScheduleDateBashoMap, map)) {
      return;
    }
    state = state.copyWith(keepScheduleDateBashoMap: map);
  }

  /// 開催ごとのレース一覧（キー: 開催日_開催回_競馬場_日目）を保持する。
  void setKeepRaceMap({required Map<String, List<RaceModel>> map}) {
    if (identical(state.keepRaceMap, map)) {
      return;
    }
    state = state.copyWith(keepRaceMap: map);
  }

  /// 開催ごとの出走馬一覧（キー: 開催日_開催回_競馬場_日目）を保持する。
  void setKeepHorseMap({required Map<String, List<HorseModel>> map}) {
    if (identical(state.keepHorseMap, map)) {
      return;
    }
    state = state.copyWith(keepHorseMap: map);
  }

  /// 取得済みのオッズ一覧を保持する。
  void setKeepOddsMap({required Map<String, List<OddsModel>> map}) {
    if (identical(state.keepOddsMap, map)) {
      return;
    }
    state = state.copyWith(keepOddsMap: map);
  }

  /// 取得済みのオッズ推移サマリーを保持する。
  void setKeepSummaryMap({required Map<String, List<SummaryModel>> map}) {
    if (identical(state.keepSummaryMap, map)) {
      return;
    }
    state = state.copyWith(keepSummaryMap: map);
  }

  /// サマリーがある開催日と競馬場の対応表を保持する。
  void setKeepSummaryDateBashoMap({required Map<String, List<String>> map}) {
    if (identical(state.keepSummaryDateBashoMap, map)) {
      return;
    }
    state = state.copyWith(keepSummaryDateBashoMap: map);
  }

  /// ログインユーザーの一覧（キー: ユーザーID）を保持する。
  void setKeepLoginUserMap({required Map<String, LoginUserModel> map}) {
    if (identical(state.keepLoginUserMap, map)) {
      return;
    }
    state = state.copyWith(keepLoginUserMap: map);
  }

  /// プッシュ通知の送信対象ユーザー一覧を保持する。
  void setKeepPushNotifierUserList({required List<PushNotifierUserModel> list}) {
    if (identical(state.keepPushNotifierUserList, list)) {
      return;
    }
    state = state.copyWith(keepPushNotifierUserList: list);
  }

  /// 人気順別オッズ中央値の一覧を保持する。
  void setKeepPopularityRankOddsMedianMap({required Map<String, List<PopularityRankOddsMedianModel>> map}) {
    if (identical(state.keepPopularityRankOddsMedianMap, map)) {
      return;
    }
    state = state.copyWith(keepPopularityRankOddsMedianMap: map);
  }

  /// 馬ごとのスコア（キー: 馬名）を保持する。
  void setKeepHorseScoreMap({required Map<String, ScoreModel> map}) {
    if (identical(state.keepHorseScoreMap, map)) {
      return;
    }
    state = state.copyWith(keepHorseScoreMap: map);
  }

  /// 騎手ごとのスコア（キー: 騎手名）を保持する。
  void setKeepJockeyScoreMap({required Map<String, ScoreModel> map}) {
    if (identical(state.keepJockeyScoreMap, map)) {
      return;
    }
    state = state.copyWith(keepJockeyScoreMap: map);
  }

  /// レースごとの振り返りを保持する。
  void setKeepRaceIntrospectionMap({required Map<String, RaceIntrospectionModel> map}) {
    if (identical(state.keepRaceIntrospectionMap, map)) {
      return;
    }
    state = state.copyWith(keepRaceIntrospectionMap: map);
  }

  /// 開発者向けお知らせを、種類別（map）と時刻別（map2）の2通りで保持する。
  void setKeepDeveloperNews({
    required Map<String, List<DeveloperNewsModel>> map,
    required Map<String, List<DeveloperNewsModel>> map2,
  }) {
    if (identical(state.keepDeveloperNewsKindMap, map) && identical(state.keepDeveloperNewsTimeMap, map2)) {
      return;
    }
    state = state.copyWith(keepDeveloperNewsKindMap: map, keepDeveloperNewsTimeMap: map2);
  }

  /// AI 分析（1st AI）の結果を保持する。
  void setKeepAiAnalysisMap({required Map<String, List<AiAnalysisModel>> map}) {
    if (identical(state.keepAiAnalysisMap, map)) {
      return;
    }
    state = state.copyWith(keepAiAnalysisMap: map);
  }

  /// AI 分析（2nd AI）の結果を保持する。
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

  /// オッズ急落の判定に使う率（本命・中穴・大穴）を保持する。
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

  /// 「馬眼力の頭脳」画面に表示する文章を保持する。
  void setConfigBaganrikiBrain({required String str}) {
    if (state.configBaganrikiBrain == str) {
      return;
    }
    state = state.copyWith(configBaganrikiBrain: str);
  }

  //////////////

  /// 選択中の開催日を更新する。
  void setSelectedScheduleDate({required String date}) {
    if (state.selectedScheduleDate == date) {
      return;
    }
    state = state.copyWith(selectedScheduleDate: date);
  }

  /// 選択中の開催（開催回・競馬場・日目のキーと表示名）を更新する。
  void setSelectedScheduleKaisuuBashoDay({required String kbd, required String name}) {
    if (state.selectedScheduleKaisuuBashoDay == kbd && state.selectedScheduleKaisuuBashoDayName == name) {
      return;
    }
    state = state.copyWith(selectedScheduleKaisuuBashoDay: kbd, selectedScheduleKaisuuBashoDayName: name);
  }

  /// 選択中のレース番号を更新する。
  void setSelectedRaceNumber({required int num}) {
    if (state.selectedRaceNumber == num) {
      return;
    }
    state = state.copyWith(selectedRaceNumber: num);
  }

  /// 選択中のオッズ取得タイミングを更新する。
  void setSelectedTiming({required String timing}) {
    if (state.selectedTiming == timing) {
      return;
    }
    state = state.copyWith(selectedTiming: timing);
  }

  /// タイミング未選択のときに使う、既定のオッズ取得タイミングを更新する。
  void setSelectedTiming2({required String timing2}) {
    if (state.selectedTiming2 == timing2) {
      return;
    }
    state = state.copyWith(selectedTiming2: timing2);
  }

  /// ユーザー検索の文字列を更新する。
  void setQueryUser({required String user}) {
    if (state.queryUser == user) {
      return;
    }
    state = state.copyWith(queryUser: user);
  }

  /// レース画面の上部エリアの表示・非表示を更新する。
  void setIsShowUpperBox({required bool flag}) {
    if (state.isShowUpperBox == flag) {
      return;
    }
    state = state.copyWith(isShowUpperBox: flag);
  }

  /// オッズランキング画面の上部エリアの表示・非表示を更新する。
  void setIsShowUpperBox2({required bool flag}) {
    if (state.isShowUpperBox2 == flag) {
      return;
    }
    state = state.copyWith(isShowUpperBox2: flag);
  }

  /// 過去レース一覧（ドロワー）で選択中のレースを更新する。
  void setSelectedDrawerRace({required String race}) {
    if (state.selectedDrawerRace == race) {
      return;
    }
    state = state.copyWith(selectedDrawerRace: race);
  }

  /// オッズランキング画面の拡大表示中かどうかを更新する。
  void setIsZoomed({required bool flag}) {
    if (state.isZoomed == flag) {
      return;
    }
    state = state.copyWith(isZoomed: flag);
  }

  /// 選択中の人気順を更新する。
  void setSelectedPopularityRank({required int rank}) {
    if (state.selectedPopularityRank == rank) {
      return;
    }
    state = state.copyWith(selectedPopularityRank: rank);
  }

  /// 人気別成績画面で選択中の年を更新する。
  void setSelectedPopularityRankYear({required String year}) {
    if (state.selectedPopularityRankYear == year) {
      return;
    }
    state = state.copyWith(selectedPopularityRankYear: year);
  }

  /// 過去レース成績画面で選択中の年を更新する。
  void setSelectedHistoryYear({required String year}) {
    if (state.selectedHistoryYear == year) {
      return;
    }
    state = state.copyWith(selectedHistoryYear: year);
  }

  /// 馬名頭文字パネルで選択中の1文字目を更新する。
  void setSelectedHorseNameChar1({required String char}) {
    if (state.selectedHorseNameChar1 == char) {
      return;
    }
    state = state.copyWith(selectedHorseNameChar1: char);
  }

  /// 馬名頭文字パネルで選択中の2文字目を更新する。
  void setSelectedHorseNameChar2({required String char}) {
    if (state.selectedHorseNameChar2 == char) {
      return;
    }
    state = state.copyWith(selectedHorseNameChar2: char);
  }

  /// 馬ごとの明細を、すべて開く／すべて閉じるを切り替える。
  void setAllExpanded() => state = state.copyWith(allExpanded: !state.allExpanded);

  /// オッズ推移グラフで強調表示する馬番を更新する（null で解除）。
  void setSelectedHorseLineNum({required int? num}) {
    if (state.selectedHorseLineNum == num) {
      return;
    }
    state = state.copyWith(selectedHorseLineNum: num);
  }
}
