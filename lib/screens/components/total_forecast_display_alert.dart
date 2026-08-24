import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';

import '../../models/common/ai_response_recommend_horse_model.dart';
import '../../models/horse_model.dart';
import '../../models/odds_model.dart';
import '../../models/popularity_rank_odds_median_model.dart';
import '../../models/race_model.dart';

import '../../utility/functions.dart';
import '../parts/dashed_line_painter.dart';

class TotalForecastDisplayAlert extends ConsumerStatefulWidget {
  const TotalForecastDisplayAlert({
    super.key,
    required this.displayList,
    required this.horseModelMap,
    required this.numToRankMap,
    required this.currentRaceModel,
    this.pickupHorse = '',
    required this.gapHorseNums,
    required this.upsetPickupHorseNums,
  });

  /// 6分前オッズのリスト（オッズ昇順ソート済み）。
  final List<OddsModel> displayList;
  final Map<int, HorseModel> horseModelMap;
  final Map<int, int> numToRankMap;
  final RaceModel currentRaceModel;
  final String pickupHorse;
  final List<int> gapHorseNums;
  final List<int> upsetPickupHorseNums;

  @override
  ConsumerState<TotalForecastDisplayAlert> createState() => _TotalForecastDisplayAlertState();
}

class _TotalForecastDisplayAlertState extends ConsumerState<TotalForecastDisplayAlert>
    with ControllersMixin<TotalForecastDisplayAlert> {
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();
  Timer? _repeatTimer;
  static const double _moveAmount = 18;
  static const int _tickMs = 16;
  Set<int> _highProbabilityPopularities = <int>{};
  Set<int> _aiPickupNums = <int>{};
  Map<int, String> _aiPickupScores = <int, String>{};
  Map<int, double?> _aiPickupIndexes = <int, double?>{};
  int? _upsetRaceValue;
  Set<int> _secondAiNums = <int>{};
  Map<int, String> _secondAiScores = <int, String>{};

  static const double _w0 = 60;
  static const double _w1 = 40;

  static Widget get _dashedDivider => SizedBox(
    width: double.infinity,
    height: 5,
    child: CustomPaint(
      painter: DashedLinePainter(
        color: Colors.white.withValues(alpha: 0.8),
        strokeWidth: 1,
        dashWidth: 1,
        dashSpace: 10,
      ),
    ),
  );

  /// selectedScheduleKaisuuBashoDay を分解する省略記法。
  /// 内部実装は functions.dart の parseKbdParts に委譲する。
  ({String kaisuu, String basho, String day}) get _kbdParts {
    return parseKbdParts(appParamState.selectedScheduleKaisuuBashoDay);
  }

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAll());
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
    final double newOffset = (_scrollController.offset + delta).clamp(0.0, pos.maxScrollExtent);
    _scrollController.jumpTo(newOffset);
  }

  ///
  Set<int> get _supplementNums {
    return _secondAiNums.difference(_aiPickupNums);
  }

  Future<void> _fetchAll() async {
    await Future.wait(<Future<void>>[
      _fetchHighProbabilityHorses(),
      _fetchAiPickup(),
      _fetchSecondAiPickup(),
      _fetchBaganrikiIndex(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  ///
  Future<void> _fetchHighProbabilityHorses() async {
    final String date = appParamState.selectedScheduleDate;
    final int race = widget.currentRaceModel.race;
    final (:String kaisuu, :String basho, :String day) = _kbdParts;
    try {
      final Map<int, String> result = await fetchHighProbabilityAnalysis(
        ref,
        date: date,
        kaisuu: kaisuu,
        basho: basho,
        day: day,
        race: race,
      );
      // analysis がある人気順位のみ Set に変換して保持する
      _highProbabilityPopularities = result.keys.toSet();
    } catch (e) {
      debugPrint('[TotalForecast] _fetchHighProbabilityHorses error: $e');
    }
  }

  ///
  Future<void> _fetchAiPickup() async {
    final String date = appParamState.selectedScheduleDate;
    final int race = widget.currentRaceModel.race;
    final (:String kaisuu, :String basho, :String day) = _kbdParts;
    try {
      final Map<String, dynamic> data = await fetchAiAnalysisData(
        ref,
        date: date,
        kaisuu: kaisuu,
        basho: basho,
        day: day,
        race: race,
        gapHorseNums: widget.gapHorseNums,
        upsetPickupHorseNums: widget.upsetPickupHorseNums,
      );
      final String analysisText = (data['analysis_text'] as String?) ?? '';
      final List<AiResponseRecommendHorseModel> horses = parseAnalysisText(analysisText);
      _aiPickupNums = horses.map((AiResponseRecommendHorseModel h) => h.num).toSet();
      _aiPickupScores = <int, String>{for (final AiResponseRecommendHorseModel h in horses) h.num: h.score.toString()};
      _upsetRaceValue = parseUpsetRaceValue(analysisText);
    } catch (e) {
      debugPrint('[TotalForecast] _fetchAiPickup error: $e');
    }
  }

  ///
  Future<void> _fetchBaganrikiIndex() async {
    final String date = appParamState.selectedScheduleDate;
    final int race = widget.currentRaceModel.race;
    final (:String kaisuu, :String basho, :String day) = _kbdParts;
    try {
      final Map<int, double?> result = await fetchBaganrikiIndexData(
        ref,
        date: date,
        kaisuu: kaisuu,
        basho: basho,
        day: day,
        race: race,
      );
      if (mounted) {
        setState(() {
          _aiPickupIndexes = result;
        });
      }
    } catch (e) {
      debugPrint('[TotalForecast] _fetchBaganrikiIndex error: $e');
    }
  }

  ///
  Future<void> _fetchSecondAiPickup() async {
    final String date = appParamState.selectedScheduleDate;
    final int race = widget.currentRaceModel.race;
    final (:String kaisuu, :String basho, :String day) = _kbdParts;
    try {
      final Map<String, dynamic> data = await fetchSecondAiOpinionData(
        ref,
        date: date,
        kaisuu: kaisuu,
        basho: basho,
        day: day,
        race: race,
      );
      final String analysisText = (data['analysis_text'] as String?) ?? '';
      final List<AiResponseRecommendHorseModel> horses = parseAnalysisText(analysisText);
      _secondAiNums = horses.map((AiResponseRecommendHorseModel h) => h.num).toSet();
      _secondAiScores = <int, String>{for (final AiResponseRecommendHorseModel h in horses) h.num: h.score.toString()};
    } catch (e) {
      debugPrint('[TotalForecast] _fetchSecondAiPickup error: $e');
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.yellowAccent));
    }

    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';
    final PopularityRankOddsMedianModel? medianModel = () {
      final List<PopularityRankOddsMedianModel> list =
          appParamState.keepPopularityRankOddsMedianMap[mapKey] ?? <PopularityRankOddsMedianModel>[];
      final List<PopularityRankOddsMedianModel> filtered = list
          .where((PopularityRankOddsMedianModel e) => e.race == widget.currentRaceModel.race)
          .toList();
      return filtered.isNotEmpty ? filtered.first : null;
    }();

    final int pickupCount = widget.displayList.length <= 8
        ? 4
        : widget.displayList.length <= 13
        ? 5
        : 6;

    final Set<int> pickupPopularitySet = medianModel != null
        ? calcPickupPopularitySet(widget.displayList, medianModel, pickupCount)
        : <int>{};

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildHeader(),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: DefaultTextStyle(
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text('R${widget.currentRaceModel.race}'),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.currentRaceModel.raceName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          Text('${widget.currentRaceModel.course} ${widget.currentRaceModel.dist}m'),
                        ],
                      ),
                    ),
                  ),
                ),

                Row(
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) => _startRepeating(() => _scrollBy(_moveAmount)),
                      onTapUp: (_) => _stopRepeating(),
                      onTapCancel: _stopRepeating,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(child: Icon(Icons.arrow_downward, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) => _startRepeating(() => _scrollBy(-_moveAmount)),
                      onTapUp: (_) => _stopRepeating(),
                      onTapCancel: _stopRepeating,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(child: Icon(Icons.arrow_upward, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(color: Colors.white.withValues(alpha: 0.5), thickness: 5),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
                    child: DefaultTextStyle(
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                      child: Column(
                        children: <Widget>[
                          _buildColumnHeader(),
                          Divider(color: Colors.white.withValues(alpha: 0.5), thickness: 2),
                          if (_upsetRaceValue != null) ...<Widget>[
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  if (_upsetRaceValue == 0) Container(width: 20, height: 1, color: Colors.white),
                                  Text(
                                    '厳選穴レース',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _upsetRaceValue == 1
                                          ? const Color(0xFFFBB6CE)
                                          : Colors.white.withValues(alpha: 0.4),
                                      decoration: _upsetRaceValue == 0
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      decorationColor: Colors.white,
                                    ),
                                  ),
                                  if (_upsetRaceValue == 0) Container(width: 20, height: 1, color: Colors.white),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: widget.displayList.length,
                              itemBuilder: (BuildContext context, int index) => _buildHorseItem(
                                index: index,
                                medianModel: medianModel,
                                pickupPopularitySet: pickupPopularitySet,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 50,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('6分前オッズを使用', style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 12, color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(appParamState.selectedScheduleDate),
            Text(appParamState.selectedScheduleKaisuuBashoDayName),
          ],
        ),
      ),
    );
  }

  ///
  Widget _buildColumnHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
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
                  'AI判定',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  '過去合致',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          Text('オッズ表示、期待数値の計算には発走6分前のオッズを使用しています。', style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
        ],
      ),
    );
  }

  ///
  Widget _buildHorseItem({
    required int index,
    required PopularityRankOddsMedianModel? medianModel,
    required Set<int> pickupPopularitySet,
  }) {
    final OddsModel item = widget.displayList[index];
    final int popularity = index + 1;
    final String horseName = widget.horseModelMap[item.num]?.name ?? '';
    final int? rank = widget.numToRankMap[item.num];
    final bool isAiPickup = _aiPickupNums.contains(item.num);
    final bool isSupplementary = !isAiPickup && _supplementNums.contains(item.num);
    final bool hasAnalysis = _highProbabilityPopularities.contains(popularity);
    final bool isInHighlight = pickupPopularitySet.contains(popularity);

    String upsetScore = '';
    if (medianModel != null) {
      final double medianDouble = double.tryParse(medianByRank(medianModel, popularity)) ?? 0;
      final double oddsVal = double.tryParse(item.odds) ?? 0;
      if (medianDouble > 0 && oddsVal > 0) {
        upsetScore = (medianDouble / oddsVal).toStringAsFixed(2);
      }
    }

    String faultRatio = '';
    if (index + 1 < widget.displayList.length) {
      final double currentOdds = double.tryParse(item.odds) ?? 0;
      final double nextOdds = double.tryParse(widget.displayList[index + 1].odds) ?? 0;
      if (currentOdds != 0) {
        faultRatio = (nextOdds / currentOdds).toStringAsFixed(2);
      }
    }

    final String jockeyName = widget.horseModelMap[item.num]?.jockey ?? '';

    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _dashedDivider,

        Container(
          decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2)),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),

          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  if (_aiPickupIndexes[item.num] != null) ...<Widget>[
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Stack(
                        children: <Widget>[
                          Text('馬眼力指数', style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: 0.6))),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Transform(
                              alignment: Alignment.centerLeft,
                              transform: Matrix4.identity()..setEntry(0, 1, -0.8),
                              child: Text(
                                _aiPickupIndexes[item.num].toString(),
                                style: TextStyle(fontSize: 20, color: Colors.white.withValues(alpha: 0.6)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: _w0,
                          child: Text('$popularity番人気', style: const TextStyle(fontSize: 11, color: Colors.white)),
                        ),
                        SizedBox(
                          width: _w1,
                          child: Text('${item.num}番', style: const TextStyle(fontSize: 11, color: Colors.white)),
                        ),
                        Expanded(
                          child: Text(
                            horseName,
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 6),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),

                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,

                        child: Text(item.odds, style: const TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isInHighlight
                              ? Colors.yellowAccent.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.1),

                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          upsetScore.isEmpty ? '-' : upsetScore,
                          style: TextStyle(
                            fontSize: 12,
                            color: isInHighlight ? Colors.yellowAccent : Colors.white,
                            fontWeight: isInHighlight ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: isAiPickup
                          ? _buildAiBadge(item.num)
                          : isSupplementary
                          ? _buildSupplementBadge(item.num)
                          : const SizedBox.shrink(),
                    ),
                    Expanded(child: hasAnalysis ? _buildPastBadge() : const SizedBox.shrink()),
                  ],
                ),
              ),

              if (appParamState.keepJockeyScoreMap[jockeyName] != null) ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text('ジョッキー名: $jockeyName', style: const TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        _dashedDivider,

        if (faultRatio.isNotEmpty) ...<Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Builder(
              builder: (BuildContext context) {
                final bool isLarge = (double.tryParse(faultRatio) ?? 0) > 2.0;
                return Text(
                  '$faultRatio（オッズ断層）',
                  style: TextStyle(
                    fontSize: 11,
                    color: isLarge ? const Color(0xFFFBB6CE) : Colors.grey,
                    fontWeight: isLarge ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );

    if (rank == null) {
      return column;
    }

    return Stack(
      children: <Widget>[
        column,
        Positioned(
          bottom: 45,
          left: 5,
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
    );
  }

  ///
  Widget _buildAiBadge(int horseNum) {
    return Center(
      child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 5, right: 15, left: 5, bottom: 5),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFFD700)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Text(
              'AI',
              style: TextStyle(fontSize: 9, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
            ),
          ),
          if (_aiPickupScores[horseNum] != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Text(
                '${_aiPickupScores[horseNum]} %',
                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  ///
  Widget _buildSupplementBadge(int horseNum) {
    return Center(
      child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 5, right: 15, left: 5, bottom: 5),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.15),
              border: Border.all(color: Colors.greenAccent),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '補欠',
              style: TextStyle(fontSize: 9, color: Colors.greenAccent, fontWeight: FontWeight.bold),
            ),
          ),
          if (_secondAiScores[horseNum] != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Text(
                '${_secondAiScores[horseNum]} %',
                style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  ///
  Widget _buildPastBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellowAccent.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Text(
          '過去',
          style: TextStyle(fontSize: 9, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
