import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/common/ai_response_recommend_horse_model.dart';
import '../../models/horse_model.dart';
import '../../models/race_introspection_model.dart';
import '../../models/race_result_history_model.dart';
import '../../models/race_result_payout_model.dart';
import '../../utility/functions.dart';
import '../parts/odds_finder_dialog.dart';
import 'ai_analysis_payout_result_alert.dart';

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
  List<AiResponseRecommendHorseModel> aiRecommendHorses = <AiResponseRecommendHorseModel>[];
  String? _errorMessage;
  final Map<String, RaceResultPayoutModel> _payoutMap = <String, RaceResultPayoutModel>{};
  final Map<int, int?> _finishingPositionMap = <int, int?>{};

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAiAnalysis();
      _fetchPayout();
      _fetchBattleRecords();
    });
  }

  ///
  Future<void> _fetchPayout() async {
    final String date = appParamState.selectedScheduleDate;
    final List<String> kbdParts = appParamState.selectedScheduleKaisuuBashoDay.split('_');
    if (kbdParts.length < 3) {
      return;
    }
    final String kaisuu = kbdParts[0];
    final String basho = kbdParts[1];

    try {
      final dynamic response = await ref
          .read(httpClientProvider)
          .get(
            path: APIPath.getHorseOddsFinderRaceResultPayout,
            queryParameters: <String, dynamic>{'races': '$date|$kaisuu|$basho|${widget.raceNumber}'},
          );
      final List<dynamic> dataList = (response as Map<String, dynamic>)['data'] as List<dynamic>? ?? <dynamic>[];
      if (mounted) {
        setState(() {
          for (final dynamic item in dataList) {
            final RaceResultPayoutModel m = RaceResultPayoutModel.fromJson(item as Map<String, dynamic>);
            _payoutMap['${m.date}_${m.kaisuu}_${m.bashoCode}_${m.day}_${m.race}'] = m;
          }
        });
      }
    } catch (_) {}
  }

  ///
  Future<void> _fetchBattleRecords() async {
    final String date = appParamState.selectedScheduleDate;
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';
    final List<HorseModel> horses = (appParamState.keepHorseMap[mapKey] ?? <HorseModel>[])
        .where((HorseModel e) => e.race == widget.raceNumber)
        .toList();

    if (horses.isEmpty) {
      return;
    }

    final List<String> horseNames = horses.map((HorseModel e) => e.name).where((String n) => n.isNotEmpty).toList();
    if (horseNames.isEmpty) {
      return;
    }

    try {
      final dynamic response = await ref
          .read(httpClientProvider)
          .get(
            path: APIPath.getHorseOddsFinderHorseBattleRecord,
            queryParameters: <String, dynamic>{'name': horseNames.join('/')},
          );
      final List<dynamic> dataList = (response as Map<String, dynamic>)['data'] as List<dynamic>? ?? <dynamic>[];

      final Map<String, List<RaceResultHistoryModel>> byName = <String, List<RaceResultHistoryModel>>{};
      for (final dynamic item in dataList) {
        final RaceResultHistoryModel m = RaceResultHistoryModel.fromJson(item as Map<String, dynamic>);
        byName.putIfAbsent(m.name, () => <RaceResultHistoryModel>[]).add(m);
      }

      if (mounted) {
        setState(() {
          for (final HorseModel horse in horses) {
            final List<RaceResultHistoryModel> records = byName[horse.name] ?? <RaceResultHistoryModel>[];
            final RaceResultHistoryModel? record = records
                .where((RaceResultHistoryModel r) => r.date == date)
                .firstOrNull;
            if (record != null) {
              final int pos = record.finishingPosition;
              _finishingPositionMap[horse.num] = pos >= 1 ? pos : null;
            }
          }
        });
      }
    } catch (_) {}
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
          aiRecommendHorses = _parseAnalysisText(analysisText);
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
  static String? _extractResultLine(String introspection) {
    final List<String> lines = introspection.split('\n');
    bool inResult = false;
    for (final String line in lines) {
      final String trimmed = line.trim();
      if (trimmed == '## 結果') {
        inResult = true;
        continue;
      }
      if (inResult) {
        if (trimmed.startsWith('## ')) {
          break;
        }
        if (trimmed.isNotEmpty) {
          return trimmed;
        }
      }
    }
    return null;
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

    final List<String> kbdParts = appParamState.selectedScheduleKaisuuBashoDay.split('_');
    final int kaisuu = int.tryParse(kbdParts.isNotEmpty ? kbdParts[0] : '') ?? 0;
    final String basho = kbdParts.length > 1 ? kbdParts[1] : '';
    final int day = int.tryParse(kbdParts.length > 2 ? kbdParts[2] : '') ?? 0;
    final String lookupKey = '${appParamState.selectedScheduleDate}_${kaisuu}_${basho}_${day}_${widget.raceNumber}';
    final RaceResultPayoutModel? payout = _payoutMap[lookupKey];
    final RaceIntrospectionModel? introspectionModel = raceIntrospectionState.raceIntrospectionMap.values
        .where(
          (RaceIntrospectionModel e) =>
              e.date == appParamState.selectedScheduleDate &&
              e.kaisuu == kaisuu &&
              e.day == day &&
              e.race == widget.raceNumber,
        )
        .firstOrNull;
    final String? resultText = introspectionModel != null ? _extractResultLine(introspectionModel.introspection) : null;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('馬眼力ピックアップ', style: TextStyle(fontSize: 12)),

                        if (resultText != null) ...<Widget>[
                          Text(resultText, style: const TextStyle(fontSize: 11, color: Colors.yellowAccent)),
                        ],
                      ],
                    ),

                    if (payout != null) ...<Widget>[
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            OddsFinderDialog(
                              context: context,
                              widget: AiAnalysisPayoutResultAlert(
                                aiRecommendHorses: aiRecommendHorses,
                                raceNumber: widget.raceNumber,
                              ),
                              paddingLeft: context.screenSize.width * 0.25,
                            );
                          },

                          borderRadius: BorderRadius.circular(10),
                          splashColor: const Color(0xFFFFD700).withValues(alpha: 0.35),
                          highlightColor: const Color(0xFFFFD700).withValues(alpha: 0.1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFFFD700)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '合致結果',
                              style: TextStyle(fontSize: 10, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ] else ...<Widget>[const SizedBox.shrink()],
                  ],
                ),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                Expanded(child: displayRecommendHorseData()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget displayRecommendHorseData() {
    return ListView(
      children: aiRecommendHorses.map((AiResponseRecommendHorseModel h) {
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

            if (_finishingPositionMap[h.num] != null && _finishingPositionMap[h.num]! <= 3)
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  width: 32,

                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: raceRankColor(_finishingPositionMap[h.num], fallback: Colors.grey.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _finishingPositionMap[h.num].toString(),
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
