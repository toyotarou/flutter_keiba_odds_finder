import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/odds_model.dart';
import '../../models/race_model.dart';

class HorseOddsRankingDisplayAlert extends ConsumerStatefulWidget {
  const HorseOddsRankingDisplayAlert({super.key});

  @override
  ConsumerState<HorseOddsRankingDisplayAlert> createState() => _HorseOddsRankingDisplayAlertState();
}

class _HorseOddsRankingDisplayAlertState extends ConsumerState<HorseOddsRankingDisplayAlert>
    with ControllersMixin<HorseOddsRankingDisplayAlert> {
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Text('順位表'), SizedBox.shrink()],
                ),
                Divider(color: Colors.white.withOpacity(0.4), thickness: 5),

                const Text('縦軸：順位、横軸：タイミング、セル内：馬番', style: TextStyle(fontSize: 10)),

                const SizedBox(height: 5),

                const Text('赤く塗られたセルは、左のセルと順位が変わっています。', style: TextStyle(fontSize: 10)),

                const SizedBox(height: 10),

                Expanded(child: displayHorseOddsRankingList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget displayHorseOddsRankingList() {
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';

    final bool hasData = appParamState.keepRaceMap[mapKey] != null && appParamState.selectedRaceNumber > 0;

    final int horseNum = hasData
        ? appParamState.keepRaceMap[mapKey]!
              .firstWhere((RaceModel e) => e.race == appParamState.selectedRaceNumber)
              .numHorses
        : 0;

    final List<OddsModel> oddsModelList = hasData
        ? (appParamState.keepOddsMap[mapKey] ?? <OddsModel>[])
              .where((OddsModel e) => e.race == appParamState.selectedRaceNumber)
              .toList()
        : <OddsModel>[];

    final List<String> timingParts = appParamState.configOddsGetTiming.split('|');
    final List<int> timingOrder = List<int>.generate(timingParts.length, (int i) {
      if (i == 0) {
        return 999;
      }
      if (timingParts[i] == '0') {
        return -999;
      }
      return int.parse(timingParts[i]);
    });

    // タイミングごとにオッズ昇順ソート済みリストを作成
    final Map<int, List<OddsModel>> oddsTimingOddsModelMap = Map<int, List<OddsModel>>.fromEntries(
      timingOrder.map(
        (int timing) => MapEntry<int, List<OddsModel>>(
          timing,
          oddsModelList.where((OddsModel e) => e.minutesBeforeStart == timing).toList()..sort(
            (OddsModel a, OddsModel b) => (double.tryParse(a.odds) ?? 0).compareTo(double.tryParse(b.odds) ?? 0),
          ),
        ),
      ),
    );

    // 縦軸: 順位（1〜horseNum）、横軸: タイミング（timingOrder順）
    final Map<int, List<OddsModel?>> displayHorseRankingMap = Map<int, List<OddsModel?>>.fromEntries(
      List<MapEntry<int, List<OddsModel?>>>.generate(horseNum, (int rankIndex) {
        return MapEntry<int, List<OddsModel?>>(
          rankIndex + 1,
          timingOrder.map((int timing) {
            final List<OddsModel> list = oddsTimingOddsModelMap[timing] ?? <OddsModel>[];
            return rankIndex < list.length ? list[rankIndex] : null;
          }).toList(),
        );
      }),
    );

    final List<String> timingLabels = List<String>.generate(timingParts.length, (int i) {
      if (i == 0) {
        return 'S';
      }
      if (i == timingParts.length - 1) {
        return 'E';
      }
      return timingParts[i];
    });

    // ========================================
    // 色の設定（変更する場合はここを編集）
    const Color headerBgColor = Color(0xFF1B3A2A); // 上段ヘッダー・左端順位列の背景色
    const Color changedBgColor = Color(0xFF3A1B1B); // 一つ前のタイミングから馬番が変わったセルの背景色
    const Color defaultBgColor = Colors.transparent; // 変化なしのセルの背景色
    // ========================================

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ヘッダー行
            Row(
              children: <Widget>[
                // 左上の空セル（罫線・塗りなし）
                const SizedBox(
                  width: 40,
                  height: 30,
                  child: Stack(
                    children: <Widget>[
                      Positioned(bottom: 0, left: 0, child: Text('順位', style: TextStyle(fontSize: 8))),
                      Positioned(top: 0, right: 0, child: Text('タイミング', style: TextStyle(fontSize: 8))),
                    ],
                  ),
                ),

                // タイミングラベル（S, 21, ..., E）
                ...timingLabels.map((String label) {
                  return Container(
                    width: 50,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: headerBgColor,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  );
                }),
                // 右上の空セル（罫線・塗りなし）
                const SizedBox(
                  width: 40,
                  height: 30,
                  child: Stack(
                    children: <Widget>[
                      Positioned(bottom: 0, right: 0, child: Text('順位', style: TextStyle(fontSize: 8))),
                      Positioned(top: 0, left: 0, child: Text('タイミング', style: TextStyle(fontSize: 8))),
                    ],
                  ),
                ),
              ],
            ),

            // データ行（順位ごと）
            ...List<Widget>.generate(horseNum, (int rankIndex) {
              final int rank = rankIndex + 1;
              final List<OddsModel?> rowData = displayHorseRankingMap[rank] ?? <OddsModel?>[];
              return Row(
                children: <Widget>[
                  // 左端の順位
                  Container(
                    width: 40,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: headerBgColor,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(rank.toString(), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                  // 各タイミングの馬番（右に行くほど新しいタイミング）
                  ...rowData.asMap().entries.map((MapEntry<int, OddsModel?> entry) {
                    final int colIndex = entry.key;
                    final OddsModel? e = entry.value;

                    // 一つ前のタイミングと馬番が変わったか判定
                    final bool isChanged =
                        colIndex > 0 &&
                        e != null &&
                        rowData[colIndex - 1] != null &&
                        e.num != rowData[colIndex - 1]!.num;

                    return Container(
                      width: 50,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isChanged ? changedBgColor : defaultBgColor,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        e != null ? e.num.toString() : '-',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    );
                  }),
                  // 右端の順位
                  Container(
                    width: 40,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: headerBgColor,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(rank.toString(), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                ],
              );
            }),

            // フッター行（最下段にもタイミングラベルを表示）
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 40,
                  height: 30,
                  child: Stack(
                    children: <Widget>[
                      Positioned(top: 0, left: 0, child: Text('順位', style: TextStyle(fontSize: 8))),
                      Positioned(bottom: 0, right: 0, child: Text('タイミング', style: TextStyle(fontSize: 8))),
                    ],
                  ),
                ),
                ...timingLabels.map((String label) {
                  return Container(
                    width: 50,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: headerBgColor,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  );
                }),
                const SizedBox(
                  width: 40,
                  height: 30,
                  child: Stack(
                    children: <Widget>[
                      Positioned(top: 0, right: 0, child: Text('順位', style: TextStyle(fontSize: 8))),
                      Positioned(bottom: 0, left: 0, child: Text('タイミング', style: TextStyle(fontSize: 8))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
