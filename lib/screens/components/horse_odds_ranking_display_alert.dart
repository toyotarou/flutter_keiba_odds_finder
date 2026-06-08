import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/controllers_mixin.dart';
import '../../main.dart';
import '../../models/odds_model.dart';
import '../../models/race_model.dart';

// 色定数（変更する場合はここを編集）
const Color _headerBgColor = Color(0xFF1B3A2A);
const Color _changedBgColor = Color(0xFF3A1B1B);
const Color _defaultBgColor = Colors.transparent;

class HorseOddsRankingDisplayAlert extends ConsumerStatefulWidget {
  const HorseOddsRankingDisplayAlert({super.key});

  @override
  ConsumerState<HorseOddsRankingDisplayAlert> createState() => _HorseOddsRankingDisplayAlertState();
}

class _HorseOddsRankingDisplayAlertState extends ConsumerState<HorseOddsRankingDisplayAlert>
    with ControllersMixin<HorseOddsRankingDisplayAlert> {
  final TransformationController _controller = TransformationController();
  double? _fitScale;

  ///
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                _buildTitleRow(),
                Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
                const Text('縦軸：順位、横軸：タイミング、セル内：馬番', style: TextStyle(fontSize: 10)),
                const SizedBox(height: 5),
                const Text('赤く塗られたセルは、左のセルと順位が変わっています。', style: TextStyle(fontSize: 10)),
                const SizedBox(height: 5),
                const Text('表をダブルタップすると、初期の全体表示に戻ります。', style: TextStyle(fontSize: 10)),
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
  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text('順位表'),
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
            await prefs.setBool('isRankingDialogOpen', true);
            if (mounted) {
              // ignore: use_build_context_synchronously
              context.findAncestorStateOfType<AppRootState>()?.restartApp();
            }
          },
          icon: const Icon(Icons.refresh, color: Colors.greenAccent),
        ),
      ],
    );
  }

  ///
  static List<int> _computeTimingOrder(List<String> timingParts) {
    return List<int>.generate(timingParts.length, (int i) {
      if (i == 0) {
        return 999;
      }
      if (timingParts[i] == '0') {
        return -999;
      }
      return int.parse(timingParts[i]);
    });
  }

  ///
  static Map<int, List<OddsModel>> _computeOddsTimingMap(List<OddsModel> oddsModelList, List<int> timingOrder) {
    return Map<int, List<OddsModel>>.fromEntries(
      timingOrder.map((int timing) {
        final List<OddsModel> sorted = oddsModelList.where((OddsModel e) => e.minutesBeforeStart == timing).toList()
          ..sort((OddsModel a, OddsModel b) => (double.tryParse(a.odds) ?? 0).compareTo(double.tryParse(b.odds) ?? 0));
        return MapEntry<int, List<OddsModel>>(timing, sorted);
      }),
    );
  }

  ///
  static Map<int, List<OddsModel?>> _computeRankingMap(
    int horseNum,
    List<int> timingOrder,
    Map<int, List<OddsModel>> oddsTimingMap,
  ) {
    return Map<int, List<OddsModel?>>.fromEntries(
      List<MapEntry<int, List<OddsModel?>>>.generate(horseNum, (int rankIndex) {
        return MapEntry<int, List<OddsModel?>>(
          rankIndex + 1,
          timingOrder.map((int timing) {
            final List<OddsModel> list = oddsTimingMap[timing] ?? <OddsModel>[];
            return rankIndex < list.length ? list[rankIndex] : null;
          }).toList(),
        );
      }),
    );
  }

  ///
  static List<String> _buildTimingLabels(List<String> timingParts) {
    return List<String>.generate(timingParts.length, (int i) {
      if (i == 0) {
        return 'S';
      }
      if (i == timingParts.length - 1) {
        return 'E';
      }
      return timingParts[i];
    });
  }

  ///
  static Widget _buildTimingLabelCell(String label) {
    return Container(
      width: 50,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _headerBgColor,
        border: Border.all(color: Colors.white24),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    );
  }

  ///
  static Widget _buildRankCell(int rank) {
    return Container(
      width: 40,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _headerBgColor,
        border: Border.all(color: Colors.white24),
      ),
      child: Text(rank.toString(), style: const TextStyle(color: Colors.white70, fontSize: 10)),
    );
  }

  ///
  static Widget _buildDataCell(OddsModel? model, bool isChanged) {
    return Container(
      width: 50,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isChanged ? _changedBgColor : _defaultBgColor,
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        model != null ? model.num.toString() : '-',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  ///
  static Widget _buildTimingHeaderFooterRow(List<String> timingLabels, {required bool isTop}) {
    final Widget leftCorner = SizedBox(
      width: 40,
      height: 30,
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: isTop ? 0 : null,
            top: isTop ? null : 0,
            left: 0,
            child: const Text('順位', style: TextStyle(fontSize: 8)),
          ),
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            right: 0,
            child: const Text('タイミング', style: TextStyle(fontSize: 8)),
          ),
        ],
      ),
    );

    final Widget rightCorner = SizedBox(
      width: 40,
      height: 30,
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: isTop ? 0 : null,
            top: isTop ? null : 0,
            right: 0,
            child: const Text('順位', style: TextStyle(fontSize: 8)),
          ),
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: 0,
            child: const Text('タイミング', style: TextStyle(fontSize: 8)),
          ),
        ],
      ),
    );

    return Row(children: <Widget>[leftCorner, ...timingLabels.map(_buildTimingLabelCell), rightCorner]);
  }

  ///
  static Widget _buildRankingDataRow(int rank, List<OddsModel?> rowData) {
    return Row(
      children: <Widget>[
        _buildRankCell(rank),
        ...rowData.asMap().entries.map((MapEntry<int, OddsModel?> entry) {
          final bool isChanged =
              entry.key > 0 &&
              entry.value != null &&
              rowData[entry.key - 1] != null &&
              entry.value!.num != rowData[entry.key - 1]!.num;
          return _buildDataCell(entry.value, isChanged);
        }),
        _buildRankCell(rank),
      ],
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
    final List<int> timingOrder = _computeTimingOrder(timingParts);
    final Map<int, List<OddsModel>> oddsTimingMap = _computeOddsTimingMap(oddsModelList, timingOrder);
    final Map<int, List<OddsModel?>> rankingMap = _computeRankingMap(horseNum, timingOrder, oddsTimingMap);
    final List<String> timingLabels = _buildTimingLabels(timingParts);

    final double tableWidth = 80 + 50.0 * timingParts.length;

    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        if (_fitScale == null) {
          _fitScale = constraints.maxWidth / tableWidth;
          _controller.value = Matrix4.identity()..scale(_fitScale);
        }
        return GestureDetector(
          onDoubleTap: () => _controller.value = Matrix4.identity()..scale(_fitScale),
          child: InteractiveViewer(
            transformationController: _controller,
            constrained: false,
            minScale: _fitScale!,
            maxScale: 4.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTimingHeaderFooterRow(timingLabels, isTop: true),
                ...List<Widget>.generate(horseNum, (int rankIndex) {
                  final int rank = rankIndex + 1;
                  return _buildRankingDataRow(rank, rankingMap[rank] ?? <OddsModel?>[]);
                }),
                _buildTimingHeaderFooterRow(timingLabels, isTop: false),
              ],
            ),
          ),
        );
      },
    );
  }
}
