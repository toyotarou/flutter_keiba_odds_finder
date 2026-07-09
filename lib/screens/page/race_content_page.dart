import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../models/horse_model.dart';
import '../../models/odds_model.dart';
import '../../models/race_model.dart';
import '../../models/race_result_model.dart';
import '../../utility/utility.dart';
import '../components/horse_detail_display_alert.dart';
import '../components/horse_odds_ranking_display_alert.dart';
import '../components/popularity_record_display_alert.dart';
import '../components/similar_races_display_alert.dart';
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

class _RaceContentPageState extends ConsumerState<RaceContentPage> with ControllersMixin<RaceContentPage> {
  final AutoScrollController _horseListScrollController = AutoScrollController();
  int _currentHorseIndex = 0;
  int _displayListLength = 0;

  Timer? _countdownTimer;
  final ValueNotifier<int> _remainingSecondsNotifier = ValueNotifier<int>(0);
  String _lastStartTime = '';

  final Utility _utility = Utility();
  final GlobalKey _harandoKey = GlobalKey();

  ///
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _remainingSecondsNotifier.dispose();
    _horseListScrollController.dispose();
    super.dispose();
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
        0 => 999,
        _ when timingParts[i] == '0' => -999,
        _ => int.tryParse(timingParts[i]) ?? 0,
      },
    );
  }

  ///
  static int? _resolveFilterMinutes(String selectedTiming, List<OddsModel> oddsModelList) {
    if (selectedTiming.isNotEmpty) {
      if (selectedTiming == '0') {
        return -999;
      }
      final int parsed = int.tryParse(selectedTiming) ?? 0;
      if (parsed == 24) {
        return oddsModelList.any((OddsModel e) => e.minutesBeforeStart == 24) ? 24 : 999;
      }
      return parsed;
    }
    if (oddsModelList.any((OddsModel e) => e.minutesBeforeStart == -999)) {
      return -999;
    }
    if (oddsModelList.isNotEmpty && oddsModelList.every((OddsModel e) => e.minutesBeforeStart == 999)) {
      return 999;
    }
    final List<int> validValues =
        oddsModelList.map((OddsModel e) => e.minutesBeforeStart).where((int v) => v >= 0).toList()..sort();
    return validValues.isNotEmpty ? validValues.first : null;
  }

  ///
  static String _filterMinutesToTimingKey(int? filterMinutes) => switch (filterMinutes) {
    null => '',
    999 => '24',
    -999 => '0',
    _ => filterMinutes.toString(),
  };

  ///
  static String _resolveMinTiming(List<OddsModel> oddsModelList) {
    if (oddsModelList.any((OddsModel e) => e.minutesBeforeStart == -999)) {
      return '0';
    }
    if (oddsModelList.isNotEmpty && oddsModelList.every((OddsModel e) => e.minutesBeforeStart == 999)) {
      return '24';
    }
    final List<OddsModel> validList = oddsModelList.where((OddsModel e) => e.minutesBeforeStart >= 0).toList()
      ..sort((OddsModel a, OddsModel b) => a.minutesBeforeStart.compareTo(b.minutesBeforeStart));
    return validList.isNotEmpty ? validList.first.minutesBeforeStart.toString() : '';
  }

  ///
  List<OddsModel> _buildDisplayList() {
    final List<OddsModel> allOdds = (widget.oddsMap[widget.mapKey] ?? <OddsModel>[])
        .where((OddsModel e) => e.race == widget.raceNumber)
        .toList();

    final int? filterMinutes = _resolveFilterMinutes(appParamState.selectedTiming, allOdds);

    return (filterMinutes != null
          ? allOdds.where((OddsModel e) => e.minutesBeforeStart == filterMinutes).toList()
          : allOdds)
      ..sort((OddsModel a, OddsModel b) => (double.tryParse(a.odds) ?? 0).compareTo(double.tryParse(b.odds) ?? 0));
  }

  ///
  Widget _buildRaceInfoBar(String startTime, String raceName) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const SizedBox(),
                  Column(
                    children: <Widget>[
                      Text('$startTime 出走', style: const TextStyle(fontSize: 12, color: Colors.greenAccent)),
                      ValueListenableBuilder<int>(
                        valueListenable: _remainingSecondsNotifier,
                        builder: (BuildContext context, int seconds, Widget? _) =>
                            Text(_formatCountdown(seconds), style: const TextStyle(fontSize: 13, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
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
                          child: Text(
                            raceName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(),
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
        (widget.oddsMap[widget.mapKey] ?? <OddsModel>[])
            .where((OddsModel o) => o.race == widget.raceNumber && o.minutesBeforeStart == -999)
            .toList()
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
  Widget _buildSimilarRaceButton(int raceIdx) {
    if (raceIdx == -1) {
      return const SizedBox.shrink();
    }

    final List<RaceModel>? races = widget.raceMap[widget.mapKey];
    if (races == null || raceIdx >= races.length) {
      return const SizedBox.shrink();
    }

    final RaceModel currentRace = races[raceIdx];
    if (currentRace.popularityRatioTableIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => OddsFinderDialog(
        context: context,
        widget: SimilarRacesDisplayAlert(raceModel: currentRace),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFBB6CE)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          '類似',
          style: TextStyle(fontSize: 10, color: Color(0xFFFBB6CE), fontWeight: FontWeight.bold),
        ),
      ),
    );
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
                appParamNotifier.setIsShowUpperBox2(flag: true);
                OddsFinderDialog(context: context, widget: const HorseOddsRankingDisplayAlert());
              },
              child: Icon(Icons.list, color: Colors.white.withValues(alpha: 0.5)),
            ),

            const SizedBox(width: 15),

            _buildSimilarRaceButton(raceIdx),
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
    final List<OddsModel> oddsModelList = (widget.oddsMap[widget.mapKey] ?? <OddsModel>[])
        .where((OddsModel e) => e.race == widget.raceNumber)
        .toList();

    final String minTiming = _resolveMinTiming(oddsModelList);

    if (appParamState.selectedTiming.isEmpty && minTiming.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          appParamNotifier.setSelectedTiming2(timing2: minTiming);
        }
      });
    }

    return Row(
      children: appParamState.configOddsGetTiming.split('|').map((String e) {
        return Expanded(
          child: GestureDetector(
            onTap: () => appParamNotifier.setSelectedTiming(timing: appParamState.selectedTiming == e ? '' : e),
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                color: (appParamState.selectedTiming == e)
                    ? Colors.greenAccent.withValues(alpha: 0.1)
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
  Widget _displayRaceHorseList() {
    final List<OddsModel> oddsModelList = (widget.oddsMap[widget.mapKey] ?? <OddsModel>[])
        .where((OddsModel e) => e.race == widget.raceNumber)
        .toList();

    final Map<int, HorseModel> horseModelMap = <int, HorseModel>{
      for (final HorseModel e in (widget.horseMap[widget.mapKey] ?? <HorseModel>[]).where(
        (HorseModel e) => e.race == widget.raceNumber,
      ))
        e.num: e,
    };

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

    final int? filterMinutes = _resolveFilterMinutes(selectedTiming, displayList);
    final String activeTimingKey = _filterMinutesToTimingKey(filterMinutes);

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

    // 馬番 → 着順（1-3着のみ）
    final Map<int, int> numToRankMap = <int, int>{
      for (final RaceResultModel r in (widget.raceResultMap[widget.mapKey] ?? <RaceResultModel>[]).where(
        (RaceResultModel r) => r.race == widget.raceNumber && r.result <= 3,
      ))
        r.num: r.result,
    };

    return ListView.builder(
      controller: _horseListScrollController,
      itemCount: displayList.length,
      itemBuilder: (BuildContext context, int index) {
        final OddsModel element = displayList[index];
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
    List<String>? nextOddsTimeline,
    int? fukuRank,
    int? raceRank,
  }) {
    final int popularity = index + 1;
    final HorseModel? horse = horseModelMap[element.num];
    final List<String>? oddsTimeline = oddsTimelineMap[element.num];
    final List<String>? fukuMinTimeline = fukuMinTimelineMap[element.num];
    final List<String>? fukuMaxTimeline = fukuMaxTimelineMap[element.num];

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 5,
            right: 30,

            child: oddsTimeline != null && oddsTimeline.isNotEmpty
                ? SizedBox(width: 150, child: _buildJudgeOddsSection(oddsTimeline))
                : const SizedBox.shrink(),
          ),

          ExpansionTile(
            key: ValueKey<String>('horse_${element.num}_${appParamState.allExpanded}'),
            initiallyExpanded: appParamState.allExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Stack(
              children: <Widget>[
                if (raceRank != null && raceRank <= 3) ...<Widget>[
                  Positioned(
                    top: (context.screenSize.height * 0.08) * -1,
                    right: (context.screenSize.width * 0.08) * -1,

                    child: CustomPaint(
                      painter: RankBadgePainter(
                        color: switch (raceRank) {
                          1 => const Color(0xFFFFD700).withValues(alpha: 0.3),
                          2 => const Color(0xFFC0C0C0).withValues(alpha: 0.3),
                          3 => const Color(0xFFCD7F32).withValues(alpha: 0.3),
                          _ => Colors.transparent,
                        },
                      ),

                      child: SizedBox(
                        width: context.screenSize.width * 0.2,
                        height: context.screenSize.height * 0.15,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30, left: 25),
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

                DefaultTextStyle(
                  style: const TextStyle(fontSize: 10),
                  child: Column(
                    children: <Widget>[
                      _buildHorseItemHeader(popularity: popularity, fukuRank: fukuRank, timeline: oddsTimeline),
                      const SizedBox(height: 10),
                      _buildHorseNameRow(element: element, horse: horse, horseWakuColorMap: horseWakuColorMap),
                    ],
                  ),
                ),
              ],
            ),

            children: <Widget>[
              if (oddsTimeline != null) ...<Widget>[
                const SizedBox(height: 20),
                _buildOddsTimelineRow(
                  timeline: oddsTimeline,
                  activeTimingKey: activeTimingKey,
                  selectedTiming: selectedTiming,
                  fukuMinList: fukuMinTimeline,
                  fukuMaxList: fukuMaxTimeline,
                  nextTimeline: nextOddsTimeline,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  ///
  Widget _buildJudgeOddsSection(List<String> timeline) {
    final List<String> timingParts = widget.oddsGetTiming.split('|');
    final String odds24 = timeline[0];
    final int idx3 = timingParts.indexOf('3');
    final String odds3 = idx3 != -1 && idx3 < timeline.length ? timeline[idx3] : '';

    if (odds24.isEmpty || odds3.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, dynamic> judged = _utility.judgeOdds(
      before24: double.tryParse(odds24) ?? 0,
      before3: double.tryParse(odds3) ?? 0,
      rateHonmei: double.tryParse(appParamState.configOddsDropRateHonmei) ?? 0,
      rateChuAna: double.tryParse(appParamState.configOddsDropRateChuana) ?? 0,
    );

    if (judged['display'] != true) {
      return const SizedBox.shrink();
    }

    // as String → as String? でクラッシュを防止
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 10, color: Colors.yellowAccent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[Text((judged['message'] as String?) ?? ''), Text((judged['description'] as String?) ?? '')],
      ),
    );
  }

  ///
  Widget _buildHorseItemHeader({required int popularity, int? fukuRank, List<String>? timeline}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          width: context.screenSize.width * 0.4,
          child: Row(
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
                        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 20,
                            child: Text(fukuRank.toString(), style: const TextStyle(color: Colors.blue)),
                          ),
                          const Text('番人気', style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                    const Positioned(
                      left: 15,
                      child: Text('複勝', style: TextStyle(fontSize: 10, color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  ///
  Widget _buildPopularityHorseRow({required List<OddsModel> displayList}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: displayList.asMap().entries.map((MapEntry<int, OddsModel> entry) {
                final int index = entry.key + 1;
                final OddsModel o = entry.value;

                String average = '';
                String upsetScore = '';
                if (appParamState.keepPopularityRankOddsAverageMap[index] != null) {
                  average = appParamState.keepPopularityRankOddsAverageMap[index]!.oddsAverage;
                  upsetScore = (average.toDouble() / o.odds.toDouble()).toStringAsFixed(2);
                }

                return Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
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
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
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
                            Text('2023年以降の人気順の平均オッズ（A）'),
                            Text('このレースの人気順のオッズ（B）'),
                            Text('「A / B」を行うことで、期待数値がわかります。'),
                            Text('人気順のどこに高い数値が出るかによって、レースの期待数値が決まります。'),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            appParamNotifier.setSelectedPopularityRank(rank: 0);
                            appParamNotifier.setSelectedPopularityRankYear(year: '');
                            OddsFinderDialog(context: context, widget: const PopularityRecordDisplayAlert());
                          },
                          child: const Text('過去オッズレコード', style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text('期待数値とは？', style: TextStyle(fontSize: 10, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 3),
      ],
    );
  }

  ///
  Widget _buildHorseNameRow({
    required OddsModel element,
    required HorseModel? horse,
    required Map<int, Color> horseWakuColorMap,
  }) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white),
      child: Stack(
        children: <Widget>[
          DefaultTextStyle(
            style: const TextStyle(fontSize: 12, color: Colors.white),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 20),
                if (horse != null) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: (horseWakuColorMap[horse.waku] != null)
                          ? horseWakuColorMap[horse.waku]!.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(fontSize: 12),
                      child: DefaultTextStyle(
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 15, child: Text(horse.waku.toString())),
                            const Text('枠'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 20),
                DefaultTextStyle(
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 20, child: Text(element.num.toString())),
                      const Text('番'),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                if (horse != null) ...<Widget>[
                  Expanded(child: Text(horse.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ],
            ),
          ),

          Positioned(
            right: 0,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(-1.0, 1.0),
              child: GestureDetector(
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
                child: Icon(FontAwesomeIcons.horse, size: 20, color: Colors.green[500]!.withValues(alpha: 0.6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///
  Widget _buildOddsTimelineRow({
    required List<String> timeline,
    required String activeTimingKey,
    required String selectedTiming,
    List<String>? fukuMinList,
    List<String>? fukuMaxList,
    List<String>? nextTimeline,
  }) {
    final List<String> timingKeys = widget.oddsGetTiming.split('|');

    int oddsEdgeNum = 0;
    if (nextTimeline != null) {
      for (final MapEntry<int, String> entry in timeline.asMap().entries) {
        if (entry.value.isNotEmpty && entry.key < nextTimeline.length) {
          final double? next = double.tryParse(nextTimeline[entry.key]);
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
                child: const Text('オッズ断層数値', style: TextStyle(fontSize: 10, color: Color(0xFFFBB6CE))),
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

            final String circleMinute = entry.key == 0
                ? '24'
                : entry.key == timingKeys.length - 1
                ? '0'
                : entryTimingKey;

            final String fukuMin = fukuMinList?[entry.key] ?? '';
            final String fukuMax = fukuMaxList?[entry.key] ?? '';

            final double? nextVal = (nextTimeline != null && entry.key < nextTimeline.length)
                ? double.tryParse(nextTimeline[entry.key])
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('単勝', style: TextStyle(fontSize: 8, color: Colors.white)),
                                    SizedBox.shrink(),
                                  ],
                                ),
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
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('複勝', style: TextStyle(fontSize: 8, color: Colors.white)),
                                          SizedBox.shrink(),
                                        ],
                                      ),
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
                                  circleMinute,
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
                          border: Border.all(color: const Color(0xFFFBB6CE).withValues(alpha: 0.4)),
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

  ///
  @override
  Widget build(BuildContext context) {
    final List<RaceModel> races = widget.raceMap[widget.mapKey] ?? <RaceModel>[];
    final int raceIdx = races.indexWhere((RaceModel e) => e.race == widget.raceNumber);

    String raceName = '';
    String startTime = '--:--';

    if (raceIdx != -1) {
      final RaceModel race = races[raceIdx];
      raceName = race.raceName;
      final int colonIdx = race.startTime.lastIndexOf(':');
      startTime = colonIdx > 0 ? race.startTime.substring(0, colonIdx) : race.startTime;
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

    final Map<int, RaceResultModel> raceResultByRank = Map<int, RaceResultModel>.fromEntries(
      (widget.raceResultMap[widget.mapKey] ?? <RaceResultModel>[])
          .where((RaceResultModel e) => e.race == widget.raceNumber)
          .map((RaceResultModel e) => MapEntry<int, RaceResultModel>(e.result, e)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildRaceInfoBar(startTime, raceName),

        _buildControlButtons(raceIdx: raceIdx),

        if (displayList.isNotEmpty) ...<Widget>[
          SideTabPanel(
            tabLabels: raceResultByRank.isEmpty ? <String>['期待数値'] : <String>['期待数値', 'レース結果'],
            tabWidth: 90,
            tabGap: 0,
            height: 100,
            borderColor: Colors.white.withValues(alpha: 0.4),
            selectedIndex: raceResultByRank.isEmpty ? 0 : appParamState.selectedUpsetBoxNum,
            onSelected: (int i) => appParamNotifier.setSelectedUpsetBoxNum(num: i),
            panelChild: (raceResultByRank.isEmpty || appParamState.selectedUpsetBoxNum == 0)
                ? _buildPopularityHorseRow(displayList: displayList)
                : _buildRaceResultBox(raceResultByRank: raceResultByRank),
          ),
        ],

        Divider(color: Colors.white.withValues(alpha: 0.5)),

        SizedBox(height: 40, child: _displayRaceMinutesRow()),

        const SizedBox(height: 5),
        Expanded(child: _displayRaceHorseList()),
      ],
    );
  }
}
