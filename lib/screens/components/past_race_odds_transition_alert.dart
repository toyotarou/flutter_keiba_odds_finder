import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
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
                const Text('過去レースのオッズ遷移表', style: TextStyle(fontSize: 12)),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
                Expanded(
                  child: SingleChildScrollView(
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
                                            .map((MapEntry<int, String> r) => _buildRaceRow(
                                                  date: e.key,
                                                  models: models,
                                                  r: r,
                                                ))
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

  Widget _buildRaceRow({
    required String date,
    required List<SummaryModel> models,
    required MapEntry<int, String> r,
  }) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white70, fontSize: 11),
      child: Container(
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
                color: ('${date}_${models.first.kaisuu}_${models.first.basho}_${models.first.day}_${r.key}' ==
                        appParamState.selectedDrawerRace)
                    ? Colors.yellowAccent.withValues(alpha: 0.4)
                    : Colors.greenAccent.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
