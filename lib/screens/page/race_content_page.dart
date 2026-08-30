import 'dart:async';

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const/const.dart';
import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../models/horse_model.dart';
import '../../models/odds_model.dart';
import '../../models/popularity_rank_odds_median_model.dart';
import '../../models/race_model.dart';
import '../../models/race_result_model.dart';
import '../../utility/functions.dart';
import '../../utility/utility.dart';
import '../components/ai_analysis_display_alert.dart';
import '../components/horse_detail_display_alert.dart';
import '../components/horse_odds_ranking_display_alert.dart';
import '../components/similar_races_display_alert.dart';

import '../components/total_forecast_display_alert.dart';
import '../parts/dashed_line_painter.dart';
import '../parts/odds_finder_dialog.dart';
import '../parts/odds_up_down_icon.dart';
import '../parts/race_top_three_widget.dart';
import '../parts/rank_badge_painter.dart';
import '../parts/side_tab_panel.dart';
import '../parts/widget_display_overlay.dart';

class RaceContentPage extends ConsumerStatefulWidget {
  const RaceContentPage({
    super.key,
    required this.raceNumber,
    required this.mapKey,
    required this.raceMap,
    required this.oddsMap,
    required this.horseMap,
    required this.oddsGetTiming,
    required this.oddsDropRateHonmei,
    required this.oddsDropRateChuana,
    required this.oddsDropRateDaiana,
    required this.raceResultMap,
  });

  final int raceNumber;
  final String mapKey;
  final Map<String, List<RaceModel>> raceMap;
  final Map<String, List<OddsModel>> oddsMap;
  final Map<String, List<HorseModel>> horseMap;
  final String oddsGetTiming;
  final String oddsDropRateHonmei;
  final String oddsDropRateChuana;
  final String oddsDropRateDaiana;
  final Map<String, List<RaceResultModel>> raceResultMap;

  @override
  ConsumerState<RaceContentPage> createState() => _RaceContentPageState();
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(0, size.height)
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _RaceContentPageState extends ConsumerState<RaceContentPage> with ControllersMixin<RaceContentPage> {
  final AutoScrollController _horseListScrollController = AutoScrollController();
  int _currentHorseIndex = 0;
  int _displayListLength = 0;

  Timer? _countdownTimer;
  final ValueNotifier<int> _remainingSecondsNotifier = ValueNotifier<int>(0);
  String _lastStartTime = '';

  final Utility _utility = Utility();
  final GlobalKey _harandoKey = GlobalKey();
  final GlobalKey _analysisButtonKey = GlobalKey();
  Map<int, String> _analysisMap = <int, String>{};
  Set<int> _aiPickupNums = <int>{};
  Map<int, String> _aiPickupScores = <int, String>{};
  String _aiPickupHorse = '';
  Map<int, double?> _baganrikiIndexMap = <int, double?>{};

  // 初回訪問時にmedianなし&期待数値タブ選択状態でパネルを自動クローズしたかどうか
  bool _autoClosedPanel = false;

  Map<int, int> get _numToRankMap =>
      _utility.buildNumToRankMap(widget.raceResultMap[widget.mapKey] ?? <RaceResultModel>[], widget.raceNumber);

  ///
  List<OddsModel> get _oddsForRace =>
      (widget.oddsMap[widget.mapKey] ?? <OddsModel>[]).where((OddsModel e) => e.race == widget.raceNumber).toList();

  ///
  Map<int, HorseModel> get _horseModelMap => <int, HorseModel>{
    for (final HorseModel e in (widget.horseMap[widget.mapKey] ?? <HorseModel>[]).where(
      (HorseModel e) => e.race == widget.raceNumber,
    ))
      e.num: e,
  };

  ///
  List<String> get _configTimingParts => appParamState.configOddsGetTiming.split('|');

  ///
  String get _configFirstKey {
    final List<String> p = _configTimingParts;
    return p.isNotEmpty ? p.first : '';
  }

  ///
  String get _configLastKey {
    final List<String> p = _configTimingParts;
    return p.isNotEmpty ? p.last : '';
  }

  ///
  String get _minTiming {
    return _resolveMinTiming(_oddsForRace, _configFirstKey, _configLastKey);
  }

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchAiPickup();
        _fetchBaganrikiIndex();
      }
    });
  }

  ///
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _remainingSecondsNotifier.dispose();
    _horseListScrollController.dispose();
    super.dispose();
  }

  ///
  Future<void> _fetchAiPickup() async {
    final List<OddsModel> allOdds = _oddsForRace;
    final bool hasFirstTiming = allOdds.any((OddsModel e) => e.minutesBeforeStart == kOddsTimingFirst);
    final bool hasSixMinTiming = allOdds.any((OddsModel e) => e.minutesBeforeStart == kOddsJudgeTiming);
    if (!hasFirstTiming || !hasSixMinTiming) {
      return;
    }

    final String date = appParamState.selectedScheduleDate;
    final int race = widget.raceNumber;
    final (:String kaisuu, :String basho, :String day) = parseKbdParts(appParamState.selectedScheduleKaisuuBashoDay);
    try {
      final List<int> gapHorseNums = _calcOddsGapHorseNums();
      final List<int> upsetPickupHorseNums = _calcUpsetPickupHorseNums();

      final Map<String, dynamic> data = await fetchAiAnalysisData(
        ref,
        date: date,
        kaisuu: kaisuu,
        basho: basho,
        day: day,
        race: race,
        gapHorseNums: gapHorseNums,
        upsetPickupHorseNums: upsetPickupHorseNums,
      );
      final String pickupRaw = (data['pickup_horse'] as String?) ?? '';
      if (mounted) {
        setState(() {
          _aiPickupHorse = pickupRaw;
          _aiPickupNums = _parsePickupHorse(pickupRaw);
          _aiPickupScores = _parsePickupScores(pickupRaw);
        });
      }
    } catch (_) {}
  }

  ///
  Future<void> _fetchBaganrikiIndex() async {
    final List<OddsModel> allOdds = _oddsForRace;
    final bool hasFirstTiming = allOdds.any((OddsModel e) => e.minutesBeforeStart == kOddsTimingFirst);
    final bool hasSixMinTiming = allOdds.any((OddsModel e) => e.minutesBeforeStart == kOddsJudgeTiming);
    if (!hasFirstTiming || !hasSixMinTiming) {
      return;
    }
    final String date = appParamState.selectedScheduleDate;
    final int race = widget.raceNumber;
    final (:String kaisuu, :String basho, :String day) = parseKbdParts(appParamState.selectedScheduleKaisuuBashoDay);
    try {
      final Map<int, double?> indexMap = await fetchBaganrikiIndexData(
        ref,
        date: date,
        kaisuu: kaisuu,
        basho: basho,
        day: day,
        race: race,
      );
      if (mounted) {
        setState(() {
          _baganrikiIndexMap = indexMap;
        });
      }
    } catch (_) {}
  }

  ///
  static Set<int> _parsePickupHorse(String pickupRaw) {
    final Set<int> nums = <int>{};
    for (final String part in pickupRaw.split('/')) {
      final String trimmed = part.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final int? num = int.tryParse(trimmed.split('|').first.trim());
      if (num != null) {
        nums.add(num);
      }
    }
    return nums;
  }

  ///
  static Map<int, String> _parsePickupScores(String pickupRaw) {
    final Map<int, String> scores = <int, String>{};
    for (final String part in pickupRaw.split('/')) {
      final List<String> fields = part.trim().split('|');
      if (fields.length < 3) {
        continue;
      }
      final int? num = int.tryParse(fields[0].trim());
      if (num != null) {
        scores[num] = fields[2].trim();
      }
    }
    return scores;
  }

  ///
  Future<bool> _fetchAnalysis() async {
    final String date = appParamState.selectedScheduleDate;
    final int race = widget.raceNumber;
    final (:String kaisuu, :String basho, :String day) = parseKbdParts(appParamState.selectedScheduleKaisuuBashoDay);
    try {
      // 人気順位 → analysis テキストの Map を取得（空の場合は過去合致なし）
      final Map<int, String> newMap = await fetchHighProbabilityAnalysis(
        ref,
        date: date,
        kaisuu: kaisuu,
        basho: basho,
        day: day,
        race: race,
      );
      if (mounted) {
        setState(() => _analysisMap = newMap);
      }
      return newMap.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  ///
  void _startCountdown(String startTime, String raceDate) {
    _countdownTimer?.cancel();

    if (startTime == '--:--') {
      _remainingSecondsNotifier.value = 0;
      return;
    }

    final List<String> parts = startTime.split(':');
    if (parts.length < 2) {
      _remainingSecondsNotifier.value = 0;
      return;
    }

    final int hour = int.tryParse(parts[0]) ?? 0;
    final int minute = int.tryParse(parts[1]) ?? 0;

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    DateTime? parsedDate;
    final String cleaned = raceDate.replaceAll('/', '').replaceAll('-', '');
    if (cleaned.length == 8) {
      final int? y = int.tryParse(cleaned.substring(0, 4));
      final int? m = int.tryParse(cleaned.substring(4, 6));
      final int? d = int.tryParse(cleaned.substring(6, 8));
      if (y != null && m != null && d != null) {
        parsedDate = DateTime(y, m, d);
      }
    }

    if (parsedDate != null && parsedDate.isBefore(today)) {
      _remainingSecondsNotifier.value = 0;
      return;
    }

    final DateTime raceTime = parsedDate != null
        ? DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour, minute)
        : DateTime(now.year, now.month, now.day, hour, minute);

    final int diff = raceTime.difference(now).inSeconds;
    _remainingSecondsNotifier.value = diff > 0 ? diff : 0;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSecondsNotifier.value > 0) {
        _remainingSecondsNotifier.value--;
      } else {
        timer.cancel();
      }
    });
  }

  ///
  static String _formatCountdown(int totalSeconds) {
    final int h = totalSeconds ~/ 3600;
    final int m = (totalSeconds % 3600) ~/ 60;
    final int s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  ///
  void _scrollHorseList(int delta) {
    if (!_horseListScrollController.hasClients || _displayListLength == 0) {
      return;
    }
    final int next = (_currentHorseIndex + delta).clamp(0, _displayListLength - 1);
    _currentHorseIndex = next;
    _horseListScrollController.scrollToIndex(next, preferPosition: AutoScrollPosition.begin);
  }

  ///
  static String _beforeMinutesText(String selectedTiming) => switch (selectedTiming) {
    '0' => 'レース開始時点の',
    '' => '',
    _ => '$selectedTiming分前の',
  };

  ///
  static Map<int, List<String>> _buildTimelineMap<T>({
    required List<T> models,
    required int Function(T) getNum,
    required int Function(T) getMinutes,
    required String Function(T) getValue,
    required int length,
    required List<int> timingOrder,
  }) {
    final Map<int, List<String>> result = <int, List<String>>{};
    for (final T model in models) {
      final int num = getNum(model);
      result.putIfAbsent(num, () => List<String>.filled(length, ''));
      final int idx = timingOrder.indexOf(getMinutes(model));
      if (idx != -1) {
        result[num]![idx] = getValue(model);
      }
    }
    return result;
  }

  ///
  static List<int> _buildTimingOrder(List<String> timingParts) {
    return List<int>.generate(
      timingParts.length,
      (int i) => switch (i) {
        0 => kOddsTimingFirst,
        _ when timingParts[i] == kOddsTimingLastLabel => kOddsTimingLast,
        _ => int.tryParse(timingParts[i]) ?? 0,
      },
    );
  }

  ///
  static int? _resolveFilterMinutes(String selectedTiming, List<OddsModel> oddsModelList, int firstTiming) =>
      resolveFilterMinutes(selectedTiming, oddsModelList, firstTiming);

  ///
  static String _filterMinutesToTimingKey(int? filterMinutes, String firstTimingKey, String lastTimingKey) {
    return switch (filterMinutes) {
      null => '',
      kOddsTimingFirst => firstTimingKey,
      kOddsTimingLast => lastTimingKey,
      _ => filterMinutes.toString(),
    };
  }

  ///
  static String _resolveMinTiming(List<OddsModel> oddsModelList, String firstTimingKey, String lastTimingKey) {
    if (oddsModelList.any((OddsModel e) => e.minutesBeforeStart == kOddsTimingLast)) {
      return lastTimingKey;
    }
    if (oddsModelList.isNotEmpty && oddsModelList.every((OddsModel e) => e.minutesBeforeStart == kOddsTimingFirst)) {
      return firstTimingKey;
    }

    final List<OddsModel> validList = oddsModelList.where((OddsModel e) => e.minutesBeforeStart >= 0).toList()
      ..sort((OddsModel a, OddsModel b) => a.minutesBeforeStart.compareTo(b.minutesBeforeStart));
    return validList.isNotEmpty ? validList.first.minutesBeforeStart.toString() : '';
  }

  ///
  List<OddsModel> _buildDisplayList() => buildOddsDisplayList(
    oddsForRace: _oddsForRace,
    selectedTiming: appParamState.selectedTiming,
    configFirstKey: _configFirstKey,
  );

  ///
  Widget _buildRaceInfoBar({
    required String startTime,
    required String raceName,
    required String course,
    required int dist,
  }) {
    return Stack(
      children: <Widget>[
        if (!appParamState.isShowUpperBox) ...<Widget>[
          DefaultTextStyle(
            style: const TextStyle(fontSize: 10, color: Colors.yellowAccent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(width: 10),
                Text(appParamState.selectedScheduleDate),
                Text(appParamState.selectedScheduleKaisuuBashoDayName),
                Text('${widget.raceNumber}レース'),
                const SizedBox(width: 80),
              ],
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 5, left: 5, bottom: 5),
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(width: context.screenSize.width * 0.6),

                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const SizedBox.shrink(),
                            Text('$startTime 発走', style: const TextStyle(fontSize: 12, color: Colors.greenAccent)),
                          ],
                        ),

                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.orangeAccent.withValues(alpha: 0.5))),
                          ),

                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  alignment: Alignment.topRight,
                                  child: const Text('発走まで', style: TextStyle(fontSize: 8, color: Colors.orangeAccent)),
                                ),
                              ),

                              SizedBox(
                                width: context.screenSize.width * 0.15,
                                child: Container(
                                  alignment: Alignment.topRight,
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: _remainingSecondsNotifier,
                                    builder: (BuildContext context, int seconds, Widget? _) => Text(
                                      _formatCountdown(seconds),
                                      style: const TextStyle(fontSize: 13, color: Colors.orangeAccent),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.white60.withValues(alpha: 0.5))),
                          ),

                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  alignment: Alignment.topRight,
                                  child: const Text('馬券締切まで', style: TextStyle(fontSize: 8, color: Colors.white60)),
                                ),
                              ),
                              SizedBox(
                                width: context.screenSize.width * 0.15,
                                child: Container(
                                  alignment: Alignment.topRight,
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: _remainingSecondsNotifier,
                                    builder: (BuildContext context, int seconds, Widget? _) => Text(
                                      _formatCountdown(seconds > 180 ? seconds - 180 : 0),
                                      style: const TextStyle(fontSize: 13, color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => appParamNotifier.setIsShowUpperBox(flag: !appParamState.isShowUpperBox),
                    child: Icon(
                      appParamState.isShowUpperBox ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                      color: Colors.green[500],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          raceName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),

                        if (course != '' && dist > 0) ...<Widget>[
                          Text(
                            '$course ${dist.toString().toCurrency()}m',
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///
  Widget _buildRaceResultBox({required Map<int, RaceResultModel> raceResultByRank}) {
    if (raceResultByRank.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<OddsModel> eRecordOdds =
        _oddsForRace.where((OddsModel o) => o.minutesBeforeStart == kOddsTimingLast).toList()
          ..sort((OddsModel a, OddsModel b) => (double.tryParse(a.odds) ?? 0).compareTo(double.tryParse(b.odds) ?? 0));

    final Map<int, int> numToPopularityMap = <int, int>{
      for (int i = 0; i < eRecordOdds.length; i++) eRecordOdds[i].num: i + 1,
    };

    final Map<int, String> numToOddsMap = <int, String>{for (final OddsModel o in eRecordOdds) o.num: o.odds};

    final Map<int, RaceTopThreeEntry> entries = <int, RaceTopThreeEntry>{
      for (final MapEntry<int, RaceResultModel> e in raceResultByRank.entries)
        e.key: RaceTopThreeEntry(
          num: e.value.num,
          name: e.value.horseName,
          odds: numToOddsMap[e.value.num] ?? '',
          popularity: numToPopularityMap[e.value.num],
        ),
    };

    return RaceTopThreeWidget(entries: entries, showTitle: true);
  }

  ///
  Widget _buildControlButtons({required int raceIdx}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => appParamNotifier.setAllExpanded(),
              child: Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: appParamState.allExpanded
                      ? const Color(0xFF2196F3).withValues(alpha: 0.4)
                      : const Color(0xFF4CAF50).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    appParamState.allExpanded ? 'CLOSE' : 'OPEN',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 15),

            GestureDetector(
              onTap: () async {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('reload_selected_schedule_date', appParamState.selectedScheduleDate);
                await prefs.setString(
                  'reload_selected_schedule_kaisuu_basho_day',
                  appParamState.selectedScheduleKaisuuBashoDay,
                );
                await prefs.setString(
                  'reload_selected_schedule_kaisuu_basho_day_name',
                  appParamState.selectedScheduleKaisuuBashoDayName,
                );
                await prefs.setInt('reload_selected_race_number', widget.raceNumber);
                await prefs.setBool('reload_all_expanded', appParamState.allExpanded);
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  context.findAncestorStateOfType<AppRootState>()?.restartApp();
                }
              },
              child: Icon(Icons.refresh, color: Colors.green[500]),
            ),

            const SizedBox(width: 15),

            GestureDetector(
              onTap: () {
                appParamNotifier.setSelectedRaceNumber(num: widget.raceNumber);
                appParamNotifier.setIsShowUpperBox2(flag: true);
                OddsFinderDialog(context: context, widget: const HorseOddsRankingDisplayAlert());
              },
              child: Icon(Icons.list, color: Colors.white.withValues(alpha: 0.5)),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            IconButton(
              onPressed: () => _scrollHorseList(1),
              icon: const Icon(Icons.arrow_downward, color: Colors.white70),
            ),
            IconButton(
              onPressed: () => _scrollHorseList(-1),
              icon: const Icon(Icons.arrow_upward, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  ///
  Widget _displayRaceMinutesRow() {
    final List<String> timingParts = _configTimingParts;
    final String minTiming = _minTiming;

    if (appParamState.selectedTiming.isEmpty && minTiming.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          appParamNotifier.setSelectedTiming2(timing2: minTiming);
        }
      });
    }

    return Row(
      children: timingParts.map((String e) {
        return Expanded(
          child: GestureDetector(
            onTap: () => appParamNotifier.setSelectedTiming(timing: appParamState.selectedTiming == e ? '' : e),
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                color: (appParamState.selectedTiming == e)
                    ? Colors.greenAccent.withValues(alpha: 0.3)
                    : (appParamState.selectedTiming == '' && e == minTiming)
                    ? Colors.red.withValues(alpha: 0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
              ),
              alignment: Alignment.center,
              child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 8)),
            ),
          ),
        );
      }).toList(),
    );
  }

  ///
  Widget _displayRaceHorseList({required String course, required int dist}) {
    final List<OddsModel> oddsModelList = _oddsForRace;
    final Map<int, HorseModel> horseModelMap = _horseModelMap;

    oddsModelList.sort((OddsModel a, OddsModel b) {
      final int cmp = a.num.compareTo(b.num);
      return cmp != 0 ? cmp : b.minutesBeforeStart.compareTo(a.minutesBeforeStart);
    });

    final List<String> timingParts = widget.oddsGetTiming.split('|');
    final List<int> timingOrder = _buildTimingOrder(timingParts);

    final Map<int, List<String>> oddsTimelineMap = _buildTimelineMap<OddsModel>(
      models: oddsModelList,
      getNum: (OddsModel e) => e.num,
      getMinutes: (OddsModel e) => e.minutesBeforeStart,
      getValue: (OddsModel e) => e.odds,
      length: timingParts.length,
      timingOrder: timingOrder,
    );
    final Map<int, List<String>> fukuMinTimelineMap = _buildTimelineMap<OddsModel>(
      models: oddsModelList,
      getNum: (OddsModel e) => e.num,
      getMinutes: (OddsModel e) => e.minutesBeforeStart,
      getValue: (OddsModel e) => e.fukuMin,
      length: timingParts.length,
      timingOrder: timingOrder,
    );
    final Map<int, List<String>> fukuMaxTimelineMap = _buildTimelineMap<OddsModel>(
      models: oddsModelList,
      getNum: (OddsModel e) => e.num,
      getMinutes: (OddsModel e) => e.minutesBeforeStart,
      getValue: (OddsModel e) => e.fukuMax,
      length: timingParts.length,
      timingOrder: timingOrder,
    );

    final String selectedTiming = appParamState.selectedTiming;
    final List<OddsModel> displayList = _buildDisplayList();

    if (displayList.isEmpty) {
      _displayListLength = 0;
      return Text(
        '${_beforeMinutesText(selectedTiming)}オッズデータはありません。',
        style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
      );
    }

    final int firstTiming = int.tryParse(_configFirstKey) ?? 0;
    final int? filterMinutes = _resolveFilterMinutes(selectedTiming, displayList, firstTiming);
    final String lastTimingKey = _configLastKey;
    final String activeTimingKey = _filterMinutesToTimingKey(filterMinutes, firstTiming.toString(), lastTimingKey);

    _displayListLength = displayList.length;

    final Map<int, Color> horseWakuColorMap = _utility.getHorseWakuColorMap();

    final List<MapEntry<int, double>> fukuSortable =
        displayList
            .where((OddsModel o) => double.tryParse(o.fukuMin) != null)
            .map((OddsModel o) => MapEntry<int, double>(o.num, double.parse(o.fukuMin)))
            .toList()
          ..sort((MapEntry<int, double> a, MapEntry<int, double> b) => a.value.compareTo(b.value));
    final Map<int, int> fukuRankMap = <int, int>{
      for (int i = 0; i < fukuSortable.length; i++) fukuSortable[i].key: i + 1,
    };

    final Map<int, int> numToRankMap = _numToRankMap;

    final List<int> sortedAnalysisKeys = _analysisMap.keys.toList()..sort();
    final int analysisTotalCount = sortedAnalysisKeys.length;

    return ListView.builder(
      controller: _horseListScrollController,
      itemCount: displayList.length,
      itemBuilder: (BuildContext context, int index) {
        final OddsModel element = displayList[index];
        final int popularity = index + 1;
        final int rawRank = sortedAnalysisKeys.indexOf(popularity);
        final int? analysisRank = rawRank == -1 ? null : rawRank + 1;
        return AutoScrollTag(
          key: ValueKey<int>(index),
          controller: _horseListScrollController,
          index: index,
          child: _buildHorseListItem(
            index: index,
            element: element,
            horseModelMap: horseModelMap,
            horseWakuColorMap: horseWakuColorMap,
            oddsTimelineMap: oddsTimelineMap,
            fukuMinTimelineMap: fukuMinTimelineMap,
            fukuMaxTimelineMap: fukuMaxTimelineMap,
            activeTimingKey: activeTimingKey,
            selectedTiming: selectedTiming,
            nextOddsTimeline: index + 1 < displayList.length ? oddsTimelineMap[displayList[index + 1].num] : null,
            fukuRank: fukuRankMap[element.num],
            raceRank: numToRankMap[element.num],
            analysis: _analysisMap[popularity],
            analysisRank: analysisRank,
            analysisTotalCount: analysisTotalCount,
            course: course,
            dist: dist,
          ),
        );
      },
    );
  }

  ///
  Widget _buildHorseListItem({
    required int index,
    required OddsModel element,
    required Map<int, HorseModel> horseModelMap,
    required Map<int, Color> horseWakuColorMap,
    required Map<int, List<String>> oddsTimelineMap,
    required Map<int, List<String>> fukuMinTimelineMap,
    required Map<int, List<String>> fukuMaxTimelineMap,
    required String activeTimingKey,
    required String selectedTiming,
    required String course,
    required int dist,
    List<String>? nextOddsTimeline,
    int? fukuRank,
    int? raceRank,
    String? analysis,
    int? analysisRank,
    int analysisTotalCount = 0,
  }) {
    final int popularity = index + 1;
    final HorseModel? horse = horseModelMap[element.num];
    final List<String>? oddsTimeline = oddsTimelineMap[element.num];
    final List<String>? fukuMinTimeline = fukuMinTimelineMap[element.num];
    final List<String>? fukuMaxTimeline = fukuMaxTimelineMap[element.num];

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              if (analysis != null && analysis.isNotEmpty && analysisRank != null) ...<Widget>[
                Container(
                  width: 40,
                  height: 20,
                  decoration: BoxDecoration(color: Colors.yellowAccent.withValues(alpha: 0.3)),
                  child: Center(
                    child: Text(
                      '$analysisRank/$analysisTotalCount',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],

              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (analysis != null && analysis.isNotEmpty)
                        ? Colors.yellowAccent.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ),

                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        if (analysis != null && analysis.isNotEmpty) ...<Widget>[
                          /// 分析結果（過去データからの判断）
                          Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3)),
                            child: Text(
                              analysis,
                              style: TextStyle(fontSize: 10, color: Colors.yellowAccent.withValues(alpha: 0.8)),
                            ),
                          ),
                        ],

                        if (oddsTimeline != null && oddsTimeline.isNotEmpty) ...<Widget>[
                          _buildJudgeOddsSection(timeline: oddsTimeline),
                        ],

                        ExpansionTile(
                          key: ValueKey<String>('horse_${element.num}_${appParamState.allExpanded}'),
                          initiallyExpanded: appParamState.allExpanded,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                          childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
                          expandedAlignment: Alignment.centerLeft,
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          title: DefaultTextStyle(
                            style: const TextStyle(fontSize: 10),
                            child: Column(
                              children: <Widget>[
                                _buildHorseItemHeader(popularity: popularity, fukuRank: fukuRank, horse: horse),
                                const SizedBox(height: 5),
                                _buildHorseNameRow(
                                  element: element,
                                  horse: horse,
                                  horseWakuColorMap: horseWakuColorMap,
                                  oddsTimeline: oddsTimeline,
                                ),
                              ],
                            ),
                          ),

                          children: <Widget>[
                            //////////////////////
                            if (oddsTimeline != null) ...<Widget>[
                              const SizedBox(height: 5),

                              const Text('発走のX分前のオッズ:', style: TextStyle(color: Colors.orangeAccent, fontSize: 10)),

                              const SizedBox(height: 3),

                              _OddsTimelineRow(
                                timeline: oddsTimeline,
                                activeTimingKey: activeTimingKey,
                                selectedTiming: selectedTiming,
                                oddsGetTiming: widget.oddsGetTiming,
                                fukuMinList: fukuMinTimeline,
                                fukuMaxList: fukuMaxTimeline,
                                nextTimeline: nextOddsTimeline,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    if (raceRank != null && raceRank <= 3) ...<Widget>[
                      Positioned(
                        top: 2,
                        right: 2,
                        child: CustomPaint(
                          painter: RankBadgePainter(color: raceRankColor(raceRank, alpha: 0.3)),
                          child: SizedBox(
                            width: context.screenSize.width * 0.15,
                            height: context.screenSize.height * 0.05,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20, left: 25),
                                child: Text(
                                  '$raceRank着',
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
                  ],
                ),
              ),
            ],
          ),

          if (popularity == 6) ...<Widget>[
            const SizedBox(height: 10),

            const SizedBox(
              width: double.infinity,
              height: 5,
              child: CustomPaint(painter: DashedLinePainter()),
            ),

            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  ///
  Widget _buildJudgeOddsSection({required List<String> timeline}) {
    final List<String> timingParts = widget.oddsGetTiming.split('|');
    final String odds30 = timeline[0];
    final int idx6 = timingParts.indexOf(kOddsJudgeTimingLabel);
    final String odds6 = idx6 != -1 && idx6 < timeline.length ? timeline[idx6] : '';

    if (odds30.isEmpty || odds6.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, dynamic> judged = _utility.judgeOdds(
      before30: double.tryParse(odds30) ?? 0,
      before6: double.tryParse(odds6) ?? 0,
      rateHonmei: double.tryParse(appParamState.configOddsDropRateHonmei) ?? 0,
      rateChuAna: double.tryParse(appParamState.configOddsDropRateChuana) ?? 0,
    );

    if (judged['display'] != true) {
      return const SizedBox.shrink();
    }

    // as String? でクラッシュを防止（APIが稀にnullを返す）
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3)),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 10, color: Colors.greenAccent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text((judged['message'] as String?) ?? ''),
            Text((judged['description'] as String?) ?? ''),
          ],
        ),
      ),
    );
  }

  ///
  Widget _buildHorseItemHeader({required int popularity, int? fukuRank, HorseModel? horse}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 10),
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                        child: Text(popularity.toString(), style: TextStyle(color: Colors.green[500])),
                      ),
                      Text('番人気', style: TextStyle(color: Colors.green[500])),
                    ],
                  ),
                ),
                Positioned(
                  left: 15,
                  child: Text('単勝', style: TextStyle(fontSize: 10, color: Colors.green[500])),
                ),
              ],
            ),

            if (fukuRank != null) ...<Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 10),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightBlueAccent.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      children: <Widget>[
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 20,
                          child: Text(fukuRank.toString(), style: const TextStyle(color: Colors.lightBlueAccent)),
                        ),
                        const Text('番人気', style: TextStyle(color: Colors.lightBlueAccent)),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: 15,
                    child: Text('複勝', style: TextStyle(fontSize: 10, color: Colors.lightBlueAccent)),
                  ),
                ],
              ),
            ],
          ],
        ),

        Row(
          children: <Widget>[
            if (horse != null && _aiPickupNums.contains(horse.num)) ...<Widget>[
              Stack(
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

                  if (_aiPickupScores[horse.num] != null) ...<Widget>[
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Text(
                        '${_aiPickupScores[horse.num]} %',
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ],

            const SizedBox(width: 20),

            GestureDetector(
              onTap: () {
                if (horse == null) {
                  return;
                }
                final List<String> exUrl = horse.horseUrl.split('=');
                final String horseId = exUrl.length > 1 ? exUrl[1] : '';
                if (horseId.isNotEmpty) {
                  horseNotifier.fetchHorseDetail(horseId: horseId);
                  OddsFinderDialog(context: context, widget: const HorseDetailDisplayAlert());
                }
              },
              child: FaIcon(FontAwesomeIcons.horse, size: 20, color: Colors.green[500]!.withValues(alpha: 0.6)),
            ),

            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  ///
  Widget _buildPopularityHorseRow({
    required List<OddsModel> displayList,
    required PopularityRankOddsMedianModel median,
    RaceModel? raceModel,
  }) {
    final Map<int, int> numToRankMap = _numToRankMap;
    final String minTiming = _minTiming;

    final int pickupCount = displayList.length <= 8
        ? 4
        : displayList.length <= 13
        ? 5
        : 6;

    final Set<int> pickupIndexSet = calcPickupPopularitySet(displayList, median, pickupCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
          children: <Widget>[
            const SizedBox(width: 5),

            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(dragDevices: <PointerDeviceKind>{PointerDeviceKind.touch, PointerDeviceKind.mouse}),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: displayList.asMap().entries.map((MapEntry<int, OddsModel> entry) {
                        final int index = entry.key + 1;
                        final OddsModel o = entry.value;

                        // 期待数値スコアを計算する（選択タイミングのオッズに従う）。
                        String upsetScore = '';
                        final double medianDouble = double.tryParse(medianByRank(median, index)) ?? 0;
                        if (medianDouble > 0) {
                          final double oddsVal = o.odds.toDouble();
                          if (oddsVal > 0) {
                            upsetScore = (medianDouble / oddsVal).toStringAsFixed(2);
                          }
                        }

                        return Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Container(
                              width: 70,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: pickupIndexSet.contains(index)
                                    ? Colors.yellowAccent.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.05),

                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),

                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: DefaultTextStyle(
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3)),
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      child: Text('$index番人気'),
                                    ),
                                    Text('馬番: ${o.num}'),
                                    const SizedBox(height: 3),
                                    Text(
                                      upsetScore,
                                      style: TextStyle(
                                        color: Colors.yellowAccent.withValues(alpha: 0.6),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                  ],
                                ),
                              ),
                            ),

                            if (numToRankMap.containsKey(o.num))
                              Positioned(
                                right: -3,
                                bottom: -3,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: raceRankColor(numToRankMap[o.num]),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.flag, size: 14, color: Colors.white),
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 5),
          ],
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (appParamState.selectedTiming.isNotEmpty ? appParamState.selectedTiming : minTiming
                      case final String t when t.isNotEmpty) ...<Widget>[
                    Text('$t分前のデータを表示中', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ],

                  const SizedBox.shrink(),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const SizedBox.shrink(),

                  GestureDetector(
                    key: _harandoKey,
                    onTap: () {
                      widgetDisplayOverlay(
                        context: context,
                        buttonKey: _harandoKey,
                        displayDuration: const Duration(seconds: 5),
                        child: Container(
                          width: 300,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black87.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const DefaultTextStyle(
                                style: TextStyle(color: Colors.white, fontSize: 11),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('過去の似たレースと比べて、今のオッズが「お得かどうか」を数値化しています。高いほど割安感あり。'),
                                    Text(''),
                                    Text('出走頭数に応じて上位をピックアップ。'),
                                    Text('8頭以下：4頭 ／ 9〜13頭：5頭 ／ 14頭以上：6頭'),
                                  ],
                                ),
                              ),

                              if (raceModel != null) ...<Widget>[
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const SizedBox.shrink(),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        child: InkWell(
                                          onTap: () => OddsFinderDialog(
                                            context: context,
                                            widget: SimilarRacesDisplayAlert(raceModel: raceModel),
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          splashColor: const Color(0xFFFBB6CE).withValues(alpha: 0.35),
                                          highlightColor: const Color(0xFFFBB6CE).withValues(alpha: 0.1),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: const Color(0xFFFBB6CE)),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              '過去の類似レース',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFFFBB6CE),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Text('期待数値とは？', style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 3),
      ],
    );
  }

  ///
  List<int> _calcOddsGapHorseNums() => calcOddsGapHorseNums(_oddsForRace);

  ///
  List<int> _calcUpsetPickupHorseNums() => calcUpsetPickupHorseNums(
    oddsForRace: _oddsForRace,
    medianModel: _makeMedianList(),
    displayList: _buildDisplayList(),
  );

  ///
  double? _calcOddsDropRatio(List<String>? timeline) {
    if (timeline == null || timeline.isEmpty) {
      return null;
    }
    final String odds30Str = timeline[0];
    final List<String> timingParts = widget.oddsGetTiming.split('|');
    final int lastIdx = timingParts.indexOf(kOddsTimingLastLabel);
    if (lastIdx == -1 || lastIdx >= timeline.length) {
      return null;
    }
    final String lastOddsStr = timeline[lastIdx];
    final double odds30 = double.tryParse(odds30Str) ?? 0;
    final double lastOdds = double.tryParse(lastOddsStr) ?? 0;
    if (odds30 <= 0 || lastOdds <= 0) {
      return null;
    }
    final double ratio = lastOdds / odds30;
    return ratio <= 0.8 ? ratio : null;
  }

  ///
  Widget _buildHorseNameRow({
    required OddsModel element,
    required HorseModel? horse,
    required Map<int, Color> horseWakuColorMap,
    List<String>? oddsTimeline,
  }) {
    if (horse == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 15),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 12, color: Colors.white),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: (horseWakuColorMap[horse.waku] != null)
                              ? horseWakuColorMap[horse.waku]!.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 15, child: Text(horse.waku.toString())),
                            const Text('枠'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(width: 20, child: Text(element.num.toString())),
                      const Text('番'),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(horse.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (horseBestWeightState.horseBestWeightMap[horse.name] != null &&
                                horseBestWeightState.horseBestWeightMap[horse.name]!.horseWeight != '') ...<Widget>[
                              const SizedBox(height: 3),
                              Text(
                                'Best Weight: ${horseBestWeightState.horseBestWeightMap[horse.name]!.horseWeight}',
                                style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_baganrikiIndexMap[element.num] != null) ...<Widget>[
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
                              _baganrikiIndexMap[element.num]!.toStringAsFixed(1),
                              style: TextStyle(fontSize: 20, color: Colors.white.withValues(alpha: 0.6)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        if (_calcOddsDropRatio(oddsTimeline) != null) ...<Widget>[
          Positioned(
            left: 10,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 50,
                  height: 14,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.yellowAccent),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '+${((1 - _calcOddsDropRatio(oddsTimeline)!) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 10, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Text(
                  'オッズ遷移',
                  style: TextStyle(fontSize: 8, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  ///
  @override
  Widget build(BuildContext context) {
    final List<RaceModel> races = widget.raceMap[widget.mapKey] ?? <RaceModel>[];
    final int raceIdx = races.indexWhere((RaceModel e) => e.race == widget.raceNumber);

    final PopularityRankOddsMedianModel? median = _makeMedianList();

    // 他レースで「期待数値」タブを開いたまま本レース（medianなし）に切り替えた場合、パネルを自動クローズ
    if (!_autoClosedPanel &&
        median == null &&
        appParamState.isShowSideTabPanel &&
        appParamState.selectedUpsetBoxNum == 0) {
      _autoClosedPanel = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          appParamNotifier.setIsShowSideTabPanel(flag: false);
        }
      });
    }

    String raceName = '';
    String startTime = '--:--';
    RaceModel? currentRaceModel;

    String course = '';
    int dist = 0;

    if (raceIdx != -1) {
      currentRaceModel = races[raceIdx];
      raceName = currentRaceModel.raceName;

      course = currentRaceModel.course;
      dist = currentRaceModel.dist;

      final int colonIdx = currentRaceModel.startTime.lastIndexOf(':');
      startTime = colonIdx > 0 ? currentRaceModel.startTime.substring(0, colonIdx) : currentRaceModel.startTime;
    }

    if (startTime != _lastStartTime) {
      _lastStartTime = startTime;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startCountdown(startTime, appParamState.selectedScheduleDate);
        }
      });
    }

    final List<OddsModel> displayList = _buildDisplayList();

    final Map<int, HorseModel> horseModelMap = _horseModelMap;
    final Map<int, int> numToRankMap = _numToRankMap;
    final List<OddsModel> allOddsForRace = _oddsForRace;

    // 6分前オッズのリスト（オッズ昇順）。TotalForecastDisplayAlert に渡す。
    // 6分前データがない場合は現在オッズのリストで代替する。
    final List<OddsModel> sixMinDisplayList = () {
      final List<OddsModel> list =
          allOddsForRace.where((OddsModel e) => e.minutesBeforeStart == kOddsJudgeTiming).toList()
            ..sort((OddsModel a, OddsModel b) {
              final double aOdds = double.tryParse(a.odds) ?? double.infinity;
              final double bOdds = double.tryParse(b.odds) ?? double.infinity;
              return aOdds.compareTo(bOdds);
            });
      return list.isNotEmpty ? list : displayList;
    }();

    final bool hasBothTimings =
        allOddsForRace.any((OddsModel e) => e.minutesBeforeStart == kOddsTimingFirst) &&
        allOddsForRace.any((OddsModel e) => e.minutesBeforeStart == kOddsJudgeTiming);

    final Map<int, RaceResultModel> raceResultByRank = Map<int, RaceResultModel>.fromEntries(
      (widget.raceResultMap[widget.mapKey] ?? <RaceResultModel>[])
          .where((RaceResultModel e) => e.race == widget.raceNumber)
          .map((RaceResultModel e) => MapEntry<int, RaceResultModel>(e.result, e)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildRaceInfoBar(startTime: startTime, raceName: raceName, course: course, dist: dist),

        _buildControlButtons(raceIdx: raceIdx),

        Divider(color: Colors.white.withValues(alpha: 0.5)),

        SizedBox(height: 40, child: _displayRaceMinutesRow()),

        const SizedBox(height: 10),

        if (displayList.isNotEmpty && (median != null || raceResultByRank.isNotEmpty)) ...<Widget>[
          Stack(
            children: <Widget>[
              if (appParamState.isShowSideTabPanel && (median != null || raceResultByRank.isNotEmpty)) ...<Widget>[
                SideTabPanel(
                  tabLabels: <String>[if (median != null) '期待数値', if (raceResultByRank.isNotEmpty) 'レース結果'],

                  tabWidth: 90,
                  tabGap: 0,
                  height: 100,
                  borderColor: Colors.white.withValues(alpha: 0.4),
                  selectedIndex: (median != null && raceResultByRank.isNotEmpty)
                      ? appParamState.selectedUpsetBoxNum
                      : 0,
                  onSelected: (int i) => appParamNotifier.setSelectedUpsetBoxNum(num: i),

                  panelChild: median == null
                      ? _buildRaceResultBox(raceResultByRank: raceResultByRank)
                      : (raceResultByRank.isEmpty || appParamState.selectedUpsetBoxNum == 0)
                      ? _buildPopularityHorseRow(displayList: displayList, median: median, raceModel: currentRaceModel)
                      : _buildRaceResultBox(raceResultByRank: raceResultByRank),
                ),
              ],

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () => appParamNotifier.setIsShowSideTabPanel(flag: !appParamState.isShowSideTabPanel),
                    child: ClipPath(
                      clipper: _TriangleClipper(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: (appParamState.isShowSideTabPanel)
                              ? Colors.green[500]!.withValues(alpha: 0.4)
                              : Colors.grey.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),

                  if (!appParamState.isShowSideTabPanel) ...<Widget>[
                    GestureDetector(
                      onTap: () => appParamNotifier.setIsShowSideTabPanel(flag: true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                        child: Text(
                          median != null && raceResultByRank.isNotEmpty
                              ? '期待数値、レース結果の表示'
                              : median != null
                              ? '期待数値の表示'
                              : 'レース結果の表示',
                          style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],

        const SizedBox(height: 5),

        if (hasBothTimings) ...<Widget>[
          const SizedBox(height: 5),

          Row(
            children: <Widget>[
              Material(
                key: _analysisButtonKey,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () async {
                    final BuildContext ctx = context;
                    final bool found = await _fetchAnalysis();
                    if (!found && ctx.mounted) {
                      final RenderBox? renderBox = _analysisButtonKey.currentContext?.findRenderObject() as RenderBox?;
                      if (renderBox != null) {
                        final Offset offset = renderBox.localToGlobal(Offset.zero);
                        widgetDisplayOverlay(
                          context: ctx,
                          tapPosition: Offset(offset.dx, offset.dy - 10),
                          displayDuration: const Duration(seconds: 3),
                          child: const Text('合致がありません', style: TextStyle(fontSize: 12, color: Colors.yellowAccent)),
                        );
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  splashColor: Colors.yellowAccent.withValues(alpha: 0.35),
                  highlightColor: Colors.yellowAccent.withValues(alpha: 0.1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellowAccent),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '過去データからの分析',
                      style: TextStyle(fontSize: 10, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    final List<int> gapHorseNums = _calcOddsGapHorseNums();

                    final List<int> upsetPickupHorseNums = _calcUpsetPickupHorseNums();

                    OddsFinderDialog(
                      context: context,
                      widget: AiAnalysisDisplayAlert(
                        raceNumber: widget.raceNumber,
                        gapHorseNums: gapHorseNums,
                        upsetPickupHorseNums: upsetPickupHorseNums,
                        numToRankMap: numToRankMap,
                      ),
                    );
                  },

                  borderRadius: BorderRadius.circular(10),
                  splashColor: const Color(0xFFFFD700).withValues(alpha: 0.35),
                  highlightColor: const Color(0xFFFFD700).withValues(alpha: 0.1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFFD700)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'AI予想',
                      style: TextStyle(fontSize: 10, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    final List<int> gapHorseNums = _calcOddsGapHorseNums();

                    final List<int> upsetPickupHorseNums = _calcUpsetPickupHorseNums();

                    OddsFinderDialog(
                      context: context,
                      widget: TotalForecastDisplayAlert(
                        displayList: sixMinDisplayList,
                        horseModelMap: horseModelMap,
                        numToRankMap: numToRankMap,
                        currentRaceModel: currentRaceModel!,
                        pickupHorse: _aiPickupHorse,
                        gapHorseNums: gapHorseNums,
                        upsetPickupHorseNums: upsetPickupHorseNums,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  splashColor: const Color(0xFFFBB6CE).withValues(alpha: 0.35),
                  highlightColor: const Color(0xFFFBB6CE).withValues(alpha: 0.1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFFBB6CE)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '予想総括',
                      style: TextStyle(fontSize: 10, color: Color(0xFFFBB6CE), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),
        ],

        const SizedBox(height: 5),
        Expanded(
          child: _displayRaceHorseList(course: course, dist: dist),
        ),
      ],
    );
  }

  ///
  PopularityRankOddsMedianModel? _makeMedianList() {
    final List<PopularityRankOddsMedianModel> popularityRankOddsMedianModelList =
        appParamState.keepPopularityRankOddsMedianMap[widget.mapKey] ?? <PopularityRankOddsMedianModel>[];

    final List<PopularityRankOddsMedianModel> filtered = popularityRankOddsMedianModelList
        .where((PopularityRankOddsMedianModel e) => e.race == widget.raceNumber)
        .toList();

    return filtered.isNotEmpty ? filtered.first : null;
  }
}

class _OddsTimelineRow extends StatelessWidget {
  const _OddsTimelineRow({
    required this.timeline,
    required this.activeTimingKey,
    required this.selectedTiming,
    required this.oddsGetTiming,
    this.fukuMinList,
    this.fukuMaxList,
    this.nextTimeline,
  });

  final List<String> timeline;
  final String activeTimingKey;
  final String selectedTiming;
  final String oddsGetTiming;
  final List<String>? fukuMinList;
  final List<String>? fukuMaxList;
  final List<String>? nextTimeline;

  ///
  @override
  Widget build(BuildContext context) {
    final List<String> timingKeys = oddsGetTiming.split('|');

    int oddsEdgeNum = 0;
    if (nextTimeline != null) {
      for (final MapEntry<int, String> entry in timeline.asMap().entries) {
        if (entry.value.isNotEmpty && entry.key < nextTimeline!.length) {
          final double? next = double.tryParse(nextTimeline![entry.key]);
          final double? current = double.tryParse(entry.value);
          if (next != null && current != null && current != 0) {
            oddsEdgeNum = (next / current).toInt();
          }
        }
      }
    }

    return Stack(
      children: <Widget>[
        Positioned(
          top: 145,
          left: 0,
          child: Stack(
            children: <Widget>[
              Container(
                height: 100,
                margin: const EdgeInsets.only(top: 10, right: 15),
                child: const Text('オッズ断層', style: TextStyle(fontSize: 10, color: Color(0xFFFBB6CE))),
              ),
              if (oddsEdgeNum > 1)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.circle_outlined, size: 30, color: Color(0xFFFBB6CE)),
                ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: timeline.asMap().entries.map((MapEntry<int, String> entry) {
            if (entry.value.isEmpty) {
              return Expanded(
                child: Container(
                  height: 150,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2)),
                ),
              );
            }

            final String entryTimingKey = entry.key < timingKeys.length ? timingKeys[entry.key] : '';
            final Color circleColor = (selectedTiming == entryTimingKey)
                ? Colors.greenAccent
                : (selectedTiming.isEmpty && entryTimingKey == activeTimingKey)
                ? Colors.red
                : Colors.white;

            final String fukuMin = fukuMinList?[entry.key] ?? '';
            final String fukuMax = fukuMaxList?[entry.key] ?? '';

            final double? nextVal = (nextTimeline != null && entry.key < nextTimeline!.length)
                ? double.tryParse(nextTimeline![entry.key])
                : null;
            final double? currentVal = double.tryParse(entry.value);
            final bool hasRatio = nextVal != null && currentVal != null && currentVal != 0;
            final double ratio = hasRatio ? nextVal / currentVal : 0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          margin: const EdgeInsets.only(top: 8),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 35),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text('単勝', style: TextStyle(fontSize: 8, color: Colors.white)),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                entry.value,
                                style: const TextStyle(fontSize: 10, color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              if (fukuMin.isNotEmpty || fukuMax.isNotEmpty) ...<Widget>[
                                Stack(
                                  children: <Widget>[
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(top: 8, right: 3, left: 3),
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            fukuMin,
                                            style: const TextStyle(fontSize: 10, color: Colors.white),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 1),
                                          Container(width: 1, height: 5, color: Colors.white),
                                          const SizedBox(height: 1),
                                          Text(
                                            fukuMax,
                                            style: const TextStyle(fontSize: 10, color: Colors.white),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: Text('複勝', style: TextStyle(fontSize: 8, color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                              width: 12,
                              height: 12,
                              child: Center(
                                child: Text(
                                  entryTimingKey,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: circleColor == Colors.red ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            OddsUpDownIcon(
                              current: entry.value,
                              prev: () {
                                for (int i = entry.key - 1; i >= 0; i--) {
                                  if (timeline[i].isNotEmpty) {
                                    return timeline[i];
                                  }
                                }
                                return null;
                              }(),
                              label: '単',
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (nextTimeline != null) ...<Widget>[
                      const SizedBox(height: 50),
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: hasRatio && ratio >= 2.0
                                ? const Color(0xFFFBB6CE).withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          children: <Widget>[
                            const Spacer(),
                            Text(
                              hasRatio ? ratio.toStringAsFixed(2) : '',
                              style: TextStyle(
                                fontSize: 10,
                                color: hasRatio && ratio >= 2.0
                                    ? const Color(0xFFFBB6CE)
                                    : Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
