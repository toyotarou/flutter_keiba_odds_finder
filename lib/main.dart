import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/controllers_mixin.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? queryUser;

  // push通知のディープリンク用パラメータ（URLのクエリから取得）
  // Laravel側(ImportKeibaOdds)が付与する date / kbd / name / race を読み取り、
  // リロード復元と同じ仕組みで該当レースの選択状態を復元する。
  String deepLinkDate = '';
  String deepLinkKbd = '';
  String deepLinkName = '';
  int deepLinkRace = 0;
  bool deepLinkRanking = false;
  bool deepLinkZoomed = false;

  if (kIsWeb) {
    final Uri uri = Uri.base;
    queryUser = uri.queryParameters['user'];

    deepLinkDate = uri.queryParameters['date'] ?? '';
    deepLinkKbd = uri.queryParameters['kbd'] ?? '';
    deepLinkName = uri.queryParameters['name'] ?? '';
    deepLinkRace = int.tryParse(uri.queryParameters['race'] ?? '') ?? 0;
    deepLinkRanking = uri.queryParameters['ranking'] == '1';
    deepLinkZoomed = uri.queryParameters['zoomed'] == '1';
  }

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String loggedInUserId = (prefs.getString('loggedInUserId') ?? '').trim();

  // 既にログイン済みの場合、起動時にpush subscriptionを再登録する
  // （DBから削除された場合でも自動復旧する）
  if (loggedInUserId.isNotEmpty) {
    unawaited(FcmService.registerToken(userId: loggedInUserId));
  }

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: AppRoot(
        queryUser: queryUser,
        loggedInUserId: loggedInUserId,
        deepLinkDate: deepLinkDate,
        deepLinkKbd: deepLinkKbd,
        deepLinkName: deepLinkName,
        deepLinkRace: deepLinkRace,
        deepLinkRanking: deepLinkRanking,
        deepLinkZoomed: deepLinkZoomed,
      ),
    ),
  );
}

class AppRoot extends StatefulWidget {
  const AppRoot({
    super.key,
    this.queryUser,
    required this.loggedInUserId,
    this.deepLinkDate = '',
    this.deepLinkKbd = '',
    this.deepLinkName = '',
    this.deepLinkRace = 0,
    this.deepLinkRanking = false,
    this.deepLinkZoomed = false,
  });

  final String? queryUser;
  final String loggedInUserId;

  // push通知のディープリンク用パラメータ
  final String deepLinkDate;
  final String deepLinkKbd;
  final String deepLinkName;
  final int deepLinkRace;
  final bool deepLinkRanking;
  final bool deepLinkZoomed;

  @override
  State<AppRoot> createState() => AppRootState();
}

class AppRootState extends State<AppRoot> {
  Key _appKey = UniqueKey();
  String _reloadDate = '';
  String _reloadKbd = '';
  String _reloadName = '';
  int _reloadRace = 0;
  bool _reloadIsRankingDialogOpen = false;
  bool _reloadIsZoomed = false;
  bool _reloadAllExpanded = false;
  late String _loggedInUserId;

  @override
  void initState() {
    super.initState();
    _loggedInUserId = widget.loggedInUserId;

    // push通知のディープリンクで開かれた場合、reload用フィールドに初期値として渡す。
    // これにより MyApp.initState の既存のreload復元ロジックがそのまま使われ、
    // 該当レースの 日付 / 会場 / レース番号 が自動選択される。
    if (widget.deepLinkDate.isNotEmpty) {
      _reloadDate = widget.deepLinkDate;
      _reloadKbd = widget.deepLinkKbd;
      _reloadName = widget.deepLinkName;
      _reloadRace = widget.deepLinkRace;
      _reloadIsRankingDialogOpen = widget.deepLinkRanking;
      _reloadIsZoomed = widget.deepLinkZoomed;
    }
  }

  Future<void> restartApp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _loggedInUserId = (prefs.getString('loggedInUserId') ?? '').trim();

    _reloadDate = prefs.getString('reload_selected_schedule_date') ?? '';
    _reloadKbd = prefs.getString('reload_selected_schedule_kaisuu_basho_day') ?? '';
    _reloadName = prefs.getString('reload_selected_schedule_kaisuu_basho_day_name') ?? '';
    _reloadRace = prefs.getInt('reload_selected_race_number') ?? 0;
    _reloadIsRankingDialogOpen = prefs.getBool('isRankingDialogOpen') ?? false;
    _reloadAllExpanded = prefs.getBool('reload_all_expanded') ?? false;

    await prefs.remove('reload_selected_schedule_date');
    await prefs.remove('reload_selected_schedule_kaisuu_basho_day');
    await prefs.remove('reload_selected_schedule_kaisuu_basho_day_name');
    await prefs.remove('reload_selected_race_number');
    await prefs.remove('isRankingDialogOpen');
    await prefs.remove('reload_all_expanded');

    if (mounted) {
      setState(() => _appKey = UniqueKey());
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    return MyApp(
      key: _appKey,
      onRestart: restartApp,
      reloadDate: _reloadDate,
      reloadKbd: _reloadKbd,
      reloadName: _reloadName,
      reloadRace: _reloadRace,
      reloadIsRankingDialogOpen: _reloadIsRankingDialogOpen,
      reloadIsZoomed: _reloadIsZoomed,
      reloadAllExpanded: _reloadAllExpanded,
      queryUser: widget.queryUser,
      loggedInUserId: _loggedInUserId,
    );
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({
    super.key,
    required this.onRestart,
    required this.reloadDate,
    required this.reloadKbd,
    required this.reloadName,
    required this.reloadRace,
    required this.reloadIsRankingDialogOpen,
    this.reloadIsZoomed = false,
    this.reloadAllExpanded = false,
    this.queryUser,
    required this.loggedInUserId,
  });

  // ignore: unreachable_from_main
  final VoidCallback onRestart;
  final String reloadDate;
  final String reloadKbd;
  final String reloadName;
  final int reloadRace;
  final bool reloadIsRankingDialogOpen;
  final bool reloadIsZoomed;
  final bool reloadAllExpanded;
  final String? queryUser;
  final String loggedInUserId;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with ControllersMixin<MyApp> {
  late String _loggedInUserId;

  ///
  @override
  void initState() {
    super.initState();

    _loggedInUserId = widget.loggedInUserId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.queryUser != null && widget.queryUser!.isNotEmpty) {
        appParamNotifier.setQueryUser(user: widget.queryUser!);
      }

      if (widget.reloadDate.isNotEmpty) {
        appParamNotifier.setSelectedScheduleDate(date: widget.reloadDate);
        if (widget.reloadKbd.isNotEmpty) {
          appParamNotifier.setSelectedScheduleKaisuuBashoDay(kbd: widget.reloadKbd, name: widget.reloadName);
        }
        if (widget.reloadRace > 0) {
          appParamNotifier.setSelectedRaceNumber(num: widget.reloadRace);
        }

        appParamNotifier.setIsZoomed(flag: widget.reloadIsZoomed);

        if (widget.reloadAllExpanded != appParamState.allExpanded) {
          appParamNotifier.setAllExpanded();
        }
      }
    });
  }

  ///
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ignore: always_specify_types
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const <Locale>[Locale('en'), Locale('ja')],

      theme: ThemeData(
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(Colors.greenAccent.withOpacity(0.4)),
        ),
        useMaterial3: false,
        colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark),
        highlightColor: Colors.grey,
      ),

      themeMode: ThemeMode.dark,
      title: 'HORSE ODDS FINDER',
      debugShowCheckedModeBanner: false,
      home: GestureDetector(
        onTap: () => primaryFocus?.unfocus(),
        child: _loggedInUserId.isNotEmpty
            ? HomeScreen(
                scheduleDateBashoMap: scheduleState.scheduleDateBashoMap,
                raceMap: raceState.raceMap,
                horseMap: horseState.horseMap,
                oddsMap: oddsState.oddsMap,
                oddsGetTiming: laravelConfigState.oddsGetTiming,

                oddsDropRateHonmei: laravelConfigState.oddsDropRateHonmei,
                oddsDropRateChuana: laravelConfigState.oddsDropRateChuana,
                oddsDropRateDaiana: laravelConfigState.oddsDropRateDaiana,

                //                netkeibaOddsMap: netkeibaOddsState.netkeibaOddsMap,
                // oddsWideMap: oddsWideState.oddsWideMap,
                //
                //
                //
                isRankingDialogOpen: widget.reloadIsRankingDialogOpen,
                summaryMap: summaryState.summaryMap,
                summaryDateBashoMap: summaryState.summaryDateBashoMap,
                raceResultMap: raceResultState.raceResultMap,
                loginUserMap: loginUserState.loginUserMap,
                pushNotifierUserList: pushNotifierUserState.pushNotifierUserList,
                popularityRankOddsAverageMap: popularityRankOddsAverageState.popularityRankOddsAverageMap,
                popularityRankOddsMedianMap: popularityRankOddsMedianState.popularityRankOddsMedianMap,
                loggedInUserId: _loggedInUserId,
                onLogout: () => setState(() => _loggedInUserId = ''),
              )
            : LoginScreen(onLoginSuccess: (String userId) => setState(() => _loggedInUserId = userId)),
      ),
    );
  }
}
