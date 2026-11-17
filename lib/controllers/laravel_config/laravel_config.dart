// =============================================================================
// ファイル名   : laravel_config.dart
// 概要         : サーバー側の設定値を API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-30
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../utility/utility.dart';

part 'laravel_config.freezed.dart';

part 'laravel_config.g.dart';

/// サーバー側の設定値の状態。
@freezed
class LaravelConfigState with _$LaravelConfigState {
  // ignore: non_constant_identifier_names
  const factory LaravelConfigState({
    @Default('') String oddsGetTiming,

    @Default('') String oddsDropRateHonmei,
    @Default('') String oddsDropRateChuana,
    @Default('') String oddsDropRateDaiana,

    @Default('') String baganrikiBrain,
  }) = _LaravelConfigState;
}

/// サーバー側の設定値を API から取得して保持する Notifier。
@riverpod
class LaravelConfig extends _$LaravelConfig {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  LaravelConfigState build() => const LaravelConfigState();

  //============================================== api

  /// API からサーバー側の設定値を全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
  Future<LaravelConfigState> fetchAllLaravelConfigData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      String strOddsGetTiming = '';

      String strOddsDropRateHonmei = '';
      String strOddsDropRateChuana = '';
      String strOddsDropRateDaiana = '';

      String strBaganrikiBrain = '';

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderConfigs).then((value) {
        // ignore: avoid_dynamic_calls
        strOddsGetTiming = value['data']['odds_get_timing'] as String;

        // ignore: avoid_dynamic_calls, always_specify_types
        final oddsDropRate = value['data']['odds_drop_rate'];
        // ignore: avoid_dynamic_calls
        strOddsDropRateHonmei = (oddsDropRate['honmei'] as num).toString();
        // ignore: avoid_dynamic_calls
        strOddsDropRateChuana = (oddsDropRate['chu_ana'] as num).toString();
        // ignore: avoid_dynamic_calls
        strOddsDropRateDaiana = (oddsDropRate['daiana'] as num).toString();

        // ignore: avoid_dynamic_calls
        strBaganrikiBrain = value['data']['baganriki_brain'] as String;
      });

      return state.copyWith(
        oddsGetTiming: strOddsGetTiming,
        oddsDropRateHonmei: strOddsDropRateHonmei,
        oddsDropRateChuana: strOddsDropRateChuana,
        oddsDropRateDaiana: strOddsDropRateDaiana,
        baganrikiBrain: strBaganrikiBrain,
      );
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  /// サーバー側の設定値を全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllLaravelConfigData() async {
    try {
      final LaravelConfigState newState = await fetchAllLaravelConfigData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
