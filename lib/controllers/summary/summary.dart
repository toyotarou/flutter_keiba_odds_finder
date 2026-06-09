import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/summary_model.dart';
import '../../utility/utility.dart';

part 'summary.freezed.dart';

part 'summary.g.dart';

@freezed
class SummaryState with _$SummaryState {
  const factory SummaryState({
    @Default(<SummaryModel>[]) List<SummaryModel> summaryList,
    @Default(<String, List<SummaryModel>>{}) Map<String, List<SummaryModel>> summaryMap,
    @Default(<String, List<String>>{}) Map<String, List<String>> summaryDateBashoMap,
  }) = _SummaryState;
}

@riverpod
class Summary extends _$Summary {
  final Utility utility = Utility();

  ///
  @override
  SummaryState build() => const SummaryState();

  //============================================== api

  ///
  Future<SummaryState> fetchAllSummaryData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<SummaryModel> list = <SummaryModel>[];

      final Map<String, List<SummaryModel>> map = <String, List<SummaryModel>>{};

      final Map<String, Set<String>> map2Set = <String, Set<String>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderSummary).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final SummaryModel val = SummaryModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <SummaryModel>[]).add(val);

          (map2Set[val.date] ??= <String>{}).add('${val.kaisuu}_${val.basho}_${val.day}');
        }
      });

      // ignore: always_specify_types
      final List<String> sortedDates = map2Set.keys.toList()..sort((String a, String b) => b.compareTo(a));
      final Map<String, List<String>> map2 = <String, List<String>>{
        for (final String date in sortedDates) date: map2Set[date]!.toList(),
      };

      return state.copyWith(summaryList: list, summaryMap: map, summaryDateBashoMap: map2);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllSummaryData() async {
    try {
      final SummaryState newState = await fetchAllSummaryData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
