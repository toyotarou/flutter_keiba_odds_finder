import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/popularity_rank_odds_median_model.dart';
import '../../utility/utility.dart';

part 'popularity_rank_odds_median.freezed.dart';

part 'popularity_rank_odds_median.g.dart';

@freezed
class PopularityRankOddsMedianState with _$PopularityRankOddsMedianState {
  const factory PopularityRankOddsMedianState({
    @Default(<PopularityRankOddsMedianModel>[]) List<PopularityRankOddsMedianModel> popularityRankOddsMedianList,

    @Default(<String, PopularityRankOddsMedianModel>{})
    Map<String, PopularityRankOddsMedianModel> popularityRankOddsMedianMap,
  }) = _PopularityRankOddsMedianState;
}

@riverpod
class PopularityRankOddsMedian extends _$PopularityRankOddsMedian {
  final Utility utility = Utility();

  ///
  @override
  PopularityRankOddsMedianState build() => const PopularityRankOddsMedianState();

  //============================================== api

  ///
  Future<PopularityRankOddsMedianState> fetchAllPopularityRankOddsMedianData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<PopularityRankOddsMedianModel> list = <PopularityRankOddsMedianModel>[];

      final Map<String, PopularityRankOddsMedianModel> map = <String, PopularityRankOddsMedianModel>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderPopularityRankMedian).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          final PopularityRankOddsMedianModel val = PopularityRankOddsMedianModel.fromJson(
            // ignore: avoid_dynamic_calls
            value['data'][i] as Map<String, dynamic>,
          );

          list.add(val);

          map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] = val;
        }
      });

      return state.copyWith(popularityRankOddsMedianList: list, popularityRankOddsMedianMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllPopularityRankOddsMedianData() async {
    try {
      final PopularityRankOddsMedianState newState = await fetchAllPopularityRankOddsMedianData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
