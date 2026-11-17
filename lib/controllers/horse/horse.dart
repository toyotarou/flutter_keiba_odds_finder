// =============================================================================
// ファイル名   : horse.dart
// 概要         : 出走馬を API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-30
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/horse_detail_model.dart';
import '../../models/horse_model.dart';
import '../../utility/utility.dart';

part 'horse.freezed.dart';

part 'horse.g.dart';

/// 出走馬の状態。
@freezed
class HorseState with _$HorseState {
  const factory HorseState({
    @Default(<HorseModel>[]) List<HorseModel> horseList,

    @Default(<String, List<HorseModel>>{}) Map<String, List<HorseModel>> horseMap,

    HorseDetailModel? horseDetail,
  }) = _HorseState;
}

/// 出走馬を API から取得して保持する Notifier。
@riverpod
class Horse extends _$Horse {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  HorseState build() => const HorseState();

  //============================================== api

  /// API から出走馬を全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
  Future<HorseState> fetchAllHorseData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<HorseModel> list = <HorseModel>[];
      final Map<String, List<HorseModel>> map = <String, List<HorseModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderHorses).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final HorseModel val = HorseModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <HorseModel>[]).add(val);
        }
      });

      return state.copyWith(horseList: list, horseMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  /// 出走馬を全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllHorseData() async {
    try {
      final HorseState newState = await fetchAllHorseData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api

  /// 指定した馬の詳細情報を API から取得し、状態に反映する。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
  Future<void> fetchHorseDetail({required String horseId}) async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseDetail, queryParameters: {'cname': horseId}).then((value) {
        // ignore: avoid_dynamic_calls
        final HorseDetailModel detail = HorseDetailModel.fromJson(value['data'] as Map<String, dynamic>);
        state = state.copyWith(horseDetail: detail);
      });
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow;
    }
  }
}
