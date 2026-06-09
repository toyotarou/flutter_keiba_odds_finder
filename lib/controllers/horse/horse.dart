import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/horse_detail_model.dart';
import '../../models/horse_model.dart';
import '../../utility/utility.dart';

part 'horse.freezed.dart';

part 'horse.g.dart';

@freezed
class HorseState with _$HorseState {
  const factory HorseState({
    @Default(<HorseModel>[]) List<HorseModel> horseList,

    @Default(<String, List<HorseModel>>{}) Map<String, List<HorseModel>> horseMap,

    HorseDetailModel? horseDetail,
  }) = _HorseState;
}

@riverpod
class Horse extends _$Horse {
  final Utility utility = Utility();

  ///
  @override
  HorseState build() => const HorseState();

  //============================================== api

  ///
  Future<HorseState> fetchAllHorseData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<HorseModel> list = <HorseModel>[];
      final Map<String, List<HorseModel>> map = <String, List<HorseModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderHorses).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final HorseModel val = HorseModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <HorseModel>[]).add(val);
        }
      });

      return state.copyWith(horseList: list, horseMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllHorseData() async {
    try {
      final HorseState newState = await fetchAllHorseData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api

  ///
  Future<void> fetchHorseDetail({required String horseId}) async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseDetail, queryParameters: {'cname': horseId}).then((value) {
        // ignore: avoid_dynamic_calls
        final HorseDetailModel detail = HorseDetailModel.fromJson(value['data'] as Map<String, dynamic>);
        state = state.copyWith(horseDetail: detail);
      });
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow;
    }
  }
}
