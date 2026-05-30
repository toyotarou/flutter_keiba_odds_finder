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
  const factory LaravelConfigState({@Default('') String odds_get_timing}) = _LaravelConfigState;
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

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderConfigs).then((value) {
        // ignore: avoid_dynamic_calls
        strOddsGetTiming = value['data']['odds_get_timing'] as String;
      });

      return state.copyWith(odds_get_timing: strOddsGetTiming);
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
