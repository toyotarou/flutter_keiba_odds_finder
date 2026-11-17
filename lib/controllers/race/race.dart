// =============================================================================
// ファイル名   : race.dart
// 概要         : レースを API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-30
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/race_model.dart';
import '../../utility/utility.dart';

part 'race.freezed.dart';

part 'race.g.dart';

/// レースの状態。
@freezed
class RaceState with _$RaceState {
  const factory RaceState({
    @Default(<RaceModel>[]) List<RaceModel> raceList,

    @Default(<String, List<RaceModel>>{}) Map<String, List<RaceModel>> raceMap,
  }) = _RaceState;
}

/// レースを API から取得して保持する Notifier。
@riverpod
class Race extends _$Race {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  RaceState build() => const RaceState();

  //============================================== api

  /// API からレースを全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
  Future<RaceState> fetchAllRaceData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<RaceModel> list = <RaceModel>[];

      final Map<String, List<RaceModel>> map = <String, List<RaceModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderRaces).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final RaceModel val = RaceModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <RaceModel>[]).add(val);
        }
      });

      return state.copyWith(raceList: list, raceMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  /// レースを全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllRaceData() async {
    try {
      final RaceState newState = await fetchAllRaceData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
