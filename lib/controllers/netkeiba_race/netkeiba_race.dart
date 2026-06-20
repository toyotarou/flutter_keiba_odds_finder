import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/netkeiba_race_model.dart';
import '../../utility/utility.dart';

part 'netkeiba_race.freezed.dart';

part 'netkeiba_race.g.dart';

@freezed
class NetkeibaRaceState with _$NetkeibaRaceState {
  const factory NetkeibaRaceState({
    @Default(<NetkeibaRaceModel>[]) List<NetkeibaRaceModel> netkeibaRaceList,

    @Default(<String, List<NetkeibaRaceModel>>{}) Map<String, List<NetkeibaRaceModel>> netkeibaRaceMap,
  }) = _NetkeibaRaceState;
}

@riverpod
class NetkeibaRace extends _$NetkeibaRace {
  final Utility utility = Utility();

  ///
  @override
  NetkeibaRaceState build() => const NetkeibaRaceState();

  //============================================== api

  ///
  Future<NetkeibaRaceState> fetchAllNetkeibaRaceData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<NetkeibaRaceModel> list = <NetkeibaRaceModel>[];

      final Map<String, List<NetkeibaRaceModel>> map = <String, List<NetkeibaRaceModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderNetkeibaRaces).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final NetkeibaRaceModel val = NetkeibaRaceModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <NetkeibaRaceModel>[]).add(val);
        }
      });

      return state.copyWith(netkeibaRaceList: list, netkeibaRaceMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> get__AllNetkeibaRaceData() async {
    try {
      final NetkeibaRaceState newState = await fetchAllNetkeibaRaceData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
