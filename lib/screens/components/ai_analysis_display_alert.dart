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
    this.overrideDate,
    this.overrideKaisuuBashoDay,
    super.key,
    required this.raceNumber,
    required this.numToRankMap,
    required this.aiHorseList,
    required this.secondAiHorseList,
    this.mergedHorseList,
    this.upsetRaceValue,
    this.raceMetrics,
  });

  final int raceNumber;
  final Map<int, int> numToRankMap;
  final String? overrideDate;
  final String? overrideKaisuuBashoDay;
  final List<AiResponseRecommendHorseModel> aiHorseList;
  final List<AiResponseRecommendHorseModel> secondAiHorseList;
  final List<AiResponseRecommendHorseModel>? mergedHorseList;
  final int? upsetRaceValue;
  final Map<String, int>? raceMetrics;

  @override
  ConsumerState<AiAnalysisDisplayAlert> createState() => _AiAnalysisDisplayAlertState();
}

class _AiAnalysisDisplayAlertState extends ConsumerState<AiAnalysisDisplayAlert>
    with ControllersMixin<AiAnalysisDisplayAlert> {
  final Map<String, RaceResultPayoutModel> _payoutMap = <String, RaceResultPayoutModel>{};
  Map<int, double?> _baganrikiIndexMap = <int, double?>{};

  /// 過去レースから呼ばれた場合は override 値を、そうでなければ appParamState の値を使う
  String get _effectiveDate => widget.overrideDate ?? appParamState.selectedScheduleDate;

  String get _effectiveKbd => widget.overrideKaisuuBashoDay ?? appParamState.selectedScheduleKaisuuBashoDay;

  List<AiResponseRecommendHorseModel> get _mergedHorses => widget.mergedHorseList ?? <AiResponseRecommendHorseModel>[];

  /// 補欠馬リスト（表示用）: 1st AI の選出馬との差分
  List<AiResponseRecommendHorseModel> get _supplementHorses {
    if (_mergedHorses.isNotEmpty) {
      return _mergedHorses.where((AiResponseRecommendHorseModel h) => h.category == 'second_only').toList();
    }
    final Set<int> claudeNums = widget.aiHorseList.map((AiResponseRecommendHorseModel h) => h.num).toSet();
    return widget.secondAiHorseList.where((AiResponseRecommendHorseModel h) => !claudeNums.contains(h.num)).toList();
  }

  /// 補欠カバー数（集計用）: ai_analysis（1st AI 4頭）を基準にして計算
  /// 7番など ai_analysis にいない 2nd AI 馬が入賞した頭数を返す
  int _calcSupplementCoveredCount({required String? introspectionText, required RaceResultPayoutModel? payout}) {
    final Set<int> aiNums = widget.aiHorseList.map((AiResponseRecommendHorseModel h) => h.num).toSet();
    final List<AiResponseRecommendHorseModel> supplementHorses = widget.secondAiHorseList
        .where((AiResponseRecommendHorseModel h) => !aiNums.contains(h.num))
        .toList();
    return calcSupplementCoveredCount(supplementHorses: supplementHorses, payout: payout) ?? 0;
  }

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPayout();
      _fetchBaganrikiIndex();
    });
  }

  ///
  Future<void> _fetchPayout() async {
    final String date = _effectiveDate;
    final (:String kaisuu, :String basho, day: _) = parseKbdParts(_effectiveKbd);
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
  Future<void> _fetchBaganrikiIndex() async {
    final String date = _effectiveDate;
    final (:String kaisuu, :String basho, :String day) = parseKbdParts(_effectiveKbd);
    try {
      final Map<int, double?> result = await fetchBaganrikiIndexData(
        ref,
        date: date,
        kaisuu: kaisuu,
        basho: basho,
        day: day,
        race: widget.raceNumber,
      );
      if (mounted) {
        setState(() {
          _baganrikiIndexMap = result;
        });
      }
    } catch (_) {}
  }

  ///
  @override
  Widget build(BuildContext context) {
    final (:String kaisuu, :String basho, day: String dayStr) = parseKbdParts(_effectiveKbd);

    final int kaisuuInt = int.tryParse(kaisuu) ?? 0;

    final int day = int.tryParse(dayStr) ?? 0;

    final String lookupKey = '${_effectiveDate}_${kaisuuInt}_${basho}_${day}_${widget.raceNumber}';

    final RaceResultPayoutModel? payout = _payoutMap[lookupKey];

    final RaceIntrospectionModel? introspectionModel = findRaceIntrospection(
      raceIntrospectionState.raceIntrospectionMap,
      date: _effectiveDate,
      kaisuu: kaisuuInt,
      basho: basho,
      day: day,
      race: widget.raceNumber,
    );

    final String? resultText = introspectionModel != null ? extractResultLine(introspectionModel.introspection) : null;

    // 表示用: 開いた時は 1st AI（ai_analysis 4頭）のみ。2nd AI ボタンタップ後に補欠を追加表示
    final List<AiResponseRecommendHorseModel> supplements = _supplementHorses;

    // 補欠カバー数: ai_analysis（4頭）基準 — 7番など 2nd AI 補欠が入賞した頭数
    // ※ 2nd AI 未取得時は widget.secondAiHorseList が空なので 0 になる（正常）
    final int supplementCoveredCount = _calcSupplementCoveredCount(
      introspectionText: introspectionModel?.introspection,
      payout: payout,
    );

    // 1st AI（ai_analysis 4頭）が 3着以内に入った頭数を numToRankMap から直接計算
    // → 2nd AI のロード状態に関係なく常に正しい値を返す
    final int firstAiMatchCount = widget.aiHorseList
        .where((AiResponseRecommendHorseModel h) => (widget.numToRankMap[h.num] ?? 99) <= 3)
        .length;

    // DB の resultText はピックアップ（6頭）ベースで生成されているため、
    // 1st AI の実際の合致数（firstAiMatchCount）で数字部分を上書きして表示する
    // 例: "6頭中2頭が合致" → "6頭中1頭が合致"
    String? adjustedResultText = resultText;
    if (resultText != null && firstAiMatchCount > 0) {
      final RegExpMatch? m = RegExp(r'(\d+)頭が合致').firstMatch(resultText);
      if (m != null) {
        final int origCount = int.tryParse(m.group(1) ?? '') ?? 0;
        if (origCount != firstAiMatchCount) {
          adjustedResultText = resultText.replaceFirst(RegExp(r'\d+頭が合致'), '$firstAiMatchCount頭が合致');
        }
      }
    }

    // 結果ボタンの主数字: 1st AI の合致数（numToRankMap ベース）
    final String matchCount = firstAiMatchCount > 0 ? firstAiMatchCount.toString() : '';

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
                        if (adjustedResultText != null)
                          Text(
                            adjustedResultText,
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
                    if (showResultButton)
                      _buildResultButton(
                        matchCount: matchCount,
                        supplementCoveredCount: supplementCoveredCount,
                        supplements: supplements,
                      ),
                  ],
                ),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
                if (widget.upsetRaceValue != null) ...<Widget>[
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (widget.upsetRaceValue == 0) ...<Widget>[
                          Container(width: 20, height: 1, color: Colors.white),
                        ],
                        Text(
                          '厳選穴レース',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.upsetRaceValue == 1
                                ? const Color(0xFFFBB6CE)
                                : Colors.white.withValues(alpha: 0.4),
                            decoration: widget.upsetRaceValue == 0 ? TextDecoration.lineThrough : TextDecoration.none,
                            decorationColor: Colors.white,
                          ),
                        ),
                        if (widget.upsetRaceValue == 0) ...<Widget>[
                          Container(width: 20, height: 1, color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (widget.raceMetrics != null) ...<Widget>[
                  _buildRaceMetrics(widget.raceMetrics!),
                  const SizedBox(height: 6),
                ],
                Expanded(
                  child: _buildHorseList(firstAiHorses: widget.aiHorseList, supplements: supplements),
                ),
              ],
            ),
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
                      aiRecommendHorses: widget.aiHorseList,
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
  Widget _buildRaceMetrics(Map<String, int> metrics) {
    String stars(int v) => '★' * v + '☆' * (5 - v);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildMetricItem('波乱度', metrics['波乱度']!, stars(metrics['波乱度']!)),
          _buildMetricItem('下位進入度', metrics['下位進入度']!, stars(metrics['下位進入度']!)),
          _buildMetricItem('大穴進入度', metrics['大穴進入度']!, stars(metrics['大穴進入度']!)),
        ],
      ),
    );
  }

  ///
  Widget _buildMetricItem(String label, int value, String stars) {
    return Column(
      children: <Widget>[
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(stars, style: const TextStyle(fontSize: 10, color: Colors.yellowAccent, letterSpacing: 1)),
        Text(value.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  ///
  Widget _buildHorseCard(
    AiResponseRecommendHorseModel h, {
    bool isSupplementary = false,
    bool hideSecondAiSection = false,
  }) {
    // supplementary の場合は reason 自体が 2nd AI のコメント → 緑ボックスで表示
    final String? secondAiReason = isSupplementary
        ? h.reason
        : hideSecondAiSection
        ? null
        : _mergedHorses.isNotEmpty
        ? h.reasonSecond
        : widget.secondAiHorseList.where((AiResponseRecommendHorseModel s) => s.num == h.num).firstOrNull?.reason;

    final int? rank = widget.numToRankMap[h.num];

    return Stack(
      children: <Widget>[
        Positioned(
          right: 15,
          bottom: 10,
          child: Stack(
            children: <Widget>[
              Builder(
                builder: (BuildContext context) {
                  final double? idx = _baganrikiIndexMap[h.num];
                  String? activeLabel;
                  if (idx != null) {
                    if (idx >= 150) {
                      activeLabel = '◎有力';
                    } else if (idx >= 120) {
                      activeLabel = '○注目';
                    } else if (idx >= 100) {
                      activeLabel = '△様子見';
                    } else {
                      activeLabel = '✕妙味薄';
                    }
                  }
                  const List<(String, String)> labels = <(String, String)>[
                    ('◎有力', '150↑'),
                    ('○注目', '120↑'),
                    ('△様子見', '100↑'),
                    ('✕妙味薄', '~99'),
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          const Text('馬眼力指数', style: TextStyle(fontSize: 8, color: Colors.white)),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Transform(
                              alignment: Alignment.centerLeft,
                              transform: Matrix4.identity()..setEntry(0, 1, -0.8),
                              child: Text(
                                idx?.toStringAsFixed(1) ?? '',
                                style: const TextStyle(fontSize: 25, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: labels.map(((String, String) entry) {
                          final String label = entry.$1;
                          final String range = entry.$2;
                          final bool isActive = label == activeLabel;
                          final Color col = isActive ? Colors.greenAccent : Colors.white;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: col,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                Text(range, style: TextStyle(fontSize: 10, color: col)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
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
                DefaultTextStyle(
                  style: const TextStyle(color: Color(0xFFFBB6CE), fontSize: 12),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10),
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
                    ],
                  ),
                ),
                if (!isSupplementary)
                  Text(
                    h.reason.replaceAll(RegExp(r'\n?[─]+\n?'), '').trim(),
                    style: const TextStyle(letterSpacing: 0.4, height: 1.7),
                  ),
                if (secondAiReason != null && secondAiReason.isNotEmpty) ...<Widget>[
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
                          secondAiReason.replaceAll(RegExp(r'\n?[─]+\n?'), '').trim(),
                          style: const TextStyle(letterSpacing: 0.4, height: 1.7),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 60),
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
        if (!isSupplementary && h.category == 'matched')
          Positioned(
            top: 30,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                border: Border.all(color: const Color(0xFFFFD700)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '両AI一致',
                style: TextStyle(fontSize: 10, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  ///
  Widget _buildHorseList({
    required List<AiResponseRecommendHorseModel> firstAiHorses,
    required List<AiResponseRecommendHorseModel> supplements,
  }) {
    // merged_horses がある場合は統合表示モード（仕切りなし）
    if (_mergedHorses.isNotEmpty) {
      return ListView(
        children: _mergedHorses
            .map((AiResponseRecommendHorseModel h) => _buildHorseCard(h, isSupplementary: h.category == 'second_only'))
            .toList(),
      );
    }
    // フォールバック: 旧ロジック（仕切りなし）
    return ListView(
      children: <Widget>[
        ...firstAiHorses.map((AiResponseRecommendHorseModel h) => _buildHorseCard(h)),
        ...supplements.map((AiResponseRecommendHorseModel h) => _buildHorseCard(h, isSupplementary: true)),
      ],
    );
  }
}
