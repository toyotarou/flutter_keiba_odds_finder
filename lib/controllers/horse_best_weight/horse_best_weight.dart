import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/horse_best_weight_model.dart';
import '../../utility/utility.dart';

part 'horse_best_weight.freezed.dart';

part 'horse_best_weight.g.dart';

@freezed
class HorseBestWeightState with _$HorseBestWeightState {
  const factory HorseBestWeightState({
    @Default(<HorseBestWeightModel>[]) List<HorseBestWeightModel> horseBestWeightList,

    @Default(<String, HorseBestWeightModel>{}) Map<String, HorseBestWeightModel> horseBestWeightMap,
  }) = _HorseBestWeightState;
}

@riverpod
class HorseBestWeight extends _$HorseBestWeight {
  final Utility utility = Utility();

  ///
  @override
  HorseBestWeightState build() => const HorseBestWeightState();

  //============================================== api

  ///
  Future<HorseBestWeightState> fetchAllHorseBestWeightData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<HorseBestWeightModel> list = <HorseBestWeightModel>[];
      final Map<String, HorseBestWeightModel> map = <String, HorseBestWeightModel>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderBestHorseWeight).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final HorseBestWeightModel val = HorseBestWeightModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          map[val.name] = val;
        }
      });

      return state.copyWith(horseBestWeightList: list, horseBestWeightMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllHorseBestWeightData() async {
    try {
      final HorseBestWeightState newState = await fetchAllHorseBestWeightData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
