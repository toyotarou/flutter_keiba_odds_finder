import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/popularity_rank_odds_average_model.dart';
import '../../utility/utility.dart';

part 'popularity_rank_odds_average.freezed.dart';

part 'popularity_rank_odds_average.g.dart';

@freezed
class PopularityRankOddsAverageState with _$PopularityRankOddsAverageState {
  const factory PopularityRankOddsAverageState({
    @Default(<PopularityRankOddsAverageModel>[]) List<PopularityRankOddsAverageModel> popularityRankOddsAverageList,

    @Default(<int, PopularityRankOddsAverageModel>{})
    Map<int, PopularityRankOddsAverageModel> popularityRankOddsAverageMap,
  }) = _PopularityRankOddsAverageState;
}

@riverpod
class PopularityRankOddsAverage extends _$PopularityRankOddsAverage {
  final Utility utility = Utility();

  ///
  @override
  PopularityRankOddsAverageState build() => const PopularityRankOddsAverageState();

  //============================================== api

  ///
  Future<PopularityRankOddsAverageState> fetchAllPopularityRankOddsAverageData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<PopularityRankOddsAverageModel> list = <PopularityRankOddsAverageModel>[];

      final Map<int, PopularityRankOddsAverageModel> map = <int, PopularityRankOddsAverageModel>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderPopularityRankAverage).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          final PopularityRankOddsAverageModel val = PopularityRankOddsAverageModel.fromJson(
            // ignore: avoid_dynamic_calls
            value['data'][i] as Map<String, dynamic>,
          );

          list.add(val);

          map[val.popularityRank] = val;
        }
      });

      return state.copyWith(popularityRankOddsAverageList: list, popularityRankOddsAverageMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllPopularityRankOddsAverageData() async {
    try {
      final PopularityRankOddsAverageState newState = await fetchAllPopularityRankOddsAverageData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
