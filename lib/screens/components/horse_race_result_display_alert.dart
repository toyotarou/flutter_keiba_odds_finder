// =============================================================================
// ファイル名   : horse_race_result_display_alert.dart
// 概要         : レース結果（1〜3着）の画面。当日はレース結果から、過去レースはサマリーから表示する。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-10
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../const/const.dart';
import '../../controllers/controllers_mixin.dart';
import '../../models/odds_model.dart';
import '../../models/race_result_model.dart';
import '../../models/summary_model.dart';
import '../parts/race_top_three_widget.dart';

/// レース結果をどのデータから表示するか（raceResult: 当日のレース結果、summary: 過去レースのサマリー）。
enum ResultDisplayFrom { raceResult, summary }

/// レース結果（1〜3着）の画面。
class HorseRaceResultDisplayAlert extends ConsumerStatefulWidget {
  const HorseRaceResultDisplayAlert({super.key, required this.from, this.numToPopularityRank = const <int, int>{}});

  final ResultDisplayFrom from;
  final Map<int, int> numToPopularityRank;

  @override
  ConsumerState<HorseRaceResultDisplayAlert> createState() => _HorseRaceResultDisplayAlertState();
}

/// レース結果の画面の状態。
class _HorseRaceResultDisplayAlertState extends ConsumerState<HorseRaceResultDisplayAlert>
    with ControllersMixin<HorseRaceResultDisplayAlert> {
  /// レース結果（1〜3着）の画面を組み立てる。
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

  /// サマリーのうち、いちばん発走に近い時点の単勝オッズを返す。
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
          m.oddsTanBefore30,
        ].nonNulls.firstOrNull ??
        '-';
  }

  /// 当日のレース結果から、1〜3着の馬を表示する。
  Widget _displayFromRaceResult() {
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';

    final Map<int, RaceResultModel> raceResultMap = Map<int, RaceResultModel>.fromEntries(
      (raceResultState.raceResultMap[mapKey] ?? <RaceResultModel>[])
          .where((RaceResultModel e) => e.race == appParamState.selectedRaceNumber)
          .map((RaceResultModel e) => MapEntry<int, RaceResultModel>(e.result, e)),
    );

    final List<OddsModel> eRecordOdds =
        (appParamState.keepOddsMap[mapKey] ?? <OddsModel>[])
            .where(
              (OddsModel o) => o.race == appParamState.selectedRaceNumber && o.minutesBeforeStart == kOddsTimingLast,
            )
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

  /// 過去レースのサマリーから、1〜3着の馬を表示する。
  Widget _displayFromSummary() {
    final List<SummaryModel> top3 =
        (<SummaryModel>[...summaryState.oneRaceSummaryList]
              ..sort((SummaryModel a, SummaryModel b) => a.result.compareTo(b.result)))
            .where((SummaryModel e) => e.result <= kRaceTopFinishers)
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
