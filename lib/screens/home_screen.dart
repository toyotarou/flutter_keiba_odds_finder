import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/controllers_mixin.dart';
import '../main.dart';
import '../models/horse_model.dart';
import '../models/odds_model.dart';
import '../models/race_model.dart';
import '../models/schedule_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.scheduleDateBashoMap,
    required this.raceMap,
    required this.horseMap,
    required this.oddsMap,
    required this.oddsGetTiming,
  });

  final Map<String, List<ScheduleModel>> scheduleDateBashoMap;
  final Map<String, List<RaceModel>> raceMap;
  final Map<String, List<HorseModel>> horseMap;
  final Map<String, List<OddsModel>> oddsMap;
  final String oddsGetTiming;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with ControllersMixin<HomeScreen> {
  final AutoScrollController _raceScrollController = AutoScrollController();
  int _prevRaceNumber = 0;

  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  String _dummyCurrentTime = '--:--';
  String _lastStartTime = '';

  ///
  @override
  void initState() {
    super.initState();
  }

  ///
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _raceScrollController.dispose();
    super.dispose();
  }

  ///
  void _startCountdown(String startTime) {
    _countdownTimer?.cancel();

    if (startTime == '--:--') {
      setState(() {
        _dummyCurrentTime = '--:--';
        _remainingSeconds = 0;
      });
      return;
    }

    final List<String> parts = startTime.split(':');
    final int hour = int.tryParse(parts[0]) ?? 0;
    final int minute = int.tryParse(parts[1]) ?? 0;

    final DateTime raceTime = DateTime(2000, 1, 1, hour, minute);

    // ignore: flutter_style_todos
    // TODO: ダミー実装。現在時刻に直す際はここを変更する。
    // 本来は DateTime.now() から raceTime までの差分を _remainingSeconds にセットし、
    // _dummyCurrentTime も DateTime.now() の時刻文字列に置き換える。
    // 00:00:00 になったらそのまま止まる仕様でOK。
    final DateTime dummyTime = raceTime.subtract(const Duration(minutes: 20));

    setState(() {
      _dummyCurrentTime =
          // ignore: flutter_style_todos
          '${dummyTime.hour.toString().padLeft(2, '0')}:${dummyTime.minute.toString().padLeft(2, '0')}'; // TODO: DateTime.now() の HH:mm に置き換える
      // ignore: flutter_style_todos
      _remainingSeconds = 20 * 60; // TODO: raceTime.difference(DateTime.now()).inSeconds に置き換える
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  ///
  String _formatCountdown(int totalSeconds) {
    final int h = totalSeconds ~/ 3600;
    final int m = (totalSeconds % 3600) ~/ 60;
    final int s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  ///
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appParamNotifier.setKeepScheduleDateBashoMap(map: widget.scheduleDateBashoMap);
      appParamNotifier.setKeepRaceMap(map: widget.raceMap);
      appParamNotifier.setKeepHorseMap(map: widget.horseMap);
      appParamNotifier.setKeepOddsMap(map: widget.oddsMap);
      appParamNotifier.setConfigOddsGetTiming(oddsGetTiming: widget.oddsGetTiming);

      final int selected = appParamState.selectedRaceNumber;
      if (selected > 0 && selected != _prevRaceNumber) {
        _prevRaceNumber = selected;
        _raceScrollController.scrollToIndex(selected - 1, preferPosition: AutoScrollPosition.middle);
      }
    });

    String raceName = 'レースを選択してください';
    String startTime = '--:--';

    List<RaceModel> raceModelList = <RaceModel>[];

    if (widget.raceMap['${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}'] !=
        null) {
      if (appParamState.selectedRaceNumber > 0) {
        final RaceModel race = widget
            .raceMap['${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}']!
            .firstWhere((RaceModel e) => e.race == appParamState.selectedRaceNumber);

        raceName = race.raceName;

        startTime = race.startTime.substring(0, race.startTime.lastIndexOf(':'));
      }

      raceModelList =
          widget.raceMap['${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}']!;
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //=====================//
                Row(
                  children: widget.scheduleDateBashoMap.entries.map((MapEntry<String, List<ScheduleModel>> e) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          appParamNotifier.setSelectedScheduleDate(date: e.key);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: (appParamState.selectedScheduleDate == e.key)
                                ? Colors.greenAccent.withValues(alpha: 0.1)
                                : Colors.transparent,

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
                    children: widget.scheduleDateBashoMap[appParamState.selectedScheduleDate]!.map((ScheduleModel e) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            appParamNotifier.setSelectedScheduleKaisuuBashoDay(
                              kbd: '${e.kaisuu}_${e.basho}_${e.day}',

                              name: '${e.kaisuu}回 ${e.bashoName} ${e.day}日',
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),

                              color:
                                  (appParamState.selectedScheduleKaisuuBashoDayName ==
                                      '${e.kaisuu}回 ${e.bashoName} ${e.day}日')
                                  ? Colors.greenAccent.withValues(alpha: 0.1)
                                  : Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${e.kaisuu}回 ${e.bashoName} ${e.day}日',
                              style: const TextStyle(color: Colors.white),
                            ),
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
                if (widget
                        .raceMap['${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}'] !=
                    null) ...<Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 5),

                      SingleChildScrollView(
                        controller: _raceScrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          // ignore: always_specify_types
                          children: List.generate(
                            widget
                                .raceMap['${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}']!
                                .length,
                            (int index) {
                              return AutoScrollTag(
                                // ignore: always_specify_types
                                key: ValueKey(index),
                                controller: _raceScrollController,
                                index: index,
                                child: GestureDetector(
                                  onTap: () {
                                    appParamNotifier.setSelectedRaceNumber(num: index + 1);
                                  },

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
                            },
                          ).toList(),
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

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      _dummyCurrentTime,
                                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                                    ),
                                    Text(
                                      _formatCountdown(_remainingSeconds),
                                      style: const TextStyle(fontSize: 13, color: Colors.white),
                                    ),
                                  ],
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
                      const SizedBox.shrink(),

                      IconButton(
                        onPressed: () async {
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
                          await prefs.setInt('reload_selected_race_number', appParamState.selectedRaceNumber);

                          if (mounted) {
                            // ignore: use_build_context_synchronously
                            context.findAncestorStateOfType<AppRootState>()?.restartApp();
                          }
                        },
                        icon: const Icon(Icons.refresh, color: Colors.greenAccent),
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
    );
  }

  ///
  Widget displayRaceMinutesRow() {
    final Map<String, String> ogtNamesMap = <String, String>{};

    appParamState.configOddsGetTiming.split('|').forEach((String element) {
      switch (element) {
        case '24':
          ogtNamesMap[element] = 'S';
        case '0':
          ogtNamesMap[element] = 'E';
        default:
          ogtNamesMap[element] = element;
      }
    });

    final List<OddsModel> oddsModelList = <OddsModel>[];

    if (widget.raceMap['${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}'] !=
        null) {
      if (appParamState.selectedRaceNumber > 0) {
        if (widget.oddsMap['${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}'] !=
            null) {
          for (final OddsModel element
              in widget
                  .oddsMap['${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}']!) {
            if (element.race == appParamState.selectedRaceNumber) {
              oddsModelList.add(element);
            }
          }
        }
      }
    }

    final String minTiming;
    if (oddsModelList.any((OddsModel e) => e.minutesBeforeStart == -999)) {
      minTiming = '0';
    } else if (oddsModelList.isNotEmpty && oddsModelList.every((OddsModel e) => e.minutesBeforeStart == 999)) {
      minTiming = '24';
    } else {
      final List<OddsModel> validTimingList = oddsModelList.where((OddsModel e) => e.minutesBeforeStart >= 0).toList()
        ..sort((OddsModel a, OddsModel b) => a.minutesBeforeStart.compareTo(b.minutesBeforeStart));
      minTiming = validTimingList.isNotEmpty ? validTimingList[0].minutesBeforeStart.toString() : '';
    }

    return Row(
      children: appParamState.configOddsGetTiming.split('|').map((String e) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (appParamState.selectedTiming == e) {
                appParamNotifier.setSelectedTiming(timing: '');
              } else {
                appParamNotifier.setSelectedTiming(timing: e);
              }
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
    final List<Widget> list = <Widget>[];

    final List<OddsModel> oddsModelList = <OddsModel>[];

    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';

    final Map<int, HorseModel> horseModelMap = <int, HorseModel>{};

    if (widget.raceMap[mapKey] != null) {
      if (appParamState.selectedRaceNumber > 0) {
        if (widget.oddsMap[mapKey] != null) {
          for (final OddsModel element in widget.oddsMap[mapKey]!) {
            if (element.race == appParamState.selectedRaceNumber) {
              oddsModelList.add(element);
            }
          }
        }

        if (widget.horseMap[mapKey] != null) {
          for (final HorseModel element in widget.horseMap[mapKey]!) {
            if (element.race == appParamState.selectedRaceNumber) {
              horseModelMap[element.num] = element;
            }
          }
        }
      }
    }

    oddsModelList.sort((OddsModel a, OddsModel b) {
      final int numCompare = a.num.compareTo(b.num);

      if (numCompare != 0) {
        return numCompare;
      }

      return b.minutesBeforeStart.compareTo(a.minutesBeforeStart);
    });

    const List<int> timingOrder = <int>[999, 21, 18, 15, 12, 9, 6, 3, -999];

    final Map<int, List<String>> oddsTimelineMap = <int, List<String>>{};

    for (final OddsModel element in oddsModelList) {
      oddsTimelineMap.putIfAbsent(element.num, () => List<String>.filled(timingOrder.length, ''));
      final int timingIndex = timingOrder.indexOf(element.minutesBeforeStart);
      if (timingIndex != -1) {
        oddsTimelineMap[element.num]![timingIndex] = element.odds;
      }
    }

    int? filterMinutes;

    if (appParamState.selectedTiming.isNotEmpty) {
      if (appParamState.selectedTiming == '0') {
        filterMinutes = -999;
      } else {
        final int parsed = int.parse(appParamState.selectedTiming);
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

    final List<OddsModel> displayList =
        (filterMinutes != null
              ? oddsModelList.where((OddsModel e) => e.minutesBeforeStart == filterMinutes).toList()
              : oddsModelList)
          ..sort((OddsModel a, OddsModel b) => (double.tryParse(a.odds) ?? 0).compareTo(double.tryParse(b.odds) ?? 0));

    int i = 1;
    for (final OddsModel element in displayList) {
      list.add(
        Stack(
          children: <Widget>[
            Container(
              height: 120,
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
                                child: Text(i.toString(), style: const TextStyle(color: Colors.greenAccent)),
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

                        if (horseModelMap[element.num] != null) ...<Widget>[
                          Row(
                            children: <Widget>[
                              SizedBox(width: 15, child: Text(horseModelMap[element.num]!.waku.toString())),
                              const Text('枠'),
                            ],
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

                        if (horseModelMap[element.num] != null) ...<Widget>[
                          Expanded(
                            child: Text(horseModelMap[element.num]!.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (oddsTimelineMap[element.num] != null) ...<Widget>[
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: oddsTimelineMap[element.num]!.asMap().entries.map((MapEntry<int, String> entry) {
                        if (entry.value.isEmpty) {
                          return Container(
                            width: 30,
                            height: 30,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.2)),
                          );
                        }

                        const List<String> timingLabels = <String>['S', '21', '18', '15', '12', '9', '6', '3', 'E'];

                        const List<String> timingKeys = <String>['24', '21', '18', '15', '12', '9', '6', '3', '0'];

                        final String entryTimingKey = timingKeys[entry.key];

                        final String activeTimingKey = filterMinutes == null
                            ? ''
                            : filterMinutes == 999
                            ? '24'
                            : filterMinutes == -999
                            ? '0'
                            : filterMinutes.toString();

                        final Color circleColor = (appParamState.selectedTiming == entryTimingKey)
                            ? Colors.greenAccent
                            : (appParamState.selectedTiming.isEmpty && entryTimingKey == activeTimingKey)
                            ? Colors.red
                            : Colors.white;

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
                                      timingLabels[entry.key],
                                      style: TextStyle(
                                        fontSize: 9,

                                        color: circleColor == Colors.red ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                getUpDownIcon(entry: entry, timeLineMap: oddsTimelineMap[element.num]!.asMap().entries),
                              ],
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      );

      i++;
    }

    if (list.isEmpty) {
      list.add(
        Text(
          (appParamState.selectedTiming == '0')
              ? 'レース開始時点のオッズデータはありません。'
              : '${appParamState.selectedTiming}分前のオッズデータはありません。',

          style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
        ),
      );
    }

    return SingleChildScrollView(child: Column(children: list));
  }

  ///
  Widget getUpDownIcon({required MapEntry<int, String> entry, required Iterable<MapEntry<int, String>> timeLineMap}) {
    if (entry.key == 0) {
      return const SizedBox.shrink();
    }

    final String currentValue = entry.value;

    if (currentValue.isEmpty) {
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

    final double? current = double.tryParse(currentValue);
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
