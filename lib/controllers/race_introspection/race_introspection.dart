import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/race_introspection_model.dart';
import '../../utility/utility.dart';

part 'race_introspection.freezed.dart';

part 'race_introspection.g.dart';

@freezed
class RaceIntrospectionState with _$RaceIntrospectionState {
  const factory RaceIntrospectionState({
    @Default(<RaceIntrospectionModel>[]) List<RaceIntrospectionModel> raceIntrospectionList,
    @Default(<String, RaceIntrospectionModel>{}) Map<String, RaceIntrospectionModel> raceIntrospectionMap,
  }) = _RaceIntrospectionState;
}

@riverpod
class RaceIntrospection extends _$RaceIntrospection {
  final Utility utility = Utility();

  ///
  @override
  RaceIntrospectionState build() => const RaceIntrospectionState();

  //============================================== api

  ///
  Future<RaceIntrospectionState> fetchAllRaceIntrospectionData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<RaceIntrospectionModel> list = <RaceIntrospectionModel>[];
      final Map<String, RaceIntrospectionModel> map = <String, RaceIntrospectionModel>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderRaceIntrospection).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final RaceIntrospectionModel val = RaceIntrospectionModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          map['${val.date}_${val.kaisuu}_${val.bashoCode}_${val.day}_${val.race}'] = val;
        }
      });

      return state.copyWith(raceIntrospectionList: list, raceIntrospectionMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllRaceIntrospectionData() async {
    try {
      final RaceIntrospectionState newState = await fetchAllRaceIntrospectionData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
