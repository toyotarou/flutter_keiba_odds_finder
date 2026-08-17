import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../models/common/ai_response_recommend_horse_model.dart';
import '../../models/race_introspection_model.dart';
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
    required this.numToRankMap,
  });

  final int raceNumber;
  final List<int> gapHorseNums;
  final List<int> upsetPickupHorseNums;
  final Map<int, int> numToRankMap;

  @override
  ConsumerState<AiAnalysisDisplayAlert> createState() => _AiAnalysisDisplayAlertState();
}

class _AiAnalysisDisplayAlertState extends ConsumerState<AiAnalysisDisplayAlert>
    with ControllersMixin<AiAnalysisDisplayAlert> {
  bool _isLoading = true;
  List<AiResponseRecommendHorseModel> aiRecommendHorses = <AiResponseRecommendHorseModel>[];
  String? _errorMessage;
  final Map<String, RaceResultPayoutModel> _payoutMap = <String, RaceResultPayoutModel>{};

  // DeepSeek（第2AI）結果
  bool _isLoadingSecondAi = false;
  List<AiResponseRecommendHorseModel> _secondAiHorses = <AiResponseRecommendHorseModel>[];

  // DeepSeekのみが選んだ馬（Claudeの選出にない馬＝補欠）
  List<AiResponseRecommendHorseModel> get _supplementHorses {
    final Set<int> claudeNums = aiRecommendHorses.map((AiResponseRecommendHorseModel h) => h.num).toSet();
    return _secondAiHorses.where((AiResponseRecommendHorseModel h) => !claudeNums.contains(h.num)).toList();
  }

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAiAnalysis();
      _fetchPayout();
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
  Future<void> _fetchSecondAiOpinion() async {
    if (_isLoadingSecondAi) {
      return;
    }
    setState(() => _isLoadingSecondAi = true);

    final String date = appParamState.selectedScheduleDate;
    final (:String kaisuu, :String basho, :String day) = parseKbdParts(appParamState.selectedScheduleKaisuuBashoDay);

    try {
      final Map<String, dynamic> data = await fetchSecondAiOpinionData(
        ref,
        date: date,
        kaisuu: kaisuu,
        basho: basho,
        day: day,
        race: widget.raceNumber,
      );
      final String analysisText = (data['analysis_text'] as String?) ?? '';
      final List<AiResponseRecommendHorseModel> secondHorses = parseAnalysisText(analysisText);

      if (mounted) {
        setState(() {
          _secondAiHorses = secondHorses;
          _isLoadingSecondAi = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingSecondAi = false);
      }
    }
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

    final String matchCount = resultText != null ? (RegExp(r'(\d+)頭が合致').firstMatch(resultText)?.group(1) ?? '') : '';

    final int supplementCoveredCount =
        calcSupplementCoveredCount(supplementHorses: _supplementHorses, payout: payout) ?? 0;

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
                          Text(
                            resultText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.yellowAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],

                        if (supplementCoveredCount > 0) ...<Widget>[
                          Text(
                            '補欠で$supplementCoveredCount頭をカバー',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),

                    Row(
                      children: <Widget>[
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: _isLoadingSecondAi ? null : _fetchSecondAiOpinion,

                            borderRadius: BorderRadius.circular(10),
                            splashColor: Colors.greenAccent.withValues(alpha: 0.35),
                            highlightColor: Colors.greenAccent.withValues(alpha: 0.1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.greenAccent),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _isLoadingSecondAi
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 1.5),
                                    )
                                  : const Text(
                                      '2nd AI',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        if (payout != null && resultText != null && !resultText.contains('0頭が合致')) ...<Widget>[
                          const SizedBox(width: 10),

                          Stack(
                            children: <Widget>[
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Transform(
                                        alignment: Alignment.centerLeft,
                                        transform: Matrix4.identity()..setEntry(0, 1, -0.8),
                                        child: Text(
                                          matchCount,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFFFBB6CE),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (supplementCoveredCount > 0) ...<Widget>[
                                        Transform(
                                          alignment: Alignment.centerLeft,
                                          transform: Matrix4.identity()..setEntry(0, 1, -0.8),
                                          child: Text(
                                            '+$supplementCoveredCount',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              Column(
                                children: <Widget>[
                                  const SizedBox(height: 10),

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
                                            supplementHorses: _supplementHorses,
                                            supplementCoveredCount: supplementCoveredCount,
                                          ),
                                          paddingLeft: context.screenSize.width * 0.2,
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
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFFFFD700),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                ],
                              ),
                            ],
                          ),
                        ] else ...<Widget>[const SizedBox.shrink()],
                      ],
                    ),
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
  Widget _buildHorseCard(AiResponseRecommendHorseModel h, {bool isSupplementary = false}) {
    // consensus 時に表示する DeepSeek の理由文（補欠カードは不要）
    final AiResponseRecommendHorseModel? secondAiHorse = !isSupplementary
        ? _secondAiHorses.where((AiResponseRecommendHorseModel s) => s.num == h.num).firstOrNull
        : null;

    return Stack(
      children: <Widget>[
        Positioned(
          right: 15,
          bottom: 10,
          child: Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()..setEntry(0, 1, -0.8),
            child: Text(h.score.toString(), style: const TextStyle(fontSize: 40)),
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(5),

          decoration: BoxDecoration(
            color: isSupplementary ? Colors.greenAccent.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.4),
            border: Border.all(
              color: isSupplementary ? Colors.greenAccent.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 12, color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const SizedBox.shrink(),

                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.orangeAccent.withValues(alpha: 0.5))),
                          ),

                          child: DefaultTextStyle(
                            style: const TextStyle(color: Colors.orangeAccent, fontSize: 10),
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
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.5))),
                          ),

                          child: DefaultTextStyle(
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 10),
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
                        ),

                        const SizedBox.shrink(),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                DefaultTextStyle(
                  style: const TextStyle(color: Color(0xFFFBB6CE), fontSize: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Container(
                        width: 40,

                        padding: const EdgeInsets.all(2),

                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFBB6CE).withValues(alpha: 0.5)),
                        ),

                        alignment: Alignment.center,
                        child: Text(h.num.toString()),
                      ),
                      const SizedBox(width: 10),
                      Text(h.name),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                Text(h.reason, style: const TextStyle(letterSpacing: 0.4, height: 1.7)),

                if (secondAiHorse != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('2nd AI', style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
                        const SizedBox(height: 4),
                        Text(secondAiHorse.reason, style: const TextStyle(letterSpacing: 0.4, height: 1.7)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        if (widget.numToRankMap[h.num] != null && widget.numToRankMap[h.num]! <= 3) ...<Widget>[
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              width: 32,

              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: raceRankColor(widget.numToRankMap[h.num], fallback: Colors.grey.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('${widget.numToRankMap[h.num]}位', style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
          ),
        ],

        // 補欠カードには「補欠」ラベルを表示
        if (isSupplementary) ...<Widget>[
          Positioned(
            top: 30,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.15),
                border: Border.all(color: Colors.greenAccent),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '補欠',
                style: TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }

  ///
  Widget displayRecommendHorseData() {
    final List<AiResponseRecommendHorseModel> supplements = _supplementHorses;

    return ListView(
      children: <Widget>[
        // Claude の選出馬
        ...aiRecommendHorses.map((AiResponseRecommendHorseModel h) => _buildHorseCard(h)),

        // DeepSeek のみが返した補欠馬
        if (supplements.isNotEmpty) ...<Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(child: Divider(color: Colors.greenAccent.withValues(alpha: 0.4))),
                const SizedBox(width: 8),
                const Text('2nd AI 補欠', style: TextStyle(fontSize: 11, color: Colors.greenAccent)),
                const SizedBox(width: 8),
                Expanded(child: Divider(color: Colors.greenAccent.withValues(alpha: 0.4))),
              ],
            ),
          ),
          ...supplements.map((AiResponseRecommendHorseModel h) => _buildHorseCard(h, isSupplementary: true)),
        ],
      ],
    );
  }
}
