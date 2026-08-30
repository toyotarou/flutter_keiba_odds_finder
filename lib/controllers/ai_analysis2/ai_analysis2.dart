import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/ai_analysis_model.dart';
import '../../utility/utility.dart';

part 'ai_analysis2.freezed.dart';

part 'ai_analysis2.g.dart';

@freezed
class AiAnalysisState2 with _$AiAnalysisState2 {
  const factory AiAnalysisState2({
    @Default(<AiAnalysisModel>[]) List<AiAnalysisModel> aiAnalysisList2,
    @Default(<String, List<AiAnalysisModel>>{}) Map<String, List<AiAnalysisModel>> aiAnalysisMap2,
  }) = _AiAnalysisState2;
}

@riverpod
class AiAnalysis2 extends _$AiAnalysis2 {
  final Utility utility = Utility();

  ///
  @override
  AiAnalysisState2 build() => const AiAnalysisState2();

  //============================================== api

  ///
  Future<AiAnalysisState2> fetchAllAiAnalysisData2() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<AiAnalysisModel> list = <AiAnalysisModel>[];
      final Map<String, List<AiAnalysisModel>> map = <String, List<AiAnalysisModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderAiAnalysisRecord2).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final AiAnalysisModel val = AiAnalysisModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <AiAnalysisModel>[]).add(val);
        }
      });

      return state.copyWith(aiAnalysisList2: list, aiAnalysisMap2: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllAiAnalysisData2() async {
    try {
      final AiAnalysisState2 newState = await fetchAllAiAnalysisData2();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
