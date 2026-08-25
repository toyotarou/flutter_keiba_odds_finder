import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/developer_news_model.dart';
import '../../utility/utility.dart';

part 'developer_news.freezed.dart';

part 'developer_news.g.dart';

@freezed
class DeveloperNewsState with _$DeveloperNewsState {
  const factory DeveloperNewsState({
    @Default(<DeveloperNewsModel>[]) List<DeveloperNewsModel> developerNewsList,
    @Default(<String, List<DeveloperNewsModel>>{}) Map<String, List<DeveloperNewsModel>> developerNewsKindMap,
    @Default(<String, List<DeveloperNewsModel>>{}) Map<String, List<DeveloperNewsModel>> developerNewsTimeMap,
  }) = _DeveloperNewsState;
}

@riverpod
class DeveloperNews extends _$DeveloperNews {
  final Utility utility = Utility();

  ///
  @override
  DeveloperNewsState build() => const DeveloperNewsState();

  //============================================== api

  ///
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

  ///
  Future<void> getAllDeveloperNewsData() async {
    try {
      final DeveloperNewsState newState = await fetchAllDeveloperNewsData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
