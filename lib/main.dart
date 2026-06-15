import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/controllers_mixin.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? queryUser;

  if (kIsWeb) {
    final Uri uri = Uri.base;
    queryUser = uri.queryParameters['user'];
  }

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(ProviderScope(child: AppRoot(queryUser: queryUser)));
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key, this.queryUser});

  final String? queryUser;

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

  Future<void> restartApp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _reloadDate = prefs.getString('reload_selected_schedule_date') ?? '';
    _reloadKbd = prefs.getString('reload_selected_schedule_kaisuu_basho_day') ?? '';
    _reloadName = prefs.getString('reload_selected_schedule_kaisuu_basho_day_name') ?? '';
    _reloadRace = prefs.getInt('reload_selected_race_number') ?? 0;
    _reloadIsRankingDialogOpen = prefs.getBool('isRankingDialogOpen') ?? false;

    await prefs.remove('reload_selected_schedule_date');
    await prefs.remove('reload_selected_schedule_kaisuu_basho_day');
    await prefs.remove('reload_selected_schedule_kaisuu_basho_day_name');
    await prefs.remove('reload_selected_race_number');
    await prefs.remove('isRankingDialogOpen');

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
      queryUser: widget.queryUser,
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
    this.queryUser,
  });

  // ignore: unreachable_from_main
  final VoidCallback onRestart;
  final String reloadDate;
  final String reloadKbd;
  final String reloadName;
  final int reloadRace;
  final bool reloadIsRankingDialogOpen;
  final String? queryUser;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with ControllersMixin<MyApp> {
  ///
  @override
  void initState() {
    super.initState();

    scheduleNotifier.getAllScheduleData();
    raceNotifier.getAllRaceData();
    horseNotifier.getAllHorseData();
    oddsNotifier.getAllOddsData();
    laravelConfigNotifier.getAllLaravelConfigData();
    netkeibaOddsNotifier.getAllNetkeibaOddsData();
    netkeibaRaceNotifier.getAllNetkeibaRaceData();
    oddsGetTimingNotifier.getAllOddsGetTimingData();
    oddsWideNotifier.getAllOddsWideData();
    summaryNotifier.getAllSummaryData();
    raceResultNotifier.getAllRaceResultData();

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
        child: HomeScreen(
          scheduleDateBashoMap: scheduleState.scheduleDateBashoMap,
          raceMap: raceState.raceMap,
          horseMap: horseState.horseMap,
          oddsMap: oddsState.oddsMap,
          oddsGetTiming: laravelConfigState.odds_get_timing,
          netkeibaOddsMap: netkeibaOddsState.netkeibaOddsMap,
          oddsWideMap: oddsWideState.oddsWideMap,
          isRankingDialogOpen: widget.reloadIsRankingDialogOpen,
          summaryMap: summaryState.summaryMap,
          summaryDateBashoMap: summaryState.summaryDateBashoMap,
          raceResultMap: raceResultState.raceResultMap,
        ),
      ),
    );
  }
}
