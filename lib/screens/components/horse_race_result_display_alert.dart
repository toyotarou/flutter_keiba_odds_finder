import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/odds_model.dart';
import '../../models/race_result_model.dart';
import '../../models/summary_model.dart';

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
  static Widget _buildResultRow({
    required int rank,
    required String num,
    required String horseName,
    required String odds,
    required String popularity,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 10,
                  backgroundColor: switch (rank) {
                    1 => const Color(0xFFFFD700).withValues(alpha: 0.5),
                    2 => const Color(0xFFC0C0C0).withValues(alpha: 0.5),
                    3 => const Color(0xFFCD7F32).withValues(alpha: 0.5),
                    _ => Colors.grey,
                  },
                  child: Text(
                    '$rank',
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Container(width: 40, alignment: Alignment.center, child: Text(num)),
                const SizedBox(width: 10),
                Expanded(child: Text(horseName, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 2),
            DefaultTextStyle(
              style: const TextStyle(color: Colors.greenAccent, fontSize: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[Text('オッズ　$odds'), Text('人気　$popularity')],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  static Widget _buildResultList(List<Widget> rows) {
    return SingleChildScrollView(child: Column(children: rows));
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

    return _buildResultList(<Widget>[
      for (final int rank in <int>[1, 2, 3])
        _buildResultRow(
          rank: rank,
          num: raceResultMap[rank]?.num.toString() ?? '-',
          horseName: raceResultMap[rank]?.horseName ?? '-',
          odds: raceResultMap[rank] != null ? (numToOddsMap[raceResultMap[rank]!.num] ?? '-') : '-',
          popularity: raceResultMap[rank] != null
              ? (numToPopularityMap[raceResultMap[rank]!.num]?.toString() ?? '-')
              : '-',
        ),
    ]);
  }

  ///
  Widget _displayFromSummary() {
    final List<SummaryModel> top3 =
        (<SummaryModel>[...summaryState.oneRaceSummaryList]
              ..sort((SummaryModel a, SummaryModel b) => a.result.compareTo(b.result)))
            .where((SummaryModel e) => <int>[1, 2, 3].contains(e.result))
            .toList();

    return _buildResultList(<Widget>[
      for (final SummaryModel element in top3)
        _buildResultRow(
          rank: element.result,
          num: element.num.toString(),
          horseName: element.horseName,
          odds: _latestOddsFrom(element),
          popularity: widget.numToPopularityRank[element.num]?.toString() ?? '-',
        ),
    ]);
  }
}
