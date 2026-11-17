// =============================================================================
// ファイル名   : horse_score.dart
// 概要         : 馬ごとのスコアを API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-29
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/score_model.dart';
import '../../utility/utility.dart';

part 'horse_score.freezed.dart';

part 'horse_score.g.dart';

/// 馬ごとのスコアの状態。
@freezed
class HorseScoreState with _$HorseScoreState {
  const factory HorseScoreState({
    @Default(<ScoreModel>[]) List<ScoreModel> horseScoreList,
    @Default(<String, ScoreModel>{}) Map<String, ScoreModel> horseScoreMap,
  }) = _HorseScoreState;
}

/// 馬ごとのスコアを API から取得して保持する Notifier。
@riverpod
class HorseScore extends _$HorseScore {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  HorseScoreState build() => const HorseScoreState();

  //============================================== api

  /// API から馬ごとのスコアを全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
  Future<HorseScoreState> fetchAllHorseScoreData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<ScoreModel> list = <ScoreModel>[];
      final Map<String, ScoreModel> map = <String, ScoreModel>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderHorseScores).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final ScoreModel val = ScoreModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          map[val.name] = val;
        }
      });

      return state.copyWith(horseScoreList: list, horseScoreMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  /// 馬ごとのスコアを全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllHorseScoreData() async {
    try {
      final HorseScoreState newState = await fetchAllHorseScoreData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
