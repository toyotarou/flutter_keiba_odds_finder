import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/horse_model.dart';
import '../../models/odds_model.dart';
import '../../models/race_analysis_model.dart';
import '../../utility/functions.dart';

class TotalForecastDisplayAlert extends ConsumerStatefulWidget {
  const TotalForecastDisplayAlert({
    super.key,
    required this.displayList,
    required this.horseModelMap,
    required this.numToRankMap,
    required this.raceNumber,
  });

  final List<OddsModel> displayList;
  final Map<int, HorseModel> horseModelMap;
  final Map<int, int> numToRankMap;
  final int raceNumber;

  @override
  ConsumerState<TotalForecastDisplayAlert> createState() => _TotalForecastDisplayAlertState();
}

class _TotalForecastDisplayAlertState extends ConsumerState<TotalForecastDisplayAlert>
    with ControllersMixin<TotalForecastDisplayAlert> {
  bool _isLoading = true;
  Set<int> _highProbabilityPopularities = <int>{};
  Set<int> _aiPickupNums = <int>{};

  static const double _w0 = 40;
  static const double _w1 = 40;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAll());
  }

  Future<void> _fetchAll() async {
    await Future.wait(<Future<void>>[
      _fetchHighProbabilityHorses(),
      _fetchAiPickup(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchHighProbabilityHorses() async {
    final String date = appParamState.selectedScheduleDate;
    final int race = widget.raceNumber;
    final List<String> kbdParts = appParamState.selectedScheduleKaisuuBashoDay.split('_');
    final String kaisuu = kbdParts.isNotEmpty ? kbdParts[0] : '';
    final String basho = kbdParts.length > 1 ? kbdParts[1] : '';
    final String day = kbdParts.length > 2 ? kbdParts[2] : '';
    try {
      final dynamic response = await ref.read(httpClientProvider).get(
        path: APIPath.getHorseOddsFinderHighProbabilityHorses,
        queryParameters: <String, dynamic>{
          'date': date,
          'kaisuu': kaisuu,
          'basho': basho,
          'day': day,
          'race': race.toString(),
        },
      );
      final List<dynamic> dataList =
          (response as Map<String, dynamic>)['data'] as List<dynamic>? ?? <dynamic>[];
      final Set<int> popularities = <int>{};
      for (final dynamic item in dataList) {
        final RaceAnalysisModel model = RaceAnalysisModel.fromJson(item as Map<String, dynamic>);
        if (model.race == race && model.kaisuu == kaisuu && model.basho == basho && model.day == day) {
          for (final HorseOddsFinderSimilarRaceHorseModel horse in model.horses) {
            if (horse.analysis.isNotEmpty) {
              popularities.add(horse.popularityRank);
            }
          }
        }
      }
      _highProbabilityPopularities = popularities;
    } catch (e) {
      debugPrint('[TotalForecast] _fetchHighProbabilityHorses error: $e');
    }
  }

  Future<void> _fetchAiPickup() async {
    final String date = appParamState.selectedScheduleDate;
    final int race = widget.raceNumber;
    final List<String> kbdParts = appParamState.selectedScheduleKaisuuBashoDay.split('_');
    final String kaisuu = kbdParts.isNotEmpty ? kbdParts[0] : '';
    final String basho = kbdParts.length > 1 ? kbdParts[1] : '';
    final String day = kbdParts.length > 2 ? kbdParts[2] : '';
    try {
      final dynamic response = await ref.read(httpClientProvider).get(
        path: APIPath.getHorseOddsFinderAiAnalysis,
        queryParameters: <String, dynamic>{
          'date': date,
          'kaisuu': kaisuu,
          'basho': basho,
          'day': day,
          'race': race.toString(),
        },
      );
      final Map<String, dynamic> data =
          (response as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final String pickupRaw = (data['pickup_horse'] as String?) ?? '';
      Set<int> nums = <int>{};
      if (pickupRaw.isNotEmpty) {
        for (final String part in pickupRaw.split('/')) {
          final String trimmed = part.trim();
          if (trimmed.isEmpty) continue;
          final int? num = int.tryParse(trimmed.split('|').first.trim());
          if (num != null) nums.add(num);
        }
      } else {
        final String analysisText = (data['analysis_text'] as String?) ?? '';
        nums = _parsePickupFromAnalysis(analysisText);
      }
      _aiPickupNums = nums;
    } catch (e) {
      debugPrint('[TotalForecast] _fetchAiPickup error: $e');
    }
  }

  Set<int> _parsePickupFromAnalysis(String analysisText) {
    final int sec1Start = analysisText.indexOf('## 1.');
    final int sec2Start = analysisText.indexOf('## 2.');
    if (sec1Start == -1) return <int>{};
    final String section1 = sec2Start != -1
        ? analysisText.substring(sec1Start, sec2Start)
        : analysisText.substring(sec1Start);
    final RegExp numPattern = RegExp(r'（(\d+)番）');
    final Set<int> nums = <int>{};
    for (final RegExpMatch m in numPattern.allMatches(section1)) {
      final int? num = int.tryParse(m.group(1) ?? '');
      if (num != null) nums.add(num);
    }
    return nums;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.yellowAccent),
      );
    }

    double maxUpsetScore = 0;
    int maxRank = 0;
    for (int i = 0; i < widget.displayList.length; i++) {
      final int idx = i + 1;
      final OddsModel o = widget.displayList[i];
      final String? avg = appParamState.keepPopularityRankOddsAverageMap[idx]?.oddsAverage;
      if (avg != null) {
        final double oddsVal = o.odds.toDouble();
        if (oddsVal != 0) {
          final double score = avg.toDouble() / oddsVal;
          if (score > maxUpsetScore) {
            maxUpsetScore = score;
            maxRank = idx;
          }
        }
      }
    }

    final int cellCount = widget.displayList.length <= 8 ? 4 : 5;
    final int highlightStart = maxRank <= 5 ? maxRank : maxRank - cellCount + 1;
    final int highlightEnd = maxRank <= 5 ? maxRank + cellCount - 1 : maxRank;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(5),

      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),

      child: Column(
        children: <Widget>[
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              border: const Border(bottom: BorderSide(color: Colors.white38)),
            ),
            child: const Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'オッズ',
                    style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '期待数値',
                    style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'AI',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    '過去',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Records
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.displayList.length,
              itemBuilder: (BuildContext context, int index) {
                final OddsModel item = widget.displayList[index];
                final int popularity = index + 1;
                final String horseName = widget.horseModelMap[item.num]?.name ?? '';
                final int? rank = widget.numToRankMap[item.num];
                final bool isAiPickup = _aiPickupNums.contains(item.num);
                final bool hasAnalysis = _highProbabilityPopularities.contains(popularity);

                String upsetScore = '';
                double upsetScoreVal = 0;
                final String? avg = appParamState.keepPopularityRankOddsAverageMap[popularity]?.oddsAverage;
                if (avg != null) {
                  final double oddsVal = item.odds.toDouble();
                  if (oddsVal != 0) {
                    upsetScoreVal = avg.toDouble() / oddsVal;
                    upsetScore = upsetScoreVal.toStringAsFixed(2);
                  }
                }
                final bool isInHighlight = maxRank > 0 && popularity >= highlightStart && popularity <= highlightEnd;

                return Stack(
                  children: <Widget>[
                    if (rank != null) ...<Widget>[
                      Positioned(
                        top: 5,
                        right: 5,

                        child: Container(
                          width: 32,
                          height: 18,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: raceRankColor(rank), borderRadius: BorderRadius.circular(3)),
                          child: Text(
                            '$rank着',
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Row 1: 人気・馬番・馬名（馬名は残り幅すべてをスパン）
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: _w0,
                                child: Text('$popularity', style: const TextStyle(fontSize: 11, color: Colors.white)),
                              ),
                              SizedBox(
                                width: _w1,
                                child: Text('${item.num}番', style: const TextStyle(fontSize: 11, color: Colors.white)),
                              ),
                              Expanded(
                                child: Text(
                                  horseName,
                                  style: const TextStyle(fontSize: 13, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Row 2: オッズ・upset・AI・合致
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  item.odds,
                                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  upsetScore,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isInHighlight ? Colors.yellowAccent : Colors.white,
                                    fontWeight: isInHighlight ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),

                              Expanded(
                                child: isAiPickup
                                    ? Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 3),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFFFFD700)),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: const Text(
                                            'AI',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Color(0xFFFFD700),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              Expanded(
                                child: hasAnalysis
                                    ? Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.yellowAccent.withValues(alpha: 0.7)),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: const Text(
                                            '過去',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.yellowAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),

                        Divider(color: Colors.white.withValues(alpha: 0.5)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
