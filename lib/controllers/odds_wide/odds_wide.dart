import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/odds_wide_model.dart';
import '../../utility/utility.dart';

part 'odds_wide.freezed.dart';

part 'odds_wide.g.dart';

@freezed
class OddsWideState with _$OddsWideState {
  const factory OddsWideState({
    @Default(<OddsWideModel>[]) List<OddsWideModel> oddsWideList,

    @Default(<String, List<OddsWideModel>>{}) Map<String, List<OddsWideModel>> oddsWideMap,
  }) = _OddsWideState;
}

@riverpod
class OddsWide extends _$OddsWide {
  final Utility utility = Utility();

  ///
  @override
  OddsWideState build() => const OddsWideState();

  //============================================== api

  ///
  Future<OddsWideState> fetchAllOddsWideData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<OddsWideModel> list = <OddsWideModel>[];

      final Map<String, List<OddsWideModel>> map = <String, List<OddsWideModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderOddsWide).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final OddsWideModel val = OddsWideModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <OddsWideModel>[]).add(val);
        }
      });

      return state.copyWith(oddsWideList: list, oddsWideMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllOddsWideData() async {
    try {
      final OddsWideState newState = await fetchAllOddsWideData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
