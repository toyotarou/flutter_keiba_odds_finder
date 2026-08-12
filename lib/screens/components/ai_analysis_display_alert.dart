import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/common/ai_response_recommend_horse_model.dart';

class AiAnalysisDisplayAlert extends ConsumerStatefulWidget {
  const AiAnalysisDisplayAlert({
    super.key,
    required this.raceNumber,
    required this.gapHorseNums,
    required this.upsetPickupHorseNums,
  });

  final int raceNumber;
  final List<int> gapHorseNums;
  final List<int> upsetPickupHorseNums;

  @override
  ConsumerState<AiAnalysisDisplayAlert> createState() => _AiAnalysisDisplayAlertState();
}

class _AiAnalysisDisplayAlertState extends ConsumerState<AiAnalysisDisplayAlert>
    with ControllersMixin<AiAnalysisDisplayAlert> {
  bool _isLoading = true;
  List<AiResponseRecommendHorseModel> _aiRecommendHorses = <AiResponseRecommendHorseModel>[];
  String? _errorMessage;

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAiAnalysis());
  }

  ///
  Future<void> _fetchAiAnalysis() async {
    final String date = appParamState.selectedScheduleDate;

    final List<String> kbdParts = appParamState.selectedScheduleKaisuuBashoDay.split('_');
    final String kaisuu = kbdParts.isNotEmpty ? kbdParts[0] : '';
    final String basho = kbdParts.length > 1 ? kbdParts[1] : '';
    final String day = kbdParts.length > 2 ? kbdParts[2] : '';

    try {
      final dynamic response = await ref
          .read(httpClientProvider)
          .get(
            path: APIPath.getHorseOddsFinderAiAnalysis,
            queryParameters: <String, dynamic>{
              'date': date,
              'kaisuu': kaisuu,
              'basho': basho,
              'day': day,
              'race': widget.raceNumber.toString(),
              'gapHorseNums': widget.gapHorseNums.join('|'),
              'upsetPickupHorseNums': widget.upsetPickupHorseNums.join('|'),
            },
          );

      final Map<String, dynamic> data =
          (response as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final String analysisText = (data['analysis_text'] as String?) ?? '';

      if (mounted) {
        setState(() {
          _aiRecommendHorses = _parseAnalysisText(analysisText);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'データの取得に失敗しました';
          _isLoading = false;
        });
      }
    }
  }

  ///
  static List<AiResponseRecommendHorseModel> _parseAnalysisText(String text) {
    return text.split('\n\n').where((String block) => block.contains('馬番：')).map((String block) {
      final String trimmed = block.trim();
      final int reasonIdx = trimmed.indexOf('選出理由：');
      final String reason = reasonIdx != -1 ? trimmed.substring(reasonIdx + '選出理由：'.length).trim() : '';
      final String meta = reasonIdx != -1 ? trimmed.substring(0, reasonIdx) : trimmed;

      String extract(String key) {
        final int idx = meta.indexOf(key);
        if (idx == -1) {
          return '';
        }
        final int start = idx + key.length;
        final int end = meta.indexOf('、', start);
        return (end == -1 ? meta.substring(start) : meta.substring(start, end)).trim();
      }

      return AiResponseRecommendHorseModel(
        num: int.tryParse(extract('馬番：')) ?? 0,
        name: extract('馬名：'),
        popularity: extract('人気順: '),
        odds: extract('6分前オッズ: '),
        score: int.tryParse(extract('おすすめ度: ')) ?? 0,
        reason: reason,
      );
    }).toList();
  }

  ///
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator(color: Colors.yellowAccent)),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('馬眼力ピックアップ', style: TextStyle(fontSize: 12)),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                Expanded(child: displayRecommendHorseData()),

                if (_aiRecommendHorses.length >= 3) ...<Widget>[const SizedBox(height: 10), _buildCombinations()],
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _buildCombinations() {
    final List<String> combos = <String>[];
    for (int i = 0; i < _aiRecommendHorses.length; i++) {
      for (int j = 0; j < _aiRecommendHorses.length; j++) {
        if (j == i) {
          continue;
        }
        for (int k = 0; k < _aiRecommendHorses.length; k++) {
          if (k == i || k == j) {
            continue;
          }
          combos.add('${_aiRecommendHorses[i].num}-${_aiRecommendHorses[j].num}-${_aiRecommendHorses[k].num}');
        }
      }
    }

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          children: combos.map((String combo) {
            return Container(
              width: context.screenSize.width / 6,
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(combo, style: const TextStyle(fontSize: 12, color: Colors.white)),
            );
          }).toList(),
        ),
      ),
    );
  }

  ///
  Widget displayRecommendHorseData() {
    return ListView(
      children: _aiRecommendHorses.map((AiResponseRecommendHorseModel h) {
        return Stack(
          children: <Widget>[
            Positioned(right: 10, bottom: 10, child: Text(h.score.toString(), style: const TextStyle(fontSize: 40))),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(5),

              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(fontSize: 12, color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.5))),
                          ),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              const SizedBox(width: 10),

                              Container(width: 20, alignment: Alignment.topLeft, child: Text(h.popularity)),
                              const Text('番人気'),

                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.5))),
                          ),

                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              const SizedBox(width: 10),
                              const Text('6分前オッズ'),
                              Container(width: 40, alignment: Alignment.topRight, child: Text(h.odds)),

                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Container(
                          width: 40,

                          padding: const EdgeInsets.all(2),

                          decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.5))),

                          alignment: Alignment.center,
                          child: Text(h.num.toString()),
                        ),
                        const SizedBox(width: 10),
                        Text(h.name),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(h.reason, style: const TextStyle(letterSpacing: 0.4, height: 1.7)),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
