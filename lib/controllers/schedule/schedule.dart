import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/schedule_model.dart';
import '../../utility/utility.dart';

part 'schedule.freezed.dart';

part 'schedule.g.dart';

@freezed
class ScheduleState with _$ScheduleState {
  const factory ScheduleState({
    @Default(<ScheduleModel>[]) List<ScheduleModel> scheduleList,
    @Default(<String, ScheduleModel>{}) Map<String, ScheduleModel> scheduleMap,
    @Default(<String, List<ScheduleModel>>{}) Map<String, List<ScheduleModel>> scheduleDateBashoMap,
  }) = _ScheduleState;
}

@riverpod
class Schedule extends _$Schedule {
  final Utility utility = Utility();

  ///
  @override
  ScheduleState build() => const ScheduleState();

  //============================================== api

  ///
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

  ///
  Future<void> getAllScheduleData() async {
    try {
      final ScheduleState newState = await fetchAllScheduleData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
