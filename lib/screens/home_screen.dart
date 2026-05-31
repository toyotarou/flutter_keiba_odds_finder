import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/controllers_mixin.dart';
import '../main.dart';
import '../models/horse_model.dart';
import '../models/netkeiba_odds_model.dart';
import '../models/odds_model.dart';
import '../models/race_model.dart';
import '../models/schedule_model.dart';
import '../utility/utility.dart';
import 'components/horse_odds_ranking_display_alert.dart';
import 'parts/odds_finder_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.scheduleDateBashoMap,
    required this.raceMap,
    required this.horseMap,
    required this.oddsMap,
    required this.netkeibaOddsMap,
    required this.oddsGetTiming,
  });

  final Map<String, List<ScheduleModel>> scheduleDateBashoMap;
  final Map<String, List<RaceModel>> raceMap;
  final Map<String, List<HorseModel>> horseMap;
  final Map<String, List<OddsModel>> oddsMap;
  final Map<String, List<NetkeibaOddsModel>> netkeibaOddsMap;
  final String oddsGetTiming;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with ControllersMixin<HomeScreen> {
  final AutoScrollController _raceScrollController = AutoScrollController();
  final AutoScrollController _horseListScrollController = AutoScrollController();
  int _prevRaceNumber = 0;
  int _currentHorseIndex = 0;
  int _displayListLength = 0;

  Timer? _countdownTimer;
  final ValueNotifier<int> _remainingSecondsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> _currentTimeNotifier = ValueNotifier<String>('--:--');
  String _lastStartTime = '';

  Utility utility = Utility();

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAppParam());
  }

  ///
  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scheduleDateBashoMap != widget.scheduleDateBashoMap ||
        oldWidget.raceMap != widget.raceMap ||
        oldWidget.horseMap != widget.horseMap ||
        oldWidget.oddsMap != widget.oddsMap ||
        oldWidget.oddsGetTiming != widget.oddsGetTiming) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncAppParam());
    }
  }

  ///
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _remainingSecondsNotifier.dispose();
    _currentTimeNotifier.dispose();
    _raceScrollController.dispose();
    _horseListScrollController.dispose();
    super.dispose();
  }

  ///
  void _syncAppParam() {
    if (!mounted) {
      return;
    }
    appParamNotifier.setKeepScheduleDateBashoMap(map: widget.scheduleDateBashoMap);
    appParamNotifier.setKeepRaceMap(map: widget.raceMap);
    appParamNotifier.setKeepHorseMap(map: widget.horseMap);
    appParamNotifier.setKeepOddsMap(map: widget.oddsMap);
    appParamNotifier.setConfigOddsGetTiming(oddsGetTiming: widget.oddsGetTiming);
  }

  ///
  void _startCountdown(String startTime) {
    _countdownTimer?.cancel();

    if (startTime == '--:--') {
      _currentTimeNotifier.value = '--:--';
      _remainingSecondsNotifier.value = 0;
      return;
    }

    final List<String> parts = startTime.split(':');
    final int hour = int.tryParse(parts[0]) ?? 0;
    final int minute = int.tryParse(parts[1]) ?? 0;

    final DateTime now = DateTime.now();
    final DateTime raceTime = DateTime(now.year, now.month, now.day, hour, minute);
    final int diff = raceTime.difference(now).inSeconds;

    _currentTimeNotifier.value = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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
  static String _beforeMinutesText(String selectedTiming) {
    if (selectedTiming == '0') {
      return 'レース開始時点の';
    }
    if (selectedTiming.isNotEmpty) {
      return '$selectedTiming分前の';
    }
    return '';
  }

  ///
  Widget _buildOddsTimelineRow({
    required List<String> timeline,
    required String activeTimingKey,
    required String selectedTiming,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: timeline.asMap().entries.map((MapEntry<int, String> entry) {
        if (entry.value.isEmpty) {
          return Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2)),
          );
        }

        final String entryTimingKey = widget.oddsGetTiming.split('|')[entry.key];

        final Color circleColor = (selectedTiming == entryTimingKey)
            ? Colors.greenAccent
            : (selectedTiming.isEmpty && entryTimingKey == activeTimingKey)
            ? Colors.red
            : Colors.white;

        final List<String> exOddsGetTiming = widget.oddsGetTiming.split('|');
        final String circleMinute = entry.key == 0
            ? 'S'
            : entry.key == exOddsGetTiming.length - 1
            ? 'E'
            : exOddsGetTiming[entry.key];

        return Stack(
          children: <Widget>[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.2)),
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.only(bottom: 5),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(entry.value, style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                getUpDownIcon(entry: entry, timeLineMap: timeline.asMap().entries),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  ///
  @override
  Widget build(BuildContext context) {
    final int selected = appParamState.selectedRaceNumber;
    if (selected > 0 && selected != _prevRaceNumber) {
      _prevRaceNumber = selected;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _raceScrollController.scrollToIndex(selected - 1, preferPosition: AutoScrollPosition.middle);
        }
      });
    }

    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';

    String raceName = 'レースを選択してください';
    String startTime = '--:--';
    final List<RaceModel> raceModelList = widget.raceMap[mapKey] ?? <RaceModel>[];

    if (widget.raceMap[mapKey] != null && appParamState.selectedRaceNumber > 0) {
      final RaceModel race = widget.raceMap[mapKey]!.firstWhere(
        (RaceModel e) => e.race == appParamState.selectedRaceNumber,
      );
      raceName = race.raceName;
      startTime = race.startTime.substring(0, race.startTime.lastIndexOf(':'));
    }

    if (startTime != _lastStartTime) {
      _lastStartTime = startTime;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startCountdown(startTime);
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            right: 0,
            child: Opacity(opacity: 0.4, child: Image.asset('assets/images/bg.png', width: 220)),
          ),

          Positioned(
            top: 70,
            left: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Opacity(
                  opacity: 0.3,
                  child: Transform.scale(
                    scaleX: 1.0,
                    scaleY: 2.0,
                    alignment: Alignment.centerLeft,
                    child: Image.asset('assets/images/baganryoku_title.png', width: 180),
                  ),
                ),

                const SizedBox(width: 20),

                Transform.scale(
                  scaleX: 1.0,
                  scaleY: 4.0,
                  child: Text('ODDS FINDER', style: TextStyle(fontSize: 14, color: Colors.green[700])),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DefaultTextStyle(
                style: const TextStyle(fontSize: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 40),

                    //=====================//
                    Row(
                      children: widget.scheduleDateBashoMap.entries.map((MapEntry<String, List<ScheduleModel>> e) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              appParamNotifier.setSelectedScheduleDate(date: e.key);
                              appParamNotifier.setSelectedScheduleKaisuuBashoDay(kbd: '', name: '');
                              appParamNotifier.setSelectedRaceNumber(num: 0);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: (appParamState.selectedScheduleDate == e.key)
                                    ? Colors.greenAccent.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.3),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                              ),
                              alignment: Alignment.center,
                              child: Text(e.key, style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    //=====================//
                    const SizedBox(height: 5),

                    //=====================//
                    if (widget.scheduleDateBashoMap[appParamState.selectedScheduleDate] != null) ...<Widget>[
                      Row(
                        children: widget.scheduleDateBashoMap[appParamState.selectedScheduleDate]!.map((
                          ScheduleModel e,
                        ) {
                          final String label = '${e.kaisuu}回 ${e.bashoName} ${e.day}日';
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                appParamNotifier.setSelectedScheduleKaisuuBashoDay(
                                  kbd: '${e.kaisuu}_${e.basho}_${e.day}',
                                  name: label,
                                );
                                appParamNotifier.setSelectedRaceNumber(num: 0);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                  color: (appParamState.selectedScheduleKaisuuBashoDayName == label)
                                      ? Colors.greenAccent.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                ),
                                alignment: Alignment.center,
                                child: Text(label, style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...<Widget>[
                      if (widget.scheduleDateBashoMap.isNotEmpty) ...<Widget>[
                        const Text('日付を選択してください', style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
                      ],
                    ],

                    //=====================//
                    const SizedBox(height: 5),

                    //=====================//
                    if (widget.raceMap[mapKey] != null) ...<Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 5),

                          SingleChildScrollView(
                            controller: _raceScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List<Widget>.generate(widget.raceMap[mapKey]!.length, (int index) {
                                return AutoScrollTag(
                                  key: ValueKey<int>(index),
                                  controller: _raceScrollController,
                                  index: index,
                                  child: GestureDetector(
                                    onTap: () => appParamNotifier.setSelectedRaceNumber(num: index + 1),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: CircleAvatar(
                                        backgroundColor: (appParamState.selectedRaceNumber == index + 1)
                                            ? Colors.greenAccent.withValues(alpha: 0.2)
                                            : Colors.black.withValues(alpha: 0.4),
                                        child: Text(
                                          raceModelList[index].race.toString(),
                                          style: const TextStyle(fontSize: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Divider(color: Colors.white.withValues(alpha: 0.5), thickness: 5),

                          const SizedBox(height: 5),

                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: Stack(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const SizedBox(),

                                    ValueListenableBuilder<int>(
                                      valueListenable: _remainingSecondsNotifier,
                                      builder: (BuildContext context, int seconds, Widget? _) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: <Widget>[
                                            ValueListenableBuilder<String>(
                                              valueListenable: _currentTimeNotifier,
                                              builder: (BuildContext context, String time, Widget? _) {
                                                return Text(
                                                  time,
                                                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                                                );
                                              },
                                            ),
                                            Text(
                                              _formatCountdown(seconds),
                                              style: const TextStyle(fontSize: 13, color: Colors.white),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      '🚩　$startTime　$raceName',
                                      style: (raceName == 'レースを選択してください')
                                          ? const TextStyle(color: Colors.greenAccent, fontSize: 12)
                                          : const TextStyle(fontSize: 14, color: Colors.white),
                                    ),

                                    const SizedBox(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...<Widget>[
                      if (widget.scheduleDateBashoMap[appParamState.selectedScheduleDate] != null) ...<Widget>[
                        const Text('会場を選択してください', style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
                      ],
                    ],

                    //=====================//
                    const SizedBox(height: 5),

                    //=====================//
                    if (appParamState.selectedRaceNumber > 0) ...<Widget>[
                      SizedBox(height: 40, child: displayRaceMinutesRow()),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              IconButton(
                                onPressed: () async {
                                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString(
                                    'reload_selected_schedule_date',
                                    appParamState.selectedScheduleDate,
                                  );
                                  await prefs.setString(
                                    'reload_selected_schedule_kaisuu_basho_day',
                                    appParamState.selectedScheduleKaisuuBashoDay,
                                  );
                                  await prefs.setString(
                                    'reload_selected_schedule_kaisuu_basho_day_name',
                                    appParamState.selectedScheduleKaisuuBashoDayName,
                                  );
                                  await prefs.setInt('reload_selected_race_number', appParamState.selectedRaceNumber);

                                  if (mounted) {
                                    // ignore: use_build_context_synchronously
                                    context.findAncestorStateOfType<AppRootState>()?.restartApp();
                                  }
                                },
                                icon: const Icon(Icons.refresh, color: Colors.greenAccent),
                              ),

                              if (!kIsWeb) ...<Widget>[
                                IconButton(
                                  onPressed: () {
                                    OddsFinderDialog(context: context, widget: HorseOddsRankingDisplayAlert());
                                  },
                                  icon: Icon(Icons.list, color: Colors.white.withValues(alpha: 0.5)),
                                ),
                              ],
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
                      ),

                      if (widget.scheduleDateBashoMap.isNotEmpty) ...<Widget>[
                        Divider(color: Colors.white.withValues(alpha: 0.5)),
                        const SizedBox(height: 5),
                      ],

                      Expanded(child: displayRaceHorseList()),
                    ],

                    //=====================//
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///
  Widget displayRaceMinutesRow() {
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';

    final Map<String, String> ogtNamesMap = Map<String, String>.fromEntries(
      appParamState.configOddsGetTiming
          .split('|')
          .map(
            (String e) => MapEntry<String, String>(
              e,
              e == '24'
                  ? 'S'
                  : e == '0'
                  ? 'E'
                  : e,
            ),
          ),
    );

    final List<OddsModel> oddsModelList = <OddsModel>[];
    if (widget.raceMap[mapKey] != null && appParamState.selectedRaceNumber > 0) {
      for (final OddsModel element in widget.oddsMap[mapKey] ?? <OddsModel>[]) {
        if (element.race == appParamState.selectedRaceNumber) {
          oddsModelList.add(element);
        }
      }
    }

    final String minTiming;
    if (oddsModelList.any((OddsModel e) => e.minutesBeforeStart == -999)) {
      minTiming = '0';
    } else if (oddsModelList.isNotEmpty && oddsModelList.every((OddsModel e) => e.minutesBeforeStart == 999)) {
      minTiming = '24';
    } else {
      final List<OddsModel> validList = oddsModelList.where((OddsModel e) => e.minutesBeforeStart >= 0).toList()
        ..sort((OddsModel a, OddsModel b) => a.minutesBeforeStart.compareTo(b.minutesBeforeStart));
      minTiming = validList.isNotEmpty ? validList.first.minutesBeforeStart.toString() : '';
    }

    return Row(
      children: appParamState.configOddsGetTiming.split('|').map((String e) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              appParamNotifier.setSelectedTiming(timing: appParamState.selectedTiming == e ? '' : e);
            },
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
              ),
              alignment: Alignment.center,
              child: Text(ogtNamesMap[e] ?? '', style: const TextStyle(color: Colors.white)),
            ),
          ),
        );
      }).toList(),
    );
  }

  ///
  Widget displayRaceHorseList() {
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';

    final List<OddsModel> oddsModelList = <OddsModel>[];
    final List<NetkeibaOddsModel> netkeibaOddsModelList = <NetkeibaOddsModel>[];
    final Map<int, HorseModel> horseModelMap = <int, HorseModel>{};

    if (widget.raceMap[mapKey] != null && appParamState.selectedRaceNumber > 0) {
      for (final OddsModel e in widget.oddsMap[mapKey] ?? <OddsModel>[]) {
        if (e.race == appParamState.selectedRaceNumber) {
          oddsModelList.add(e);
        }
      }
      for (final NetkeibaOddsModel e in widget.netkeibaOddsMap[mapKey] ?? <NetkeibaOddsModel>[]) {
        if (e.race == appParamState.selectedRaceNumber) {
          netkeibaOddsModelList.add(e);
        }
      }
      for (final HorseModel e in widget.horseMap[mapKey] ?? <HorseModel>[]) {
        if (e.race == appParamState.selectedRaceNumber) {
          horseModelMap[e.num] = e;
        }
      }
    }

    oddsModelList.sort((OddsModel a, OddsModel b) {
      final int cmp = a.num.compareTo(b.num);
      return cmp != 0 ? cmp : b.minutesBeforeStart.compareTo(a.minutesBeforeStart);
    });
    netkeibaOddsModelList.sort((NetkeibaOddsModel a, NetkeibaOddsModel b) {
      final int cmp = a.num.compareTo(b.num);
      return cmp != 0 ? cmp : b.minutesBeforeStart.compareTo(a.minutesBeforeStart);
    });

    final List<String> timingParts = widget.oddsGetTiming.split('|');
    final List<int> timingOrder = List<int>.generate(timingParts.length, (int i) {
      if (i == 0) {
        return 999;
      }
      if (timingParts[i] == '0') {
        return -999;
      }
      return int.parse(timingParts[i]);
    });

    final Map<int, List<String>> oddsTimelineMap = <int, List<String>>{};
    for (final OddsModel e in oddsModelList) {
      oddsTimelineMap.putIfAbsent(e.num, () => List<String>.filled(timingParts.length, ''));
      final int idx = timingOrder.indexOf(e.minutesBeforeStart);
      if (idx != -1) {
        oddsTimelineMap[e.num]![idx] = e.odds;
      }
    }

    final Map<int, List<String>> netkeibaOddsTimelineMap = <int, List<String>>{};
    for (final NetkeibaOddsModel e in netkeibaOddsModelList) {
      netkeibaOddsTimelineMap.putIfAbsent(e.num, () => List<String>.filled(timingParts.length, ''));
      final int idx = timingOrder.indexOf(e.minutesBeforeStart);
      if (idx != -1) {
        netkeibaOddsTimelineMap[e.num]![idx] = e.odds;
      }
    }

    // oddsModelListはnum昇順・minutesBeforeStart降順済みなので
    // 後から上書きするほど minutesBeforeStart が小さい（＝最新）レコードになる
    final Map<int, Map<String, String>> fukuOddsMap = <int, Map<String, String>>{};
    for (final OddsModel e in oddsModelList) {
      fukuOddsMap[e.num] = <String, String>{'fukuMin': e.fukuMin, 'fukuMax': e.fukuMax};
    }

    int? filterMinutes;
    final String selectedTiming = appParamState.selectedTiming;

    if (selectedTiming.isNotEmpty) {
      if (selectedTiming == '0') {
        filterMinutes = -999;
      } else {
        final int parsed = int.parse(selectedTiming);
        if (parsed == 24) {
          filterMinutes = oddsModelList.any((OddsModel e) => e.minutesBeforeStart == 24) ? 24 : 999;
        } else {
          filterMinutes = parsed;
        }
      }
    } else if (oddsModelList.any((OddsModel e) => e.minutesBeforeStart == -999)) {
      filterMinutes = -999;
    } else if (oddsModelList.isNotEmpty && oddsModelList.every((OddsModel e) => e.minutesBeforeStart == 999)) {
      filterMinutes = 999;
    } else {
      final List<int> validValues =
          oddsModelList.map((OddsModel e) => e.minutesBeforeStart).where((int v) => v >= 0).toList()..sort();
      filterMinutes = validValues.isNotEmpty ? validValues.first : null;
    }

    final String activeTimingKey = filterMinutes == null
        ? ''
        : filterMinutes == 999
        ? '24'
        : filterMinutes == -999
        ? '0'
        : filterMinutes.toString();

    final List<OddsModel> displayList =
        (filterMinutes != null
              ? oddsModelList.where((OddsModel e) => e.minutesBeforeStart == filterMinutes).toList()
              : oddsModelList)
          ..sort((OddsModel a, OddsModel b) => (double.tryParse(a.odds) ?? 0).compareTo(double.tryParse(b.odds) ?? 0));

    if (displayList.isEmpty) {
      _displayListLength = 0;
      return Text(
        '${_beforeMinutesText(selectedTiming)}オッズデータはありません。',
        style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
      );
    }

    _displayListLength = displayList.length;

    final Map<int, Color> horseWakuColorMap = utility.getHorseWakuColorMap();

    return ListView.builder(
      controller: _horseListScrollController,
      itemCount: displayList.length,
      itemBuilder: (BuildContext context, int index) {
        final OddsModel element = displayList[index];
        final int popularity = index + 1;
        final HorseModel? horse = horseModelMap[element.num];
        final List<String>? oddsTimeline = oddsTimelineMap[element.num];
        final List<String>? netkeibaTimeline = netkeibaOddsTimelineMap[element.num];

        return AutoScrollTag(
          key: ValueKey<int>(index),
          controller: _horseListScrollController,
          index: index,
          child: Stack(
            children: <Widget>[
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.1), width: 10)),
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.2), width: 2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Opacity(
                          opacity: 0.4,
                          child: Container(
                            margin: const EdgeInsets.only(top: 5, left: 15),
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 20,
                                  child: Text(popularity.toString(), style: const TextStyle(color: Colors.greenAccent)),
                                ),
                                const Text('番人気', style: TextStyle(color: Colors.greenAccent)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox.shrink(),
                      ],
                    ),

                    const SizedBox(height: 10),

                    DefaultTextStyle(
                      style: const TextStyle(color: Colors.white),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 20),

                          if (horse != null) ...<Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: (horseWakuColorMap[horse.waku] != null)
                                    ? horseWakuColorMap[horse.waku]!.withValues(alpha: 0.2)
                                    : Colors.yellowAccent.withValues(alpha: 0.2),
                              ),

                              child: DefaultTextStyle(
                                style: const TextStyle(fontSize: 12),
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(width: 15, child: Text(horse.waku.toString())),
                                    const Text('枠'),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(width: 20),

                          Row(
                            children: <Widget>[
                              SizedBox(width: 20, child: Text(element.num.toString())),
                              const Text('番'),
                            ],
                          ),

                          const SizedBox(width: 20),

                          if (horse != null) ...<Widget>[
                            Expanded(child: Text(horse.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const SizedBox.shrink(),
                        DefaultTextStyle(
                          style: const TextStyle(fontSize: 12),
                          child: Row(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1)),
                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                                child: const Text('複勝（最終）', style: TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.5))),
                                ),
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text(
                                  fukuOddsMap[element.num]!['fukuMin'] ?? '',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(child: Text(' / ')),
                              Container(
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.5))),
                                ),
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text(
                                  fukuOddsMap[element.num]!['fukuMax'] ?? '',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (oddsTimeline != null) ...<Widget>[
                      const SizedBox(height: 10),
                      _buildSourceLabel('JRA'),
                      const SizedBox(height: 5),
                      _buildOddsTimelineRow(
                        timeline: oddsTimeline,
                        activeTimingKey: activeTimingKey,
                        selectedTiming: selectedTiming,
                      ),
                    ],

                    if (netkeibaTimeline != null) ...<Widget>[
                      const SizedBox(height: 10),
                      _buildSourceLabel('ネットケイバ'),
                      const SizedBox(height: 5),
                      _buildOddsTimelineRow(
                        timeline: netkeibaTimeline,
                        activeTimingKey: activeTimingKey,
                        selectedTiming: selectedTiming,
                      ),
                    ],

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///
  static Widget _buildSourceLabel(String label) {
    return Container(
      margin: const EdgeInsets.only(left: 15),
      padding: const EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.2), width: 5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.greenAccent)),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  ///
  Widget getUpDownIcon({required MapEntry<int, String> entry, required Iterable<MapEntry<int, String>> timeLineMap}) {
    if (entry.key == 0 || entry.value.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<MapEntry<int, String>> list = timeLineMap.toList();
    String prevValue = '';
    for (int i = entry.key - 1; i >= 0; i--) {
      if (list[i].value.isNotEmpty) {
        prevValue = list[i].value;
        break;
      }
    }

    if (prevValue.isEmpty) {
      return const SizedBox.shrink();
    }

    final double? current = double.tryParse(entry.value);
    final double? prev = double.tryParse(prevValue);

    if (current == null || prev == null) {
      return const SizedBox.shrink();
    }

    if (current > prev) {
      return const Icon(Icons.arrow_upward, size: 15, color: Colors.redAccent);
    } else if (current < prev) {
      return const Icon(Icons.arrow_downward, size: 15, color: Colors.greenAccent);
    } else {
      return const Icon(Icons.drag_handle, size: 15, color: Colors.white54);
    }
  }
}
