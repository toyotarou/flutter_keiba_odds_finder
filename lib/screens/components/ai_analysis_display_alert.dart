import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../models/common/ai_response_recommend_horse_model.dart';
import '../../models/horse_model.dart';
import '../../models/race_introspection_model.dart';
import '../../models/race_result_payout_model.dart';
import '../../utility/functions.dart';
import '../parts/error_confirm_dialog.dart';
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
    final (:String kaisuu, :String basho, day: _) = parseKbdParts(appParamState.selectedScheduleKaisuuBashoDay);
    if (kaisuu.isEmpty || basho.isEmpty) {
      return;
    }

    try {
      final Map<String, RaceResultPayoutModel> result = await fetchPayoutMap(
        ref,
        racesParam: '$date|$kaisuu|$basho|${widget.raceNumber}',
      );
      if (mounted) {
        setState(() => _payoutMap.addAll(result));
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

    try {
      final Map<int, int?> result = await fetchFinishingPositionMap(ref, horses: horses, date: date);
      if (mounted) {
        setState(() => _finishingPositionMap.addAll(result));
      }
    } catch (_) {}
  }

  ///
  Future<void> _fetchAiAnalysis() async {
    final String date = appParamState.selectedScheduleDate;
    final (:String kaisuu, :String basho, :String day) = parseKbdParts(appParamState.selectedScheduleKaisuuBashoDay);

    try {
      final Map<String, dynamic> data = await fetchAiAnalysisData(
        ref,
        date: date,
        kaisuu: kaisuu,
        basho: basho,
        day: day,
        race: widget.raceNumber,
        gapHorseNums: widget.gapHorseNums,
        upsetPickupHorseNums: widget.upsetPickupHorseNums,
      );
      final String analysisText = (data['analysis_text'] as String?) ?? '';
      if (mounted) {
        setState(() {
          aiRecommendHorses = parseAnalysisText(analysisText);
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

    final (:String kaisuu, :String basho, day: String dayStr) = parseKbdParts(
      appParamState.selectedScheduleKaisuuBashoDay,
    );
    final int kaisuuInt = int.tryParse(kaisuu) ?? 0;
    final int day = int.tryParse(dayStr) ?? 0;
    final String lookupKey = '${appParamState.selectedScheduleDate}_${kaisuuInt}_${basho}_${day}_${widget.raceNumber}';
    final RaceResultPayoutModel? payout = _payoutMap[lookupKey];
    final RaceIntrospectionModel? introspectionModel = findRaceIntrospection(
      raceIntrospectionState.raceIntrospectionMap,
      date: appParamState.selectedScheduleDate,
      kaisuu: kaisuuInt,
      basho: basho,
      day: day,
      race: widget.raceNumber,
    );
    final String? resultText = introspectionModel != null ? extractResultLine(introspectionModel.introspection) : null;

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
                            if (resultText != null && !resultText.contains('0頭が合致')) {
                              OddsFinderDialog(
                                context: context,
                                widget: AiAnalysisPayoutResultAlert(
                                  aiRecommendHorses: aiRecommendHorses,
                                  raceNumber: widget.raceNumber,
                                ),
                                paddingLeft: context.screenSize.width * 0.25,
                              );
                            } else {
                              errorConfirmDialog(context: context, title: '合致なし', content: '1頭も合致しませんでした。');
                            }
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
