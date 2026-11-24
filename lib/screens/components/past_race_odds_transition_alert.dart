// =============================================================================
// ファイル名   : past_race_odds_transition_alert.dart
// 概要         : 過去レースの一覧画面。日付・競馬場・レースごとに、AI 予想の合致結果と払戻金を表示し、
//                各レースの AI 予想・人気順位の推移・払戻金などの画面を開ける。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-21
// 最終更新日   : 2026-11-17
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../const/const.dart';
import '../../controllers/controllers_mixin.dart';
import '../../controllers/race_introspection/race_introspection.dart';
import '../../controllers/summary/summary.dart';
import '../../extensions/extensions.dart';
import '../../models/common/ai_response_recommend_horse_model.dart';
import '../../models/horse_model.dart';
import '../../models/odds_model.dart';
import '../../models/popularity_rank_odds_median_model.dart';
import '../../models/race_introspection_model.dart';
import '../../models/race_model.dart';
import '../../models/race_result_model.dart';
import '../../models/race_result_payout_model.dart';
import '../../models/summary_model.dart';
import '../../utility/functions.dart';
import '../../utility/utility.dart';
import '../parts/odds_finder_dialog.dart';
import 'ai_analysis_display_alert.dart';
import 'horse_odds_ranking_display_alert.dart';
import 'payout_data_display_alert.dart';
import 'total_forecast_display_alert.dart';

/// 過去レースの一覧画面。
class PastRaceOddsTransitionAlert extends ConsumerStatefulWidget {
  const PastRaceOddsTransitionAlert({super.key});

  @override
  ConsumerState<PastRaceOddsTransitionAlert> createState() => _PastRaceOddsTransitionAlertState();
}

/// 過去レースの一覧画面の状態。
class _PastRaceOddsTransitionAlertState extends ConsumerState<PastRaceOddsTransitionAlert>
    with ControllersMixin<PastRaceOddsTransitionAlert> {
  final Utility _utility = Utility();

  final ScrollController _scrollController = ScrollController();

  final Map<String, bool> _expandedByDate = <String, bool>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (ref.read(summaryProvider).summaryDateBashoMap.isEmpty) {
        ref.read(summaryProvider.notifier).getAllSummaryData();
      }

      // 振り返りは起動時に取得しなくなったため、未取得ならここで取得する
      if (ref.read(raceIntrospectionProvider).raceIntrospectionMap.isEmpty) {
        ref.read(raceIntrospectionProvider.notifier).getAllRaceIntrospectionData();
      }
    });
  }

  final Set<String> _fetchedDates = <String>{};

  final Map<String, RaceResultPayoutModel> _payoutMap = <String, RaceResultPayoutModel>{};

  final Map<String, String?> _secondAiTextMap = <String, String?>{};

  /// 2nd AI API が返す統合結果（merged_horses）をレースキー単位で保持する。
  final Map<String, List<AiResponseRecommendHorseModel>> _mergedHorsesMap =
      <String, List<AiResponseRecommendHorseModel>>{};

  /// 統合後にサーバーが再判定した厳選穴レース値（1st AI テキストの値より優先する）。
  final Map<String, int> _mergedUpsetRaceMap = <String, int>{};

  /// サーバーが確定させたレース指標（波乱度・下位進入度・大穴進入度）。
  final Map<String, Map<String, int?>> _mergedRaceMetricsMap = <String, Map<String, int?>>{};

  /// 3指標の数字に添える言葉（サーバーが計算した値のときだけ入る）。
  final Map<String, Map<String, String>> _mergedRaceMetricNotesMap = <String, Map<String, String>>{};

  /// 統合結果の状態（'undetermined' ＝ 採用できるAI回答が無かった）
  final Map<String, String?> _mergeStatusMap = <String, String?>{};

  /// 予想を出さなかった理由の文言（サーバーの status_reason）
  final Map<String, String?> _mergeStatusReasonMap = <String, String?>{};

  /// 新しい予想（prediction_method == 'new'）のレースか
  final Map<String, bool> _predictionNewMap = <String, bool>{};

  final Set<String> _fetchedSecondAiDates = <String>{};

  /// 1日分の AI 予想を取る通信の待ち時間の上限（サーバーは普段1秒ほどで返す）
  static const Duration _aiByDateTimeout = Duration(seconds: 15);

  /// 1日分の AI 予想を取る通信の最大回数（最初の1回＋自動の取り直し1回）
  static const int _aiByDateMaxAttempts = 2;

  final Map<String, String?> _firstAiTextMap = <String, String?>{};

  final Set<String> _fetchedFirstAiDates = <String>{};

  final Set<String> _payoutFetchDone = <String>{};

  /// 払戻の先読みを開始したか。build のたびに通信を投げないよう、一度立てたら戻さない。
  bool _payoutPrefetchStarted = false;

  /// 先読みで1回の通信にまとめる日付の数（URL が長くなりすぎないよう分割する）
  static const int _payoutPrefetchDatesPerRequest = 5;

  static const double _moveAmount = 18;

  static const int _tickMs = 16;

  Timer? _repeatTimer;

  // 以下の _fetchSecondAiForDate / _fetchFirstAiForDate は、レースごとに API を1回ずつ呼んでいた
  //   （1日36レースなら72回。保存済みの回答が無いレースではサーバーが AI（有料）を呼びに行っていた）。

  /// 1日分の 1st / 2nd AI を、保存済みの結果だけから1回の通信でまとめて取得する。
  ///
  /// 以前はレースごとに 1st / 2nd を1回ずつ呼んでいた（1日36レースなら72回）。
  /// 新しい API はサーバー側で AI を呼ばない（保存済みの回答を読むだけ）。
  /// 取得中の表示（isSecondAiLoading）に使うため、_fetchedSecondAiDates / _fetchedFirstAiDates は以前と同じく使う。
  Future<void> _fetchAiForDate(String date) async {
    if (_fetchedSecondAiDates.contains(date)) {
      return;
    }
    _fetchedSecondAiDates.add(date);
    _fetchedFirstAiDates.add(date);

    final Map<String, List<SummaryModel>> summaryMap = summaryState.summaryMap;

    // 画面側のキー（_firstAiTextMap などのキー）と、API 応答を引くキーの組
    final List<({String key, String lookupKey})> races = <({String key, String lookupKey})>[];

    for (final MapEntry<String, List<SummaryModel>> entry in summaryMap.entries) {
      if (!entry.key.startsWith(date)) {
        continue;
      }

      final List<SummaryModel> models = entry.value;

      if (models.isEmpty) {
        continue;
      }

      final int kaisuu = int.tryParse(models.first.kaisuu) ?? 0;

      final Set<int> seenRaces = <int>{};

      for (final SummaryModel m in models) {
        if (!seenRaces.add(m.race)) {
          continue;
        }

        races.add((
          key: '${m.date}_${kaisuu}_${m.basho}_${m.day}_${m.race}',
          lookupKey: aiByDateKey(
            date: m.date,
            kaisuu: kaisuu.toString(),
            basho: m.basho,
            day: m.day.toString(),
            race: m.race.toString(),
          ),
        ));
      }
    }

    if (races.isEmpty) {
      // summaryMap がまだ空だった場合もリトライできるよう解除する
      _fetchedSecondAiDates.remove(date);
      _fetchedFirstAiDates.remove(date);
      return;
    }

    try {
      final Map<String, Map<String, dynamic>> byKey = await _fetchAiAnalysisByDateWithRetry(date);

      if (!mounted) {
        return;
      }

      setState(() {
        for (final ({String key, String lookupKey}) r in races) {
          final Map<String, dynamic>? item = byKey[r.lookupKey];

          _firstAiTextMap[r.key] = item?['first_analysis_text'] as String?;

          final Map<String, dynamic>? second = item?['second'] as Map<String, dynamic>?;
          if (second == null) {
            _secondAiTextMap[r.key] = null;
            continue;
          }

          _secondAiTextMap[r.key] = second['analysis_text'] as String?;
          // 0頭の統合結果も「受け取った」として保持する（サーバーが除外した馬を出さないため）
          final List<dynamic>? mergedRaw = second['merged_horses'] as List<dynamic>?;
          if (mergedRaw != null) {
            _mergedHorsesMap[r.key] = parseMergedHorses(mergedRaw);
          }
          _mergeStatusMap[r.key] = second['status'] as String?;
          _mergeStatusReasonMap[r.key] = second['status_reason'] as String?;
          _predictionNewMap[r.key] = second['prediction_method'] == 'new';
          final int? upsetRace = (second['upset_race'] as num?)?.toInt();
          if (upsetRace != null) {
            _mergedUpsetRaceMap[r.key] = upsetRace;
          }
          final Map<String, int?>? metrics = parseRaceMetricsJson(second['race_metrics']);
          if (metrics != null) {
            _mergedRaceMetricsMap[r.key] = metrics;
          }
          final Map<String, String>? metricNotes = parseRaceMetricNotesJson(second['race_metric_notes']);
          if (metricNotes != null) {
            _mergedRaceMetricNotesMap[r.key] = metricNotes;
          }
        }
      });
    } catch (_) {
      // 失敗したら、もう一度開いたときに取り直せるよう解除する
      _fetchedSecondAiDates.remove(date);
      _fetchedFirstAiDates.remove(date);
      if (mounted) {
        setState(() {
          for (final ({String key, String lookupKey}) r in races) {
            _firstAiTextMap[r.key] = null;
            _secondAiTextMap[r.key] = null;
          }
        });
      }
    }
  }

  /// 1日分の AI 予想を取得する。
  /// 通信が返ってこないまま止まると「AI予想を取得中...」が回り続けるため、
  /// [_aiByDateTimeout] で打ち切り、[_aiByDateMaxAttempts] 回まで自動で取り直す。
  /// すべて失敗したときは例外を投げる（呼び出し元で取得中の表示を消す）。
  Future<Map<String, Map<String, dynamic>>> _fetchAiAnalysisByDateWithRetry(String date) async {
    for (int attempt = 1; ; attempt++) {
      try {
        return await fetchAiAnalysisByDate(ref, date: date).timeout(_aiByDateTimeout);
      } catch (_) {
        if (attempt >= _aiByDateMaxAttempts) {
          rethrow;
        }
      }
    }
  }

  /// 複数日付の AI を、一斉にではなく1日ずつ順番に取得する
  Future<void> _fetchAiForDatesInOrder(List<String> dates) async {
    for (final String d in dates) {
      if (!mounted) {
        return;
      }
      await _fetchAiForDate(d);
    }
  }

  /// 指定した日付の全レースの払戻金をまとめて取得する（取得済みの日付は取り直さない）。
  Future<void> _fetchPayoutsForDate(String date) async {
    if (_fetchedDates.contains(date)) {
      return;
    }

    _fetchedDates.add(date);

    final Set<String> raceParamSet = _buildPayoutRaceParams(date);

    if (raceParamSet.isEmpty) {
      return;
    }

    try {
      final Map<String, RaceResultPayoutModel> result = await fetchPayoutMap(ref, racesParam: raceParamSet.join('/'));

      if (mounted) {
        setState(() {
          _payoutMap.addAll(result);
          _payoutFetchDone.add(date);
        });
      }
    } catch (_) {
      _fetchedDates.remove(date);
    }
  }

  /// 指定日付の全レース分の races パラメータ（"date|kaisuu|basho|race"）を組み立てる。
  Set<String> _buildPayoutRaceParams(String date) {
    final Map<String, List<SummaryModel>> summaryMap = summaryState.summaryMap;

    final Set<String> raceParamSet = <String>{};

    for (final MapEntry<String, List<SummaryModel>> entry in summaryMap.entries) {
      if (!entry.key.startsWith(date)) {
        continue;
      }

      final List<SummaryModel> models = entry.value;

      if (models.isEmpty) {
        continue;
      }

      final int kaisuu = int.tryParse(models.first.kaisuu) ?? 0;

      final Set<int> seenRaces = <int>{};

      for (final SummaryModel m in models) {
        if (seenRaces.add(m.race)) {
          raceParamSet.add('${m.date}|$kaisuu|${m.basho}|${m.race}');
        }
      }
    }

    return raceParamSet;
  }

  /// 過去日付の払戻を、数日分ずつまとめて順番に取得する。
  ///
  /// 以前は build のたびに「1日1回 × 全日付」を一斉に投げており、
  /// 429 で失敗すると次の build でまた投げ直すため、1回開くだけで100回以上の通信になっていた。
  /// 失敗時はこの中で最大3回まで再試行し、それでもだめなら諦める（日付を開いたときに取り直す）。
  Future<void> _prefetchPastPayouts(List<String> dates) async {
    final List<String> targets = dates.where((String d) => !_fetchedDates.contains(d)).toList();
    _fetchedDates.addAll(targets);

    for (int i = 0; i < targets.length; i += _payoutPrefetchDatesPerRequest) {
      final int end = (i + _payoutPrefetchDatesPerRequest < targets.length)
          ? i + _payoutPrefetchDatesPerRequest
          : targets.length;
      final List<String> chunk = targets.sublist(i, end);

      final Set<String> raceParamSet = <String>{};
      for (final String d in chunk) {
        raceParamSet.addAll(_buildPayoutRaceParams(d));
      }

      if (raceParamSet.isEmpty) {
        continue;
      }

      const int maxAttempts = 3;
      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          final Map<String, RaceResultPayoutModel> result = await fetchPayoutMap(
            ref,
            racesParam: raceParamSet.join('/'),
          );

          if (!mounted) {
            return;
          }

          setState(() {
            _payoutMap.addAll(result);
            _payoutFetchDone.addAll(chunk);
          });
          break;
        } catch (_) {
          if (attempt == maxAttempts) {
            // 日付を開いたときに _fetchPayoutsForDate で取り直せるよう解除しておく
            _fetchedDates.removeAll(chunk);
            break;
          }
          await Future<void>.delayed(const Duration(seconds: 2));
          if (!mounted) {
            return;
          }
        }
      }
    }
  }

  /// 長押しスクロール用のタイマーと、スクロールの制御を破棄する。
  @override
  void dispose() {
    _repeatTimer?.cancel();

    _repeatTimer = null;

    _scrollController.dispose();

    super.dispose();
  }

  /// ボタンを押している間、指定した処理を繰り返す。
  void _startRepeating(VoidCallback action) {
    _repeatTimer?.cancel();

    action();

    _repeatTimer = Timer.periodic(const Duration(milliseconds: _tickMs), (_) => action());
  }

  /// 繰り返しを止める。
  void _stopRepeating() {
    _repeatTimer?.cancel();

    _repeatTimer = null;
  }

  /// 一覧を指定した量だけスクロールする。
  void _scrollBy(double delta) {
    if (!_scrollController.hasClients) {
      return;
    }

    final ScrollPosition pos = _scrollController.position;

    final double newOffset = (_scrollController.offset + delta).clamp(0.0, pos.maxScrollExtent);

    _scrollController.jumpTo(newOffset);
  }

  /// 日付の行を開く・閉じるボタンを表示する。
  Widget _buildToggleButton({required bool isOpen, required VoidCallback onTap, VoidCallback? onSecondAiFetch}) {
    return GestureDetector(
      onTap: () {
        onTap();
        if (!isOpen) {
          onSecondAiFetch?.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
          color: isOpen
              ? const Color(0xFF2196F3).withValues(alpha: 0.4)
              : const Color(0xFF4CAF50).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(isOpen ? 'CLOSE' : 'OPEN', style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }

  /// 過去レースの一覧（日付 → 競馬場 → レース）の画面を組み立てる。
  @override
  Widget build(BuildContext context) {
    // JRAの特性で翌日のレースが1レースだけ取得されてしまう場合があるため、本日以前の日付だけを表示する
    final String today = DateTime.now().toString().substring(0, 10);

    // 配当が取得できた（＝レースが終了している）日付だけを表示する。判定のため、開く前に配当を先読みする
    // build のたびに日付ごとの通信を投げていたため、先読みは summary 取得後に1回だけ・まとめて行う
    if (!_payoutPrefetchStarted && summaryState.summaryMap.isNotEmpty) {
      _payoutPrefetchStarted = true;
      final List<String> pastDates = summaryState.summaryDateBashoMap.keys
          .where((String d) => d.compareTo(today) <= 0)
          .toList();
      Future<void>.microtask(() => _prefetchPastPayouts(pastDates));
    }

    final Map<String, List<String>> summaryDateBashoMap = <String, List<String>>{
      for (final MapEntry<String, List<String>> e in summaryState.summaryDateBashoMap.entries)
        if (e.key.compareTo(today) <= 0 && _payoutMap.keys.any((String k) => k.startsWith(e.key))) e.key: e.value,
    };

    final Map<String, List<SummaryModel>> summaryMap = summaryState.summaryMap;

    final bool allOpen = summaryDateBashoMap.entries.every(
      (MapEntry<String, List<String>> e) => e.value.every((String e2) => _expandedByDate['${e.key}_$e2'] ?? false),
    );

    final bool anyOpen = summaryDateBashoMap.entries.any(
      (MapEntry<String, List<String>> e) => e.value.any((String e2) => _expandedByDate['${e.key}_$e2'] ?? false),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Text('過去レースのオッズ遷移表', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        _buildToggleButton(
                          isOpen: allOpen,
                          onTap: () {
                            setState(() {
                              for (final MapEntry<String, List<String>> entry in summaryDateBashoMap.entries) {
                                for (final String e2 in entry.value) {
                                  _expandedByDate['${entry.key}_$e2'] = !anyOpen;
                                }
                              }
                            });
                            if (!anyOpen) {
                              summaryDateBashoMap.keys.forEach(_fetchPayoutsForDate);
                            }
                          },
                          onSecondAiFetch: () {
                            // 全日付を一斉に呼ばず、1日ずつ順番にまとめて取得する
                            _fetchAiForDatesInOrder(summaryDateBashoMap.keys.toList());
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) => _startRepeating(() => _scrollBy(_moveAmount)),
                          onTapUp: (_) => _stopRepeating(),
                          onTapCancel: _stopRepeating,
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(child: Icon(Icons.arrow_downward, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) => _startRepeating(() => _scrollBy(-_moveAmount)),
                          onTapUp: (_) => _stopRepeating(),
                          onTapCancel: _stopRepeating,
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(child: Icon(Icons.arrow_upward, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: summaryDateBashoMap.entries.map((MapEntry<String, List<String>> e) {
                        final bool isOpenForDate = e.value.any((String e2) => _expandedByDate['${e.key}_$e2'] ?? false);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[Colors.greenAccent.withValues(alpha: 0.3), Colors.transparent],
                                  stops: const <double>[0.7, 1],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(e.key, style: const TextStyle(color: Colors.white)),
                                  _buildToggleButton(
                                    isOpen: isOpenForDate,
                                    onTap: () {
                                      setState(() {
                                        for (final String e2 in e.value) {
                                          _expandedByDate['${e.key}_$e2'] = !isOpenForDate;
                                        }
                                      });

                                      if (!isOpenForDate) {
                                        _fetchPayoutsForDate(e.key);
                                      }
                                    },
                                    onSecondAiFetch: () {
                                      _fetchAiForDate(e.key);   // 1日分をまとめて1回で取得
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: e.value.map((String e2) {
                                final List<SummaryModel> models = summaryMap['${e.key}_$e2'] ?? <SummaryModel>[];
                                if (models.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                final Map<int, String> uniqueRaces = <int, String>{};
                                for (final SummaryModel m in models) {
                                  uniqueRaces.putIfAbsent(m.race, () => m.raceName);
                                }
                                final List<MapEntry<int, String>> races = uniqueRaces.entries.toList()
                                  ..sort((MapEntry<int, String> a, MapEntry<int, String> b) => a.key.compareTo(b.key));

                                final bool isOpenForBasho = _expandedByDate['${e.key}_$e2'] ?? false;
                                return ExpansionTile(
                                  key: ValueKey<String>('${e.key}_${e2}_$isOpenForBasho'),
                                  initiallyExpanded: isOpenForBasho,
                                  onExpansionChanged: (bool expanded) {
                                    setState(() => _expandedByDate['${e.key}_$e2'] = expanded);
                                    if (expanded) {
                                      _fetchPayoutsForDate(e.key);
                                      _fetchAiForDate(e.key);   // 1日分をまとめて1回で取得
                                    }
                                  },
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
                                                  _buildRaceRow(date: e.key, models: models, r: r),
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
        ),
      ),
    );
  }

  /// 過去レース1件ぶんの行（AI 予想の合致数・払戻金・各画面へのボタン）を表示する。
  Widget _buildRaceRow({required String date, required List<SummaryModel> models, required MapEntry<int, String> r}) {
    final int kaisuu = int.tryParse(models.first.kaisuu) ?? 0;

    final String lookupKey = '${date}_${kaisuu}_${models.first.basho}_${models.first.day}_${r.key}';

    final String raceKey = '${date}_${models.first.kaisuu}_${models.first.basho}_${models.first.day}_${r.key}';

    final RaceIntrospectionModel? introspectionModel = findRaceIntrospection(
      raceIntrospectionState.raceIntrospectionMap,
      date: date,
      kaisuu: kaisuu,
      basho: models.first.basho,
      day: models.first.day,
      race: r.key,
    );

    final String? resultText = introspectionModel != null ? extractResultLine(introspectionModel.introspection) : null;

    final RaceResultPayoutModel? payout = _payoutMap[lookupKey];

    final String grade = payout?.grade ?? '';

    // ═══ NNN: keepRaceMap からこのレースの RaceModel を特定 ═══════════════
    // キー形式: date_kaisuu_basho_day （race は含まない）
    final String keepRaceMapKey = '${date}_${models.first.kaisuu}_${models.first.basho}_${models.first.day}';
    final RaceModel? currentRaceModel = (appParamState.keepRaceMap[keepRaceMapKey] ?? <RaceModel>[])
        .where((RaceModel e) => e.race == r.key)
        .firstOrNull;

    // オッズ・馬・結果データを各 State から取得
    final List<OddsModel> oddsForRace = buildOddsForRace(appParamState.keepOddsMap, keepRaceMapKey, r.key);
    final Map<int, HorseModel> horseModelMap = buildHorseModelMap(appParamState.keepHorseMap, keepRaceMapKey, r.key);
    // 馬番 → 枠番。馬データ（keepHorseMap）は今週分しか無いため、古いレースでは空になり、
    //   枠連が「獲得」にならなかった（07-11 小倉6R の枠連 8-8 など）。
    //   馬データが無いときは、この画面の元データである summary の waku から作る。
    final Map<int, int> numToWaku = horseModelMap.isNotEmpty
        ? buildNumToWakuMap(horseModelMap.values)
        : <int, int>{
            for (final SummaryModel m in models.where((SummaryModel m) => m.race == r.key && m.waku > 0))
              m.num: m.waku,
          };
    // t_horse_odds_finder_race_results は土曜の deleteKeibaTableRecords で毎週 TRUNCATE されるため、
    // 先週以前のレースは raceResultMap に着順が無く、合致数が全て0頭になっていた。
    // raceResultMap に無い場合は、この画面の元データである summary の result（着順）から作る。
    final Map<int, int> raceResultNumToRankMap = _utility.buildNumToRankMap(
      raceResultState.raceResultMap[keepRaceMapKey] ?? <RaceResultModel>[],
      r.key,
    );
    final Map<int, int> numToRankMap = raceResultNumToRankMap.isNotEmpty
        ? raceResultNumToRankMap
        : <int, int>{
            for (final SummaryModel m in models.where(
              (SummaryModel m) => m.race == r.key && m.result >= 1 && m.result <= kRaceTopFinishers,
            ))
              m.num: m.result,
          };
    final PopularityRankOddsMedianModel? medianModel = lookupMedianModel(
      appParamState.keepPopularityRankOddsMedianMap,
      keepRaceMapKey,
      r.key,
    );
    final String configFirstKey = appParamState.configOddsGetTiming.split('|').first;
    final List<OddsModel> displayList = buildOddsDisplayList(
      oddsForRace: oddsForRace,
      selectedTiming: appParamState.selectedTiming,
      configFirstKey: configFirstKey,
    );
    final List<OddsModel> sixMinDisplayList = buildSixMinDisplayList(oddsForRace, displayList);
    final List<int> gapHorseNums = calcOddsGapHorseNums(oddsForRace);
    final List<int> upsetPickupHorseNums = calcUpsetPickupHorseNums(
      oddsForRace: oddsForRace,
      medianModel: medianModel,
      displayList: displayList,
    );
    // ════════════════════════════════════════════════════════════════════════

    // AI予想画面に並ぶのと同じ候補リストから合致数を計算する（ai_analysis_display_alert と同じ基準）
    final List<AiResponseRecommendHorseModel> displayHorses = _mergedHorsesMap.containsKey(lookupKey)
        ? _mergedHorsesMap[lookupKey]!
        : mergeAiHorseLists(
            parseAnalysisText(_firstAiTextMap[lookupKey] ?? ''),
            parseAnalysisText(_secondAiTextMap[lookupKey] ?? ''),
          );
    // 3着以内に入った（合致した）馬の馬番。合致数と最高獲得払戻金額の計算に使う。
    // AI予想の候補リストが空のとき（1st AI の回答が空で「未確定」になったレースなど）は、
    // 「X頭中Y頭が合致」が振り返り（DB保存）の文章のまま出る。合致馬が分からず 0頭扱いになるのを防ぐため、
    // その文章と同じ根拠である振り返りのピックアップ馬のうち、3着以内に入った馬を使う。
    // 新しい予想で「予想を出さなかった」レース。振り返りのピックアップ馬で合致を作らない
    final bool isNoPrediction =
        displayHorses.isEmpty && _mergeStatusMap[lookupKey] == 'undetermined' && (_predictionNewMap[lookupKey] ?? false);
    final Set<int> hitHorseNums = displayHorses.isNotEmpty
        ? displayHorses
              .where((AiResponseRecommendHorseModel h) => (numToRankMap[h.num] ?? 99) <= 3)
              .map((AiResponseRecommendHorseModel h) => h.num)
              .toSet()
        : ((introspectionModel == null || isNoPrediction)   // isNoPrediction を追加
              ? <int>{}
              : extractPickupNums(
                  introspectionModel.introspection,
                ).where((int n) => (numToRankMap[n] ?? 99) <= 3).toSet());

    final int matchedCount = hitHorseNums.length;

    // 補充の内訳の文は、AI予想画面と同じ共通の関数で作る（functions.dart の buildMatchResultText）
    final String matchText = buildMatchResultText(displayHorses, hitHorseNums);

    // 同着対応。3着以内に入った馬（同着の馬も含む）の頭数。通常は3頭、同着があると4頭以上になることがある。

    // 同じ着順の馬が2頭以上いれば同着あり
    final List<int> topRanks = numToRankMap.values.where((int rank) => rank <= kRaceTopFinishers).toList();
    final bool isDeadHeat = topRanks.toSet().length < topRanks.length;

    // 全合致＝同着の馬も含めて、3着以内の馬を全部AIが選んでいる（このときだけピンクにする）
    // ピンクの条件を「三連複が取れる」に変更。
    //   合致した馬の着順を小さい順に並べ、1頭目が1着・2頭目が2着以内・3頭目が3着以内なら三連複が成立する。
    //   同着が無いレースでは「3頭合致」と同じ。同着で3着の片方だけ合致していてもピンクになる。
    final List<int> hitRanks = hitHorseNums.map((int n) => numToRankMap[n] ?? 99).toList()..sort();
    final bool isAllMatched =
        hitRanks.length >= 3 && hitRanks[0] <= 1 && hitRanks[1] <= 2 && hitRanks[2] <= kRaceTopFinishers;

    // 同着があるレースで、どの着順の馬が合致したかを「1着、2着、3着の片方が合致」のように表す。
    //   同着の着順は、全部合致なら「3着の2頭」、一部なら「3着の片方」（3頭以上の同着は「3着の1頭」など頭数で表す）。
    String? deadHeatHitText;
    if (isDeadHeat && matchedCount >= 1) {
      final List<String> parts = <String>[];
      for (int rank = 1; rank <= kRaceTopFinishers; rank++) {
        final int totalAtRank = topRanks.where((int r) => r == rank).length;
        final int hitAtRank = hitRanks.where((int r) => r == rank).length;
        if (hitAtRank == 0) {
          continue;
        }
        if (totalAtRank <= 1) {
          parts.add('$rank着');
        } else if (hitAtRank == totalAtRank) {
          parts.add('$rank着の$hitAtRank頭');
        } else if (totalAtRank == 2) {
          parts.add('$rank着の片方');
        } else {
          parts.add('$rank着の$hitAtRank頭');
        }
      }
      if (parts.isNotEmpty) {
        deadHeatHitText = '${parts.join('、')}が合致';
      }
    }

    String? adjustedResultText = resultText;
    if (resultText != null && displayHorses.isNotEmpty) {
      final RegExp pattern = RegExp(r'\d+頭中\d+頭が合致');
      if (pattern.hasMatch(resultText)) {
        adjustedResultText = resultText.replaceFirst(pattern, matchText);
      }
    }

    // 振り返り（race_introspection）が無いレースは、結果文が null のまま「分析中...」が回り続けていた。
    //   払戻があり、AI予想の取得が終わっている場合は待つのをやめる。
    //   ・AI予想の候補があれば、そこから「X頭中Y頭が合致」を作る
    //   ・AI予想も無ければ（AIデータは 2026-08-15 以降しか無い）「AI予想データなし」と出し、払戻金は見られるようにする
    if (adjustedResultText == null &&
        payout != null &&
        _fetchedSecondAiDates.contains(date) &&
        _secondAiTextMap.containsKey(lookupKey)) {
      adjustedResultText = displayHorses.isNotEmpty
          ? matchText
          : 'AI予想データなし';
    }

    // 新しい予想で「予想を出さなかった」レースは「予想なし」と出す（振り返りの「X頭中Y頭が合致」は出さない）
    if (isNoPrediction) {
      adjustedResultText = '予想なし';
    }

    // 同着があったレースは「X頭中Y頭が合致」の後に（同着あり）を付ける
    if (adjustedResultText != null && isDeadHeat) {
      final RegExp pattern = RegExp(r'\d+頭中\d+頭が合致');
      adjustedResultText = adjustedResultText.replaceFirstMapped(pattern, (Match m) => '${m.group(0)}（同着あり）');
    }

    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white70, fontSize: 11),
      child: Stack(
        children: <Widget>[
          if (grade.isNotEmpty) ...<Widget>[
            Positioned(
              top: 5,
              right: 35,
              child: Opacity(
                opacity: 0.7,
                child: Image.asset('assets/race_grade_icon/race_grade_icon_$grade.png', width: 30),
              ),
            ),
          ],

          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(width: 20, alignment: Alignment.topRight, child: Text('${r.key}R')),
                    const SizedBox(width: 20),
                    Expanded(child: Text(r.value, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),

                if (currentRaceModel != null) ...<Widget>[
                  const SizedBox(height: 10),

                  Stack(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                const SizedBox(width: 40),
                                Text('${currentRaceModel.course} ${currentRaceModel.dist}m'),
                              ],
                            ),
                          ),

                          const SizedBox.shrink(),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox.shrink(),

                          Row(
                            children: <Widget>[
                              Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  onTap: () {
                                    final String firstText = _firstAiTextMap[lookupKey] ?? '';
                                    final String secondText = _secondAiTextMap[lookupKey] ?? '';
                                    OddsFinderDialog(
                                      context: context,
                                      widget: AiAnalysisDisplayAlert(
                                        overrideDate: date,
                                        overrideKaisuuBashoDay:
                                            '${models.first.kaisuu}_${models.first.basho}_${models.first.day}',
                                        raceNumber: r.key,
                                        numToRankMap: numToRankMap,
                                        aiHorseList: parseAnalysisText(firstText),
                                        secondAiHorseList: parseAnalysisText(secondText),
                                        mergedHorseList: _mergedHorsesMap[lookupKey],
                                        upsetRaceValue:
                                            _mergedUpsetRaceMap[lookupKey] ?? parseUpsetRaceValue(firstText),
                                        raceMetrics: _mergedRaceMetricsMap[lookupKey] ?? parseRaceMetrics(firstText),
                                        raceMetricNotes: _mergedRaceMetricNotesMap[lookupKey],
                                        mergeStatus: _mergeStatusMap[lookupKey],
                                        mergeStatusReason: _mergeStatusReasonMap[lookupKey],
                                        numToWaku: numToWaku,   // 古いレースの枠連判定用
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
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFFFD700),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              ...<Widget>[
                                Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    onTap: () {
                                      final String firstAiText = _firstAiTextMap[lookupKey] ?? '';
                                      final String secondAiText = _secondAiTextMap[lookupKey] ?? '';
                                      final List<AiResponseRecommendHorseModel> firstHorses = parseAnalysisText(
                                        firstAiText,
                                      );
                                      final List<AiResponseRecommendHorseModel> secondHorses = parseAnalysisText(
                                        secondAiText,
                                      );
                                      OddsFinderDialog(
                                        context: context,
                                        widget: TotalForecastDisplayAlert(
                                          overrideDate: date,
                                          overrideKaisuuBashoDay:
                                              '${models.first.kaisuu}_${models.first.basho}_${models.first.day}',
                                          overrideMedianModel: medianModel,
                                          displayList: sixMinDisplayList,
                                          horseModelMap: horseModelMap,
                                          numToRankMap: numToRankMap,
                                          currentRaceModel: currentRaceModel,
                                          gapHorseNums: gapHorseNums,
                                          upsetPickupHorseNums: upsetPickupHorseNums,
                                          // 統合結果があればそれを使う（サーバー側フィルター適用後の本当の候補）
                                          aiHorseList: _mergedHorsesMap.containsKey(lookupKey)
                                              ? _mergedHorsesMap[lookupKey]!
                                              : mergeAiHorseLists(firstHorses, secondHorses),
                                          upsetRaceValue:
                                              _mergedUpsetRaceMap[lookupKey] ?? parseUpsetRaceValue(firstAiText),
                                          raceMetrics:
                                              _mergedRaceMetricsMap[lookupKey] ?? parseRaceMetrics(firstAiText),
                                          raceMetricNotes: _mergedRaceMetricNotesMap[lookupKey],
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
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFFBB6CE),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(width: 10),

                              GestureDetector(
                                onTap: () {
                                  appParamNotifier.setSelectedDrawerRace(race: raceKey);
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
                                  color: raceKey == appParamState.selectedDrawerRace
                                      ? Colors.yellowAccent.withValues(alpha: 0.4)
                                      : Colors.greenAccent.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],

                if (adjustedResultText != null) ...<Widget>[
                  _buildResultTextSection(
                    resultText: adjustedResultText,
                    matchedCount: matchedCount,
                    isAllMatched: isAllMatched,
                    deadHeatHitText: deadHeatHitText,
                    hitHorseNums: hitHorseNums,
                    payout: payout,
                    date: date,
                    overrideKaisuuBashoDay: '${models.first.kaisuu}_${models.first.basho}_${models.first.day}',
                    raceNumber: r.key,
                    numToRankMap: numToRankMap,
                    aiHorseNums: displayHorses.map((AiResponseRecommendHorseModel h) => h.num).toList(),
                    // 払戻金画面で馬番の下に人気順を出す
                    aiHorseNumToPopularity: <int, String>{
                      for (final AiResponseRecommendHorseModel h in displayHorses) h.num: h.popularity,
                    },
                    horseModelMap: horseModelMap,
                    numToWaku: numToWaku,
                    isSecondAiLoading: _fetchedSecondAiDates.contains(date) && !_secondAiTextMap.containsKey(lookupKey),
                  ),
                ] else ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        if (_payoutFetchDone.contains(date) && payout == null) ...<Widget>[
                          const Text('―', style: TextStyle(fontSize: 9, color: Colors.white24)),
                        ] else ...<Widget>[
                          const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38),
                          ),
                          const SizedBox(width: 5),
                          const Text('分析中...', style: TextStyle(fontSize: 9, color: Colors.white38)),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// AI 予想の合致結果の文（例：「6頭中2頭が合致」）を表示する。三連複が取れるときは色を変える。
  Widget _buildResultTextSection({
    required String resultText,
    required int matchedCount,
    required bool isAllMatched,
    required String? deadHeatHitText,
    required Set<int> hitHorseNums,
    required RaceResultPayoutModel? payout,
    required String date,
    required String overrideKaisuuBashoDay,
    required int raceNumber,
    required Map<int, int> numToRankMap,
    required Map<int, HorseModel> horseModelMap,
    required Map<int, int> numToWaku,
    required bool isSecondAiLoading,
    required List<int> aiHorseNums,
    required Map<int, String> aiHorseNumToPopularity,
  }) {
    // 3頭合致のときだけピンク、1〜2頭は白、0頭は従来どおり white60
    // ピンクは三連複が取れるとき（isAllMatched の計算部分を参照）。
    final Color textColor = isAllMatched
        ? const Color(0xFFFBB6CE)
        : matchedCount >= 1
        ? Colors.white
        : Colors.white60;

    final ({String name, int amount})? maxHit = (matchedCount >= 1 && payout != null)
        ? findMaxHitPayout(payout, hitHorseNums, numToWaku: numToWaku)   // summary の枠番も使う
        : null;

    return DefaultTextStyle(
      style: TextStyle(fontSize: 10, color: textColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(resultText),
          // 同着があるレースだけ、どの着順の馬が合致したかを出す
          if (deadHeatHitText != null) ...<Widget>[Text(deadHeatHitText)],
          if (isSecondAiLoading) ...<Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38),
                  ),
                  SizedBox(width: 5),
                  Text('AI予想を取得中...', style: TextStyle(fontSize: 9, color: Colors.white38)),
                ],
              ),
            ),
          ],

          if (maxHit != null) ...<Widget>[Text('最高獲得払戻金額：${maxHit.amount.toString().toCurrency()}円（${maxHit.name}）')],

          // そのレースの最高払戻金額（通常は三連単）
          if (payout != null && findMaxPayout(payout) != null) ...<Widget>[
            Text('最高払戻金額：${findMaxPayout(payout)!.amount.toString().toCurrency()}円（${findMaxPayout(payout)!.name}）'),
          ],

          if (payout != null) ...<Widget>[
            const SizedBox(height: 5),

            GestureDetector(
              onTap: () {
                // 払戻金画面を開く。AI予想で3着以内に入った馬の馬番を渡し、合致した払戻にだけ「獲得」を出す
                OddsFinderDialog(
                  context: context,
                  hideRaceOverlay: true,
                  widget: PayoutDataDisplayAlert(
                    raceNumber: raceNumber,
                    overrideDate: date,
                    overrideKaisuuBashoDay: overrideKaisuuBashoDay,
                    hitHorseNums: hitHorseNums,
                    numToRankMap: numToRankMap,
                    aiHorseNums: aiHorseNums,
                    aiHorseNumToPopularity: aiHorseNumToPopularity,
                    // 一覧用に取得済みの払戻データを渡す（開くたびのAPI再取得をやめる）
                    payout: payout,
                    // 馬データが無い古いレースでも枠連を判定できるよう、枠番を渡す
                    numToWaku: numToWaku,
                  ),
                  paddingLeft: context.screenSize.width * 0.1,
                  paddingTop: context.screenSize.height * 0.05,
                );
              },
              child: Container(
                width: context.screenSize.width * 0.3,
                padding: const EdgeInsets.symmetric(vertical: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBB6CE).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('払戻金', style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
