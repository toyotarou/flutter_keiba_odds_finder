import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/ai_analysis_model.dart';
import '../../utility/utility.dart';

part 'ai_analysis.freezed.dart';

part 'ai_analysis.g.dart';

@freezed
class AiAnalysisState with _$AiAnalysisState {
  const factory AiAnalysisState({
    @Default(<AiAnalysisModel>[]) List<AiAnalysisModel> aiAnalysisList,
    @Default(<String, List<AiAnalysisModel>>{}) Map<String, List<AiAnalysisModel>> aiAnalysisMap,
  }) = _AiAnalysisState;
}

@riverpod
class AiAnalysis extends _$AiAnalysis {
  final Utility utility = Utility();

  ///
  @override
  AiAnalysisState build() => const AiAnalysisState();

  //============================================== api

  ///
  Future<AiAnalysisState> fetchAllAiAnalysisData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<AiAnalysisModel> list = <AiAnalysisModel>[];
      final Map<String, List<AiAnalysisModel>> map = <String, List<AiAnalysisModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderAiAnalysisRecord).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final AiAnalysisModel val = AiAnalysisModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <AiAnalysisModel>[]).add(val);
        }
      });

      return state.copyWith(aiAnalysisList: list, aiAnalysisMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllAiAnalysisData() async {
    try {
      final AiAnalysisState newState = await fetchAllAiAnalysisData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
