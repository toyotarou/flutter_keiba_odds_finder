import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/app_param/app_param.dart';
import '../controllers/controllers_mixin.dart';
import '../extensions/extensions.dart';
import '../models/horse_model.dart';
import '../models/login_user_model.dart';
import '../models/odds_model.dart';

// import '../models/odds_wide_model.dart';
//
//

import '../models/popularity_rank_odds_median_model.dart';
import '../models/push_notifier_user_model.dart';
import '../models/race_model.dart';
import '../models/race_result_model.dart';
import '../models/schedule_model.dart';
import '../models/summary_model.dart';
import 'components/admin_menu_alert.dart';
import 'components/history_race_record_display_alert.dart';
import 'components/horse_name_initial_panel_alert.dart';
import 'components/horse_odds_ranking_display_alert.dart';
import 'components/past_race_odds_transition_alert.dart';
import 'components/popularity_record_display_alert.dart';
import 'components/terms_alert.dart';
import 'components/weekend_race_calendar_alert.dart';
import 'page/race_content_page.dart';
import 'parts/error_confirm_dialog.dart';
import 'parts/odds_finder_dialog.dart';

class RaceTabInfo {
  RaceTabInfo(this.raceNumber, this.widget);

  int raceNumber;
  Widget widget;
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.scheduleDateBashoMap,
    required this.raceMap,
    required this.horseMap,
    required this.oddsMap,
    required this.oddsGetTiming,

    required this.oddsDropRateHonmei,
    required this.oddsDropRateChuana,
    required this.oddsDropRateDaiana,

    // required this.oddsWideMap,
    //
    //
    //
    required this.isRankingDialogOpen,
    required this.summaryMap,
    required this.summaryDateBashoMap,
    required this.raceResultMap,
    required this.loginUserMap,
    required this.loggedInUserId,
    required this.onLogout,
    required this.pushNotifierUserList,
    required this.popularityRankOddsMedianMap,
  });

  final Map<String, List<ScheduleModel>> scheduleDateBashoMap;
  final Map<String, List<RaceModel>> raceMap;
  final Map<String, List<HorseModel>> horseMap;
  final Map<String, List<OddsModel>> oddsMap;

  final String oddsGetTiming;

  final String oddsDropRateHonmei;
  final String oddsDropRateChuana;
  final String oddsDropRateDaiana;

  // final Map<String, List<OddsWideModel>> oddsWideMap;
  //
  //
  //

  final bool isRankingDialogOpen;
  final Map<String, List<SummaryModel>> summaryMap;
  final Map<String, List<String>> summaryDateBashoMap;
  final Map<String, List<RaceResultModel>> raceResultMap;
  final Map<String, LoginUserModel> loginUserMap;
  final List<PushNotifierUserModel> pushNotifierUserList;
  final Map<String, List<PopularityRankOddsMedianModel>> popularityRankOddsMedianMap;

  final String loggedInUserId;
  final VoidCallback onLogout;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with ControllersMixin<HomeScreen>, TickerProviderStateMixin {
  final List<RaceTabInfo> _raceTabs = <RaceTabInfo>[];
  TabController? _raceTabController;
  TabController? _raceTabControllerPendingDispose;
  String _raceTabMapKey = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    // oddsWideNotifier.getAllOddsWideData();
    //
    //
    //
    //

    summaryNotifier.getAllSummaryData();
    raceResultNotifier.getAllRaceResultData();
    loginUserNotifier.getAllLoginUserData();
    pushNotifierUserNotifier.getAllPushNotifierUserData();
    popularityRankOddsMedianNotifier.getAllPopularityRankOddsMedianData();
    horseBestWeightNotifier.getAllHorseBestWeightData();

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
        // oldWidget.oddsWideMap != widget.oddsWideMap ||
        //
        //
        //
        oldWidget.popularityRankOddsMedianMap != widget.popularityRankOddsMedianMap) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncAppParam());
    }
  }

  ///
  @override
  void dispose() {
    try {
      _raceTabController?.removeListener(_onRaceTabChanged);
      _raceTabController?.dispose();
      _raceTabControllerPendingDispose?.removeListener(_onRaceTabChanged);
      _raceTabControllerPendingDispose?.dispose();
    } catch (e) {
      debugPrint('dispose error: $e');
    }
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

    appParamNotifier.setConfigOddsDropRate(
      oddsDropRateHonmei: widget.oddsDropRateHonmei,
      oddsDropRateChuana: widget.oddsDropRateChuana,
      oddsDropRateDaiana: widget.oddsDropRateDaiana,
    );

    // appParamNotifier.setKeepOddsWideMap(map: widget.oddsWideMap);
    //
    //
    //

    appParamNotifier.setKeepSummaryMap(map: widget.summaryMap);
    appParamNotifier.setKeepSummaryDateBashoMap(map: widget.summaryDateBashoMap);
    appParamNotifier.setKeepLoginUserMap(map: widget.loginUserMap);
    appParamNotifier.setKeepPushNotifierUserList(list: widget.pushNotifierUserList);
    appParamNotifier.setKeepPopularityRankOddsMedianMap(map: widget.popularityRankOddsMedianMap);
  }

  ///
  void _makeRaceTab() {
    _raceTabs.clear();
    try {
      final List<RaceModel>? races = widget.raceMap[_mapKey];
      if (races == null || races.isEmpty) {
        return;
      }
      for (final RaceModel race in races) {
        _raceTabs.add(
          RaceTabInfo(
            race.race,
            RaceContentPage(
              key: ValueKey<String>('race_${_mapKey}_${race.race}'),
              raceNumber: race.race,
              mapKey: _mapKey,
              raceMap: widget.raceMap,
              oddsMap: widget.oddsMap,
              horseMap: widget.horseMap,
              oddsGetTiming: widget.oddsGetTiming,
              oddsDropRateHonmei: widget.oddsDropRateHonmei,
              oddsDropRateChuana: widget.oddsDropRateChuana,
              oddsDropRateDaiana: widget.oddsDropRateDaiana,
              raceResultMap: widget.raceResultMap,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('_makeRaceTab error: $e');
    }
  }

  ///
  void _onRaceTabChanged() {
    try {
      final TabController? c = _raceTabController;
      if (c != null && !c.indexIsChanging) {
        final int index = c.index;
        if (_raceTabs.isNotEmpty && index >= 0 && index < _raceTabs.length) {
          appParamNotifier.setSelectedRaceNumber(num: _raceTabs[index].raceNumber);
        }
      }
    } catch (e) {
      debugPrint('_onRaceTabChanged error: $e');
    }
  }

  ///
  void _updateRaceTabController() {
    final String currentMapKey = _mapKey;

    final bool needsNewController =
        _raceTabController == null || currentMapKey != _raceTabMapKey || _raceTabController!.length != _raceTabs.length;

    if (needsNewController) {
      // 会場変更またはレース数変化: 正しい initialIndex で新しいコントローラーを作成
      _raceTabControllerPendingDispose = _raceTabController;

      final int selected = appParamState.selectedRaceNumber;
      int initialIdx = 0;
      if (selected > 0 && _raceTabs.isNotEmpty) {
        final int idx = _raceTabs.indexWhere((RaceTabInfo t) => t.raceNumber == selected);
        if (idx >= 0) {
          initialIdx = idx;
        }
      }

      _raceTabController = TabController(
        length: _raceTabs.isEmpty ? 1 : _raceTabs.length,
        vsync: this,
        initialIndex: initialIdx,
      );
      _raceTabController!.addListener(_onRaceTabChanged);
      _raceTabMapKey = currentMapKey;

      // 旧コントローラーを次フレーム後に破棄（現フレームはまだ旧コントローラーを使用中）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _raceTabControllerPendingDispose?.removeListener(_onRaceTabChanged);
        _raceTabControllerPendingDispose?.dispose();
        _raceTabControllerPendingDispose = null;
      });
    }
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
                    ? Colors.greenAccent.withValues(alpha: 0.3)
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
                color: (appParamState.selectedScheduleKaisuuBashoDay == '${e.kaisuu}_${e.basho}_${e.day}')
                    ? Colors.greenAccent.withValues(alpha: 0.3)
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
  Widget _buildRaceTabSection() {
    if (_raceTabController == null || _raceTabs.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: <Widget>[
        if (appParamState.isShowUpperBox) ...<Widget>[
          const SizedBox(height: 5),
          TabBar(
            controller: _raceTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Colors.greenAccent,
            padding: EdgeInsets.zero,
            tabs: _raceTabs.map((RaceTabInfo tab) {
              return Tab(
                child: Text('${tab.raceNumber}R', style: const TextStyle(fontSize: 14, color: Colors.white)),
              );
            }).toList(),
          ),
          const SizedBox(height: 5),
          Divider(color: Colors.white.withValues(alpha: 0.5)),
        ],
        Expanded(
          child: TabBarView(
            controller: _raceTabController,
            children: _raceTabs.map((RaceTabInfo tab) => tab.widget).toList(),
          ),
        ),
      ],
    );
  }

  ///
  @override
  Widget build(BuildContext context) {
    ref.listen<int>(appParamProvider.select((AppParamState s) => s.selectedRaceNumber), (int? prev, int next) {
      if (next > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _raceTabController == null || _raceTabs.isEmpty) {
            return;
          }
          final int idx = _raceTabs.indexWhere((RaceTabInfo t) => t.raceNumber == next);
          if (idx >= 0 && idx != _raceTabController!.index) {
            _raceTabController!.animateTo(idx);
          }
        });
      }
    });

    try {
      _makeRaceTab();
    } catch (e) {
      debugPrint('_makeRaceTab error: $e');
    }

    try {
      _updateRaceTabController();
    } catch (e) {
      debugPrint('_updateRaceTabController error: $e');
    }

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
                              const SizedBox(width: 20),

                              GestureDetector(
                                onTap: () =>
                                    OddsFinderDialog(context: context, widget: const WeekendRaceCalendarAlert()),
                                child: const Icon(Icons.event_note, color: Colors.white),
                              ),

                              const SizedBox(width: 20),

                              GestureDetector(
                                onTap: () {
                                  appParamNotifier.setSelectedDrawerRace(race: '');

                                  _scaffoldKey.currentState!.openDrawer();
                                },
                                child: const Icon(Icons.list, color: Colors.white),
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

                    if (_raceTabs.isNotEmpty)
                      Expanded(child: _buildRaceTabSection())
                    else if (widget.scheduleDateBashoMap[appParamState.selectedScheduleDate] != null)
                      const Text('会場を選択してください', style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      drawer: _dispDrawer(),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Divider(color: Colors.white.withValues(alpha: 0.5)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        OddsFinderDialog(context: context, widget: const TermsAlert());
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(2),
                        child: Text('利用規約', style: TextStyle(fontSize: 12, color: Colors.white54)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

            if (appParamState.keepLoginUserMap[widget.loggedInUserId] != null &&
                appParamState.keepLoginUserMap[widget.loggedInUserId]!.isAdmin == 1) ...<Widget>[
              ElevatedButton(
                onPressed: () {
                  OddsFinderDialog(
                    context: context,
                    widget: AdminMenuAlert(loggedInUserId: widget.loggedInUserId),
                  );
                },
                child: const Text('管理'),
              ),

              const SizedBox(height: 20),
            ],

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => OddsFinderDialog(context: context, widget: const HistoryRaceRecordDisplayAlert()),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.5))),
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset('assets/images/jockey.png', width: 35),
                      const SizedBox(width: 20),
                      const Text('過去レースの勝者リスト', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => OddsFinderDialog(context: context, widget: const PastRaceOddsTransitionAlert()),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.5))),
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset('assets/images/jockey.png', width: 35),
                      const SizedBox(width: 20),
                      const Text('過去レースのオッズ遷移表', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  appParamNotifier.setSelectedHorseNameChar1(char: '');
                  appParamNotifier.setSelectedHorseNameChar2(char: '');
                  OddsFinderDialog(context: context, widget: const HorseNameInitialPanelAlert());
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.5))),
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset('assets/images/jockey.png', width: 35),
                      const SizedBox(width: 20),
                      const Text('馬名リスト', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  appParamNotifier.setSelectedPopularityRank(rank: 0);
                  appParamNotifier.setSelectedPopularityRankYear(year: '');
                  OddsFinderDialog(context: context, widget: const PopularityRecordDisplayAlert());
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.5))),
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset('assets/images/jockey.png', width: 35),
                      const SizedBox(width: 20),
                      const Text('過去の人気順オッズリスト', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            Divider(color: Colors.white.withValues(alpha: 0.5), thickness: 5),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  _confirmLogout();
                },

                child: const SizedBox(
                  width: double.infinity,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox.shrink(),
                      Text('ログアウト', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
