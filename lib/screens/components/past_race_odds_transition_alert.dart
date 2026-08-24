import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../models/common/ai_response_recommend_horse_model.dart';
import '../../models/race_introspection_model.dart';
import '../../models/race_result_payout_model.dart';
import '../../models/summary_model.dart';
import '../../utility/functions.dart';
import '../parts/odds_finder_dialog.dart';
import 'horse_odds_ranking_display_alert.dart';

class PastRaceOddsTransitionAlert extends ConsumerStatefulWidget {
  const PastRaceOddsTransitionAlert({super.key});

  @override
  ConsumerState<PastRaceOddsTransitionAlert> createState() => _PastRaceOddsTransitionAlertState();
}

class _PastRaceOddsTransitionAlertState extends ConsumerState<PastRaceOddsTransitionAlert>
    with ControllersMixin<PastRaceOddsTransitionAlert> {
  final ScrollController _scrollController = ScrollController();

  final Map<String, bool> _expandedByDate = <String, bool>{};

  final Set<String> _fetchedDates = <String>{};

  final Map<String, RaceResultPayoutModel> _payoutMap = <String, RaceResultPayoutModel>{};

  final Map<String, String?> _secondAiTextMap = <String, String?>{};

  final Set<String> _fetchedSecondAiDates = <String>{};

  static const double _moveAmount = 18;

  static const int _tickMs = 16;

  Timer? _repeatTimer;

  ///
  Future<void> _fetchSecondAiForDate(String date) async {
    if (_fetchedSecondAiDates.contains(date)) {
      return;
    }
    _fetchedSecondAiDates.add(date);

    final Map<String, List<SummaryModel>> summaryMap = summaryState.summaryMap;

    final List<Future<void>> futures = <Future<void>>[];
    int successCount = 0;

    for (final MapEntry<String, List<SummaryModel>> entry in summaryMap.entries) {
      if (!entry.key.startsWith(date)) {
        continue;
      }

      final List<SummaryModel> models = entry.value;

      if (models.isEmpty) {
        continue;
      }

      final int kaisuu = int.tryParse(models.first.kaisuu) ?? 0;

      final Set<int> seenRaces = <int>{};

      for (final SummaryModel m in models) {
        if (!seenRaces.add(m.race)) {
          continue;
        }

        final String key = '${m.date}_${kaisuu}_${m.basho}_${m.day}_${m.race}';

        // 結果が届いた時点で即 setState → キャッシュ済みレースはすぐ表示される
        futures.add(
          fetchSecondAiOpinionData(
                ref,
                date: m.date,
                kaisuu: kaisuu.toString(),
                basho: m.basho,
                day: m.day.toString(),
                race: m.race,
              )
              .then((Map<String, dynamic> data) {
                final String? text = data['analysis_text'] as String?;
                if (text != null) {
                  successCount++;
                }
                if (mounted) {
                  setState(() => _secondAiTextMap[key] = text);
                }
              })
              .catchError((_) {
                if (mounted) {
                  setState(() => _secondAiTextMap[key] = null);
                }
              }),
        );
      }
    }

    if (futures.isEmpty) {
      // summaryMap がまだ空だった場合もリトライできるよう解除する
      _fetchedSecondAiDates.remove(date);
      return;
    }

    try {
      await Future.wait(futures);

      // 全レースのデータ取得に失敗した場合はリトライを許可
      if (successCount == 0) {
        _fetchedSecondAiDates.remove(date);
      }
    } catch (_) {
      _fetchedSecondAiDates.remove(date);
    }
  }

  ///
  Set<int> _extractPickupNums(String introspection) {
    final int start = introspection.indexOf('## ピックアップ');

    if (start == -1) {
      return <int>{};
    }

    final int sectionStart = start + '## ピックアップ'.length;

    final int nextSection = introspection.indexOf('## ', sectionStart);

    final String pickupPart = nextSection != -1
        ? introspection.substring(sectionStart, nextSection)
        : introspection.substring(sectionStart);

    final Set<int> nums = <int>{};

    for (final RegExpMatch m in RegExp(r'(\d+)番').allMatches(pickupPart)) {
      final int? num = int.tryParse(m.group(1)!);

      if (num != null) {
        nums.add(num);
      }
    }

    return nums;
  }

  ///
  int? _calcSupplementCovered({
    required String? resultText,
    required String lookupKey,
    required RaceIntrospectionModel? introspectionModel,
    required RaceResultPayoutModel? payout,
  }) {
    if (resultText == null || resultText.contains('3頭が合致')) {
      return null;
    }

    final String? secondAiText = _secondAiTextMap[lookupKey];

    if (secondAiText == null || secondAiText.isEmpty) {
      return null;
    }

    if (introspectionModel == null) {
      return null;
    }

    final List<AiResponseRecommendHorseModel> deepSeekHorses = parseAnalysisText(secondAiText);

    final Set<int> claudeNums = _extractPickupNums(introspectionModel.introspection);

    final List<AiResponseRecommendHorseModel> supplementHorses = deepSeekHorses
        .where((AiResponseRecommendHorseModel h) => !claudeNums.contains(h.num))
        .toList();

    return calcSupplementCoveredCount(supplementHorses: supplementHorses, payout: payout);
  }

  ///
  Future<void> _fetchPayoutsForDate(String date) async {
    if (_fetchedDates.contains(date)) {
      return;
    }

    _fetchedDates.add(date);

    final Map<String, List<SummaryModel>> summaryMap = summaryState.summaryMap;

    final Set<String> raceParamSet = <String>{};

    for (final MapEntry<String, List<SummaryModel>> entry in summaryMap.entries) {
      if (!entry.key.startsWith(date)) {
        continue;
      }

      final List<SummaryModel> models = entry.value;

      if (models.isEmpty) {
        continue;
      }

      final int kaisuu = int.tryParse(models.first.kaisuu) ?? 0;

      final Set<int> seenRaces = <int>{};

      for (final SummaryModel m in models) {
        if (seenRaces.add(m.race)) {
          raceParamSet.add('${m.date}|$kaisuu|${m.basho}|${m.race}');
        }
      }
    }

    if (raceParamSet.isEmpty) {
      return;
    }

    try {
      final Map<String, RaceResultPayoutModel> result = await fetchPayoutMap(ref, racesParam: raceParamSet.join('/'));

      if (mounted) {
        setState(() => _payoutMap.addAll(result));
      }
    } catch (_) {
      _fetchedDates.remove(date);
    }
  }

  ///
  @override
  void dispose() {
    _repeatTimer?.cancel();

    _repeatTimer = null;

    _scrollController.dispose();

    super.dispose();
  }

  ///
  void _startRepeating(VoidCallback action) {
    _repeatTimer?.cancel();

    action();

    _repeatTimer = Timer.periodic(const Duration(milliseconds: _tickMs), (_) => action());
  }

  ///
  void _stopRepeating() {
    _repeatTimer?.cancel();

    _repeatTimer = null;
  }

  ///
  void _scrollBy(double delta) {
    if (!_scrollController.hasClients) {
      return;
    }

    final ScrollPosition pos = _scrollController.position;

    final double newOffset = (_scrollController.offset + delta).clamp(0.0, pos.maxScrollExtent);

    _scrollController.jumpTo(newOffset);
  }

  ///
  Widget _buildToggleButton({required bool isOpen, required VoidCallback onTap, VoidCallback? onSecondAiFetch}) {
    return GestureDetector(
      onTap: () {
        onTap();
        if (!isOpen) {
          onSecondAiFetch?.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
          color: isOpen
              ? const Color(0xFF2196F3).withValues(alpha: 0.4)
              : const Color(0xFF4CAF50).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(isOpen ? 'CLOSE' : 'OPEN', style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  ///
  @override
  Widget build(BuildContext context) {
    final Map<String, List<String>> summaryDateBashoMap = summaryState.summaryDateBashoMap;

    final Map<String, List<SummaryModel>> summaryMap = summaryState.summaryMap;

    final bool allOpen = summaryDateBashoMap.entries.every(
      (MapEntry<String, List<String>> e) => e.value.every((String e2) => _expandedByDate['${e.key}_$e2'] ?? false),
    );

    final bool anyOpen = summaryDateBashoMap.entries.any(
      (MapEntry<String, List<String>> e) => e.value.any((String e2) => _expandedByDate['${e.key}_$e2'] ?? false),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Text('過去レースのオッズ遷移表', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        _buildToggleButton(
                          isOpen: allOpen,
                          onTap: () {
                            setState(() {
                              for (final MapEntry<String, List<String>> entry in summaryDateBashoMap.entries) {
                                for (final String e2 in entry.value) {
                                  _expandedByDate['${entry.key}_$e2'] = !anyOpen;
                                }
                              }
                            });
                            if (!anyOpen) {
                              summaryDateBashoMap.keys.forEach(_fetchPayoutsForDate);
                            }
                          },
                          onSecondAiFetch: () => summaryDateBashoMap.keys.forEach(_fetchSecondAiForDate),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) => _startRepeating(() => _scrollBy(_moveAmount)),
                          onTapUp: (_) => _stopRepeating(),
                          onTapCancel: _stopRepeating,
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(child: Icon(Icons.arrow_downward, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) => _startRepeating(() => _scrollBy(-_moveAmount)),
                          onTapUp: (_) => _stopRepeating(),
                          onTapCancel: _stopRepeating,
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(child: Icon(Icons.arrow_upward, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: summaryDateBashoMap.entries.map((MapEntry<String, List<String>> e) {
                        final bool isOpenForDate = e.value.any((String e2) => _expandedByDate['${e.key}_$e2'] ?? false);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[Colors.greenAccent.withValues(alpha: 0.3), Colors.transparent],
                                  stops: const <double>[0.7, 1],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(e.key, style: const TextStyle(color: Colors.white)),
                                  _buildToggleButton(
                                    isOpen: isOpenForDate,
                                    onTap: () {
                                      setState(() {
                                        for (final String e2 in e.value) {
                                          _expandedByDate['${e.key}_$e2'] = !isOpenForDate;
                                        }
                                      });

                                      if (!isOpenForDate) {
                                        _fetchPayoutsForDate(e.key);
                                      }
                                    },
                                    onSecondAiFetch: () => _fetchSecondAiForDate(e.key),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: e.value.map((String e2) {
                                final List<SummaryModel> models = summaryMap['${e.key}_$e2'] ?? <SummaryModel>[];
                                if (models.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                final Map<int, String> uniqueRaces = <int, String>{};
                                for (final SummaryModel m in models) {
                                  uniqueRaces.putIfAbsent(m.race, () => m.raceName);
                                }
                                final List<MapEntry<int, String>> races = uniqueRaces.entries.toList()
                                  ..sort((MapEntry<int, String> a, MapEntry<int, String> b) => a.key.compareTo(b.key));

                                final bool isOpenForBasho = _expandedByDate['${e.key}_$e2'] ?? false;
                                return ExpansionTile(
                                  key: ValueKey<String>('${e.key}_${e2}_$isOpenForBasho'),
                                  initiallyExpanded: isOpenForBasho,
                                  onExpansionChanged: (bool expanded) {
                                    setState(() => _expandedByDate['${e.key}_$e2'] = expanded);
                                    if (expanded) {
                                      _fetchPayoutsForDate(e.key);
                                      _fetchSecondAiForDate(e.key);
                                    }
                                  },
                                  iconColor: Colors.greenAccent,
                                  collapsedIconColor: Colors.white70,
                                  title: Text(
                                    '${models.first.kaisuu}回 ${models.first.bashoName} ${models.first.day}日',
                                    style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                                  ),
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: races
                                            .map(
                                              (MapEntry<int, String> r) =>
                                                  _buildRaceRow(date: e.key, models: models, r: r),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 30),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _buildRaceRow({required String date, required List<SummaryModel> models, required MapEntry<int, String> r}) {
    final int kaisuu = int.tryParse(models.first.kaisuu) ?? 0;

    final String lookupKey = '${date}_${kaisuu}_${models.first.basho}_${models.first.day}_${r.key}';

    final String raceKey = '${date}_${models.first.kaisuu}_${models.first.basho}_${models.first.day}_${r.key}';

    final RaceIntrospectionModel? introspectionModel = findRaceIntrospection(
      raceIntrospectionState.raceIntrospectionMap,
      date: date,
      kaisuu: kaisuu,
      basho: models.first.basho,
      day: models.first.day,
      race: r.key,
    );

    final String? resultText = introspectionModel != null ? extractResultLine(introspectionModel.introspection) : null;

    final RaceResultPayoutModel? payout = _payoutMap[lookupKey];

    final int? supplementCoveredCount = _calcSupplementCovered(
      resultText: resultText,
      lookupKey: lookupKey,
      introspectionModel: introspectionModel,
      payout: payout,
    );

    final String grade = payout?.grade ?? '';

    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white70, fontSize: 11),
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(width: 20, alignment: Alignment.topRight, child: Text('${r.key}R')),
                    const SizedBox(width: 20),
                    Expanded(child: Text(r.value, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    GestureDetector(
                      onTap: () {
                        appParamNotifier.setSelectedDrawerRace(race: raceKey);
                        summaryNotifier.fetchRaceSummary(
                          date: date,
                          kaisuu: models.first.kaisuu,
                          basho: models.first.basho,
                          day: models.first.day,
                          race: r.key,
                        );
                        appParamNotifier.setIsShowUpperBox2(flag: true);
                        OddsFinderDialog(
                          context: context,
                          widget: const HorseOddsRankingDisplayAlert(mode: RankingMode.summary),
                        );
                      },
                      child: Icon(
                        Icons.calendar_view_month,
                        color: raceKey == appParamState.selectedDrawerRace
                            ? Colors.yellowAccent.withValues(alpha: 0.4)
                            : Colors.greenAccent.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                if (resultText != null) ...<Widget>[
                  _buildResultTextSection(
                    resultText: resultText,
                    supplementCoveredCount: supplementCoveredCount,
                    payout: payout,
                    isSecondAiLoading: _fetchedSecondAiDates.contains(date) && !_secondAiTextMap.containsKey(lookupKey),
                  ),
                ] else ...<Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38),
                        ),
                        SizedBox(width: 5),
                        Text('分析中...', style: TextStyle(fontSize: 9, color: Colors.white38)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (grade.isNotEmpty) ...<Widget>[
            Positioned(
              top: 5,
              right: 35,
              child: Opacity(
                opacity: 0.7,
                child: Image.asset('assets/race_grade_icon/race_grade_icon_$grade.png', width: 30),
              ),
            ),
          ],
        ],
      ),
    );
  }

  ///
  Widget _buildResultTextSection({
    required String resultText,
    required int? supplementCoveredCount,
    required RaceResultPayoutModel? payout,
    required bool isSecondAiLoading,
  }) {
    final bool isMatch = resultText.contains('3頭が合致');

    final int claudeMatchCount = int.tryParse(RegExp(r'(\d+)頭が合致').firstMatch(resultText)?.group(1) ?? '') ?? 0;

    final bool isMatchWithSupplement = isMatch || (claudeMatchCount + (supplementCoveredCount ?? 0) >= 3);

    final int trioAmount = (payout != null && payout.trio.isNotEmpty)
        ? (int.tryParse(payout.trio.split('/').first.split('|').elementAtOrNull(1) ?? '') ?? 0)
        : 0;

    final Color textColor = isMatchWithSupplement
        ? const Color(0xFFFBB6CE)
        : trioAmount >= 10000
        ? Colors.yellowAccent.withValues(alpha: 0.5)
        : Colors.white60;

    return DefaultTextStyle(
      style: TextStyle(fontSize: 10, color: textColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(resultText),
          if (isSecondAiLoading && supplementCoveredCount == null) ...<Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38),
                  ),
                  SizedBox(width: 5),
                  Text('2nd AI 取得中...', style: TextStyle(fontSize: 9, color: Colors.white38)),
                ],
              ),
            ),
          ] else ...<Widget>[
            if (supplementCoveredCount != null) ...<Widget>[Text('補欠で$supplementCoveredCount頭をカバー')],
          ],
          if (payout != null) ...<Widget>[
            if (payout.trifecta.isNotEmpty) ...<Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const SizedBox.shrink(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      const Text('三連単'),
                      Container(
                        width: 60,
                        alignment: Alignment.bottomRight,
                        child: Text(payout.trifecta.split('/').first.split('|').elementAtOrNull(1)?.toCurrency() ?? ''),
                      ),
                    ],
                  ),
                ],
              ),
            ],

            if (payout.trio.isNotEmpty) ...<Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const SizedBox.shrink(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      const Text('三連複'),
                      Container(
                        width: 60,
                        alignment: Alignment.bottomRight,
                        child: Text(payout.trio.split('/').first.split('|').elementAtOrNull(1)?.toCurrency() ?? ''),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
