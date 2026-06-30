import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/odds_model.dart';
import '../../models/race_result_model.dart';
import '../../models/summary_model.dart';
import '../parts/race_top_three_widget.dart';

enum ResultDisplayFrom { raceResult, summary }

class HorseRaceResultDisplayAlert extends ConsumerStatefulWidget {
  const HorseRaceResultDisplayAlert({super.key, required this.from, this.numToPopularityRank = const <int, int>{}});

  final ResultDisplayFrom from;
  final Map<int, int> numToPopularityRank;

  @override
  ConsumerState<HorseRaceResultDisplayAlert> createState() => _HorseRaceResultDisplayAlertState();
}

class _HorseRaceResultDisplayAlertState extends ConsumerState<HorseRaceResultDisplayAlert>
    with ControllersMixin<HorseRaceResultDisplayAlert> {
  ///
  @override
  Widget build(BuildContext context) {
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
                const Text('結果'),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
                Expanded(
                  child: switch (widget.from) {
                    ResultDisplayFrom.raceResult => _displayFromRaceResult(),
                    ResultDisplayFrom.summary => _displayFromSummary(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  static String _latestOddsFrom(SummaryModel m) {
    return <String>[
          m.oddsTanBefore0,
          m.oddsTanBefore3,
          m.oddsTanBefore6,
          m.oddsTanBefore9,
          m.oddsTanBefore12,
          m.oddsTanBefore15,
          m.oddsTanBefore18,
          m.oddsTanBefore21,
          m.oddsTanBefore24,
        ].nonNulls.firstOrNull ??
        '-';
  }

  ///
  Widget _displayFromRaceResult() {
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';

    final Map<int, RaceResultModel> raceResultMap = Map<int, RaceResultModel>.fromEntries(
      (raceResultState.raceResultMap[mapKey] ?? <RaceResultModel>[])
          .where((RaceResultModel e) => e.race == appParamState.selectedRaceNumber)
          .map((RaceResultModel e) => MapEntry<int, RaceResultModel>(e.result, e)),
    );

    final List<OddsModel> eRecordOdds =
        (appParamState.keepOddsMap[mapKey] ?? <OddsModel>[])
            .where((OddsModel o) => o.race == appParamState.selectedRaceNumber && o.minutesBeforeStart == -999)
            .toList()
          ..sort((OddsModel a, OddsModel b) => (double.tryParse(a.odds) ?? 0).compareTo(double.tryParse(b.odds) ?? 0));

    final Map<int, int> numToPopularityMap = <int, int>{
      for (int i = 0; i < eRecordOdds.length; i++) eRecordOdds[i].num: i + 1,
    };
    final Map<int, String> numToOddsMap = <int, String>{for (final OddsModel o in eRecordOdds) o.num: o.odds};

    final Map<int, RaceTopThreeEntry> entries = <int, RaceTopThreeEntry>{
      for (final MapEntry<int, RaceResultModel> e in raceResultMap.entries)
        e.key: RaceTopThreeEntry(
          num: e.value.num,
          name: e.value.horseName,
          odds: numToOddsMap[e.value.num] ?? '-',
          popularity: numToPopularityMap[e.value.num],
        ),
    };

    return RaceTopThreeWidget(entries: entries, showTitle: true);
  }

  ///
  Widget _displayFromSummary() {
    final List<SummaryModel> top3 =
        (<SummaryModel>[...summaryState.oneRaceSummaryList]
              ..sort((SummaryModel a, SummaryModel b) => a.result.compareTo(b.result)))
            .where((SummaryModel e) => <int>[1, 2, 3].contains(e.result))
            .toList();

    final Map<int, RaceTopThreeEntry> entries = <int, RaceTopThreeEntry>{
      for (final SummaryModel e in top3)
        e.result: RaceTopThreeEntry(
          num: e.num,
          name: e.horseName,
          odds: _latestOddsFrom(e),
          popularity: widget.numToPopularityRank[e.num],
        ),
    };

    return RaceTopThreeWidget(entries: entries, showTitle: true);
  }
}
