import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/race_model.dart';
import '../../models/race_result_history_model.dart';
import '../../models/race_result_payout_model.dart';
import '../../models/races_popularity_ratio_model.dart';

class SimilarRacesDisplayAlert extends ConsumerStatefulWidget {
  const SimilarRacesDisplayAlert({super.key, required this.raceModel});

  final RaceModel raceModel;

  @override
  ConsumerState<SimilarRacesDisplayAlert> createState() => _SimilarRacesDisplayAlertState();
}

class _SimilarRacesDisplayAlertState extends ConsumerState<SimilarRacesDisplayAlert> {
  bool _isLoading = false;

  List<RacesPopularityRatioModel> _popularityList = <RacesPopularityRatioModel>[];

  List<RaceResultPayoutModel> _payoutList = <RaceResultPayoutModel>[];

  List<List<RaceResultHistoryModel>> _historyByIndex = <List<RaceResultHistoryModel>>[];

  String? _error;

  ///
  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  ///
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final HttpClient client = ref.read(httpClientProvider);

      // API 1: popularity ratio by ids
      final dynamic resp1 = await client.get(
        path: APIPath.getHorseOddsFinderRacesPopularityRatio,
        queryParameters: <String, dynamic>{'ids': widget.raceModel.popularityRatioTableIds},
      );

      final List<RacesPopularityRatioModel> popularityList = <RacesPopularityRatioModel>[];

      // ignore: avoid_dynamic_calls
      for (final dynamic item in resp1['data'] as List<dynamic>) {
        popularityList.add(RacesPopularityRatioModel.fromJson(item as Map<String, dynamic>));
      }

      // API1のwhereInは入力順を保証しないため、popularityRatioTableIdsの順に並び替える
      final List<String> idOrder = widget.raceModel.popularityRatioTableIds.split('|');

      popularityList.sort(
        (RacesPopularityRatioModel a, RacesPopularityRatioModel b) =>
            idOrder.indexOf(a.id.toString()).compareTo(idOrder.indexOf(b.id.toString())),
      );

      // API 2: payout results — races param = "date|kaisuu|basho|race" joined by "/"
      // ※ dayではなくraceを渡す（PHP側: list($date,$kaisuu,$basho_code,$race)）
      final String racesParam = popularityList
          .map((RacesPopularityRatioModel m) => '${m.date}|${m.kaisuu}|${m.basho}|${m.race}')
          .join('/');

      final dynamic resp2 = await client.get(
        path: APIPath.getHorseOddsFinderRaceResultPayout,
        queryParameters: <String, dynamic>{'races': racesParam},
      );

      final List<RaceResultPayoutModel> payoutList = <RaceResultPayoutModel>[];

      // ignore: avoid_dynamic_calls
      for (final dynamic item in resp2['data'] as List<dynamic>) {
        payoutList.add(RaceResultPayoutModel.fromJson(item as Map<String, dynamic>));
      }

      // API 3: race result history — 1レースずつ並列で取得
      final List<List<RaceResultHistoryModel>> historyResults = await Future.wait(
        popularityList.map((RacesPopularityRatioModel m) async {
          final dynamic resp = await client.get(
            path: APIPath.getHorseOddsFinderRaceResultHistoryRaceContents,
            queryParameters: <String, dynamic>{
              'date': m.date,
              'kaisuu': m.kaisuu,
              'basho_code': m.basho,
              'day': m.day,
              'race': m.race.toString(),
            },
          );
          // ignore: avoid_dynamic_calls
          return (resp['data'] as List<dynamic>)
              .map((dynamic e) => RaceResultHistoryModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }),
      );

      if (mounted) {
        setState(() {
          _popularityList = popularityList;
          _payoutList = payoutList;
          _historyByIndex = historyResults;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white, fontSize: 12),
      child: _buildBody(),
    );
  }

  ///
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
        ),
      );
    }

    if (_payoutList.isEmpty) {
      return const Center(
        child: Text('データがありません', style: TextStyle(color: Colors.white, fontSize: 12)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const SizedBox.shrink(),

                    Text('${widget.raceModel.numHorses}頭立て', style: const TextStyle(color: Colors.white)),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: <Widget>[
                        Text(
                          '${widget.raceModel.date}　${widget.raceModel.bashoName}　${widget.raceModel.kaisuu}回${widget.raceModel.day}日',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),

                        Text(
                          '${widget.raceModel.race}R　${widget.raceModel.raceName}',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),

          Divider(color: Colors.white.withValues(alpha: 0.5), thickness: 5),

          Expanded(
            child: ListView.builder(
              itemCount: _payoutList.length,
              itemBuilder: (BuildContext context, int index) {
                final RaceResultPayoutModel payout = _payoutList[index];

                final RacesPopularityRatioModel? popularity = index < _popularityList.length
                    ? _popularityList[index]
                    : null;

                final List<String> percentParts = widget.raceModel.popularityRatioMatchPercent.split('|');

                final String matchPercent = index < percentParts.length ? percentParts[index] : '';

                final List<RaceResultHistoryModel> historyList = index < _historyByIndex.length
                    ? _historyByIndex[index]
                    : <RaceResultHistoryModel>[];

                return _buildRaceCard(
                  payout: payout,
                  popularity: popularity,
                  matchPercent: matchPercent,
                  historyList: historyList,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  ///
  Widget _buildRaceCard({
    required RaceResultPayoutModel payout,
    RacesPopularityRatioModel? popularity,
    String matchPercent = '',
    List<RaceResultHistoryModel> historyList = const <RaceResultHistoryModel>[],
  }) {
    return Stack(
      children: <Widget>[
        if (matchPercent.isNotEmpty) ...<Widget>[
          Positioned(
            top: 10,
            right: 10,
            child: Text(
              '$matchPercent%',
              style: TextStyle(color: Colors.orange.withValues(alpha: 0.4), fontSize: 60, fontWeight: FontWeight.bold),
            ),
          ),
        ],

        Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(6),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${payout.date}　${payout.kaisuu}回${payout.basho}${payout.day}日',
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 11),
                  ),

                  Text(
                    '${payout.race}R　${payout.raceName}',
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // 人気比率
              if (popularity != null && popularity.popularityRatio.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),

                const Divider(color: Colors.white, height: 1),

                const SizedBox(height: 6),
                ...() {
                  final List<String> ratios = popularity.popularityRatio.split('|');

                  final int totalHorses = popularity.numHorses > 0 ? popularity.numHorses : ratios.length + 1;

                  final Map<int, String> nameByRank = <int, String>{
                    for (final RaceResultHistoryModel h in historyList) h.popularityRank: h.name,
                  };

                  final Map<int, int> numByRank = <int, int>{
                    for (final RaceResultHistoryModel h in historyList) h.popularityRank: h.num,
                  };

                  final Map<int, String> tanByRank = <int, String>{
                    for (final RaceResultHistoryModel h in historyList) h.popularityRank: h.tan,
                  };

                  // 3連単「9-3-7|45000」から馬番→着順マップを作成
                  final Map<int, int> finishPosByNum = <int, int>{};
                  if (payout.trifecta.isNotEmpty) {
                    final List<String> parts = payout.trifecta.split('|').first.split('-');

                    for (int i = 0; i < parts.length && i < 3; i++) {
                      final int? n = int.tryParse(parts[i].trim());

                      if (n != null) {
                        finishPosByNum[n] = i + 1;
                      }
                    }
                  }
                  // 3連単がない場合は単勝「9|160」から1着だけ
                  if (finishPosByNum.isEmpty && payout.tan.isNotEmpty) {
                    final int? n = int.tryParse(payout.tan.split('|').first.trim());

                    if (n != null) {
                      finishPosByNum[n] = 1;
                    }
                  }
                  final List<Widget> widgets = <Widget>[];
                  for (int rank = 1; rank <= totalHorses; rank++) {
                    final String name = nameByRank[rank] ?? '';

                    final String tan = tanByRank[rank] ?? '';

                    final int? horseNum = numByRank[rank];

                    final int? finishPos = horseNum != null ? finishPosByNum[horseNum] : null;

                    final Color? numBgColor = switch (finishPos) {
                      1 => const Color(0xFFFFD700).withValues(alpha: 0.5),
                      2 => const Color(0xFFC0C0C0).withValues(alpha: 0.5),
                      3 => const Color(0xFFCD7F32).withValues(alpha: 0.5),
                      _ => null,
                    };

                    widgets.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 36,
                              child: Text('人気$rank', style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),

                            const SizedBox(width: 6),

                            if (horseNum != null) ...<Widget>[
                              Container(
                                width: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: numBgColor, borderRadius: BorderRadius.circular(3)),
                                child: Text(
                                  '$horseNum',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: numBgColor != null ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ] else ...[
                              const SizedBox(width: 26),
                            ],

                            Expanded(
                              child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),

                            if (tan.isNotEmpty) ...<Widget>[
                              const SizedBox(width: 4),

                              Text(
                                (double.tryParse(tan) ?? double.nan).isNaN ? tan : double.parse(tan).toStringAsFixed(1),
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                    if (rank < totalHorses && rank - 1 < ratios.length) {
                      final String rawRatio = ratios[rank - 1];

                      final double? ratioVal = double.tryParse(rawRatio);

                      final String ratioText = ratioVal != null ? ratioVal.toStringAsFixed(1) : rawRatio;

                      final Color ratioColor = (ratioVal != null && ratioVal >= 2.0)
                          ? const Color(0xFFFBB6CE)
                          : Colors.white.withValues(alpha: 0.5);

                      widgets.add(
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: ratioColor),
                            borderRadius: BorderRadius.circular(10),
                          ),

                          margin: const EdgeInsets.only(top: 5, right: 3, bottom: 5, left: 5),
                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                          child: Text(ratioText, style: TextStyle(color: ratioColor, fontSize: 10)),
                        ),
                      );
                    }
                  }
                  return widgets;
                }(),
              ],

              const SizedBox(height: 8),

              const Text('払い戻し', style: TextStyle(color: Colors.yellowAccent)),

              const SizedBox(height: 8),

              // 払い戻し
              _buildPayoutRow('単勝', payout.tan),
              _buildPayoutRow('複勝', payout.fuku),
              _buildPayoutRow('枠連', payout.waku),
              _buildPayoutRow('ワイド', payout.wide),
              _buildPayoutRow('馬連', payout.umaren),
              _buildPayoutRow('馬単', payout.umatan),
              _buildPayoutRow('3連複', payout.trio),
              _buildPayoutRow('3連単', payout.trifecta),
            ],
          ),
        ),
      ],
    );
  }

  ///
  Widget _buildPayoutRow(String label, String value) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(left: context.screenSize.width * 0.1),

      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 40,
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: value.split('/').map((String e) {
                final List<String> exE = e.split('|');

                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
                  ),

                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 100, child: Text(exE[0])),

                      Expanded(
                        child: Container(alignment: Alignment.centerRight, child: Text(exE[1].toCurrency())),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
