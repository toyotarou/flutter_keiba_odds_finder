// =============================================================================
// ファイル名   : race_introspection.dart
// 概要         : レースの振り返りを API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-08-03
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/race_introspection_model.dart';
import '../../utility/utility.dart';

part 'race_introspection.freezed.dart';

part 'race_introspection.g.dart';

/// レースの振り返りの状態。
@freezed
class RaceIntrospectionState with _$RaceIntrospectionState {
  const factory RaceIntrospectionState({
    @Default(<RaceIntrospectionModel>[]) List<RaceIntrospectionModel> raceIntrospectionList,
    @Default(<String, RaceIntrospectionModel>{}) Map<String, RaceIntrospectionModel> raceIntrospectionMap,
  }) = _RaceIntrospectionState;
}

/// レースの振り返りを API から取得して保持する Notifier。
@riverpod
class RaceIntrospection extends _$RaceIntrospection {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  RaceIntrospectionState build() => const RaceIntrospectionState();

  //============================================== api

  /// API からレースの振り返りを全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
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

  /// レースの振り返りを全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllRaceIntrospectionData() async {
    try {
      final RaceIntrospectionState newState = await fetchAllRaceIntrospectionData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
