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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _raceScrollController.dispose();
    super.dispose();
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
                                ? Colors.yellowAccent.withValues(alpha: 0.1)
                                : Colors.transparent,

                            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          alignment: Alignment.center,
                          child: Text(e.key),
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
                                  ? Colors.yellowAccent.withValues(alpha: 0.1)
                                  : Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: Text('${e.kaisuu}回 ${e.bashoName} ${e.day}日'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...<Widget>[
                  if (widget.scheduleDateBashoMap.isNotEmpty) ...<Widget>[
                    const Text('日付を選択してください', style: TextStyle(fontSize: 12, color: Colors.yellowAccent)),
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
                                          ? Colors.yellowAccent.withValues(alpha: 0.2)
                                          : Colors.black.withValues(alpha: 0.4),

                                      child: Text(
                                        raceModelList[index].race.toString(),
                                        style: const TextStyle(fontSize: 14),
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
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[SizedBox(), Text('-----')],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '🚩　$startTime　$raceName',
                                  style: (raceName == 'レースを選択してください')
                                      ? const TextStyle(color: Colors.yellowAccent, fontSize: 12)
                                      : const TextStyle(fontSize: 14),
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
                    const Text('会場を選択してください', style: TextStyle(fontSize: 12, color: Colors.yellowAccent)),
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
                        icon: const Icon(Icons.refresh),
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
                    ? Colors.yellowAccent.withValues(alpha: 0.1)
                    : (appParamState.selectedTiming == '' && e == minTiming)
                    ? Colors.red.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Text(ogtNamesMap[e] ?? ''),
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
        Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[Text(i.toString()), Text(element.num.toString()), Text(element.odds)],
            ),

            if (horseModelMap[element.num] != null) ...<Widget>[Text(horseModelMap[element.num]!.name)],

            if (oddsTimelineMap[element.num] != null) ...<Widget>[
              Row(
                children: oddsTimelineMap[element.num]!.map((String e) {
                  return Text(e);
                }).toList(),
              ),
            ],
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

          style: const TextStyle(color: Colors.yellowAccent, fontSize: 12),
        ),
      );
    }

    return SingleChildScrollView(child: Column(children: list));
  }
}
