import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/popularity_rank_odds_average_model.dart';
import '../../models/race_result_history_model.dart';
import '../../utility/functions.dart';
import '../parts/error_confirm_dialog.dart';
import '../parts/rank_badge_painter.dart';

class PopularityRecordDisplayAlert extends ConsumerStatefulWidget {
  const PopularityRecordDisplayAlert({super.key});

  @override
  ConsumerState<PopularityRecordDisplayAlert> createState() => _PopularityRecordDisplayAlertState();
}

class _PopularityRecordDisplayAlertState extends ConsumerState<PopularityRecordDisplayAlert>
    with ControllersMixin<PopularityRecordDisplayAlert> {
  Future<List<RaceResultHistoryModel>>? _future;

  late final ScrollController _scrollController;
  Timer? _repeatTimer;

  static const double _moveAmount = 18;
  static const int _tickMs = 16;

  ///
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  ///
  @override
  void dispose() {
    _repeatTimer?.cancel();
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
    _scrollController.jumpTo((_scrollController.offset + delta).clamp(0.0, pos.maxScrollExtent));
  }

  ///
  Future<List<RaceResultHistoryModel>> _fetch({required int rank, required int year}) async {
    final HttpClient client = ref.read(httpClientProvider);

    final dynamic value = await client.get(
      path: APIPath.getHorseOddsFinderRaceResultHistory,
      queryParameters: <String, dynamic>{'year': year.toString(), 'popularity_rank': rank.toString()},
    );

    // ignore: avoid_dynamic_calls
    final List<dynamic> data = value['data'] as List<dynamic>;
    return data.map((dynamic e) => RaceResultHistoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  ///
  void _onRankTap(int newRank, String selectedYear) {
    appParamNotifier.setSelectedPopularityRank(rank: newRank);
    if (selectedYear.isNotEmpty) {
      setState(() {
        _future = _fetch(rank: newRank, year: int.parse(selectedYear));
      });
    }
  }

  ///
  void _onYearTap(int year, int selectedRank) {
    if (selectedRank == 0) {
      errorConfirmDialog(context: context, title: 'エラー', content: 'リストを表示する人気順が選択されていません。');
      return;
    }
    appParamNotifier.setSelectedPopularityRankYear(year: year.toString());
    setState(() {
      _future = _fetch(rank: selectedRank, year: year);
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    final int selectedRank = appParamState.selectedPopularityRank;
    final String selectedYear = appParamState.selectedPopularityRankYear;
    final PopularityRankOddsAverageModel? averageModel = appParamState.keepPopularityRankOddsAverageMap[selectedRank];
    final List<int> yearList = List<int>.generate(DateTime.now().year - 2022, (int i) => 2023 + i);

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
                const Text('過去オッズレコード', style: TextStyle(fontSize: 12)),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
                _buildTopPanel(context, selectedRank, selectedYear, averageModel),

                const SizedBox(height: 10),

                Row(
                  children: <Widget>[
                    Container(
                      width: 10,
                      margin: const EdgeInsets.only(right: 10, left: 10),
                      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.5)),
                      child: const Text(''),
                    ),
                    const Text('表示年'),
                  ],
                ),

                _buildYearSelector(selectedRank, selectedYear, yearList),
                Expanded(child: _buildHistoryList(averageModel)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _buildTopPanel(
    BuildContext context,
    int selectedRank,
    String selectedYear,
    PopularityRankOddsAverageModel? averageModel,
  ) {
    return Container(
      width: double.infinity,
      height: context.screenSize.height * 0.2,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 10,
                margin: const EdgeInsets.only(right: 10, left: 10),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.5)),
                child: const Text(''),
              ),
              const Text('人気度'),
            ],
          ),
          _buildRankSelector(selectedRank, selectedYear),
          Expanded(child: _buildAverageDisplay(averageModel)),
        ],
      ),
    );
  }

  ///
  Widget _buildRankSelector(int selectedRank, String selectedYear) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        // ignore: always_specify_types
        children: List.generate(18, (int index) {
          final int rank = index + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 7),
            child: GestureDetector(
              onTap: () => _onRankTap(rank, selectedYear),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: (selectedRank == rank)
                    ? Colors.green[500]!.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.8),
                child: Text(rank.toString(), style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ),
          );
        }),
      ),
    );
  }

  ///
  Widget _buildAverageDisplay(PopularityRankOddsAverageModel? model) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 5,
          left: 5,
          child: Text(model != null ? '${model.count}回の平均' : '', style: const TextStyle(color: Colors.grey)),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Text(
            model != null ? '${model.startDate} 〜 ${model.endDate}' : '',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Center(
          child: Text(
            model != null ? (double.tryParse(model.oddsAverage)?.toStringAsFixed(1) ?? model.oddsAverage) : '-----',
            style: const TextStyle(fontSize: 50, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  ///
  Widget _buildYearSelector(int selectedRank, String selectedYear, List<int> yearList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: yearList.map((int year) {
          return TextButton(
            onPressed: () => _onYearTap(year, selectedRank),
            child: Text(
              year.toString(),
              style: TextStyle(color: (selectedYear == year.toString()) ? Colors.greenAccent : Colors.grey),
            ),
          );
        }).toList(),
      ),
    );
  }

  ///
  Widget _dispUpDownIcon({required double tan, required double average}) {
    if (tan > average) {
      return Icon(Icons.arrow_upward, color: Colors.greenAccent.withValues(alpha: 0.5), size: 40);
    } else if (tan < average) {
      return Icon(Icons.arrow_downward, color: Colors.redAccent.withValues(alpha: 0.5), size: 40);
    } else {
      return Icon(Icons.remove, color: Colors.blueAccent.withValues(alpha: 0.5), size: 40);
    }
  }

  ///
  Widget _buildHistoryList(PopularityRankOddsAverageModel? averageModel) {
    return FutureBuilder<List<RaceResultHistoryModel>>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<List<RaceResultHistoryModel>> snapshot) {
        if (_future == null) {
          return const SizedBox.shrink();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('エラー: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 12)),
          );
        }

        final List<RaceResultHistoryModel> list = snapshot.data ?? <RaceResultHistoryModel>[];

        if (list.isEmpty) {
          return const Center(
            child: Text('データなし', style: TextStyle(color: Colors.white)),
          );
        }

        return DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 12),

          child: Container(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4)),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('件数: ${list.length}', style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),

                    Builder(
                      builder: (_) {
                        final List<double> tanValues = list
                            .map((RaceResultHistoryModel e) => double.tryParse(e.tan))
                            .whereType<double>()
                            .toList();
                        final double? yearlyAvg = tanValues.isEmpty
                            ? null
                            : tanValues.reduce((double a, double b) => a + b) / tanValues.length;
                        final String avgText = yearlyAvg == null ? '---' : yearlyAvg.toStringAsFixed(1);
                        final double? overallAvg = double.tryParse(averageModel?.oddsAverage ?? '');

                        return Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            if (yearlyAvg != null && overallAvg != null)
                              _dispUpDownIcon(tan: yearlyAvg, average: overallAvg),
                            Text('この年の平均: $avgText', style: const TextStyle(color: Colors.yellowAccent, fontSize: 11)),
                          ],
                        );
                      },
                    ),

                    Row(
                      children: <Widget>[
                        Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: (_) => _startRepeating(() => _scrollBy(-_moveAmount)),
                          onPointerUp: (_) => _stopRepeating(),
                          onPointerCancel: (_) => _stopRepeating(),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(child: Icon(Icons.arrow_upward, color: Colors.white70)),
                          ),
                        ),
                        Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: (_) => _startRepeating(() => _scrollBy(_moveAmount)),
                          onPointerUp: (_) => _stopRepeating(),
                          onPointerCancel: (_) => _stopRepeating(),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(child: Icon(Icons.arrow_downward, color: Colors.white70)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Builder(
                  builder: (BuildContext context) {
                    final Map<int, int> counts = <int, int>{};
                    for (final RaceResultHistoryModel e in list) {
                      if (e.finishingPosition <= 3) {
                        counts[e.finishingPosition] = (counts[e.finishingPosition] ?? 0) + 1;
                      }
                    }
                    const Map<int, Color> rankColors = <int, Color>{
                      1: Color(0xFFFFD700),
                      2: Color(0xFFC0C0C0),
                      3: Color(0xFFCD7F32),
                    };
                    final List<int> positions = <int>[1, 2, 3].where((int p) => counts.containsKey(p)).toList();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const SizedBox.shrink(),
                        Row(
                          children: positions
                              .map(
                                (int p) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Text(
                                    '$p着${counts[p].toString().toCurrency()}回',
                                    style: TextStyle(fontSize: 11, color: rankColors[p]),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    );
                  },
                ),

                Divider(color: Colors.white.withValues(alpha: 0.5)),

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: list.length,
                    itemBuilder: (BuildContext context, int index) {
                      final RaceResultHistoryModel item = list[index];
                      return Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: <Widget>[
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: Builder(
                                          builder: (_) {
                                            final double? tanVal = double.tryParse(item.tan);
                                            final double? avgVal = double.tryParse(averageModel?.oddsAverage ?? '');
                                            if (tanVal == null || avgVal == null) {
                                              return const Icon(Icons.circle_outlined, color: Colors.white24, size: 40);
                                            }
                                            return _dispUpDownIcon(tan: tanVal, average: avgVal);
                                          },
                                        ),
                                      ),

                                      Center(
                                        child: Text(
                                          double.tryParse(item.tan)?.toStringAsFixed(1) ?? item.tan,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                        right: 5,
                                        bottom: 5,
                                        child: Text(item.date, style: const TextStyle(color: Colors.grey)),
                                      ),

                                      if (item.finishingPosition <= 3) ...<Widget>[
                                        Positioned(
                                          top: (context.screenSize.height * 0.08) * -1,
                                          right: (context.screenSize.width * 0.08) * -1,

                                          child: CustomPaint(
                                            painter: RankBadgePainter(
                                              color: raceRankColor(item.finishingPosition, alpha: 0.3),
                                            ),
                                            child: SizedBox(
                                              width: context.screenSize.width * 0.2,
                                              height: context.screenSize.height * 0.15,
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(bottom: 30, left: 25),
                                                  child: Text(
                                                    '${item.finishingPosition}着',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white.withValues(alpha: 0.8),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                width: 30,
                                                alignment: Alignment.center,
                                                child: Text(item.num.toString()),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  item.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ),

                                          Row(
                                            children: <Widget>[
                                              const SizedBox(width: 30),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text('${item.kaisuu}回${item.basho}${item.day}日 R${item.race}'),

                                                    Text(item.raceName, maxLines: 1, overflow: TextOverflow.ellipsis),

                                                    Text(item.finishingPosition.toString()),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
