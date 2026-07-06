import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../models/race_model.dart';
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

      // API 2: payout results — races param = "date|kaisuu|basho|day" joined by "/"
      final String racesParam = popularityList
          .map((RacesPopularityRatioModel m) => '${m.date}|${m.kaisuu}|${m.basho}|${m.day}')
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

      if (mounted) {
        setState(() {
          _popularityList = popularityList;
          _payoutList = payoutList;
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
      return const Center(
        child: Text('エラーが発生しました', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
      );
    }

    if (_payoutList.isEmpty) {
      return const Center(
        child: Text('データがありません', style: TextStyle(color: Colors.white54, fontSize: 12)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
          ),
          child: Text(
            widget.raceModel.raceName,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
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

              return _buildRaceCard(payout: payout, popularity: popularity, matchPercent: matchPercent);
            },
          ),
        ),
      ],
    );
  }

  ///
  Widget _buildRaceCard({
    required RaceResultPayoutModel payout,
    RacesPopularityRatioModel? popularity,
    String matchPercent = '',
  }) {
    return Container(
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
          // ヘッダー
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${payout.date}　${payout.basho}　${payout.kaisuu}回${payout.day}日　${payout.race}R　${payout.raceName}${popularity != null ? "　${popularity.numHorses}頭立て" : ""}',
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 11),
                  ),
                ),
              ),
              if (matchPercent.isNotEmpty) ...<Widget>[
                const SizedBox(width: 8),
                Text(
                  '$matchPercent%',
                  style: const TextStyle(color: Colors.orange, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),

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

          // 人気比率
          if (popularity != null && popularity.popularityRatio.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 6),
            const Text('人気比率', style: TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: popularity.popularityRatio.split('|').asMap().entries.map((MapEntry<int, String> e) {
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text('${e.key + 1}人気', style: const TextStyle(color: Colors.white38, fontSize: 9)),
                        Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  ///
  Widget _buildPayoutRow(String label, String value) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 40,
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
