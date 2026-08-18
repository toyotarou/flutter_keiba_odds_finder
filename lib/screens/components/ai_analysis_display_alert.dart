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

  List<AiResponseRecommendHorseModel> _aiRecommendHorses = <AiResponseRecommendHorseModel>[];

  String? _errorMessage;

  final Map<String, RaceResultPayoutModel> _payoutMap = <String, RaceResultPayoutModel>{};

  bool _isLoadingSecondAi = false;

  List<AiResponseRecommendHorseModel> _secondAiHorses = <AiResponseRecommendHorseModel>[];

  ///
  List<AiResponseRecommendHorseModel> get _supplementHorses {
    final Set<int> claudeNums = _aiRecommendHorses.map((AiResponseRecommendHorseModel h) => h.num).toSet();
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
      if (mounted) {
        setState(() {
          _secondAiHorses = parseAnalysisText(analysisText);
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
          _aiRecommendHorses = parseAnalysisText(analysisText);
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

    final List<AiResponseRecommendHorseModel> supplements = _supplementHorses;

    final int supplementCoveredCount = calcSupplementCoveredCount(supplementHorses: supplements, payout: payout) ?? 0;

    final bool showResultButton = payout != null && resultText != null && !resultText.contains('0頭が合致');

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
                        if (resultText != null)
                          Text(
                            resultText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.yellowAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (supplementCoveredCount > 0)
                          Text(
                            '補欠で$supplementCoveredCount頭をカバー',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        if (_errorMessage == null && _aiRecommendHorses.isNotEmpty) _buildSecondAiButton(),
                        if (showResultButton) ...<Widget>[
                          const SizedBox(width: 10),
                          _buildResultButton(
                            matchCount: matchCount,
                            supplementCoveredCount: supplementCoveredCount,
                            supplements: supplements,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
                Expanded(child: _buildHorseList(supplements)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _buildSecondAiButton() {
    return Material(
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
                  style: TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  ///
  Widget _buildResultButton({
    required String matchCount,
    required int supplementCoveredCount,
    required List<AiResponseRecommendHorseModel> supplements,
  }) {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          bottom: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()..setEntry(0, 1, -0.8),
                child: Text(
                  matchCount,
                  style: const TextStyle(fontSize: 20, color: Color(0xFFFBB6CE), fontWeight: FontWeight.bold),
                ),
              ),
              if (supplementCoveredCount > 0)
                Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()..setEntry(0, 1, -0.8),
                  child: Text(
                    '+$supplementCoveredCount',
                    style: const TextStyle(fontSize: 14, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
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
                      aiRecommendHorses: _aiRecommendHorses,
                      raceNumber: widget.raceNumber,
                      supplementHorses: supplements,
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
                    style: TextStyle(fontSize: 10, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }

  ///
  Widget _buildHorseCard(AiResponseRecommendHorseModel h, {bool isSupplementary = false}) {
    final AiResponseRecommendHorseModel? secondAiHorse = isSupplementary
        ? null
        : _secondAiHorses.where((AiResponseRecommendHorseModel s) => s.num == h.num).firstOrNull;

    final int? rank = widget.numToRankMap[h.num];

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
                Text(
                  h.reason.replaceAll(RegExp(r'\n?[─]+\n?'), '').trim(),
                  style: const TextStyle(letterSpacing: 0.4, height: 1.7),
                ),
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
                        Text(
                          secondAiHorse.reason.replaceAll(RegExp(r'\n?[─]+\n?'), '').trim(),
                          style: const TextStyle(letterSpacing: 0.4, height: 1.7),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        if (rank != null && rank <= 3)
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: raceRankColor(rank, fallback: Colors.grey.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('$rank位', style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
          ),
        if (isSupplementary)
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
    );
  }

  ///
  Widget _buildHorseList(List<AiResponseRecommendHorseModel> supplements) {
    return ListView(
      children: <Widget>[
        ..._aiRecommendHorses.map((AiResponseRecommendHorseModel h) => _buildHorseCard(h)),
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
