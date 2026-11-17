// =============================================================================
// ファイル名   : race_content_page.dart
// 概要         : レース1件ぶんの画面。レース情報・発走までの残り時間・オッズ取得タイミングの選択・
//                人気順の馬の一覧（オッズの推移・急落判定・AI 予想のバッジなど）を表示する。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-08
// 最終更新日   : 2026-11-17
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const/const.dart';
import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../models/common/ai_response_recommend_horse_model.dart';
import '../../models/horse_model.dart';
import '../../models/odds_model.dart';
import '../../models/popularity_rank_odds_median_model.dart';
import '../../models/race_model.dart';
import '../../models/race_result_model.dart';
import '../../models/race_result_payout_model.dart';
import '../../utility/functions.dart';
import '../../utility/utility.dart';
import '../components/ai_analysis_display_alert.dart';

import '../components/horse_detail_display_alert.dart';
import '../components/horse_odds_ranking_display_alert.dart';
import '../components/payout_data_display_alert.dart';

import '../components/total_forecast_display_alert.dart';
import '../parts/dashed_line_painter.dart';
import '../parts/odds_finder_dialog.dart';
import '../parts/odds_up_down_icon.dart';

import '../parts/widget_display_overlay.dart';

/// レース1件ぶんの画面。
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

/// レース1件ぶんの画面の状態。
class _RaceContentPageState extends ConsumerState<RaceContentPage> with ControllersMixin<RaceContentPage> {
  final AutoScrollController _horseListScrollController = AutoScrollController();
  int _currentHorseIndex = 0;
  int _displayListLength = 0;

  Timer? _countdownTimer;
  final ValueNotifier<int> _remainingSecondsNotifier = ValueNotifier<int>(0);
  String _lastStartTime = '';

  final Utility _utility = Utility();

  final GlobalKey _analysisButtonKey = GlobalKey();
  Map<int, String> _analysisMap = <int, String>{};

  // サーバーの pickup_horse（現在は空で返ってくる）。バッジは _aiForecastScoreMap で出す。
  String _aiPickupHorse = '';
  Map<int, double?> _baganrikiIndexMap = <int, double?>{};

  // 払戻データ（t_horse_odds_finder_race_result_payout）が存在するか。払戻金ボタンの表示判定に使う。
  bool _hasPayout = false;
  List<AiResponseRecommendHorseModel> _totalForecastAiHorseList = <AiResponseRecommendHorseModel>[];
  int? _totalForecastUpsetRaceValue;
  Map<String, int?>? _totalForecastRaceMetrics;
  List<AiResponseRecommendHorseModel> _secondAiHorseList = <AiResponseRecommendHorseModel>[];
  List<AiResponseRecommendHorseModel> _mergedHorseList = <AiResponseRecommendHorseModel>[];

  /// サーバーから統合結果（merged_horses）を受け取ったか。
  /// 受け取った場合は、0頭（全頭がフィルターで除外）でもその結果を正とし、
  /// 1st/2nd の生リストを足し合わせた表示（サーバーが除外した馬が混ざる）へは戻さない。
  bool _mergedReceived = false;

  /// 統合結果の状態（'undetermined' ＝ 採用できるAI回答が無かった）
  String? _mergeStatus;

  /// 予想を出さなかった理由の文言（サーバーの status_reason）。AI予想の画面へそのまま渡す
  String? _mergeStatusReason;

  /// サーバーが「予想の準備中」（not_ready）と返したか。「AI予想」ボタンの案内の文言を分けるために使う
  bool _aiNotReady = false;

  /// 1st AI の取得に成功したか（失敗・未完了なら 2nd AI は呼ばない）
  bool _firstAiOk = false;

  /// 「AI予想」ボタンの連打防止（取得待ち中は再度押しても何もしない）
  bool _isOpeningAiForecast = false;

  // AI取得中ローディング管理
  int _aiPendingCount = 0;
  bool _showAiLoading = false;
  Timer? _aiLoadingTimer;

  // 人気順カードの展開状態（馬番 → 展開中か）。フロートタイトルを「展開中のカードだけ」に出すために保持する。
  // 値がない馬は appParamState.allExpanded と同じ扱い。allExpanded が切り替わったらクリアする（ExpansionTile の Key も作り直されるため）。
  final Map<int, bool> _horseExpandedMap = <int, bool>{};
  bool? _horseExpandedMapAllExpanded;

  /// 指定した馬のカードが展開中かどうか。個別の指定が無ければ「すべて開く／閉じる」の状態に従う。
  bool _isHorseExpanded(int horseNum) => _horseExpandedMap[horseNum] ?? appParamState.allExpanded;

  // 以下のゲッターは1回の build で何度も呼ばれるため、
  // 元データ（oddsMap / horseMap / raceResultMap の該当リスト）が同じインスタンスの間は計算結果を使い回す。
  // 元データは取得・更新のたびに新しいリストに差し替わる（その場で書き換えられない）ので、インスタンス比較で十分。
  // ※ 返したリスト・マップは共有されるので、呼び出し側でその場ソートなどの書き換えをしないこと。
  String _cacheKey = '';
  List<OddsModel>? _oddsForRaceSource;
  List<OddsModel>? _oddsForRaceCache;
  List<HorseModel>? _horseModelMapSource;
  Map<int, HorseModel>? _horseModelMapCache;
  List<RaceResultModel>? _numToRankMapSource;
  Map<int, int>? _numToRankMapCache;
  List<OddsModel>? _displayListSource;
  String _displayListTiming = '';
  String _displayListFirstKey = '';
  List<OddsModel>? _displayListCache;

  /// mapKey / raceNumber が変わったらキャッシュを破棄する（通常は Key で別 State になるが念のため）
  void _checkCacheKey() {
    final String key = '${widget.mapKey}_${widget.raceNumber}';
    if (key != _cacheKey) {
      _cacheKey = key;
      _oddsForRaceCache = null;
      _horseModelMapCache = null;
      _numToRankMapCache = null;
      _displayListCache = null;
    }
  }

  Map<int, int> get _numToRankMap {
    _checkCacheKey();
    final List<RaceResultModel>? source = widget.raceResultMap[widget.mapKey];
    if (_numToRankMapCache == null || !identical(source, _numToRankMapSource)) {
      _numToRankMapSource = source;
      _numToRankMapCache = _utility.buildNumToRankMap(source ?? <RaceResultModel>[], widget.raceNumber);
    }
    return _numToRankMapCache!;
  }

  /// 表示中のレースのオッズ一覧（元データが同じ間は前回の結果を使い回す）。
  List<OddsModel> get _oddsForRace {
    _checkCacheKey();
    final List<OddsModel>? source = widget.oddsMap[widget.mapKey];
    if (_oddsForRaceCache == null || !identical(source, _oddsForRaceSource)) {
      _oddsForRaceSource = source;
      _oddsForRaceCache = (source ?? <OddsModel>[]).where((OddsModel e) => e.race == widget.raceNumber).toList();
    }
    return _oddsForRaceCache!;
  }

  /// 表示中のレースの出走馬（馬番 → 馬）の対応表（元データが同じ間は前回の結果を使い回す）。
  Map<int, HorseModel> get _horseModelMap {
    _checkCacheKey();
    final List<HorseModel>? source = widget.horseMap[widget.mapKey];
    if (_horseModelMapCache == null || !identical(source, _horseModelMapSource)) {
      _horseModelMapSource = source;
      _horseModelMapCache = <int, HorseModel>{
        for (final HorseModel e in (source ?? <HorseModel>[]).where((HorseModel e) => e.race == widget.raceNumber))
          e.num: e,
      };
    }
    return _horseModelMapCache!;
  }

  /// サーバー設定のオッズ取得タイミングを '|' で分けた一覧。
  List<String> get _configTimingParts => appParamState.configOddsGetTiming.split('|');

  /// オッズ取得タイミングのうち最初のもの（無ければ空文字）。
  String get _configFirstKey {
    final List<String> p = _configTimingParts;
    return p.isNotEmpty ? p.first : '';
  }

  /// オッズ取得タイミングのうち最後のもの（無ければ空文字）。
  String get _configLastKey {
    final List<String> p = _configTimingParts;
    return p.isNotEmpty ? p.last : '';
  }

  /// 取得済みのオッズのうち、いちばん発走に近いタイミング。
  String get _minTiming {
    return _resolveMinTiming(_oddsForRace, _configFirstKey, _configLastKey);
  }

  /// 画面表示後に、馬眼力指数・払戻金の有無・保存済みの AI 予想（1st → 2nd の順）を取得する。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchBaganrikiIndex();
        _fetchPayoutExists();
        // 1st AI → 2nd AI の順に呼ぶ（仕様: 2nd AI は 1st AI と同じ入力で独立評価し、その後に統合する）。
        // 同時に呼ぶと 1st AI 未保存のまま 2nd AI が走り、統合できない／失敗時も 2nd AI を呼んでしまう。
        // レースを開いた時点ではAIを呼ばず、保存済みの結果だけを取りに行く。
        //   AI予想は6分前オッズのあとにサーバの補完（先回り実行）が作っておく。
        //   未保存なら何もしない（_firstAiOk は false のまま）。AIは「AI予想」ボタンを押したときに呼ぶ。
        _fetchAiPickup(cacheOnly: true).then((_) {
          if (mounted && _firstAiOk) {
            _fetchSecondAiOpinion(cacheOnly: true);
          }
        });
      }
    });
  }

  /// タイマー・通知用の値・スクロールの制御を破棄する。
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _aiLoadingTimer?.cancel();
    _remainingSecondsNotifier.dispose();
    _horseListScrollController.dispose();
    super.dispose();
  }

  /// 1st AI の予想を取得する（最初と発走6分前のオッズがそろってから）。
  /// [cacheOnly] が true のときは保存済みの結果だけを取る（AI は呼ばない）。
  Future<void> _fetchAiPickup({bool cacheOnly = false}) async {
    final List<OddsModel> allOdds = _oddsForRace;
    final bool hasFirstTiming = allOdds.any((OddsModel e) => e.minutesBeforeStart == kOddsTimingFirst);
    final bool hasSixMinTiming = allOdds.any((OddsModel e) => e.minutesBeforeStart == kOddsJudgeTiming);
    if (!hasFirstTiming || !hasSixMinTiming) {
      return;
    }

    _beginAiFetch();

    try {
      final String date = appParamState.selectedScheduleDate;
      final int race = widget.raceNumber;
      final (:String kaisuu, :String basho, :String day) = parseKbdParts(appParamState.selectedScheduleKaisuuBashoDay);
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
        cacheOnly: cacheOnly,
      );
      // 未保存（not_ready）のときは取得できていない扱いにする。
      //   ここで _firstAiOk を true にすると、「AI予想」ボタンで取り直しが走らず、空の予想が開く。
      if (data['not_ready'] == true) {
        _aiNotReady = true;   // 「予想の準備中」の案内を出すため
        return;
      }
      _aiNotReady = false;
      final String pickupRaw = (data['pickup_horse'] as String?) ?? '';
      final String analysisText = (data['analysis_text'] as String?) ?? '';
      final List<AiResponseRecommendHorseModel> horses = parseAnalysisText(analysisText);
      if (mounted) {
        setState(() {
          _aiPickupHorse = pickupRaw;
          _totalForecastAiHorseList = horses;
          _totalForecastUpsetRaceValue = parseUpsetRaceValue(analysisText);
          _totalForecastRaceMetrics = parseRaceMetrics(analysisText);
          _firstAiOk = true;
        });
      }
    } catch (_) {
    } finally {
      _endAiFetch();
    }
  }

  /// 表示中のレースの馬眼力指数を取得する（最初と発走6分前のオッズがそろってから）。
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

  /// このレースの払戻データがあるかを取得して [_hasPayout] に反映する。
  Future<void> _fetchPayoutExists() async {
    final String date = appParamState.selectedScheduleDate;
    final int race = widget.raceNumber;
    final (:String kaisuu, :String basho, day: _) = parseKbdParts(appParamState.selectedScheduleKaisuuBashoDay);
    if (kaisuu.isEmpty || basho.isEmpty) {
      return;
    }
    try {
      final Map<String, RaceResultPayoutModel> result = await fetchPayoutMap(
        ref,
        racesParam: '$date|$kaisuu|$basho|$race',
      );
      if (mounted) {
        setState(() => _hasPayout = result.isNotEmpty);
      }
    } catch (_) {}
  }

  /// 2nd AI の予想と、1st・2nd の統合結果を取得する。
  /// [cacheOnly] が true のときは保存済みの結果だけを取る（AI は呼ばない）。
  Future<void> _fetchSecondAiOpinion({bool cacheOnly = false}) async {
    final List<OddsModel> allOdds = _oddsForRace;
    final bool hasFirstTiming = allOdds.any((OddsModel e) => e.minutesBeforeStart == kOddsTimingFirst);
    final bool hasSixMinTiming = allOdds.any((OddsModel e) => e.minutesBeforeStart == kOddsJudgeTiming);
    if (!hasFirstTiming || !hasSixMinTiming) {
      return;
    }

    _beginAiFetch();

    try {
      final String date = appParamState.selectedScheduleDate;
      final int race = widget.raceNumber;
      final (:String kaisuu, :String basho, :String day) = parseKbdParts(appParamState.selectedScheduleKaisuuBashoDay);
      final Map<String, dynamic> data = await fetchSecondAiOpinionData(
        ref,
        date: date,
        kaisuu: kaisuu,
        basho: basho,
        day: day,
        race: race,
        cacheOnly: cacheOnly,
      );
      // 未保存（not_ready）のときは何も反映しない（_mergedReceived は false のまま）
      if (data['not_ready'] == true) {
        return;
      }
      final String analysisText = (data['analysis_text'] as String?) ?? '';
      final List<dynamic>? mergedRaw = data['merged_horses'] as List<dynamic>?;
      final List<AiResponseRecommendHorseModel> horses = parseAnalysisText(analysisText);
      // 厳選穴レースは統合後にサーバーが再判定した値が正。
      // 1st AI テキストの行をパースした値とは食い違うことがある。
      final int? mergedUpsetRace = (data['upset_race'] as num?)?.toInt();
      final Map<String, int?>? mergedMetrics = parseRaceMetricsJson(data['race_metrics']);
      if (mounted) {
        setState(() {
          _secondAiHorseList = horses;
          if (mergedRaw != null) {
            _mergedHorseList = parseMergedHorses(mergedRaw);
            _mergedReceived = true;
          }
          _mergeStatus = data['status'] as String?;
          _mergeStatusReason = data['status_reason'] as String?;
          if (mergedUpsetRace != null) {
            _totalForecastUpsetRaceValue = mergedUpsetRace;
          }
          if (mergedMetrics != null) {
            _totalForecastRaceMetrics = mergedMetrics;
          }
        });
      }
    } catch (_) {
    } finally {
      _endAiFetch();
    }
  }

  /// 「AI予想」アラートに並ぶ候補馬の 馬番 → おすすめ度。
  ///
  /// アラート（AiAnalysisDisplayAlert._displayHorses）と同じ基準で作る。
  ///   統合結果を受け取っていればそれを正とする（0頭でもそれを使う）。
  ///   受け取っていなければ、1st AI の選出馬に 2nd AI だけが選んだ馬を足したもの。
  // 「補充」の馬は、AI選出のバッジは出すが、おすすめ度（サーバーでは0）は null にして「%」を出さない
  Map<int, int?> get _aiForecastScoreMap {
    final List<AiResponseRecommendHorseModel> list = _mergedReceived
        ? _mergedHorseList
        : mergeAiHorseLists(_totalForecastAiHorseList, _secondAiHorseList);
    return <int, int?>{for (final AiResponseRecommendHorseModel h in list) h.num: h.fillSlot ? null : h.score};
  }

  /// 「AI予想」を開く前に、1st AI・2nd AI（統合結果）の取得完了を待つ。
  ///
  /// 【なぜ必要か】
  ///   AiAnalysisDisplayAlert は開いた時点のリストをコンストラクタで受け取るだけで、
  ///   開いたあとに届いたデータは反映されない。取得中・取得失敗のまま開くと空の予想が出ていた。
  ///   1st AI が失敗すると 2nd AI は呼ばれず、画面を開き直しても取り直しが走らなかった。
  /// 【動き】
  ///   1. 取得中なら終わるまで待つ（最大150秒）
  ///   2. 1st AI が未取得なら取り直す
  ///   3. 統合結果が未受領なら 2nd AI を取り直す
  /// 戻り値: 1st AI が取得できていれば true（false のときは画面を開かない）
  Future<bool> _ensureAiForecastLoaded() async {
    int waitedMs = 0;
    while (_aiPendingCount > 0 && mounted && waitedMs < 150000) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      waitedMs += 200;
    }
    if (!mounted) {
      return false;
    }
    if (!_firstAiOk) {
      await _fetchAiPickup();
    }
    if (mounted && _firstAiOk && !_mergedReceived) {
      await _fetchSecondAiOpinion();
    }
    return mounted && _firstAiOk;
  }

  /// AI fetch 開始: カウント 0→1 の時だけタイマーを起動
  void _beginAiFetch() {
    if (_aiPendingCount == 0) {
      _aiLoadingTimer?.cancel();
      _aiLoadingTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted && _aiPendingCount > 0) {
          setState(() => _showAiLoading = true);
        }
      });
    }
    _aiPendingCount++;
  }

  /// AI fetch 終了: 全完了時にタイマーをキャンセルしてインジケータを消す
  void _endAiFetch() {
    _aiPendingCount--;
    if (_aiPendingCount == 0) {
      _aiLoadingTimer?.cancel();
      _aiLoadingTimer = null;
      _showAiLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 過去データから見た、人気順ごとの分析文を取得する。1件以上あれば true を返す。
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

  /// 発走時刻までの残り時間を1秒ごとに数え始める。発走時刻が分からないときは 0 にする。
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

  /// 残り秒数を「時:分:秒」の文字列にする。
  static String _formatCountdown(int totalSeconds) {
    final int h = totalSeconds ~/ 3600;
    final int m = (totalSeconds % 3600) ~/ 60;
    final int s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// 馬の一覧を、指定した数だけ前後の馬までスクロールする。
  void _scrollHorseList(int delta) {
    if (!_horseListScrollController.hasClients || _displayListLength == 0) {
      return;
    }
    final int next = (_currentHorseIndex + delta).clamp(0, _displayListLength - 1);
    _currentHorseIndex = next;
    _horseListScrollController.scrollToIndex(next, preferPosition: AutoScrollPosition.begin);
  }

  /// 選択中のタイミングを「〜分前の」「レース開始時点の」という表示用の文字列にする。
  static String _beforeMinutesText(String selectedTiming) => switch (selectedTiming) {
    '0' => 'レース開始時点の',
    '' => '',
    _ => '$selectedTiming分前の',
  };

  /// 馬番ごとに、タイミング順に並べた値（オッズなど）の一覧を作る。
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

  /// 設定のタイミング文字列を、列の順番（最初・発走何分前・最後）に変換する。
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

  /// 選択中のタイミングを、絞り込みに使う「発走何分前」の値に変換する。
  static int? _resolveFilterMinutes(String selectedTiming, List<OddsModel> oddsModelList, int firstTiming) =>
      resolveFilterMinutes(selectedTiming, oddsModelList, firstTiming);

  /// 「発走何分前」の値を、タイミングのキー文字列に戻す。
  static String _filterMinutesToTimingKey(int? filterMinutes, String firstTimingKey, String lastTimingKey) {
    return switch (filterMinutes) {
      null => '',
      kOddsTimingFirst => firstTimingKey,
      kOddsTimingLast => lastTimingKey,
      _ => filterMinutes.toString(),
    };
  }

  /// 取得済みのオッズのうち、いちばん発走に近いタイミングのキーを返す。
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

  /// 選択中のタイミングで表示する、人気順のオッズ一覧（条件が同じ間は前回の結果を使い回す）。
  List<OddsModel> _buildDisplayList() {
    final List<OddsModel> oddsForRace = _oddsForRace;
    final String selectedTiming = appParamState.selectedTiming;
    final String configFirstKey = _configFirstKey;
    // 元のオッズ・選択タイミング・設定が同じ間は前回の結果を使い回す
    if (_displayListCache == null ||
        !identical(oddsForRace, _displayListSource) ||
        selectedTiming != _displayListTiming ||
        configFirstKey != _displayListFirstKey) {
      _displayListSource = oddsForRace;
      _displayListTiming = selectedTiming;
      _displayListFirstKey = configFirstKey;
      _displayListCache = buildOddsDisplayList(
        oddsForRace: oddsForRace,
        selectedTiming: selectedTiming,
        configFirstKey: configFirstKey,
      );
    }
    return _displayListCache!;
  }

  /// レース情報（発走時刻・残り時間・レース名・コース・距離・グレード）の帯を表示する。
  Widget _buildRaceInfoBar({
    required String startTime,
    required String raceName,
    required String course,
    required int dist,
    required String grade,
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
                  SizedBox(
                    width: context.screenSize.width * 0.6,
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      alignment: Alignment.topRight,
                      child: grade.isNotEmpty
                          ? Opacity(
                              opacity: 0.5,
                              child: Image.asset('assets/race_grade_icon/race_grade_icon_$grade.png', width: 30),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),

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

  /// 「すべて開く／閉じる」や前後のレースへの移動などの操作ボタンを表示する。
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
                OddsFinderDialog(context: context, widget: const HorseOddsRankingDisplayAlert(), hideRaceOverlay: true);
              },
              child: Icon(Icons.list, color: Colors.white.withValues(alpha: 0.5)),
            ),

            // ── r12.2 の確認ボタンはお客さんの画面から外す（新しい予想は非公開の段階のため）。中身は残す ──

            if (_hasPayout) ...<Widget>[
              const SizedBox(width: 15),

              GestureDetector(
                onTap: () {
                  OddsFinderDialog(
                    context: context,
                    hideRaceOverlay: true,
                    widget: PayoutDataDisplayAlert(raceNumber: widget.raceNumber),
                    paddingLeft: context.screenSize.width * 0.1,
                    paddingTop: context.screenSize.height * 0.05,
                    paddingBottom: context.screenSize.height * 0.1,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBB6CE).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Text('払戻金', style: TextStyle(fontSize: 10, color: Colors.white)),
                ),
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
    );
  }

  /// オッズ取得タイミングを選ぶボタンの行を表示する。
  Widget _displayRaceMinutesRow() {
    final List<String> timingParts = _configTimingParts;
    final String minTiming = _minTiming;

    // 値が変わるときだけセットする（毎 build セットすると再描画が止まらなくなっていた）
    if (appParamState.selectedTiming.isEmpty && minTiming.isNotEmpty && appParamState.selectedTiming2 != minTiming) {
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

  /// 人気順の馬の一覧（オッズの推移・各種バッジ付き）を表示する。
  Widget _displayRaceHorseList({required String course, required int dist}) {
    // _oddsForRace はキャッシュを共有しているため、コピーしてからソートする
    final List<OddsModel> oddsModelList = <OddsModel>[..._oddsForRace];
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

    // OPEN/CLOSE ボタンで allExpanded が切り替わったら、個別の展開状態を捨てる
    if (_horseExpandedMapAllExpanded != appParamState.allExpanded) {
      _horseExpandedMapAllExpanded = appParamState.allExpanded;
      _horseExpandedMap.clear();
    }

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

  /// 馬1頭ぶんのカード（馬名・オッズの推移・急落判定など）を表示する。
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
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
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
                          showTrailingIcon: false,

                          key: ValueKey<String>('horse_${element.num}_${appParamState.allExpanded}'),
                          // 画面外で破棄→再生成されても展開状態が戻らないよう、保持している状態から初期化する
                          initiallyExpanded: _isHorseExpanded(element.num),
                          onExpansionChanged: (bool expanded) {
                            setState(() => _horseExpandedMap[element.num] = expanded);
                          },
                          tilePadding: EdgeInsets.zero,
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
                      // 着順ラベルを ai_analysis_display_alert.dart の着順ラベル（角丸の四角）と同じ形にする
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: raceRankColor(raceRank, alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
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
                    ],

                    // 展開中カードのフロートタイトル（カード上部が画面外に出たら、表示エリア上端に追従する）
                    if (_isHorseExpanded(element.num))
                      Positioned.fill(
                        child: _FloatingHorseTitle(
                          popularity: popularity,
                          horseNum: element.num,
                          scrollController: _horseListScrollController,
                        ),
                      ),
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

  /// 発走30分前と6分前のオッズから急落を判定し、該当すれば説明を表示する。
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

  /// 馬のカードの見出し（人気順・複勝の順位・AI のバッジなど）を表示する。
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
                  OddsFinderDialog(context: context, widget: const HorseDetailDisplayAlert(), hideRaceOverlay: true);
                }
              },
              child: FaIcon(FontAwesomeIcons.horse, size: 20, color: Colors.green[500]!.withValues(alpha: 0.6)),
            ),

            const SizedBox(width: 20),

            // 「AI予想」アラートと同じ候補馬（_aiForecastScoreMap）にバッジを出す
            if (horse != null && _aiForecastScoreMap.containsKey(horse.num)) ...<Widget>[
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

                  if (_aiForecastScoreMap[horse.num] != null) ...<Widget>[
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Text(
                        '${_aiForecastScoreMap[horse.num]} %',
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),

        const SizedBox.shrink(),
      ],
    );
  }

  /// 人気順に並べたとき、オッズに大きな断絶がある馬の馬番一覧。
  List<int> _calcOddsGapHorseNums() => calcOddsGapHorseNums(_oddsForRace);

  /// 波乱馬としてピックアップした馬の馬番一覧。
  List<int> _calcUpsetPickupHorseNums() => calcUpsetPickupHorseNums(
    oddsForRace: _oddsForRace,
    medianModel: _makeMedianList(),
    displayList: _buildDisplayList(),
  );

  /// 発走30分前から最後のタイミングまでの単勝オッズの変化率。計算できなければ null。
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

  /// 馬名・枠番・騎手などの行を表示する。オッズの変化率も添える。
  Widget _buildHorseNameRow({
    required OddsModel element,
    required HorseModel? horse,
    required Map<int, Color> horseWakuColorMap,
    List<String>? oddsTimeline,
  }) {
    if (horse == null) {
      return const SizedBox.shrink();
    }

    final double? oddsDropRatio = _calcOddsDropRatio(oddsTimeline);

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
                      const SizedBox(width: 15),
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
                    right: 15,
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

        if (oddsDropRatio != null) ...<Widget>[
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
                      '+${((1 - oddsDropRatio) * 100).toStringAsFixed(0)}%',
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

  /// レース1件ぶんの画面（レース情報・操作ボタン・タイミング選択・馬の一覧）を組み立てる。
  @override
  Widget build(BuildContext context) {
    final List<RaceModel> races = widget.raceMap[widget.mapKey] ?? <RaceModel>[];
    final int raceIdx = races.indexWhere((RaceModel e) => e.race == widget.raceNumber);

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

    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildRaceInfoBar(
              startTime: startTime,
              raceName: raceName,
              course: course,
              dist: dist,
              grade: currentRaceModel?.grade ?? '',
            ),

            _buildControlButtons(raceIdx: raceIdx),

            // median != null && raceResultByRank.isNotEmpty
            if (hasBothTimings) ...<Widget>[
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
                          final RenderBox? renderBox =
                              _analysisButtonKey.currentContext?.findRenderObject() as RenderBox?;
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
                      onTap: () async {
                        // 取得が終わってから画面を開く（取得前に開くと、空の予想のまま固定される）
                        if (_isOpeningAiForecast) {
                          return;
                        }
                        _isOpeningAiForecast = true;
                        final bool aiReady = await _ensureAiForecastLoaded();
                        _isOpeningAiForecast = false;
                        if (!mounted) {
                          return;
                        }
                        if (!aiReady) {
                          ScaffoldMessenger.maybeOf(
                            // ignore: use_build_context_synchronously
                            context,
                          // サーバーが「予想の準備中」と返したときは、その旨を出す
                          )?.showSnackBar(SnackBar(content: Text(_aiNotReady
                              ? '予想の準備中です。少し待ってからもう一度押してください'
                              : 'AI予想を取得できませんでした。少し待ってからもう一度押してください')));
                          return;
                        }
                        OddsFinderDialog(
                          // ignore: use_build_context_synchronously
                          context: context,
                          hideRaceOverlay: true,
                          widget: AiAnalysisDisplayAlert(
                            raceNumber: widget.raceNumber,
                            numToRankMap: numToRankMap,
                            aiHorseList: _totalForecastAiHorseList,
                            secondAiHorseList: _secondAiHorseList,
                            mergedHorseList: _mergedReceived ? _mergedHorseList : null,
                            upsetRaceValue: _totalForecastUpsetRaceValue,
                            raceMetrics: _totalForecastRaceMetrics,
                            mergeStatus: _mergeStatus,
                            mergeStatusReason: _mergeStatusReason,
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
                          hideRaceOverlay: true,
                          widget: TotalForecastDisplayAlert(
                            displayList: sixMinDisplayList,
                            horseModelMap: horseModelMap,
                            numToRankMap: numToRankMap,
                            currentRaceModel: currentRaceModel!,
                            pickupHorse: _aiPickupHorse,
                            gapHorseNums: gapHorseNums,
                            upsetPickupHorseNums: upsetPickupHorseNums,
                            // 統合結果があればそれを使う（サーバー側フィルター適用後の本当の候補）
                            aiHorseList: _mergedReceived
                                ? _mergedHorseList
                                : mergeAiHorseLists(_totalForecastAiHorseList, _secondAiHorseList),
                            upsetRaceValue: _totalForecastUpsetRaceValue,
                            raceMetrics: _totalForecastRaceMetrics,
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

              const SizedBox(height: 10),
            ],

            SizedBox(height: 40, child: _displayRaceMinutesRow()),

            const SizedBox(height: 5),
            Expanded(
              child: _displayRaceHorseList(course: course, dist: dist),
            ),
          ],
        ),
        if (_showAiLoading)
          const Positioned.fill(
            child: Center(child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2)),
          ),
      ],
    );
  }

  /// 表示中のレースの、人気順別オッズ中央値。無ければ null。
  PopularityRankOddsMedianModel? _makeMedianList() {
    final List<PopularityRankOddsMedianModel> popularityRankOddsMedianModelList =
        appParamState.keepPopularityRankOddsMedianMap[widget.mapKey] ?? <PopularityRankOddsMedianModel>[];

    final List<PopularityRankOddsMedianModel> filtered = popularityRankOddsMedianModelList
        .where((PopularityRankOddsMedianModel e) => e.race == widget.raceNumber)
        .toList();

    return filtered.isNotEmpty ? filtered.first : null;
  }
}

/// 馬1頭ぶんのオッズの推移（タイミングごとの値と上下の矢印）を1行で表示する部品。
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

  /// オッズの推移（タイミングごとの値と上下の矢印）を1行で表示する。
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
          top: 125,
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
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        height: 30,
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
                      const SizedBox(height: 10),
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

/// 人気順カードの上に重ねる、追従タイトル（「◯番人気　馬番X」）。
/// カード本来のタイトルが画面外にスクロールされたら、表示エリア上端に貼りつく。
/// カードの下端まで来たら、それ以上は下がらず、カードと一緒にスクロールして消える。
class _FloatingHorseTitle extends StatefulWidget {
  const _FloatingHorseTitle({required this.popularity, required this.horseNum, required this.scrollController});

  final int popularity;
  final int horseNum;
  final ScrollController scrollController;

  /// カード上端がこの距離（px）以上、表示エリアの上に隠れたら表示する。
  /// カード本来のタイトル（人気・馬名）の高さに相当。表示が早い／遅いと感じたらここを調整する。
  static const double showAfter = 90;

  @override
  State<_FloatingHorseTitle> createState() => _FloatingHorseTitleState();
}

/// 追従タイトルの状態。
class _FloatingHorseTitleState extends State<_FloatingHorseTitle> {
  /// このカード自身の描画領域。
  RenderBox? _cardBox() {
    final RenderObject? ro = context.findRenderObject();
    return ro is RenderBox ? ro : null;
  }

  /// スクロールしている表示領域。
  RenderBox? _viewportBox() {
    final RenderObject? ro = Scrollable.maybeOf(context)?.context.findRenderObject();
    return ro is RenderBox ? ro : null;
  }

  /// 追従タイトルを表示する（位置は描画時に計算する）。
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Flow(
        delegate: _FloatingTitleFlowDelegate(
          scrollController: widget.scrollController,
          getCardBox: _cardBox,
          getViewportBox: _viewportBox,
          showAfter: _FloatingHorseTitle.showAfter,
        ),
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 8, top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '${widget.popularity}番人気　馬番${widget.horseNum}',
              style: const TextStyle(fontSize: 12, color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }
}

/// スクロールのたびに「描画時」に位置を計算する（build 時だと1フレーム遅れてガタつくため Flow を使う）。
class _FloatingTitleFlowDelegate extends FlowDelegate {
  _FloatingTitleFlowDelegate({
    required this.scrollController,
    required this.getCardBox,
    required this.getViewportBox,
    required this.showAfter,
  }) : super(repaint: scrollController);

  final ScrollController scrollController;
  final RenderBox? Function() getCardBox;
  final RenderBox? Function() getViewportBox;
  final double showAfter;

  /// 子の大きさは自由にする。
  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) => constraints.loosen();

  /// カードの上端が表示領域の上に隠れた分だけ、タイトルを下にずらして描く。
  @override
  void paintChildren(FlowPaintingContext context) {
    final RenderBox? card = getCardBox();
    final RenderBox? viewport = getViewportBox();
    if (card == null || viewport == null || !card.attached || !viewport.attached) {
      return;
    }
    if (!card.hasSize || !viewport.hasSize) {
      return;
    }

    // カード上端が、表示エリア上端からどれだけ上に隠れているか
    final double hidden = -card.localToGlobal(Offset.zero, ancestor: viewport).dy;
    if (hidden < showAfter) {
      return;
    }

    final Size childSize = context.getChildSize(0) ?? Size.zero;
    final double maxDy = context.size.height - childSize.height;
    final double dy = hidden.clamp(0.0, maxDy < 0 ? 0.0 : maxDy);

    context.paintChild(0, transform: Matrix4.translationValues(0, dy, 0));
  }

  /// スクロールの制御か表示し始める距離が変わったときだけ描き直す。
  @override
  bool shouldRepaint(_FloatingTitleFlowDelegate oldDelegate) =>
      oldDelegate.scrollController != scrollController || oldDelegate.showAfter != showAfter;
}
