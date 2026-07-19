import 'package:flutter/material.dart';

import '../../const/const.dart';
import '../../utility/functions.dart';

class RaceTopThreeEntry {
  const RaceTopThreeEntry({required this.num, required this.name, required this.odds, required this.popularity});

  final int num;
  final String name;
  final String odds;
  final int? popularity;
}

class RaceTopThreeWidget extends StatelessWidget {
  const RaceTopThreeWidget({super.key, required this.entries, this.showTitle = false});

  /// key = 着順(1/2/3), value = 馬情報
  final Map<int, RaceTopThreeEntry> entries;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 10, color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (showTitle)
              Container(
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1)),
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text('レース結果'),
              ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<int>.generate(kRaceTopFinishers, (int i) => i + 1).map((int rank) {
                final RaceTopThreeEntry? h = entries[rank];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: raceRankColor(rank, fallback: Colors.grey.withValues(alpha: 0.3)),
                        ),

                        child: Text(rank.toString()),
                      ),
                      Container(width: 40, alignment: Alignment.center, child: Text(h != null ? h.num.toString() : '')),
                      Expanded(child: Text(h != null ? h.name : '', maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Container(width: 40, alignment: Alignment.center, child: Text(h != null ? h.odds : '')),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(h != null ? '${h.popularity ?? '-'}番人気' : ''),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
