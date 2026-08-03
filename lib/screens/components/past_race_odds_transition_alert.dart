import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/race_introspection_model.dart';
import '../../models/summary_model.dart';
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

  static const double _moveAmount = 18;
  static const int _tickMs = 16;

  Timer? _repeatTimer;

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
                    const Text('過去レースのオッズ遷移表', style: TextStyle(fontSize: 12)),

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
                              child: Text(e.key, style: const TextStyle(color: Colors.white)),
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
  ({int hits, int total}) _calcHits({required String date, required List<SummaryModel> models, required int race}) {
    final int kaisuu = int.tryParse(models.first.kaisuu) ?? 0;
    final RaceIntrospectionModel? introspectionModel = raceIntrospectionState.raceIntrospectionMap.values
        .where(
          (RaceIntrospectionModel e) =>
              e.date == date && e.kaisuu == kaisuu && e.day == models.first.day && e.race == race,
        )
        .firstOrNull;

    if (introspectionModel == null) {
      return (hits: 0, total: 0);
    }

    final int hits = introspectionModel.introspection.split('\n').where((String l) => l.contains('（的中）')).length;
    final int total = introspectionModel.introspection
        .split('\n')
        .where((String l) => l.contains('（的中）') || l.contains('（不的中）'))
        .length;

    return (hits: hits, total: total);
  }

  ///
  Widget _buildRaceRow({required String date, required List<SummaryModel> models, required MapEntry<int, String> r}) {
    final (:int hits, :int total) = _calcHits(date: date, models: models, race: r.key);

    final Color scoreColor = total == 0
        ? Colors.transparent
        : hits == total
        ? Colors.greenAccent
        : hits == 0
        ? Colors.redAccent
        : Colors.yellowAccent;

    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white70, fontSize: 11),
      child: Stack(
        children: <Widget>[
          if (total > 0)
            Positioned(
              top: 10,
              right: 30,
              child: Text('$hits/$total', style: TextStyle(color: scoreColor, fontSize: 10)),
            ),

          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3))),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5),

            child: Row(
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
          ),
        ],
      ),
    );
  }
}
