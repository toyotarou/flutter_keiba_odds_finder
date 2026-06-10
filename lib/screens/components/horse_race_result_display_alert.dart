import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/summary_model.dart';
import '../../utility/utility.dart';

class HorseRaceResultDisplayAlert extends ConsumerStatefulWidget {
  const HorseRaceResultDisplayAlert({super.key, this.numToPopularityRank = const <int, int>{}});

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

                Expanded(child: _displayRaceResultList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _displayRaceResultList() {
    final List<Widget> list = <Widget>[];
    final Map<int, Color> wakuColorMap = Utility().getHorseWakuColorMap();

    (<SummaryModel>[...summaryState.oneRaceSummaryList]
          ..sort((SummaryModel a, SummaryModel b) => a.result.compareTo(b.result)))
        .where((SummaryModel element) => <int>[1, 2, 3].contains(element.result))
        .forEach((SummaryModel element) {
          final String? latestOdds = <String>[
            element.oddsTanBefore0,
            element.oddsTanBefore3,
            element.oddsTanBefore6,
            element.oddsTanBefore9,
            element.oddsTanBefore12,
            element.oddsTanBefore15,
            element.oddsTanBefore18,
            element.oddsTanBefore21,
            element.oddsTanBefore24,
          ].nonNulls.firstOrNull;

          list.add(
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: switch (element.result) {
                        1 => const Color(0xFFFFD700).withValues(alpha: 0.5),
                        2 => const Color(0xFFC0C0C0).withValues(alpha: 0.5),
                        3 => const Color(0xFFCD7F32).withValues(alpha: 0.5),
                        _ => Colors.grey,
                      },
                      child: Text(
                        '${element.result}',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Container(
                      width: 30,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: wakuColorMap[element.waku]?.withValues(alpha: 0.3)),
                      alignment: Alignment.center,
                      child: Text(element.waku.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                    Container(
                      width: 30,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      alignment: Alignment.center,
                      child: Text(element.num.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                    Expanded(child: Text(element.horseName, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),

                DefaultTextStyle(
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: <Widget>[
                      Text('最終オッズ　${latestOdds?.toString() ?? '-'}'),

                      Text('人気　${widget.numToPopularityRank[element.num] ?? '-'}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        });

    return SingleChildScrollView(child: Column(children: list));
  }
}
