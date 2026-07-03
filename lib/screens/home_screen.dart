import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/controllers_mixin.dart';
import '../extensions/extensions.dart';
import '../main.dart';
import '../models/horse_model.dart';
import '../models/login_user_model.dart';
import '../models/odds_model.dart';
import '../models/odds_wide_model.dart';
import '../models/popularity_rank_odds_average_model.dart';
import '../models/push_notifier_user_model.dart';
import '../models/race_model.dart';
import '../models/race_result_model.dart';
import '../models/schedule_model.dart';
import '../models/summary_model.dart';
import '../utility/utility.dart';
import 'components/admin_menu_alert.dart';
import 'components/history_race_record_display_alert.dart';
import 'components/horse_detail_display_alert.dart';
import 'components/horse_name_initial_panel_alert.dart';
import 'components/horse_odds_ranking_display_alert.dart';

// 一応残しておく
// import 'components/horse_odds_wide_display_alert.dart';

// import 'components/popularity_rank_odds_average_alert.dart';
//
//
//
//

import 'components/popularity_record_display_alert.dart';
import 'parts/error_confirm_dialog.dart';
import 'parts/odds_finder_dialog.dart';
import 'parts/odds_up_down_icon.dart';
import 'parts/race_top_three_widget.dart';
import 'parts/side_tab_panel.dart';
import 'parts/widget_display_overlay.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.scheduleDateBashoMap,
    required this.raceMap,
    required this.horseMap,
    required this.oddsMap,
    required this.oddsGetTiming,
    required this.oddsWideMap,
    required this.isRankingDialogOpen,
    required this.summaryMap,
    required this.summaryDateBashoMap,
    required this.raceResultMap,
    required this.loginUserMap,
    required this.loggedInUserId,
    required this.onLogout,
    required this.pushNotifierUserList,
    required this.popularityRankOddsAverageMap,
  });

  final Map<String, List<ScheduleModel>> scheduleDateBashoMap;
  final Map<String, List<RaceModel>> raceMap;
  final Map<String, List<HorseModel>> horseMap;
  final Map<String, List<OddsModel>> oddsMap;

  final String oddsGetTiming;
  final Map<String, List<OddsWideModel>> oddsWideMap;
  final bool isRankingDialogOpen;
  final Map<String, List<SummaryModel>> summaryMap;
  final Map<String, List<String>> summaryDateBashoMap;
  final Map<String, List<RaceResultModel>> raceResultMap;
  final Map<String, LoginUserModel> loginUserMap;
  final List<PushNotifierUserModel> pushNotifierUserList;
  final Map<int, PopularityRankOddsAverageModel> popularityRankOddsAverageMap;

  final String loggedInUserId;
  final VoidCallback onLogout;

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
  String _lastStartTime = '';

  final Utility _utility = Utility();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _haranidoKey = GlobalKey();

  String get _mapKey => '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';

  ///
  @override
  void initState() {
    super.initState();

    scheduleNotifier.getAllScheduleData();
    raceNotifier.getAllRaceData();
    horseNotifier.getAllHorseData();
    oddsNotifier.getAllOddsData();
    laravelConfigNotifier.getAllLaravelConfigData();
    oddsGetTimingNotifier.getAllOddsGetTimingData();
    oddsWideNotifier.getAllOddsWideData();
    summaryNotifier.getAllSummaryData();
    raceResultNotifier.getAllRaceResultData();
    loginUserNotifier.getAllLoginUserData();
    pushNotifierUserNotifier.getAllPushNotifierUserData();
    popularityRankOddsAverageNotifier.getAllPopularityRankOddsAverageData();

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAppParam());
    if (widget.isRankingDialogOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        appParamNotifier.setIsShowUpperBox2(flag: true);

        OddsFinderDialog(context: context, widget: const HorseOddsRankingDisplayAlert()).then((_) async {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isRankingDialogOpen', false);
        });
      });
    }
  }

  ///
  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scheduleDateBashoMap != widget.scheduleDateBashoMap ||
        oldWidget.raceMap != widget.raceMap ||
        oldWidget.horseMap != widget.horseMap ||
        oldWidget.oddsMap != widget.oddsMap ||
        oldWidget.oddsGetTiming != widget.oddsGetTiming ||
        oldWidget.oddsWideMap != widget.oddsWideMap) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncAppParam());
    }
  }

  ///
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _remainingSecondsNotifier.dispose();
    _raceScrollController.dispose();
    _horseListScrollController.dispose();
    super.dispose();
  }

  ///
  void _confirmLogout() {
    errorConfirmDialog(
      context: context,
      title: '確認',
      content: 'ログアウトします。よろしいですか？',
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('いいえ', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('loggedInUserId', '');
            widget.onLogout();
          },
          child: const Text('はい', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
        ),
      ],
    );
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
    appParamNotifier.setKeepOddsWideMap(map: widget.oddsWideMap);
    appParamNotifier.setKeepSummaryMap(map: widget.summaryMap);
    appParamNotifier.setKeepSummaryDateBashoMap(map: widget.summaryDateBashoMap);
    appParamNotifier.setKeepLoginUserMap(map: widget.loginUserMap);
    appParamNotifier.setKeepPushNotifierUserList(list: widget.pushNotifierUserList);
    appParamNotifier.setKeepPopularityRankOddsAverageMap(map: widget.popularityRankOddsAverageMap);
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
  List<Widget> _buildBackgroundLayers() {
    return <Widget>[
      Positioned(
        top: 40,
        left: 20,
        child: Opacity(opacity: 0.6, child: SizedBox(width: 130, child: Image.asset('assets/images/gold_title.png'))),
      ),

      Positioned(
        top: 70,
        left: 0,
        right: 0,
        child: Center(
          child: Transform.scale(
            scaleX: 1.0,
            scaleY: 4.0,
            child: Text(
              'ODDS FINDER',
              style: TextStyle(fontSize: 14, color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
            ),
          ),
        ),
      ),

      Opacity(
        opacity: 0.3,
        child: SizedBox(
          width: context.screenSize.width,
          height: context.screenSize.height,
          child: Center(
            child: Transform.scale(
              scale: 1.5,
              child: Image.asset('assets/images/bg3.png', width: context.screenSize.width),
            ),
          ),
        ),
      ),

      Positioned(
        bottom: 0,
        right: 0,
        child: Opacity(opacity: 0.4, child: Image.asset('assets/images/bg.png', width: 220)),
      ),
    ];
  }

  ///
  Widget _buildDateRow() {
    return Row(
      children: widget.scheduleDateBashoMap.entries.map((MapEntry<String, List<ScheduleModel>> e) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              appParamNotifier.setSelectedScheduleDate(date: e.key);
              appParamNotifier.setSelectedScheduleKaisuuBashoDay(kbd: '', name: '');
              appParamNotifier.setSelectedRaceNumber(num: 0);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: (appParamState.selectedScheduleDate == e.key)
                    ? Colors.greenAccent.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.3),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(3),
              ),
              alignment: Alignment.center,
              child: Text(e.key, style: const TextStyle(color: Colors.white)),
            ),
          ),
        );
      }).toList(),
    );
  }

  ///
  Widget _buildVenueRow() {
    final List<ScheduleModel> venues = widget.scheduleDateBashoMap[appParamState.selectedScheduleDate]!;
    return Row(
      children: venues.map((ScheduleModel e) {
        final String label = '${e.kaisuu}回 ${e.bashoName} ${e.day}日';
        return Expanded(
          child: GestureDetector(
            onTap: () {
              appParamNotifier.setSelectedScheduleKaisuuBashoDay(kbd: '${e.kaisuu}_${e.basho}_${e.day}', name: label);
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
                borderRadius: BorderRadius.circular(3),
              ),
              alignment: Alignment.center,
              child: Text(label, style: const TextStyle(color: Colors.white)),
            ),
          ),
        );
      }).toList(),
    );
  }

  ///
  Widget _buildRaceNumberRow(String mapKey) {
    final List<RaceModel> raceModelList = widget.raceMap[mapKey]!;
    return SingleChildScrollView(
      controller: _raceScrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<Widget>.generate(raceModelList.length, (int index) {
          return AutoScrollTag(
            key: ValueKey<int>(index),
            controller: _raceScrollController,
            index: index,
            child: GestureDetector(
              onTap: () => appParamNotifier.setSelectedRaceNumber(num: index + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: Colors.white.withValues(alpha: 0.4),
                  child: CircleAvatar(
                    backgroundColor: (appParamState.selectedRaceNumber == index + 1) ? Colors.green[900] : Colors.black,
                    child: Text(
                      raceModelList[index].race.toString(),
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
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
                Text('${appParamState.selectedRaceNumber}レース'),
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
                          onTap: () {
                            if (appParamState.selectedRaceNumber > 0) {
                              appParamNotifier.setIsShowUpperBox(flag: !appParamState.isShowUpperBox);
                            }
                          },

                          child: Icon(
                            appParamState.isShowUpperBox ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                            color: (appParamState.selectedRaceNumber > 0) ? Colors.green[500] : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            raceName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: (raceName == 'レースを選択してください')
                                ? const TextStyle(color: Colors.greenAccent, fontSize: 12)
                                : const TextStyle(fontSize: 14, color: Colors.white),
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
        (widget.oddsMap[_mapKey] ?? <OddsModel>[])
            .where((OddsModel o) => o.race == appParamState.selectedRaceNumber && o.minutesBeforeStart == -999)
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
  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
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

              icon: Icon(Icons.refresh, color: Colors.green[500]),
            ),
            IconButton(
              onPressed: () {
                appParamNotifier.setIsShowUpperBox2(flag: true);

                OddsFinderDialog(context: context, widget: const HorseOddsRankingDisplayAlert());
              },
              icon: Icon(Icons.list, color: Colors.white.withValues(alpha: 0.5)),
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
  Widget _buildOddsTimelineRow({
    required List<String> timeline,
    required String activeTimingKey,
    required String selectedTiming,
    List<String>? fukuMinList,
    List<String>? fukuMaxList,
    List<String>? nextTimeline,
  }) {
    final List<String> timingKeys = widget.oddsGetTiming.split('|');

    return Stack(
      children: <Widget>[
        const Positioned(
          top: 145,
          left: 0,
          child: Text('オッズ断層数値', style: TextStyle(fontSize: 10, color: Color(0xFFFBB6CE))),
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
                ? 'S'
                : entry.key == timingKeys.length - 1
                ? 'E'
                : entryTimingKey;

            final String fukuMin = fukuMinList?[entry.key] ?? '';
            final String fukuMax = fukuMaxList?[entry.key] ?? '';

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
                      const SizedBox(height: 40),

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
                              () {
                                final double? next = double.tryParse(nextTimeline[entry.key]);
                                final double? current = double.tryParse(entry.value);
                                if (next == null || current == null || current == 0) {
                                  return '';
                                }
                                return (next / current).toStringAsFixed(2);
                              }(),

                              style: TextStyle(
                                fontSize: 10,

                                color: () {
                                  final double? next = double.tryParse(nextTimeline[entry.key]);
                                  final double? current = double.tryParse(entry.value);
                                  if (next == null || current == null || current == 0) {
                                    return Colors.white;
                                  }

                                  return (next / current) >= 2.0
                                      ? const Color(0xFFFBB6CE)
                                      : Colors.white.withValues(alpha: 0.5);
                                }(),
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
    final int selected = appParamState.selectedRaceNumber;
    if (selected > 0 && selected != _prevRaceNumber) {
      _prevRaceNumber = selected;
      _currentHorseIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _raceScrollController.scrollToIndex(selected - 1, preferPosition: AutoScrollPosition.middle);
          if (_horseListScrollController.hasClients) {
            _horseListScrollController.jumpTo(0);
          }
        }
      });
    }

    String raceName = 'レースを選択してください';
    String startTime = '--:--';

    if (widget.raceMap[_mapKey] != null && appParamState.selectedRaceNumber > 0) {
      final RaceModel race = widget.raceMap[_mapKey]!.firstWhere(
        (RaceModel e) => e.race == appParamState.selectedRaceNumber,
      );
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
      (widget.raceResultMap[_mapKey] ?? <RaceResultModel>[])
          .where((RaceResultModel e) => e.race == appParamState.selectedRaceNumber)
          .map((RaceResultModel e) => MapEntry<int, RaceResultModel>(e.result, e)),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,

      body: Stack(
        children: <Widget>[
          ..._buildBackgroundLayers(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: DefaultTextStyle(
                style: const TextStyle(fontSize: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (appParamState.isShowUpperBox) ...<Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox.shrink(),

                          Row(
                            children: <Widget>[
                              if (appParamState.keepLoginUserMap[widget.loggedInUserId] != null &&
                                  appParamState.keepLoginUserMap[widget.loggedInUserId]!.isAdmin == 1) ...<Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.green[900],
                                    borderRadius: BorderRadius.circular(5),
                                  ),

                                  child: GestureDetector(
                                    onTap: () {
                                      OddsFinderDialog(
                                        context: context,
                                        widget: AdminMenuAlert(loggedInUserId: widget.loggedInUserId),
                                      );
                                    },
                                    child: const Text('管理', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],

                              const SizedBox(width: 20),

                              GestureDetector(
                                onTap: () {
                                  appParamNotifier.setSelectedDrawerRace(race: '');

                                  _scaffoldKey.currentState!.openDrawer();
                                },
                                child: Icon(Icons.list, color: Colors.green[500]),
                              ),

                              const SizedBox(width: 20),

                              GestureDetector(
                                onTap: _confirmLogout,
                                child: Icon(Icons.logout, color: Colors.white.withValues(alpha: 0.5)),
                              ),

                              const SizedBox(width: 10),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      _buildDateRow(),
                      const SizedBox(height: 5),
                    ],
                    if (widget.scheduleDateBashoMap[appParamState.selectedScheduleDate] != null) ...<Widget>[
                      if (appParamState.isShowUpperBox) _buildVenueRow(),
                    ] else ...<Widget>[
                      if (widget.scheduleDateBashoMap.isNotEmpty)
                        const Text('日付を選択してください', style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
                    ],

                    if (widget.raceMap[_mapKey] != null) ...<Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (appParamState.isShowUpperBox) ...<Widget>[
                            const SizedBox(height: 5),
                            _buildRaceNumberRow(_mapKey),
                            const SizedBox(height: 5),
                            Divider(color: Colors.white.withValues(alpha: 0.5), thickness: 5),
                          ],
                          const SizedBox(height: 5),
                          _buildRaceInfoBar(startTime, raceName),
                        ],
                      ),
                    ] else ...<Widget>[
                      if (widget.scheduleDateBashoMap[appParamState.selectedScheduleDate] != null)
                        const Text('会場を選択してください', style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
                    ],

                    if (appParamState.selectedRaceNumber > 0) ...<Widget>[
                      SizedBox(height: 40, child: displayRaceMinutesRow()),
                      _buildControlButtons(),

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

                      if (widget.scheduleDateBashoMap.isNotEmpty) ...<Widget>[
                        Divider(color: Colors.white.withValues(alpha: 0.5)),
                        const SizedBox(height: 5),
                      ],
                      Expanded(child: displayRaceHorseList()),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      drawer: _dispDrawer(),
    );
  }

  ///
  Widget _buildDrawerRaceRow({
    required String date,
    required List<SummaryModel> models,
    required MapEntry<int, String> r,
  }) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white70, fontSize: 11),

      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3))),
        ),

        padding: const EdgeInsets.symmetric(vertical: 5),

        child: Row(
          children: <Widget>[
            Container(width: 20, alignment: Alignment.topRight, child: Text('${r.key}R')),
            const SizedBox(width: 20),
            Expanded(child: Text(r.value, maxLines: 1, overflow: TextOverflow.ellipsis)),

            GestureDetector(
              onTap: () {
                appParamNotifier.setSelectedDrawerRace(
                  race: '${date}_${models.first.kaisuu}_${models.first.basho}_${models.first.day}_${r.key}',
                );

                summaryNotifier.fetchRaceSummary(
                  date: date,
                  kaisuu: models.first.kaisuu,
                  basho: models.first.basho,
                  day: models.first.day,
                  race: r.key,
                );

                appParamNotifier.setIsShowUpperBox2(flag: true);

                OddsFinderDialog(
                  context: context,
                  widget: const HorseOddsRankingDisplayAlert(mode: RankingMode.summary),
                );
              },
              child: Icon(
                Icons.calendar_view_month,
                color:
                    ('${date}_${models.first.kaisuu}_${models.first.basho}_${models.first.day}_${r.key}' ==
                        appParamState.selectedDrawerRace)
                    ? Colors.yellowAccent.withValues(alpha: 0.4)
                    : Colors.greenAccent.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  Widget _dispDrawer() {
    return Drawer(
      backgroundColor: Colors.blueGrey.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 60),

            Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          OddsFinderDialog(context: context, widget: const HistoryRaceRecordDisplayAlert());
                        },
                        child: const Text('過去データ', style: TextStyle(color: Colors.white)),
                      ),

                      TextButton(
                        onPressed: () {
                          appParamNotifier.setSelectedHorseNameChar1(char: '');
                          appParamNotifier.setSelectedHorseNameChar2(char: '');

                          OddsFinderDialog(context: context, widget: const HorseNameInitialPanelAlert());
                        },
                        child: const Text('馬名リスト', style: TextStyle(color: Colors.white)),
                      ),

                      const SizedBox(width: 60),
                    ],
                  ),
                ),

                const SizedBox(width: 10),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.summaryDateBashoMap.entries.map((MapEntry<String, List<String>> e) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: context.screenSize.width,
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(top: 10),

                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[Colors.greenAccent.withOpacity(0.3), Colors.transparent],
                              stops: const <double>[0.7, 1],
                            ),
                          ),

                          child: Text(e.key, style: const TextStyle(color: Colors.white)),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: e.value.map((String e2) {
                            final List<SummaryModel> models = widget.summaryMap['${e.key}_$e2'] ?? <SummaryModel>[];

                            final Map<int, String> uniqueRaces = <int, String>{};

                            for (final SummaryModel m in models) {
                              uniqueRaces.putIfAbsent(m.race, () => m.raceName);
                            }

                            final List<MapEntry<int, String>> races = uniqueRaces.entries.toList()
                              ..sort((MapEntry<int, String> a, MapEntry<int, String> b) => a.key.compareTo(b.key));

                            if (models.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return ExpansionTile(
                              iconColor: Colors.greenAccent,
                              collapsedIconColor: Colors.white70,

                              title: Text(
                                '${models.first.kaisuu}回 ${models.first.bashoName} ${models.first.day}日',
                                style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                              ),

                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),

                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: races
                                        .map(
                                          (MapEntry<int, String> r) =>
                                              _buildDrawerRaceRow(date: e.key, models: models, r: r),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 30),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  Widget displayRaceMinutesRow() {
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
    if (widget.raceMap[_mapKey] != null && appParamState.selectedRaceNumber > 0) {
      oddsModelList.addAll(
        (widget.oddsMap[_mapKey] ?? <OddsModel>[]).where((OddsModel e) => e.race == appParamState.selectedRaceNumber),
      );
    }

    final String minTiming = _resolveMinTiming(oddsModelList);

    if (appParamState.selectedTiming.isEmpty && minTiming.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appParamNotifier.setSelectedTiming2(timing2: minTiming);
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
              child: Text(ogtNamesMap[e] ?? '', style: const TextStyle(color: Colors.white, fontSize: 8)),
            ),
          ),
        );
      }).toList(),
    );
  }

  ///
  List<OddsModel> _buildDisplayList() {
    final List<OddsModel> allOdds = (widget.oddsMap[_mapKey] ?? <OddsModel>[])
        .where((OddsModel e) => e.race == appParamState.selectedRaceNumber)
        .toList();

    final int? filterMinutes = _resolveFilterMinutes(appParamState.selectedTiming, allOdds);

    return (filterMinutes != null
          ? allOdds.where((OddsModel e) => e.minutesBeforeStart == filterMinutes).toList()
          : allOdds)
      ..sort((OddsModel a, OddsModel b) => (double.tryParse(a.odds) ?? 0).compareTo(double.tryParse(b.odds) ?? 0));
  }

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
  Widget displayRaceHorseList() {
    final List<OddsModel> oddsModelList = <OddsModel>[];
    final Map<int, HorseModel> horseModelMap = <int, HorseModel>{};

    if (widget.raceMap[_mapKey] != null && appParamState.selectedRaceNumber > 0) {
      oddsModelList.addAll(
        (widget.oddsMap[_mapKey] ?? <OddsModel>[]).where((OddsModel e) => e.race == appParamState.selectedRaceNumber),
      );
      for (final HorseModel e in (widget.horseMap[_mapKey] ?? <HorseModel>[]).where(
        (HorseModel e) => e.race == appParamState.selectedRaceNumber,
      )) {
        horseModelMap[e.num] = e;
      }
    }

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
          ),
        );
      },
    );
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
  }) {
    final int popularity = index + 1;
    final HorseModel? horse = horseModelMap[element.num];
    final List<String>? oddsTimeline = oddsTimelineMap[element.num];
    final List<String>? fukuMinTimeline = fukuMinTimelineMap[element.num];
    final List<String>? fukuMaxTimeline = fukuMaxTimelineMap[element.num];

    return Stack(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.1), width: 10)),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 5),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: DefaultTextStyle(
                  style: const TextStyle(fontSize: 10),
                  child: Column(
                    children: <Widget>[
                      _buildHorseItemHeader(popularity: popularity, horse: horse, fukuRank: fukuRank),
                      const SizedBox(height: 10),

                      _buildHorseNameRow(element: element, horse: horse, horseWakuColorMap: horseWakuColorMap),
                    ],
                  ),
                ),
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,

                    child: Column(
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
  Widget _buildHorseItemHeader({required int popularity, required HorseModel? horse, int? fukuRank}) {
    return Row(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 10, left: 15),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                margin: const EdgeInsets.only(top: 10, left: 15),
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1)),
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text('$index番人気', style: const TextStyle(color: Colors.white)),
                      ),

                      Text(
                        '馬番: ${o.num}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 3),

                      Text(upsetScore, style: const TextStyle(color: Colors.white)),

                      const SizedBox(height: 3),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            key: _haranidoKey,
            onTap: () {
              widgetDisplayOverlay(
                context: context,
                buttonKey: _haranidoKey,

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
          Row(
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
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 15,
                          child: Text(horse.waku.toString(), style: const TextStyle(color: Colors.white)),
                        ),
                        const Text('枠', style: TextStyle(color: Colors.white)),
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
          Positioned(
            right: 10,
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
                child: Icon(FontAwesomeIcons.horse, size: 20, color: Colors.green[500]!.withValues(alpha: 0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
