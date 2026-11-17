// =============================================================================
// ファイル名   : popularity_rank_odds_median.dart
// 概要         : 人気順別オッズ中央値を API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-20
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/popularity_rank_odds_median_model.dart';
import '../../utility/utility.dart';

part 'popularity_rank_odds_median.freezed.dart';

part 'popularity_rank_odds_median.g.dart';

/// 人気順別オッズ中央値の状態。
@freezed
class PopularityRankOddsMedianState with _$PopularityRankOddsMedianState {
  const factory PopularityRankOddsMedianState({
    @Default(<PopularityRankOddsMedianModel>[]) List<PopularityRankOddsMedianModel> popularityRankOddsMedianList,

    @Default(<String, List<PopularityRankOddsMedianModel>>{})
    Map<String, List<PopularityRankOddsMedianModel>> popularityRankOddsMedianMap,
  }) = _PopularityRankOddsMedianState;
}

/// 人気順別オッズ中央値を API から取得して保持する Notifier。
@riverpod
class PopularityRankOddsMedian extends _$PopularityRankOddsMedian {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  PopularityRankOddsMedianState build() => const PopularityRankOddsMedianState();

  //============================================== api

  /// API から人気順別オッズ中央値を全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
  Future<PopularityRankOddsMedianState> fetchAllPopularityRankOddsMedianData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<PopularityRankOddsMedianModel> list = <PopularityRankOddsMedianModel>[];

      final Map<String, List<PopularityRankOddsMedianModel>> map = <String, List<PopularityRankOddsMedianModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderPopularityRankMedian).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          final PopularityRankOddsMedianModel val = PopularityRankOddsMedianModel.fromJson(
            // ignore: avoid_dynamic_calls
            value['data'][i] as Map<String, dynamic>,
          );

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <PopularityRankOddsMedianModel>[]).add(val);
        }
      });

      return state.copyWith(popularityRankOddsMedianList: list, popularityRankOddsMedianMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  /// 人気順別オッズ中央値を全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllPopularityRankOddsMedianData() async {
    try {
      final PopularityRankOddsMedianState newState = await fetchAllPopularityRankOddsMedianData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
