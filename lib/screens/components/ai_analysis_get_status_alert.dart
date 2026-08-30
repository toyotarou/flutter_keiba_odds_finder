import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../models/ai_analysis_model.dart';
import '../../models/schedule_model.dart';

class AiAnalysisGetStatusAlert extends ConsumerStatefulWidget {
  const AiAnalysisGetStatusAlert({super.key});

  @override
  ConsumerState<AiAnalysisGetStatusAlert> createState() => _AiAnalysisGetStatusAlertState();
}

class _AiAnalysisGetStatusAlertState extends ConsumerState<AiAnalysisGetStatusAlert>
    with ControllersMixin<AiAnalysisGetStatusAlert> {
  ///
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

  ///
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
                    final List<AiAnalysisModel> aiList = appParamState.keepAiAnalysisMap[aiKey] ?? <AiAnalysisModel>[];
                    final bool hasAi = aiList.any((AiAnalysisModel m) => m.race == raceNum);
                    final List<AiAnalysisModel> aiList2 =
                        appParamState.keepAiAnalysisMap2[aiKey] ?? <AiAnalysisModel>[];
                    final bool hasAi2 = aiList2.any((AiAnalysisModel m) => m.race == raceNum);
                    return Container(
                      width: context.screenSize.width / 7,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: hasAi ? Colors.green : Colors.white.withValues(alpha: 0.5), width: 3),
                          bottom: BorderSide(
                            color: hasAi2 ? Colors.blue : Colors.white.withValues(alpha: 0.5),
                            width: 3,
                          ),
                          right: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                          left: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ),
                      child: Text('$raceNum', style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
