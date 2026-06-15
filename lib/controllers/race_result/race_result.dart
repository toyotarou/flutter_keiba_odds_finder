import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/race_result_model.dart';
import '../../utility/utility.dart';

part 'race_result.freezed.dart';

part 'race_result.g.dart';

@freezed
class RaceResultState with _$RaceResultState {
  const factory RaceResultState({
    @Default(<RaceResultModel>[]) List<RaceResultModel> raceResultList,
    @Default(<String, List<RaceResultModel>>{}) Map<String, List<RaceResultModel>> raceResultMap,
  }) = _RaceResultState;
}

@riverpod
class RaceResult extends _$RaceResult {
  final Utility utility = Utility();

  ///
  @override
  RaceResultState build() => const RaceResultState();

  //============================================== api

  ///
  Future<RaceResultState> fetchAllRaceResultData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<RaceResultModel> list = <RaceResultModel>[];

      final Map<String, List<RaceResultModel>> map = <String, List<RaceResultModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderRaceOneResult).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final RaceResultModel val = RaceResultModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <RaceResultModel>[]).add(val);
        }
      });

      return state.copyWith(raceResultList: list, raceResultMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllRaceResultData() async {
    try {
      final RaceResultState newState = await fetchAllRaceResultData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
