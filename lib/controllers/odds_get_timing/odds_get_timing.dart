// =============================================================================
// ファイル名   : odds_get_timing.dart
// 概要         : オッズ取得タイミングを API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-31
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/odds_get_timing_model.dart';
import '../../utility/utility.dart';

part 'odds_get_timing.freezed.dart';

part 'odds_get_timing.g.dart';

/// オッズ取得タイミングの状態。
@freezed
class OddsGetTimingState with _$OddsGetTimingState {
  const factory OddsGetTimingState({
    @Default(<OddsGetTimingModel>[]) List<OddsGetTimingModel> oddsGetTimingList,

    @Default(<String, List<OddsGetTimingModel>>{}) Map<String, List<OddsGetTimingModel>> oddsGetTimingMap,
  }) = _OddsGetTimingState;
}

/// オッズ取得タイミングを API から取得して保持する Notifier。
@riverpod
class OddsGetTiming extends _$OddsGetTiming {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  OddsGetTimingState build() => const OddsGetTimingState();

  //============================================== api

  /// API からオッズ取得タイミングを全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
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

  /// オッズ取得タイミングを全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllOddsGetTimingData() async {
    try {
      final OddsGetTimingState newState = await fetchAllOddsGetTimingData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
