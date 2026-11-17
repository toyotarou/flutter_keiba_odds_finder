// =============================================================================
// ファイル名   : schedule.dart
// 概要         : 開催スケジュールを API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-30
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/schedule_model.dart';
import '../../utility/utility.dart';

part 'schedule.freezed.dart';

part 'schedule.g.dart';

/// 開催スケジュールの状態。
@freezed
class ScheduleState with _$ScheduleState {
  const factory ScheduleState({
    @Default(<ScheduleModel>[]) List<ScheduleModel> scheduleList,
    @Default(<String, ScheduleModel>{}) Map<String, ScheduleModel> scheduleMap,
    @Default(<String, List<ScheduleModel>>{}) Map<String, List<ScheduleModel>> scheduleDateBashoMap,
  }) = _ScheduleState;
}

/// 開催スケジュールを API から取得して保持する Notifier。
@riverpod
class Schedule extends _$Schedule {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  ScheduleState build() => const ScheduleState();

  //============================================== api

  /// API から開催スケジュールを全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
  Future<ScheduleState> fetchAllScheduleData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<ScheduleModel> list = <ScheduleModel>[];
      final Map<String, ScheduleModel> map = <String, ScheduleModel>{};
      final Map<String, List<ScheduleModel>> map2 = <String, List<ScheduleModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderSchedules).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final ScheduleModel val = ScheduleModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] = val;

          (map2[val.date] ??= <ScheduleModel>[]).add(val);
        }
      });

      return state.copyWith(scheduleList: list, scheduleMap: map, scheduleDateBashoMap: map2);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  /// 開催スケジュールを全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllScheduleData() async {
    try {
      final ScheduleState newState = await fetchAllScheduleData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
