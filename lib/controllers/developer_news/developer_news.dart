// =============================================================================
// ファイル名   : developer_news.dart
// 概要         : 開発者向けお知らせを API から取得して保持する Riverpod の Notifier と、その状態クラス。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-08-25
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/developer_news_model.dart';
import '../../utility/utility.dart';

part 'developer_news.freezed.dart';

part 'developer_news.g.dart';

/// 開発者向けお知らせの状態。
@freezed
class DeveloperNewsState with _$DeveloperNewsState {
  const factory DeveloperNewsState({
    @Default(<DeveloperNewsModel>[]) List<DeveloperNewsModel> developerNewsList,
    @Default(<String, List<DeveloperNewsModel>>{}) Map<String, List<DeveloperNewsModel>> developerNewsKindMap,
    @Default(<String, List<DeveloperNewsModel>>{}) Map<String, List<DeveloperNewsModel>> developerNewsTimeMap,
  }) = _DeveloperNewsState;
}

/// 開発者向けお知らせを API から取得して保持する Notifier。
@riverpod
class DeveloperNews extends _$DeveloperNews {
  final Utility utility = Utility();

  /// 状態の初期値を返す。
  @override
  DeveloperNewsState build() => const DeveloperNewsState();

  //============================================== api

  /// API から開発者向けお知らせを全件取得し、新しい状態を作って返す。
  /// 取得に失敗したときはエラーを表示し、例外を呼び出し元へ投げ直す。
  Future<DeveloperNewsState> fetchAllDeveloperNewsData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<DeveloperNewsModel> list = <DeveloperNewsModel>[];
      final Map<String, List<DeveloperNewsModel>> map = <String, List<DeveloperNewsModel>>{};
      final Map<String, List<DeveloperNewsModel>> map2 = <String, List<DeveloperNewsModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderPushSendLogsDeveloperNews).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final DeveloperNewsModel val = DeveloperNewsModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          map[val.kind] = (map[val.kind] ?? <DeveloperNewsModel>[])..add(val);

          map2[val.time] = (map2[val.time] ?? <DeveloperNewsModel>[])..add(val);
        }
      });

      return state.copyWith(developerNewsList: list, developerNewsKindMap: map, developerNewsTimeMap: map2);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  /// 開発者向けお知らせを全件取得して状態に反映する。失敗したときは状態を変えない。
  Future<void> getAllDeveloperNewsData() async {
    try {
      final DeveloperNewsState newState = await fetchAllDeveloperNewsData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
