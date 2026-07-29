import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/score_model.dart';
import '../../utility/utility.dart';

part 'jockey_score.freezed.dart';

part 'jockey_score.g.dart';

@freezed
class JockeyScoreState with _$JockeyScoreState {
  const factory JockeyScoreState({
    @Default(<ScoreModel>[]) List<ScoreModel> jockeyScoreList,
    @Default(<String, ScoreModel>{}) Map<String, ScoreModel> jockeyScoreMap,
  }) = _JockeyScoreState;
}

@riverpod
class JockeyScore extends _$JockeyScore {
  final Utility utility = Utility();

  ///
  @override
  JockeyScoreState build() => const JockeyScoreState();

  //============================================== api

  ///
  Future<JockeyScoreState> fetchAllJockeyScoreData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<ScoreModel> list = <ScoreModel>[];
      final Map<String, ScoreModel> map = <String, ScoreModel>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderJockeyScores).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final ScoreModel val = ScoreModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          map[val.name] = val;
        }
      });

      return state.copyWith(jockeyScoreList: list, jockeyScoreMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllJockeyScoreData() async {
    try {
      final JockeyScoreState newState = await fetchAllJockeyScoreData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
