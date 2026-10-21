// @ANCHOR-20261020-R122-FLUTTER  r12.2 読取APIのコントローラ
//   GET /api/baganriki/r12-2/races/{race_id}
//
//   読み取りだけです。AIの送信も再選出も起こしません。
//   race_id をキーにして、1レースぶんずつ持ちます。
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../models/baganriki_r122_model.dart';
import '../../utility/utility.dart';

part 'baganriki_r122.freezed.dart';

part 'baganriki_r122.g.dart';

@freezed
class BaganrikiR122State with _$BaganrikiR122State {
  const factory BaganrikiR122State({
    @Default(<String, BaganrikiR122Model>{}) Map<String, BaganrikiR122Model> raceMap,
    @Default(<String>{}) Set<String> loadingRaceIds,
    @Default(<String, String>{}) Map<String, String> errorMap,
  }) = _BaganrikiR122State;
}

@riverpod
class BaganrikiR122 extends _$BaganrikiR122 {
  final Utility utility = Utility();

  ///
  @override
  BaganrikiR122State build() => const BaganrikiR122State();

  //============================================== api

  /// 1レースぶん読みます。読めなければ errorMap に理由を残します。
  Future<BaganrikiR122State> fetchR122Race({required String raceId}) async {
    final HttpClient client = ref.read(httpClientProvider);

    final Map<String, BaganrikiR122Model> map = Map<String, BaganrikiR122Model>.of(state.raceMap);
    final Map<String, String> errors = Map<String, String>.of(state.errorMap);

    try {
      // ignore: always_specify_types
      final value = await client.get(path: APIPath.getBaganrikiR122Race, pathSuffix: raceId);

      if (value is Map<String, dynamic>) {
        map[raceId] = BaganrikiR122Model.fromJson(value);
        errors.remove(raceId);
      } else {
        errors[raceId] = '読取APIの形が違います';
      }
    } catch (e) {
      // 404（そのレースが正本に無い）や通信失敗を、画面を止めずに持ちます。
      errors[raceId] = e.toString();
    }

    return state.copyWith(raceMap: map, errorMap: errors);
  }

  /// 画面から呼ぶ入口。読み込み中の race_id を持っておき、二重に呼びません。
  Future<void> getR122Race({required String raceId}) async {
    if (raceId.isEmpty) {
      return;
    }
    if (state.loadingRaceIds.contains(raceId)) {
      return;
    }

    state = state.copyWith(loadingRaceIds: <String>{...state.loadingRaceIds, raceId});

    try {
      final BaganrikiR122State newState = await fetchR122Race(raceId: raceId);

      final Set<String> loading = <String>{...newState.loadingRaceIds}..remove(raceId);

      state = newState.copyWith(loadingRaceIds: loading);
    } catch (_) {
      final Set<String> loading = <String>{...state.loadingRaceIds}..remove(raceId);

      state = state.copyWith(loadingRaceIds: loading);
    }
  }

  /// 取り直します（取消やライブ状態が動いたあと）。
  Future<void> reloadR122Race({required String raceId}) async {
    final Set<String> loading = <String>{...state.loadingRaceIds}..remove(raceId);

    state = state.copyWith(loadingRaceIds: loading);

    await getR122Race(raceId: raceId);
  }

  //============================================== api

  /// 読み込み済みの1レース（無ければ null）
  BaganrikiR122Model? raceOf(String raceId) => state.raceMap[raceId];

  /// その race_id の読み込み中かどうか
  bool isLoading(String raceId) => state.loadingRaceIds.contains(raceId);

  /// その race_id の読めなかった理由（無ければ空）
  String errorOf(String raceId) => state.errorMap[raceId] ?? '';
}
