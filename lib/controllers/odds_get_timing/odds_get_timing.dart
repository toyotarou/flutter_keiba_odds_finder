import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/odds_get_timing_model.dart';
import '../../utility/utility.dart';

part 'odds_get_timing.freezed.dart';

part 'odds_get_timing.g.dart';

@freezed
class OddsGetTimingState with _$OddsGetTimingState {
  const factory OddsGetTimingState({
    @Default(<OddsGetTimingModel>[]) List<OddsGetTimingModel> oddsGetTimingList,

    @Default(<String, List<OddsGetTimingModel>>{}) Map<String, List<OddsGetTimingModel>> oddsGetTimingMap,
  }) = _OddsGetTimingState;
}

@riverpod
class OddsGetTiming extends _$OddsGetTiming {
  final Utility utility = Utility();

  ///
  @override
  OddsGetTimingState build() => const OddsGetTimingState();

  //============================================== api

  ///
  Future<OddsGetTimingState> fetchAllOddsGetTimingData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<OddsGetTimingModel> list = <OddsGetTimingModel>[];

      final Map<String, List<OddsGetTimingModel>> map = <String, List<OddsGetTimingModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderOddsGetTiming).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final OddsGetTimingModel val = OddsGetTimingModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <OddsGetTimingModel>[]).add(val);
        }
      });

      return state.copyWith(oddsGetTimingList: list, oddsGetTimingMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllOddsGetTimingData() async {
    try {
      final OddsGetTimingState newState = await fetchAllOddsGetTimingData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
