import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../models/odds_model.dart';
import '../../models/race_model.dart';
import '../../models/race_result_model.dart';
import '../../models/summary_model.dart';
import '../parts/odds_finder_dialog.dart';
import 'horse_race_result_display_alert.dart';

enum RankingMode { live, summary }

typedef RankingGrid = Map<int, List<int?>>;
typedef _GridData = ({RankingGrid grid, List<String> timingLabels, int horseNum, Map<int, int> horseToStartRank});

const Color _headerBgColor = Color(0xFF1B3A2A);
const Color _changedBgColor1 = Color(0xFF1B3A5A);
const Color _changedBgColor2 = Color(0xFF4A3D10);
const Color _changedBgColor3 = Color(0xFF5A1A1A);
const Color _droppedBgColor = Color(0xFF4A1A6A);
const Color _defaultBgColor = Colors.transparent;

const List<int> _kSummaryTimingMinutes = <int>[24, 21, 18, 15, 12, 9, 6, 3, 0];
const List<String> _kSummaryTimingLabels = <String>['S', '21', '18', '15', '12', '9', '6', '3', 'E'];

final Map<int, String Function(SummaryModel)> _kOddsGetters = <int, String Function(SummaryModel)>{
  24: (SummaryModel m) => m.oddsTanBefore24,
  21: (SummaryModel m) => m.oddsTanBefore21,
  18: (SummaryModel m) => m.oddsTanBefore18,
  15: (SummaryModel m) => m.oddsTanBefore15,
  12: (SummaryModel m) => m.oddsTanBefore12,
  9: (SummaryModel m) => m.oddsTanBefore9,
  6: (SummaryModel m) => m.oddsTanBefore6,
  3: (SummaryModel m) => m.oddsTanBefore3,
  0: (SummaryModel m) => m.oddsTanBefore0,
};

class HorseOddsRankingDisplayAlert extends ConsumerStatefulWidget {
  const HorseOddsRankingDisplayAlert({super.key, this.mode = RankingMode.live});

  final RankingMode mode;

  @override
  ConsumerState<HorseOddsRankingDisplayAlert> createState() => _HorseOddsRankingDisplayAlertState();
}

class _HorseOddsRankingDisplayAlertState extends ConsumerState<HorseOddsRankingDisplayAlert>
    with ControllersMixin<HorseOddsRankingDisplayAlert> {
  final TransformationController _controller = TransformationController();
  double? _fitScale;
  bool _isZoomed = false;

  ///
  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransformChanged);
  }

  ///
  @override
  void dispose() {
    _controller.removeListener(_onTransformChanged);
    _controller.dispose();
    super.dispose();
  }

  ///
  void _onTransformChanged() {
    final double currentScale = _controller.value.getMaxScaleOnAxis();
    final bool zoomed = _fitScale != null && currentScale > _fitScale! + 0.01;
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
    }
  }

  ///
  bool get _hasRaceResult {
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';
    return (raceResultState.raceResultMap[mapKey] ?? <RaceResultModel>[]).any(
      (RaceResultModel e) => e.race == appParamState.selectedRaceNumber,
    );
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
                _buildHeader(),
                Stack(
                  children: <Widget>[
                    Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const SizedBox(),
                        GestureDetector(
                          onTap: () => appParamNotifier.setIsShowUpperBox2(flag: !appParamState.isShowUpperBox2),
                          child: Icon(
                            appParamState.isShowUpperBox2 ? Icons.arrow_circle_up : Icons.arrow_circle_down,
                            color: Colors.green[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (appParamState.isShowUpperBox2) ...<Widget>[
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('縦軸：順位、横軸：タイミング、セル内：馬番', style: TextStyle(fontSize: 10)),
                      SizedBox(height: 5),
                      Text('青=1上昇、黄=2上昇、赤=3以上上昇、紫=下落（開始時点との比較）', style: TextStyle(fontSize: 10)),
                      SizedBox(height: 5),
                      Text('表をダブルタップすると、初期の全体表示に戻ります。', style: TextStyle(fontSize: 10)),
                      SizedBox(height: 10),
                    ],
                  ),
                ],
                Expanded(child: _displayRankingList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _buildHeader() {
    return Stack(
      children: <Widget>[
        _buildHeaderText(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[const SizedBox.shrink(), _buildHeaderActions()],
        ),
      ],
    );
  }

  ///
  Widget _buildHeaderText() {
    final bool isSummary = widget.mode == RankingMode.summary;
    final String date;
    final String kaisuuBashoDay;
    final String race;
    final String raceName;

    if (isSummary) {
      final List<SummaryModel> list = summaryState.oneRaceSummaryList;
      if (list.isNotEmpty) {
        final SummaryModel s = list.first;
        date = s.date;
        kaisuuBashoDay = '${s.kaisuu}回${s.bashoName}${s.day}日';
        race = '${s.race}R';
        raceName = s.raceName;
      } else {
        date = kaisuuBashoDay = race = raceName = '';
      }
    } else {
      date = appParamState.selectedScheduleDate;
      kaisuuBashoDay = appParamState.selectedScheduleKaisuuBashoDayName;
      race = '${appParamState.selectedRaceNumber}R';
      final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';
      raceName =
          (appParamState.keepRaceMap[mapKey] ?? <RaceModel>[])
              .where((RaceModel e) => e.race == appParamState.selectedRaceNumber)
              .firstOrNull
              ?.raceName ??
          '';
    }

    return DefaultTextStyle(
      style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (date.isNotEmpty) Text('$date　$kaisuuBashoDay　$race'),
          if (raceName.isNotEmpty) Text(raceName),
        ],
      ),
    );
  }

  ///
  Widget _buildHeaderActions() {
    if (widget.mode == RankingMode.summary) {
      return GestureDetector(
        onTap: () {
          final Map<int, int> popularityRank = _computeLatestPopularityRank(summaryState.oneRaceSummaryList);
          OddsFinderDialog(
            context: context,
            widget: HorseRaceResultDisplayAlert(from: ResultDisplayFrom.summary, numToPopularityRank: popularityRank),
            paddingLeft: context.screenSize.width * 0.1,
            paddingTop: context.screenSize.height * 0.45,
            paddingBottom: context.screenSize.height * 0.05,
            clearBarrierColor: true,
          );
        },
        child: Icon(Icons.flag, color: Colors.green[500]),
      );
    }

    return Row(
      children: <Widget>[
        if (_hasRaceResult) ...<Widget>[
          GestureDetector(
            onTap: () => OddsFinderDialog(
              context: context,
              widget: const HorseRaceResultDisplayAlert(from: ResultDisplayFrom.raceResult),
              paddingLeft: context.screenSize.width * 0.1,
              paddingTop: context.screenSize.height * 0.45,
              paddingBottom: context.screenSize.height * 0.05,
              clearBarrierColor: true,
            ),
            child: const Icon(Icons.flag, color: Colors.greenAccent),
          ),
          const SizedBox(width: 20),
        ],
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
            await prefs.setInt('reload_selected_race_number', appParamState.selectedRaceNumber);
            await prefs.setBool('isRankingDialogOpen', true);
            if (mounted) {
              // ignore: use_build_context_synchronously
              context.findAncestorStateOfType<AppRootState>()?.restartApp();
            }
          },
          child: const Icon(Icons.refresh, color: Colors.greenAccent),
        ),
      ],
    );
  }

  ///
  static String _oddsAt(SummaryModel m, int minutes) => (_kOddsGetters[minutes] ?? (SummaryModel _) => '')(m);

  ///
  static List<SummaryModel> _sortSummaryByOdds(List<SummaryModel> horses, int minutes) {
    return horses.where((SummaryModel e) {
      final String odds = _oddsAt(e, minutes);
      return odds.isNotEmpty && odds != '0' && double.tryParse(odds) != null;
    }).toList()..sort(
      (SummaryModel a, SummaryModel b) =>
          double.parse(_oddsAt(a, minutes)).compareTo(double.parse(_oddsAt(b, minutes))),
    );
  }

  ///
  static Map<int, int> _computeLatestPopularityRank(List<SummaryModel> horses) {
    for (final int minutes in _kSummaryTimingMinutes.reversed) {
      final List<SummaryModel> sorted = _sortSummaryByOdds(horses, minutes);
      if (sorted.isNotEmpty) {
        return <int, int>{for (int i = 0; i < sorted.length; i++) sorted[i].num: i + 1};
      }
    }
    return <int, int>{};
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
  static Map<int, List<OddsModel>> _computeOddsTimingMap(List<OddsModel> list, List<int> timingOrder) {
    return Map<int, List<OddsModel>>.fromEntries(
      timingOrder.map((int timing) {
        final List<OddsModel> sorted = list.where((OddsModel e) => e.minutesBeforeStart == timing).toList()
          ..sort((OddsModel a, OddsModel b) => (double.tryParse(a.odds) ?? 0).compareTo(double.tryParse(b.odds) ?? 0));
        return MapEntry<int, List<OddsModel>>(timing, sorted);
      }),
    );
  }

  ///
  static Map<int, int> _buildHorseToStartRank(RankingGrid grid, int horseNum) {
    return <int, int>{
      for (int r = 1; r <= horseNum; r++)
        if (grid[r]?.firstOrNull case final int num) num: r,
    };
  }

  ///
  _GridData _buildFromOddsModel() {
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

    final RankingGrid grid = <int, List<int?>>{
      for (int r = 1; r <= horseNum; r++)
        r: timingOrder.map((int timing) {
          final List<OddsModel> slot = oddsTimingMap[timing] ?? <OddsModel>[];
          return r - 1 < slot.length ? slot[r - 1].num : null;
        }).toList(),
    };

    final List<String> timingLabels = List<String>.generate(timingParts.length, (int i) {
      if (i == 0) {
        return 'S';
      }
      if (i == timingParts.length - 1) {
        return 'E';
      }
      return timingParts[i];
    });

    return (
      grid: grid,
      timingLabels: timingLabels,
      horseNum: horseNum,
      horseToStartRank: _buildHorseToStartRank(grid, horseNum),
    );
  }

  ///
  _GridData _buildFromSummaryModel() {
    final List<SummaryModel> horses = summaryState.oneRaceSummaryList;
    final int horseNum = horses.length;

    final List<List<SummaryModel>> perTiming = _kSummaryTimingMinutes
        .map((int m) => _sortSummaryByOdds(horses, m))
        .toList();

    final RankingGrid grid = <int, List<int?>>{
      for (int rank = 1; rank <= horseNum; rank++)
        rank: _kSummaryTimingMinutes.asMap().entries.map((MapEntry<int, int> e) {
          final List<SummaryModel> sorted = perTiming[e.key];
          return rank - 1 < sorted.length ? sorted[rank - 1].num : null;
        }).toList(),
    };

    return (
      grid: grid,
      timingLabels: _kSummaryTimingLabels,
      horseNum: horseNum,
      horseToStartRank: _buildHorseToStartRank(grid, horseNum),
    );
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
  static Widget _buildDataCell(int? num, int changeLevel) {
    final Color bgColor = switch (changeLevel) {
      -1 => _droppedBgColor,
      1 => _changedBgColor1,
      2 => _changedBgColor2,
      3 => _changedBgColor3,
      _ => _defaultBgColor,
    };
    return Container(
      width: 50,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.white24),
      ),
      child: Text(num != null ? num.toString() : '-', style: const TextStyle(color: Colors.white, fontSize: 10)),
    );
  }

  ///
  static Widget _buildHeaderFooterRow(List<String> labels, {required bool isTop, required String cornerLabel}) {
    Widget corner({required bool isRight}) {
      return SizedBox(
        width: 40,
        height: 30,
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: isTop ? 0 : null,
              top: isTop ? null : 0,
              left: isRight ? null : 0,
              right: isRight ? 0 : null,
              child: const Text('順位', style: TextStyle(fontSize: 8)),
            ),
            Positioned(
              top: isTop ? 0 : null,
              bottom: isTop ? null : 0,
              left: isRight ? 0 : null,
              right: isRight ? null : 0,
              child: Text(cornerLabel, style: const TextStyle(fontSize: 8)),
            ),
          ],
        ),
      );
    }

    return Row(children: <Widget>[corner(isRight: false), ...labels.map(_buildTimingLabelCell), corner(isRight: true)]);
  }

  ///
  static Widget _buildRankingRow(int rank, List<int?> rowData, Map<int, int> horseToStartRank) {
    return Row(
      children: <Widget>[
        _buildRankCell(rank),
        ...rowData.asMap().entries.map((MapEntry<int, int?> entry) {
          int changeLevel = 0;
          if (entry.key > 0 && entry.value != null) {
            final int? startRank = horseToStartRank[entry.value!];
            if (startRank != null) {
              final int rankUp = startRank - rank;
              changeLevel = switch (rankUp) {
                >= 3 => 3,
                2 => 2,
                1 => 1,
                < 0 => -1,
                _ => 0,
              };
            }
          }
          return _buildDataCell(entry.value, changeLevel);
        }),
        _buildRankCell(rank),
      ],
    );
  }

  ///
  Widget _displayRankingList() {
    final _GridData data = switch (widget.mode) {
      RankingMode.live => _buildFromOddsModel(),
      RankingMode.summary => _buildFromSummaryModel(),
    };

    if (data.horseNum == 0) {
      return widget.mode == RankingMode.summary
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : const SizedBox.shrink();
    }

    const String cornerLabel = '分前';
    final double tableWidth = 80 + 50.0 * data.timingLabels.length;

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
                _buildHeaderFooterRow(data.timingLabels, isTop: true, cornerLabel: cornerLabel),
                ...List<Widget>.generate(data.horseNum, (int i) {
                  final int rank = i + 1;
                  return _buildRankingRow(rank, data.grid[rank] ?? <int?>[], data.horseToStartRank);
                }),
                _buildHeaderFooterRow(data.timingLabels, isTop: false, cornerLabel: cornerLabel),
              ],
            ),
          ),
        );
      },
    );
  }
}
