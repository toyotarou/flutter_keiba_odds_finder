import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/odds_model.dart';
import '../../utility/utility.dart';

part 'odds.freezed.dart';

part 'odds.g.dart';

@freezed
class OddsState with _$OddsState {
  const factory OddsState({
    @Default(<OddsModel>[]) List<OddsModel> oddsList,

    @Default(<String, List<OddsModel>>{}) Map<String, List<OddsModel>> oddsMap,
  }) = _OddsState;
}

@riverpod
class Odds extends _$Odds {
  final Utility utility = Utility();

  ///
  @override
  OddsState build() => const OddsState();

  //============================================== api

  ///
  Future<OddsState> fetchAllOddsData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<OddsModel> list = <OddsModel>[];

      final Map<String, List<OddsModel>> map = <String, List<OddsModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderOdds).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final OddsModel val = OddsModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <OddsModel>[]).add(val);
        }
      });

      return state.copyWith(oddsList: list, oddsMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllOddsData() async {
    try {
      final OddsState newState = await fetchAllOddsData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
