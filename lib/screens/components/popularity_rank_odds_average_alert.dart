import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../models/popularity_rank_odds_average_model.dart';
import '../../models/race_result_history_model.dart';

class PopularityRankOddsAverageAlert extends ConsumerStatefulWidget {
  const PopularityRankOddsAverageAlert({super.key, required this.popularity});

  final int popularity;

  @override
  ConsumerState<PopularityRankOddsAverageAlert> createState() => _PopularityRankOddsAverageAlertState();
}

class _PopularityRankOddsAverageAlertState extends ConsumerState<PopularityRankOddsAverageAlert>
    with ControllersMixin<PopularityRankOddsAverageAlert> {
  ///
  @override
  void initState() {
    super.initState();
    raceResultHistoryNotifier.fetchRaceResultHistory(rank: widget.popularity).catchError((_) {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    final PopularityRankOddsAverageModel popularityRankOddsAverageModel =
        appParamState.keepPopularityRankOddsAverageMap[widget.popularity]!;

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
                DefaultTextStyle(
                  style: const TextStyle(fontSize: 12),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('${widget.popularity}番人気平均オッズ'),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text('From: ${popularityRankOddsAverageModel.startDate}'),
                          Text('To: ${popularityRankOddsAverageModel.endDate}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                Stack(
                  children: <Widget>[
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Text(
                        '${popularityRankOddsAverageModel.count}レース平均',
                        style: const TextStyle(color: Colors.orangeAccent),
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      height: context.screenSize.height * 0.1,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Center(
                        child: Text(
                          popularityRankOddsAverageModel.oddsAverage,
                          style: const TextStyle(fontSize: 50, color: Colors.orangeAccent),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Expanded(child: displayPopularityRankOddsList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget displayPopularityRankOddsList() {
    final List<RaceResultHistoryModel> list = raceResultHistoryState.raceResultHistoryList;

    if (list.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
    }

    return SingleChildScrollView(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: list.map((RaceResultHistoryModel e) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(e.tan, style: const TextStyle(color: Colors.orangeAccent, fontSize: 13)),
          );
        }).toList(),
      ),
    );
  }
}
