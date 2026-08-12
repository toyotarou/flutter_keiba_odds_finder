import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../models/common/ai_response_recommend_horse_model.dart';
import '../../models/horse_model.dart';
import '../../models/race_introspection_model.dart';
import '../../models/race_result_payout_model.dart';
import '../../utility/functions.dart';

class AiAnalysisPayoutResultAlert extends ConsumerStatefulWidget {
  const AiAnalysisPayoutResultAlert({super.key, required this.aiRecommendHorses, required this.raceNumber});

  final List<AiResponseRecommendHorseModel> aiRecommendHorses;
  final int raceNumber;

  @override
  ConsumerState<AiAnalysisPayoutResultAlert> createState() => _AiAnalysisPayoutResultAlertState();
}

class _AiAnalysisPayoutResultAlertState extends ConsumerState<AiAnalysisPayoutResultAlert>
    with ControllersMixin<AiAnalysisPayoutResultAlert> {
  final Map<String, RaceResultPayoutModel> _payoutMap = <String, RaceResultPayoutModel>{};
  final Map<int, int?> _finishingPositionMap = <int, int?>{};

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPayout();
      _fetchBattleRecords();
    });
  }

  ///
  Future<void> _fetchPayout() async {
    final String date = appParamState.selectedScheduleDate;
    final (:String kaisuu, :String basho, day: _) = parseKbdParts(appParamState.selectedScheduleKaisuuBashoDay);
    if (kaisuu.isEmpty || basho.isEmpty) {
      return;
    }

    try {
      final Map<String, RaceResultPayoutModel> result = await fetchPayoutMap(
        ref,
        racesParam: '$date|$kaisuu|$basho|${widget.raceNumber}',
      );
      if (mounted) {
        setState(() => _payoutMap.addAll(result));
      }
    } catch (_) {}
  }

  ///
  Future<void> _fetchBattleRecords() async {
    final String date = appParamState.selectedScheduleDate;
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';
    final List<HorseModel> horses = (appParamState.keepHorseMap[mapKey] ?? <HorseModel>[])
        .where((HorseModel e) => e.race == widget.raceNumber)
        .toList();

    if (horses.isEmpty) {
      return;
    }

    try {
      final Map<int, int?> result = await fetchFinishingPositionMap(ref, horses: horses, date: date);
      if (mounted) {
        setState(() => _finishingPositionMap.addAll(result));
      }
    } catch (_) {}
  }

  ///
  @override
  Widget build(BuildContext context) {
    final (:String kaisuu, :String basho, day: String dayStr) = parseKbdParts(
      appParamState.selectedScheduleKaisuuBashoDay,
    );
    final int kaisuuInt = int.tryParse(kaisuu) ?? 0;
    final int day = int.tryParse(dayStr) ?? 0;
    final String lookupKey = '${appParamState.selectedScheduleDate}_${kaisuuInt}_${basho}_${day}_${widget.raceNumber}';
    final RaceResultPayoutModel? payout = _payoutMap[lookupKey];
    final RaceIntrospectionModel? introspectionModel = findRaceIntrospection(
      raceIntrospectionState.raceIntrospectionMap,
      date: appParamState.selectedScheduleDate,
      kaisuu: kaisuuInt,
      basho: basho,
      day: day,
      race: widget.raceNumber,
    );

    final String? resultText = introspectionModel != null ? extractResultLine(introspectionModel.introspection) : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('合致結果', style: TextStyle(fontSize: 12)),

                        if (resultText != null) ...<Widget>[
                          Text(resultText, style: const TextStyle(fontSize: 11, color: Colors.yellowAccent)),
                        ],
                      ],
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _buildHorseList(payout),
                ),

                if (resultText != null && resultText.contains('2頭が合致')) ...<Widget>[
                  if (widget.aiRecommendHorses.length >= 2) ...<Widget>[
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _buildTwoCombinations(payout),
                    ),
                  ],
                ],

                if (resultText != null && resultText.contains('3頭が合致')) ...<Widget>[
                  if (widget.aiRecommendHorses.length >= 3) ...<Widget>[
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _buildThreeCombinations(payout),
                    ),
                  ],
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Set<String> _parseCombos(String raw) {
    if (raw.isEmpty) {
      return <String>{};
    }
    return raw.split('/').map((String e) => e.split('|').first.trim()).toSet();
  }

  ///
  bool _matchesUnordered(Set<String> combos, String a, String b) {
    return combos.contains('$a-$b') || combos.contains('$b-$a');
  }

  ///
  bool _matchesOrdered(Set<String> combos, String a, String b) {
    return combos.contains('$a-$b');
  }

  ///
  bool _matchesUnordered3(Set<String> combos, String a, String b, String c) {
    final List<String> sorted = <String>[a, b, c]..sort();
    return combos.any((String combo) {
      final List<String> parts = combo.split('-');
      if (parts.length != 3) {
        return false;
      }
      return (parts..sort()).join('-') == sorted.join('-');
    });
  }

  ///
  bool _matchesOrdered3(Set<String> combos, String a, String b, String c) {
    return combos.contains('$a-$b-$c');
  }

  ///
  Set<int> _parseSingleHorseNums(String raw) {
    if (raw.isEmpty) {
      return <int>{};
    }
    return raw.split('/').map((String e) => int.tryParse(e.split('|').first.trim())).whereType<int>().toSet();
  }

  ///
  String _payoutText(String raw) {
    if (raw.isEmpty) {
      return '-';
    }
    return raw
        .split('/')
        .map((String e) {
          final List<String> parts = e.split('|');
          if (parts.length < 2) {
            return parts[0];
          }
          return '${parts[0]}  ¥${parts[1].toCurrency()}';
        })
        .join('   ');
  }

  ///
  Widget _buildHorseList(RaceResultPayoutModel? payout) {
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';
    final Map<int, HorseModel> horseMap = Map<int, HorseModel>.fromEntries(
      (appParamState.keepHorseMap[mapKey] ?? <HorseModel>[])
          .where((HorseModel e) => e.race == widget.raceNumber)
          .map((HorseModel e) => MapEntry<int, HorseModel>(e.num, e)),
    );
    final Set<int> tanNums = _parseSingleHorseNums(payout?.tan ?? '');
    final Set<int> fukuNums = _parseSingleHorseNums(payout?.fuku ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (payout != null) ...<Widget>[
          Text('1頭: ${widget.aiRecommendHorses.length}通り', style: const TextStyle(fontSize: 11, color: Colors.white)),
          const SizedBox(height: 4),

          Text('単勝  ${_payoutText(payout.tan)}', style: const TextStyle(fontSize: 11, color: Colors.amber)),
          Text('複勝  ${_payoutText(payout.fuku)}', style: const TextStyle(fontSize: 11, color: Colors.lightBlue)),
          const SizedBox(height: 6),
        ],
        ...widget.aiRecommendHorses.map((AiResponseRecommendHorseModel h) {
          final String name = horseMap[h.num]?.name ?? '';
          final bool hasTan = tanNums.contains(h.num);
          final bool hasFuku = fukuNums.contains(h.num);
          final int? rank = _finishingPositionMap[h.num];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
              ),

              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Row(
                      children: <Widget>[
                        if (hasTan)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('単勝', style: TextStyle(fontSize: 10, color: Colors.black)),
                          ),
                        if (hasFuku)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('複勝', style: TextStyle(fontSize: 10, color: Colors.black)),
                          ),
                      ],
                    ),
                  ),

                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 36,
                        child: Column(
                          children: <Widget>[
                            Text('${h.num}番', style: const TextStyle(fontSize: 11, color: Colors.white)),

                            if (rank != null && rank <= 3) ...<Widget>[
                              Container(
                                width: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: raceRankColor(rank, fallback: Colors.grey.withValues(alpha: 0.3)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  rank.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(child: Text(name, style: const TextStyle(fontSize: 11))),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  ///
  Widget _buildTwoCombinations(RaceResultPayoutModel? payout) {
    final Set<String> wideCombos = _parseCombos(payout?.wide ?? '');
    final Set<String> umarenCombos = _parseCombos(payout?.umaren ?? '');
    final Set<String> umatanCombos = _parseCombos(payout?.umatan ?? '');

    final List<String> combos = <String>[];
    for (int i = 0; i < widget.aiRecommendHorses.length; i++) {
      for (int j = 0; j < widget.aiRecommendHorses.length; j++) {
        if (j == i) {
          continue;
        }
        combos.add('${widget.aiRecommendHorses[i].num}-${widget.aiRecommendHorses[j].num}');
      }
    }

    return SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Builder(
            builder: (BuildContext context) {
              final int n = widget.aiRecommendHorses.length;
              final int two = n * (n - 1);
              return Text('2頭: $two通り', style: const TextStyle(fontSize: 11, color: Colors.white));
            },
          ),

          const SizedBox(height: 10),

          Text(
            '馬連  ${_payoutText(payout?.umaren ?? '')}',
            style: const TextStyle(fontSize: 11, color: Colors.greenAccent),
          ),
          Text(
            '馬単  ${_payoutText(payout?.umatan ?? '')}',
            style: const TextStyle(fontSize: 11, color: Colors.orangeAccent),
          ),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('ワイド', style: TextStyle(fontSize: 11, color: Colors.lightBlueAccent)),
              SizedBox.shrink(),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox.shrink(),
              Expanded(
                child: Text(
                  _payoutText(payout?.wide ?? ''),
                  style: const TextStyle(fontSize: 11, color: Colors.lightBlueAccent),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: combos.map((String combo) {
                  final List<String> parts = combo.split('-');
                  final String a = parts[0];
                  final String b = parts[1];

                  // 希少性が高い順に上書き: 馬単 > 馬連 > ワイド
                  Color borderColor = Colors.white.withValues(alpha: 0.4);
                  if (_matchesUnordered(wideCombos, a, b)) {
                    borderColor = Colors.lightBlueAccent;
                  }
                  if (_matchesUnordered(umarenCombos, a, b)) {
                    borderColor = Colors.greenAccent;
                  }
                  if (_matchesOrdered(umatanCombos, a, b)) {
                    borderColor = Colors.orangeAccent;
                  }

                  return Container(
                    width: context.screenSize.width / 8,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(combo, style: const TextStyle(fontSize: 12, color: Colors.white)),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///
  Widget _buildThreeCombinations(RaceResultPayoutModel? payout) {
    final Set<String> trioCombos = _parseCombos(payout?.trio ?? '');
    final Set<String> trifectaCombos = _parseCombos(payout?.trifecta ?? '');

    final List<String> combos = <String>[];
    for (int i = 0; i < widget.aiRecommendHorses.length; i++) {
      for (int j = 0; j < widget.aiRecommendHorses.length; j++) {
        if (j == i) {
          continue;
        }
        for (int k = 0; k < widget.aiRecommendHorses.length; k++) {
          if (k == i || k == j) {
            continue;
          }
          combos.add(
            '${widget.aiRecommendHorses[i].num}-${widget.aiRecommendHorses[j].num}-${widget.aiRecommendHorses[k].num}',
          );
        }
      }
    }

    return SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Builder(
            builder: (BuildContext context) {
              final int n = widget.aiRecommendHorses.length;

              final int three = n * (n - 1) * (n - 2);
              return Text('3頭: $three通り', style: const TextStyle(fontSize: 11, color: Colors.white));
            },
          ),

          const SizedBox(height: 10),

          Text(
            '三連複  ${_payoutText(payout?.trio ?? '')}',
            style: const TextStyle(fontSize: 11, color: Colors.greenAccent),
          ),
          Text(
            '三連単  ${_payoutText(payout?.trifecta ?? '')}',
            style: const TextStyle(fontSize: 11, color: Colors.orangeAccent),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: combos.map((String combo) {
                  final List<String> parts = combo.split('-');
                  final String a = parts[0];
                  final String b = parts[1];
                  final String c = parts[2];

                  // 希少性が高い順に上書き: 三連単 > 三連複
                  Color borderColor = Colors.white.withValues(alpha: 0.4);
                  if (_matchesUnordered3(trioCombos, a, b, c)) {
                    borderColor = Colors.greenAccent;
                  }
                  if (_matchesOrdered3(trifectaCombos, a, b, c)) {
                    borderColor = Colors.orangeAccent;
                  }

                  return Container(
                    width: context.screenSize.width / 8,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(combo, style: const TextStyle(fontSize: 12, color: Colors.white)),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
