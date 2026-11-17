// =============================================================================
// ファイル名   : ai_analysis_get_status_alert.dart
// 概要         : AI 分析の取得状況の画面（管理者用）。開催日・競馬場・レースごとに取得済みかを表示する。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-08-30
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../models/ai_analysis_model.dart';
import '../../models/common/ai_response_recommend_horse_model.dart';

import '../../models/schedule_model.dart';
import '../../utility/functions.dart';
import '../parts/odds_finder_dialog.dart';
import 'ai_analysis_display_alert.dart';

/// AI 分析の取得状況の画面。
class AiAnalysisGetStatusAlert extends ConsumerStatefulWidget {
  const AiAnalysisGetStatusAlert({super.key});

  @override
  ConsumerState<AiAnalysisGetStatusAlert> createState() => _AiAnalysisGetStatusAlertState();
}

/// AI 分析の取得状況の画面の状態。
class _AiAnalysisGetStatusAlertState extends ConsumerState<AiAnalysisGetStatusAlert>
    with ControllersMixin<AiAnalysisGetStatusAlert> {
  /// AI 分析の結果を、このダイアログを開いたときに取得する（起動時には取得しない）。
  @override
  void initState() {
    super.initState();

    // AI分析の全件は起動時に取得しなくなったため、このダイアログを開いたときに取得する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      aiAnalysisNotifier.getAllAiAnalysisData();
      aiAnalysisNotifier2.getAllAiAnalysisData2();
    });
  }

  /// AI 分析の取得状況の画面を組み立てる。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('AI取得ステータス', style: TextStyle(fontSize: 12)),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
                Expanded(child: displayAiGetStatusList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 開催日・競馬場・レースごとに、AI 分析の結果を取得済みかどうかを一覧で表示する。
  Widget displayAiGetStatusList() {
    final Map<String, List<ScheduleModel>> dateBashoMap = appParamState.keepScheduleDateBashoMap;

    if (dateBashoMap.isEmpty) {
      return const Center(
        child: Text('データなし', style: TextStyle(color: Colors.white54, fontSize: 12)),
      );
    }

    final List<String> sortedDates = dateBashoMap.keys.toList()..sort();

    final List<Widget> list = <Widget>[];

    for (final String date in sortedDates) {
      final List<ScheduleModel> schedules = dateBashoMap[date] ?? <ScheduleModel>[];

      // 日付ヘッダー
      list.add(
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
          child: Text(date, style: const TextStyle(color: Colors.white)),
        ),
      );

      // 会場リスト
      for (final ScheduleModel schedule in schedules) {
        list.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${schedule.kaisuu}回 ${schedule.bashoName} ${schedule.day}日',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List<Widget>.generate(12, (int i) {
                    final int raceNum = i + 1;
                    final String aiKey = '${schedule.date}_${schedule.kaisuu}_${schedule.bashoName}_${schedule.day}';
                    final List<AiAnalysisModel> aiList = aiAnalysisState.aiAnalysisMap[aiKey] ?? <AiAnalysisModel>[];
                    final bool hasAi = aiList.any((AiAnalysisModel m) => m.race == raceNum);
                    final List<AiAnalysisModel> aiList2 =
                        aiAnalysisState2.aiAnalysisMap2[aiKey] ?? <AiAnalysisModel>[];
                    final bool hasAi2 = aiList2.any((AiAnalysisModel m) => m.race == raceNum);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // ── 選択状態をタップした会場・日付に合わせる ──
                          appParamNotifier.setSelectedScheduleDate(date: schedule.date);
                          appParamNotifier.setSelectedScheduleKaisuuBashoDay(
                            kbd: '${schedule.kaisuu}_${schedule.basho}_${schedule.day}',
                            name: '${schedule.kaisuu}回 ${schedule.bashoName} ${schedule.day}日',
                          );

                          final AiAnalysisModel? aiModel = aiList
                              .where((AiAnalysisModel m) => m.race == raceNum)
                              .firstOrNull;
                          final AiAnalysisModel? ai2Model = aiList2
                              .where((AiAnalysisModel m) => m.race == raceNum)
                              .firstOrNull;
                          final List<AiResponseRecommendHorseModel> aiHorseList = aiModel != null
                              ? parseAnalysisText(aiModel.analysisText)
                              : <AiResponseRecommendHorseModel>[];
                          final List<AiResponseRecommendHorseModel> secondAiHorseList = ai2Model != null
                              ? parseAnalysisText(ai2Model.analysisText)
                              : <AiResponseRecommendHorseModel>[];
                          OddsFinderDialog(
                            context: context,
                            widget: AiAnalysisDisplayAlert(
                              raceNumber: raceNum,
                              numToRankMap: const <int, int>{},
                              aiHorseList: aiHorseList,
                              secondAiHorseList: secondAiHorseList,
                              upsetRaceValue: aiModel != null ? parseUpsetRaceValue(aiModel.analysisText) : null,
                              raceMetrics: aiModel != null ? parseRaceMetrics(aiModel.analysisText) : null,
                            ),
                          );
                        },
                        splashColor: Colors.white.withValues(alpha: 0.2),
                        highlightColor: Colors.white.withValues(alpha: 0.1),
                        child: Container(
                          width: context.screenSize.width / 7,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: hasAi ? Colors.green : Colors.white.withValues(alpha: 0.5),
                                width: 3,
                              ),
                              bottom: BorderSide(
                                color: hasAi2 ? Colors.blue : Colors.white.withValues(alpha: 0.5),
                                width: 3,
                              ),
                              right: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                              left: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                            ),
                          ),
                          child: Text('$raceNum', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      }
    }

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: list),
    );
  }
}
