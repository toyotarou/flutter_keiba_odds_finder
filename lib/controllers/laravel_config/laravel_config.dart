import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../utility/utility.dart';

part 'laravel_config.freezed.dart';

part 'laravel_config.g.dart';

@freezed
class LaravelConfigState with _$LaravelConfigState {
  // ignore: non_constant_identifier_names
  const factory LaravelConfigState({
    @Default('') String oddsGetTiming,

    @Default('') String oddsDropRateHonmei,
    @Default('') String oddsDropRateChuana,
    @Default('') String oddsDropRateDaiana,
  }) = _LaravelConfigState;
}

@riverpod
class LaravelConfig extends _$LaravelConfig {
  final Utility utility = Utility();

  ///
  @override
  LaravelConfigState build() => const LaravelConfigState();

  //============================================== api

  ///
  Future<LaravelConfigState> fetchAllLaravelConfigData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      String strOddsGetTiming = '';

      String strOddsDropRateHonmei = '';
      String strOddsDropRateChuana = '';
      String strOddsDropRateDaiana = '';

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
      });

      return state.copyWith(
        oddsGetTiming: strOddsGetTiming,
        oddsDropRateHonmei: strOddsDropRateHonmei,
        oddsDropRateChuana: strOddsDropRateChuana,
        oddsDropRateDaiana: strOddsDropRateDaiana,
      );
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllLaravelConfigData() async {
    try {
      final LaravelConfigState newState = await fetchAllLaravelConfigData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
