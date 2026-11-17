// =============================================================================
// ファイル名   : summary.dart
// 概要         : オッズ推移のサマリーを API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-09
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/summary_model.dart';
import '../../utility/utility.dart';

part 'summary.freezed.dart';

part 'summary.g.dart';

/// オッズ推移のサマリーの状態。
@freezed
class SummaryState with _$SummaryState {
  const factory SummaryState({
    @Default(<SummaryModel>[]) List<SummaryModel> summaryList,
    @Default(<String, List<SummaryModel>>{}) Map<String, List<SummaryModel>> summaryMap,
    @Default(<String, List<String>>{}) Map<String, List<String>> summaryDateBashoMap,
    @Default(<SummaryModel>[]) List<SummaryModel> oneRaceSummaryList,
  }) = _SummaryState;
}

/// オッズ推移のサマリーを API から取得して保持する Notifier。
@Riverpod(keepAlive: true)
class Summary extends _$Summary {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  SummaryState build() => const SummaryState();

  //============================================== api

  /// API からオッズ推移のサマリーを全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
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

  /// オッズ推移のサマリーを全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllSummaryData() async {
    try {
      final SummaryState newState = await fetchAllSummaryData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api

  /// 指定した1レース分のオッズ推移サマリーを API から取得し、状態に反映する。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
  Future<void> fetchRaceSummary({
    required String date,
    required String kaisuu,
    required String basho,
    required int day,
    required int race,
  }) async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final Map<String, dynamic> queryParameters = <String, dynamic>{
        'date': date,
        'kaisuu': kaisuu,
        'basho': basho,
        'day': day.toString(),
        'race': race.toString(),
      };

      final List<SummaryModel> list = <SummaryModel>[];

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderSummaryOneRace, queryParameters: queryParameters).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final SummaryModel val = SummaryModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);
        }
      });

      state = state.copyWith(oneRaceSummaryList: list);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow;
    }
  }
}
