import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/race_result_history_model.dart';
import '../../utility/utility.dart';

part 'race_result_history.freezed.dart';

part 'race_result_history.g.dart';

@freezed
class RaceResultHistoryState with _$RaceResultHistoryState {
  const factory RaceResultHistoryState({
    @Default(<RaceResultHistoryModel>[]) List<RaceResultHistoryModel> raceResultHistoryList,

    @Default(<String, List<RaceResultHistoryModel>>{}) Map<String, List<RaceResultHistoryModel>> raceResultHistoryMap,
  }) = _RaceResultHistoryState;
}

@riverpod
class RaceResultHistory extends _$RaceResultHistory {
  final Utility utility = Utility();

  ///
  @override
  RaceResultHistoryState build() => const RaceResultHistoryState();

  ///
  Future<void> fetchRaceResultHistory({required int rank}) async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<RaceResultHistoryModel> list = <RaceResultHistoryModel>[];

      final Map<String, List<RaceResultHistoryModel>> map = <String, List<RaceResultHistoryModel>>{};

      await client
          .get(path: APIPath.getHorseOddsFinderRaceResultHistory, queryParameters: <String, dynamic>{'rank': rank.toString()})
          .then((
            // ignore: always_specify_types
            value,
          ) {
            // ignore: avoid_dynamic_calls
            for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
              // ignore: avoid_dynamic_calls
              final RaceResultHistoryModel val = RaceResultHistoryModel.fromJson(
                // ignore: avoid_dynamic_calls
                value['data'][i] as Map<String, dynamic>,
              );

              list.add(val);

              (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <RaceResultHistoryModel>[]).add(val);
            }

            state = state.copyWith(raceResultHistoryList: list, raceResultHistoryMap: map);
          });
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow;
    }
  }
}
