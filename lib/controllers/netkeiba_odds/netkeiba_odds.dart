import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/netkeiba_odds_model.dart';
import '../../utility/utility.dart';

part 'netkeiba_odds.freezed.dart';

part 'netkeiba_odds.g.dart';

@freezed
class NetkeibaOddsState with _$NetkeibaOddsState {
  const factory NetkeibaOddsState({
    @Default(<NetkeibaOddsModel>[]) List<NetkeibaOddsModel> netkeibaOddsList,

    @Default(<String, List<NetkeibaOddsModel>>{}) Map<String, List<NetkeibaOddsModel>> netkeibaOddsMap,
  }) = _NetkeibaOddsState;
}

@riverpod
class NetkeibaOdds extends _$NetkeibaOdds {
  final Utility utility = Utility();

  ///
  @override
  NetkeibaOddsState build() => const NetkeibaOddsState();

  //============================================== api

  ///
  Future<NetkeibaOddsState> fetchAllNetkeibaOddsData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<NetkeibaOddsModel> list = <NetkeibaOddsModel>[];

      final Map<String, List<NetkeibaOddsModel>> map = <String, List<NetkeibaOddsModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderNetkeibaOdds).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final NetkeibaOddsModel val = NetkeibaOddsModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <NetkeibaOddsModel>[]).add(val);
        }
      });

      return state.copyWith(netkeibaOddsList: list, netkeibaOddsMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> get__AllNetkeibaOddsData() async {
    try {
      final NetkeibaOddsState newState = await fetchAllNetkeibaOddsData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
