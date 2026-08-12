import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
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

  static const double _moveAmount = 18;
  static const int _tickMs = 16;

  Timer? _repeatTimer;

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
  @override
  Widget build(BuildContext context) {
    final Map<String, List<String>> summaryDateBashoMap = summaryState.summaryDateBashoMap;
    final Map<String, List<SummaryModel>> summaryMap = summaryState.summaryMap;

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

                        GestureDetector(
                          onTap: () {
                            final bool allOpen = summaryDateBashoMap.keys.every(
                              (String k) => _expandedByDate[k] ?? false,
                            );

                            setState(() {
                              for (final String k in summaryDateBashoMap.keys) {
                                _expandedByDate[k] = !allOpen;
                              }
                            });

                            if (!allOpen) {
                              summaryDateBashoMap.keys.forEach(_fetchPayoutsForDate);
                            }
                          },
                          child: Builder(
                            builder: (BuildContext context) {
                              final bool allOpen = summaryDateBashoMap.keys.every(
                                (String k) => _expandedByDate[k] ?? false,
                              );

                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: allOpen
                                      ? const Color(0xFF2196F3).withValues(alpha: 0.4)
                                      : const Color(0xFF4CAF50).withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    allOpen ? 'CLOSE' : 'OPEN',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              );
                            },
                          ),
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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[Colors.greenAccent.withOpacity(0.3), Colors.transparent],
                                  stops: const <double>[0.7, 1],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(e.key, style: const TextStyle(color: Colors.white)),

                                  GestureDetector(
                                    onTap: () {
                                      final bool nowOpen = !(_expandedByDate[e.key] ?? false);
                                      setState(() => _expandedByDate[e.key] = nowOpen);
                                      if (nowOpen) {
                                        _fetchPayoutsForDate(e.key);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: (_expandedByDate[e.key] ?? false)
                                            ? const Color(0xFF2196F3).withValues(alpha: 0.4)
                                            : const Color(0xFF4CAF50).withValues(alpha: 0.4),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          (_expandedByDate[e.key] ?? false) ? 'CLOSE' : 'OPEN',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: e.value.map((String e2) {
                                final List<SummaryModel> models = summaryMap['${e.key}_$e2'] ?? <SummaryModel>[];
                                final Map<int, String> uniqueRaces = <int, String>{};
                                for (final SummaryModel m in models) {
                                  uniqueRaces.putIfAbsent(m.race, () => m.raceName);
                                }
                                final List<MapEntry<int, String>> races = uniqueRaces.entries.toList()
                                  ..sort((MapEntry<int, String> a, MapEntry<int, String> b) => a.key.compareTo(b.key));

                                if (models.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return ExpansionTile(
                                  key: ValueKey<String>('${e.key}_${e2}_${_expandedByDate[e.key] ?? false}'),
                                  initiallyExpanded: _expandedByDate[e.key] ?? false,
                                  onExpansionChanged: (bool expanded) {
                                    if (expanded) {
                                      _fetchPayoutsForDate(e.key);
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

  // ///
  // ({int hits, int total, int comboHits, int comboTotal}) _calcHits({
  //   required String date,
  //   required List<SummaryModel> models,
  //   required int race,
  // }) {
  //   final int kaisuu = int.tryParse(models.first.kaisuu) ?? 0;
  //   final RaceIntrospectionModel? introspectionModel = findRaceIntrospection(
  //     raceIntrospectionState.raceIntrospectionMap,
  //     date: date,
  //     kaisuu: kaisuu,
  //     basho: models.first.basho,
  //     day: models.first.day,
  //     race: race,
  //   );
  //
  //   if (introspectionModel == null) {
  //     return (hits: 0, total: 0, comboHits: 0, comboTotal: 0);
  //   }
  //
  //   final List<String> lines = introspectionModel.introspection.split('\n');
  //
  //   final int hits = lines.where((String l) => l.contains('（的中）')).length;
  //   final int total = lines.where((String l) => l.contains('（的中）') || l.contains('（不的中）')).length;
  //
  //   // 三連複: 予想・結果それぞれの馬番号セットを抽出して順不同で一致数を計算
  //   final Set<int> predictedNumbers = <int>{};
  //   final Set<int> resultNumbers = <int>{};
  //   bool inPrediction = false;
  //   bool inResult = false;
  //   for (final String line in lines) {
  //     final String trimmed = line.trim();
  //     if (trimmed == '## 予想') {
  //       inPrediction = true;
  //       inResult = false;
  //       continue;
  //     } else if (trimmed == '## 結果') {
  //       inPrediction = false;
  //       inResult = true;
  //       continue;
  //     } else if (trimmed.startsWith('## ')) {
  //       inPrediction = false;
  //       inResult = false;
  //       continue;
  //     }
  //     final RegExpMatch? match = RegExp(r'(\d+)番').firstMatch(line);
  //     if (match != null) {
  //       final int number = int.parse(match.group(1)!);
  //       if (inPrediction) {
  //         predictedNumbers.add(number);
  //       } else if (inResult) {
  //         resultNumbers.add(number);
  //       }
  //     }
  //   }
  //
  //   final int comboHits = predictedNumbers.intersection(resultNumbers).length;
  //   final int comboTotal = predictedNumbers.length;
  //
  //   return (hits: hits, total: total, comboHits: comboHits, comboTotal: comboTotal);
  // }

  ///
  Widget _buildRaceRow({required String date, required List<SummaryModel> models, required MapEntry<int, String> r}) {
    // final (:int hits, :int total, :int comboHits, :int comboTotal) = _calcHits(date: date, models: models, race: r.key);

    // final Color scoreColor = total == 0
    //     ? Colors.transparent
    //     : hits == total
    //     ? Colors.greenAccent
    //     : hits == 0
    //     ? Colors.redAccent
    //     : Colors.yellowAccent;

    // final Color comboColor = comboTotal == 0
    //     ? Colors.transparent
    //     : comboHits == comboTotal
    //     ? Colors.greenAccent
    //     : comboHits == 0
    //     ? Colors.redAccent
    //     : Colors.yellowAccent;

    final int kaisuu = int.tryParse(models.first.kaisuu) ?? 0;
    final RaceIntrospectionModel? introspectionModel = findRaceIntrospection(
      raceIntrospectionState.raceIntrospectionMap,
      date: date,
      kaisuu: kaisuu,
      basho: models.first.basho,
      day: models.first.day,
      race: r.key,
    );
    final String? resultText = introspectionModel != null ? extractResultLine(introspectionModel.introspection) : null;
    final String lookupKey = '${date}_${kaisuu}_${models.first.basho}_${models.first.day}_${r.key}';
    final RaceResultPayoutModel? payout = _payoutMap[lookupKey];

    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white70, fontSize: 11),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3))),
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
                    appParamNotifier.setSelectedDrawerRace(
                      race: '${date}_${models.first.kaisuu}_${models.first.basho}_${models.first.day}_${r.key}',
                    );
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
                    color:
                        ('${date}_${models.first.kaisuu}_${models.first.basho}_${models.first.day}_${r.key}' ==
                            appParamState.selectedDrawerRace)
                        ? Colors.yellowAccent.withValues(alpha: 0.4)
                        : Colors.greenAccent.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),

            if (resultText != null)
              if (resultText.contains('3頭が合致')) ...<Widget>[
                DefaultTextStyle(
                  style: const TextStyle(fontSize: 10, color: Color(0xFFFBB6CE)),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(resultText),
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
                                    width: 40,
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      payout.trifecta.split('/').first.split('|').elementAtOrNull(1)?.toCurrency() ??
                                          '',
                                    ),
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
                                    width: 40,
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      payout.trio.split('/').first.split('|').elementAtOrNull(1)?.toCurrency() ?? '',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ] else ...<Widget>[Text(resultText, style: const TextStyle(fontSize: 10))],
          ],
        ),
      ),
    );
  }
}
