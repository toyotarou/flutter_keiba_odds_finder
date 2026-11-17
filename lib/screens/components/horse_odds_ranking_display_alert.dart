// =============================================================================
// ファイル名   : horse_odds_ranking_display_alert.dart
// 概要         : 人気順位の推移の画面。オッズ取得タイミングごとの人気順を表で表示し、
//                選んだ馬の推移を線で重ねる。AI が選んだ馬にはバッジを付ける。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-31
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const/const.dart';
import '../../controllers/app_param/app_param.dart';
import '../../controllers/controllers_mixin.dart';
import '../../controllers/summary/summary.dart';
import '../../extensions/extensions.dart';
import '../../main.dart';
import '../../models/common/ai_response_recommend_horse_model.dart';
import '../../models/horse_model.dart';
import '../../models/odds_model.dart';

import '../../models/race_model.dart';
import '../../models/race_result_model.dart';
import '../../models/summary_model.dart';
import '../../utility/functions.dart';
import '../parts/odds_finder_dialog.dart';
import '../parts/odds_finder_overlay.dart';
import 'horse_race_result_display_alert.dart';
import 'race_introspection_display_alert.dart';

/// 表示する元データの種類（live: 当日のオッズ、summary: 過去レースのサマリー）。
enum RankingMode { live, summary }

/// 人気順 → タイミングごとの馬番 の表。
typedef RankingGrid = Map<int, List<int?>>;
/// 表の元データ一式（表・タイミング・頭数・最初の人気順）。
typedef _GridData = ({RankingGrid grid, List<String> timingParts, int horseNum, Map<int, int> horseToStartRank});

// 表の色（見出し・順位の変化の大きさ・急落）
const Color _headerBgColor = Color(0xFF1B3A2A);
const Color _changedBgColor1 = Color(0xFF1B3A5A);
const Color _changedBgColor2 = Color(0xFF4A3D10);
const Color _changedBgColor3 = Color(0xFF5A1A1A);
const Color _droppedBgColor = Color(0xFF4A1A6A);
const Color _defaultBgColor = Colors.transparent;

/// 発走何分前 → サマリーからその時点の単勝オッズを取り出す関数 の対応表。
final Map<int, String Function(SummaryModel)> _kOddsGetters = <int, String Function(SummaryModel)>{
  30: (SummaryModel m) => m.oddsTanBefore30,
  21: (SummaryModel m) => m.oddsTanBefore21,
  18: (SummaryModel m) => m.oddsTanBefore18,
  15: (SummaryModel m) => m.oddsTanBefore15,
  12: (SummaryModel m) => m.oddsTanBefore12,
  9: (SummaryModel m) => m.oddsTanBefore9,
  6: (SummaryModel m) => m.oddsTanBefore6,
  3: (SummaryModel m) => m.oddsTanBefore3,
  0: (SummaryModel m) => m.oddsTanBefore0,
};

////////////////////////////////////////////////////////////////

/// 人気順位の推移の画面。
class HorseOddsRankingDisplayAlert extends ConsumerStatefulWidget {
  const HorseOddsRankingDisplayAlert({super.key, this.mode = RankingMode.live});

  final RankingMode mode;

  @override
  ConsumerState<HorseOddsRankingDisplayAlert> createState() => _HorseOddsRankingDisplayAlertState();
}

/// 人気順位の推移の画面の状態。
class _HorseOddsRankingDisplayAlertState extends ConsumerState<HorseOddsRankingDisplayAlert>
    with ControllersMixin<HorseOddsRankingDisplayAlert> {
  final TransformationController _controller = TransformationController();
  double? _fitScale;
  double? _lastTableWidth;

  // ─── オーバーレイ管理 ──────────────────────────────────
  final List<OverlayEntry> _firstEntries = <OverlayEntry>[];
  final List<OverlayEntry> _secondEntries = <OverlayEntry>[];
  int _currentHorseNum = 0;

  /// 拡大・縮小の変化を監視し始める。
  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransformChanged);
  }

  /// 表示中のオーバーレイを外し、監視と制御を破棄する。
  @override
  void dispose() {
    for (final OverlayEntry e in _firstEntries) {
      e.remove();
    }
    for (final OverlayEntry e in _secondEntries) {
      e.remove();
    }
    _controller.removeListener(_onTransformChanged);
    _controller.dispose();
    super.dispose();
  }

  /// 強調表示する馬を選ぶパネルをオーバーレイで表示する。
  void _showHorseSelector() {
    if (_currentHorseNum == 0) {
      return;
    }

    final Map<int, String> horseNameMap;
    if (widget.mode == RankingMode.summary) {
      horseNameMap = Map<int, String>.fromEntries(
        summaryState.oneRaceSummaryList.map((SummaryModel e) => MapEntry<int, String>(e.num, e.horseName)),
      );
    } else {
      final ({String kaisuu, String basho, String day}) kbd = parseKbdParts(
        appParamState.selectedScheduleKaisuuBashoDay,
      );
      final int dayInt = int.tryParse(kbd.day) ?? 0;
      horseNameMap = Map<int, String>.fromEntries(
        horseState.horseList
            .where(
              (HorseModel e) =>
                  e.date == appParamState.selectedScheduleDate &&
                  e.kaisuu == kbd.kaisuu &&
                  e.basho == kbd.basho &&
                  e.day == dayInt &&
                  e.race == appParamState.selectedRaceNumber,
            )
            .map((HorseModel e) => MapEntry<int, String>(e.num, e.name)),
      );
    }

    final double topPadding = context.screenSize.height * 0.5;
    const double overlayW = 180;
    const double overlayH = 250;
    final double leftPos = context.screenSize.width - overlayW - 8;

    addFirstOverlay(
      context: context,
      firstEntries: _firstEntries,
      secondEntries: _secondEntries,
      setStateCallback: setState,
      width: overlayW,
      height: overlayH,
      color: Colors.black.withValues(alpha: 0.5),
      initialPosition: Offset(leftPos, topPadding),
      widget: _HorseSelectorContent(
        horseNum: _currentHorseNum,
        horseNameMap: horseNameMap,
        mode: widget.mode,
        markOverlayDirty: () {
          if (_firstEntries.isNotEmpty) {
            _firstEntries.last.markNeedsBuild();
          }
        },
      ),
      onPositionChanged: (_) {},
    );
  }

  /// 拡大・縮小の倍率から、拡大表示中かどうかを判定して状態に反映する。
  void _onTransformChanged() {
    final double currentScale = _controller.value.getMaxScaleOnAxis();
    final bool zoomed = _fitScale != null && currentScale > _fitScale! + 0.01;
    if (zoomed != ref.read(appParamProvider).isZoomed) {
      Future<void>(() => appParamNotifier.setIsZoomed(flag: zoomed));
    }
  }

  /// 表示中のレースの結果を取得済みかどうか。
  bool get _hasRaceResult {
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';
    return (raceResultState.raceResultMap[mapKey] ?? <RaceResultModel>[]).any(
      (RaceResultModel e) => e.race == appParamState.selectedRaceNumber,
    );
  }

  /// 人気順位の推移（オッズ取得タイミングごとの人気順）を表で表示する画面を組み立てる。
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Expanded(
                        child: Column(
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
                      ),

                      const SizedBox(width: 20),

                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.greenAccent.withValues(alpha: 0.5),
                        child: CircleAvatar(
                          radius: 14,
                          child: GestureDetector(
                            onTap: _showHorseSelector,
                            child: const Icon(Icons.stacked_line_chart, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
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

  /// 画面上部の見出しと操作ボタンを表示する。
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

  /// 表示中のレース（開催日・競馬場・レース番号・レース名）を表示する。
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

  /// 見出しの右側の操作ボタンを表示する。
  Widget _buildHeaderActions() {
    if (widget.mode == RankingMode.summary) {
      return GestureDetector(
        onTap: () {
          OddsFinderDialog(context: context, widget: const RaceIntrospectionDisplayAlert());
        },
        child: const Icon(Icons.flag, color: Colors.greenAccent),
      );
    }

    return Row(
      children: <Widget>[
        if (_hasRaceResult) ...<Widget>[
          GestureDetector(
            onTap: () => OddsFinderDialog(
              context: context,
              widget: const HorseRaceResultDisplayAlert(from: ResultDisplayFrom.raceResult),

              paddingTop: context.screenSize.height * 0.45,
              paddingBottom: context.screenSize.height * 0.1,
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

            await prefs.setBool('reload_all_expanded', appParamState.allExpanded);

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

  /// サマリーから、指定した発走何分前の単勝オッズを取り出す。
  static String _oddsAt(SummaryModel m, int minutes) => (_kOddsGetters[minutes] ?? (SummaryModel _) => '')(m);

  /// 指定した発走何分前の単勝オッズが低い順（人気順）に並べる。オッズが無い馬は除く。
  static List<SummaryModel> _sortSummaryByOdds(List<SummaryModel> horses, int minutes) {
    return horses.where((SummaryModel e) {
      final String odds = _oddsAt(e, minutes);

      return odds.isNotEmpty && odds != '0' && double.tryParse(odds) != null;
    }).toList()..sort(
      (SummaryModel a, SummaryModel b) =>
          double.parse(_oddsAt(a, minutes)).compareTo(double.parse(_oddsAt(b, minutes))),
    );
  }

  /// 設定のタイミング文字列を、表の列の順番（最初・発走何分前・最後）に変換する。
  static List<int> _computeTimingOrder(List<String> timingParts) {
    return List<int>.generate(timingParts.length, (int i) {
      if (i == 0) {
        return kOddsTimingFirst;
      }

      if (timingParts[i] == kOddsTimingLastLabel) {
        return kOddsTimingLast;
      }

      return int.parse(timingParts[i]);
    });
  }

  /// タイミングごとに、オッズを人気順に並べた一覧を作る。
  static Map<int, List<OddsModel>> _computeOddsTimingMap(List<OddsModel> list, List<int> timingOrder) {
    return Map<int, List<OddsModel>>.fromEntries(
      timingOrder.map((int timing) {
        final List<OddsModel> sorted = list.where((OddsModel e) => e.minutesBeforeStart == timing).toList()
          ..sort((OddsModel a, OddsModel b) => (double.tryParse(a.odds) ?? 0).compareTo(double.tryParse(b.odds) ?? 0));

        return MapEntry<int, List<OddsModel>>(timing, sorted);
      }),
    );
  }

  /// 最初の列での人気順（馬番 → 順位）の対応表を作る。
  static Map<int, int> _buildHorseToStartRank(RankingGrid grid, int horseNum) {
    return <int, int>{
      for (int r = 1; r <= horseNum; r++)
        if (grid[r]?.firstWhere((int? n) => n != null, orElse: () => null) case final int num) num: r,
    };
  }

  /// 当日のオッズから、表の元データ（順位 × タイミングの馬番）を作る。
  _GridData _buildFromOddsModel() {
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';

    final int selectedRace = appParamState.selectedRaceNumber;

    final int horseNum = selectedRace > 0
        ? (raceState.raceMap[mapKey]?.where((RaceModel e) => e.race == selectedRace).firstOrNull?.numHorses ?? 0)
        : 0;

    final List<OddsModel> oddsModelList = selectedRace > 0
        ? (oddsState.oddsMap[mapKey] ?? <OddsModel>[]).where((OddsModel e) => e.race == selectedRace).toList()
        : <OddsModel>[];

    final String oddsGetTiming = laravelConfigState.oddsGetTiming.isNotEmpty
        ? laravelConfigState.oddsGetTiming
        : appParamState.configOddsGetTiming;

    final List<String> timingParts = oddsGetTiming.split('|');
    final List<int> timingOrder = _computeTimingOrder(timingParts);
    final Map<int, List<OddsModel>> oddsTimingMap = _computeOddsTimingMap(oddsModelList, timingOrder);

    final RankingGrid grid = <int, List<int?>>{
      for (int r = 1; r <= horseNum; r++)
        r: timingOrder.map((int timing) {
          final List<OddsModel> slot = oddsTimingMap[timing] ?? <OddsModel>[];

          return r - 1 < slot.length ? slot[r - 1].num : null;
        }).toList(),
    };

    return (
      grid: grid,
      timingParts: timingParts,
      horseNum: horseNum,
      horseToStartRank: _buildHorseToStartRank(grid, horseNum),
    );
  }

  /// 過去レースのサマリーから、表の元データ（順位 × タイミングの馬番）を作る。
  _GridData _buildFromSummaryModel() {
    final List<SummaryModel> horses = summaryState.oneRaceSummaryList;

    final int horseNum = horses.length;

    final List<int> summaryTimingMinutes = appParamState.configOddsGetTiming.isEmpty
        ? <int>[]
        : appParamState.configOddsGetTiming.split('|').map(int.parse).toList();

    final List<List<SummaryModel>> perTiming = summaryTimingMinutes
        .map((int m) => _sortSummaryByOdds(horses, m))
        .toList();

    final RankingGrid grid = <int, List<int?>>{
      for (int rank = 1; rank <= horseNum; rank++)
        rank: summaryTimingMinutes.asMap().entries.map((MapEntry<int, int> e) {
          final List<SummaryModel> sorted = perTiming[e.key];

          return rank - 1 < sorted.length ? sorted[rank - 1].num : null;
        }).toList(),
    };

    return (
      grid: grid,
      timingParts: summaryTimingMinutes.map((int m) => m.toString()).toList(),
      horseNum: horseNum,
      horseToStartRank: _buildHorseToStartRank(grid, horseNum),
    );
  }

  /// タイミング（発走何分前か）の見出しセルを表示する。
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

  /// 人気順のセルを表示する。
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

  /// 馬番のセルを表示する。順位の変化の大きさに応じて背景色を変える。
  Widget _buildDataCell(int? num, int changeLevel) {
    final Color bgColor = switch (changeLevel) {
      -1 => _droppedBgColor,
      1 => _changedBgColor1,
      2 => _changedBgColor2,
      3 => _changedBgColor3,
      _ => _defaultBgColor,
    };
    return GestureDetector(
      onDoubleTap: () => _controller.value = Matrix4.identity()..scale(_fitScale),
      child: Container(
        width: 50,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: Colors.white24),
        ),
        child: Text(num != null ? num.toString() : '-', style: const TextStyle(color: Colors.white, fontSize: 10)),
      ),
    );
  }

  /// 表の上下に付ける、タイミングの見出し行を表示する。
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

  /// 人気順1行ぶん（各タイミングの馬番）を表示する。
  Widget _buildRankingRow(int rank, List<int?> rowData, Map<int, int> horseToStartRank) {
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

  /// 人気順位の推移の表全体を表示する。選択した馬の推移を線で重ねる。
  Widget _displayRankingList() {
    final _GridData data = switch (widget.mode) {
      RankingMode.live => _buildFromOddsModel(),
      RankingMode.summary => _buildFromSummaryModel(),
    };

    if (data.horseNum == 0) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    _currentHorseNum = data.horseNum;

    const String cornerLabel = '分前';

    final double tableWidth = 80 + 50.0 * data.timingParts.length;
    final double tableHeight = 30.0 * (data.horseNum + 2);

    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        if (_fitScale == null || _lastTableWidth != tableWidth) {
          _lastTableWidth = tableWidth;
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
            child: SizedBox(
              width: tableWidth,
              height: tableHeight,
              child: Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildHeaderFooterRow(data.timingParts, isTop: true, cornerLabel: cornerLabel),
                      ...List<Widget>.generate(data.horseNum, (int i) {
                        final int rank = i + 1;
                        return _buildRankingRow(rank, data.grid[rank] ?? <int?>[], data.horseToStartRank);
                      }),
                      _buildHeaderFooterRow(data.timingParts, isTop: false, cornerLabel: cornerLabel),
                    ],
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _HorseLinePainter(
                        grid: data.grid,
                        selectedHorse: appParamState.selectedHorseLineNum,
                        colCount: data.timingParts.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

////////////////////////////////////////////////////////////////

/// 強調表示する馬を選ぶパネル。
class _HorseSelectorContent extends ConsumerStatefulWidget {
  const _HorseSelectorContent({
    required this.horseNum,
    required this.horseNameMap,
    required this.mode,
    this.markOverlayDirty,
  });

  final int horseNum;
  final Map<int, String> horseNameMap;
  final RankingMode mode;
  final VoidCallback? markOverlayDirty;

  @override
  ConsumerState<_HorseSelectorContent> createState() => _HorseSelectorContentState();
}

/// 強調表示する馬を選ぶパネルの状態。
class _HorseSelectorContentState extends ConsumerState<_HorseSelectorContent>
    with ControllersMixin<_HorseSelectorContent> {
  Set<int> _aiPickupNums = <int>{};
  Map<int, String> _aiPickupScores = <int, String>{};
  Set<int> _secondAiNums = <int>{};
  Map<int, String> _secondAiScores = <int, String>{};

  bool _isAiLoading = true;
  bool _isSecondAiLoading = true;
  /// 1st AI が選ばず 2nd AI だけが選んだ馬番。バッジの見た目は AI 馬と同じにする。
  Set<int> get _secondOnlyNums => _secondAiNums.difference(_aiPickupNums);

  /// 画面表示後に、AI の選出馬を取得する。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAiData());
  }

  /// 表示中のレースの AI 選出馬（1st AI・2nd AI）を取得する。
  Future<void> _fetchAiData() async {
    final String date;
    final String kaisuu;
    final String basho;
    final String day;
    final int race;

    if (widget.mode == RankingMode.summary) {
      final List<SummaryModel> list = ref.read(summaryProvider).oneRaceSummaryList;
      if (list.isEmpty) {
        if (mounted) {
          setState(() {
            _isAiLoading = false;
            _isSecondAiLoading = false;
          });
        }
        return;
      }
      final SummaryModel first = list.first;
      date = first.date;
      kaisuu = first.kaisuu;
      basho = first.basho;
      day = first.day.toString();
      race = first.race;
    } else {
      final AppParamState appParam = ref.read(appParamProvider);
      date = appParam.selectedScheduleDate;
      if (date.isEmpty) {
        if (mounted) {
          setState(() {
            _isAiLoading = false;
            _isSecondAiLoading = false;
          });
        }
        return;
      }
      final ({String kaisuu, String basho, String day}) kbd = parseKbdParts(appParam.selectedScheduleKaisuuBashoDay);
      kaisuu = kbd.kaisuu;
      basho = kbd.basho;
      day = kbd.day;
      race = appParam.selectedRaceNumber;
      if (race == 0) {
        if (mounted) {
          setState(() {
            _isAiLoading = false;
            _isSecondAiLoading = false;
          });
        }
        return;
      }
    }

    try {
      final List<Map<String, dynamic>> results = await Future.wait(<Future<Map<String, dynamic>>>[
        fetchAiAnalysisData(
          ref,
          date: date,
          kaisuu: kaisuu,
          basho: basho,
          day: day,
          race: race,
          gapHorseNums: <int>[],
          upsetPickupHorseNums: <int>[],
        ),
        fetchSecondAiOpinionData(ref, date: date, kaisuu: kaisuu, basho: basho, day: day, race: race),
      ]);

      final List<AiResponseRecommendHorseModel> aiHorses = parseAnalysisText(
        (results[0]['analysis_text'] as String?) ?? '',
      );
      final List<AiResponseRecommendHorseModel> secondHorses = parseAnalysisText(
        (results[1]['analysis_text'] as String?) ?? '',
      );

      // 統合結果（merged_horses）を受け取っていれば、それを正とする（AI予想画面・総合予想と同じ基準）。
      //   頭数に足りない分の「補充」の馬も、サーバーが選んだAI選出なので、AIの印を付ける。
      //   各AIの文章だけを見ると、補充の馬とサーバーが外した馬の扱いがAI予想画面と食い違う。
      final Map<String, dynamic> second = results[1];
      final List<dynamic>? mergedRaw = second['not_ready'] == true ? null : second['merged_horses'] as List<dynamic>?;
      final List<AiResponseRecommendHorseModel>? merged = mergedRaw == null ? null : parseMergedHorses(mergedRaw);

      if (mounted) {
        setState(() {
          if (merged != null) {
            final List<AiResponseRecommendHorseModel> firstSide =
                merged.where((AiResponseRecommendHorseModel h) => h.category != 'second_only').toList();
            final List<AiResponseRecommendHorseModel> secondSide =
                merged.where((AiResponseRecommendHorseModel h) => h.category == 'second_only').toList();
            _aiPickupNums = firstSide.map((AiResponseRecommendHorseModel h) => h.num).toSet();
            // 「補充」の馬は印だけ付け、おすすめ度（サーバーでは0）は出さない
            _aiPickupScores = <int, String>{
              for (final AiResponseRecommendHorseModel h in firstSide)
                if (!h.fillSlot) h.num: h.score.toString(),
            };
            _secondAiNums = secondSide.map((AiResponseRecommendHorseModel h) => h.num).toSet();
            _secondAiScores = <int, String>{
              for (final AiResponseRecommendHorseModel h in secondSide) h.num: h.score.toString(),
            };
          } else {
            _aiPickupNums = aiHorses.map((AiResponseRecommendHorseModel h) => h.num).toSet();
            _aiPickupScores = <int, String>{
              for (final AiResponseRecommendHorseModel h in aiHorses) h.num: h.score.toString(),
            };
            _secondAiNums = secondHorses.map((AiResponseRecommendHorseModel h) => h.num).toSet();
            _secondAiScores = <int, String>{
              for (final AiResponseRecommendHorseModel h in secondHorses) h.num: h.score.toString(),
            };
          }
          _isAiLoading = false;
          _isSecondAiLoading = false;
        });
        widget.markOverlayDirty?.call();
      }
    } catch (e) {
      debugPrint('[HorseSelector] _fetchAiData error: $e');
      if (mounted) {
        setState(() {
          _isAiLoading = false;
          _isSecondAiLoading = false;
        });
      }
    }
  }

  /// 1st AI が選んだ馬に、おすすめ度のバッジを表示する。
  Widget _buildAiBadge(int num) {
    if (_isAiLoading) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38)),
          SizedBox(width: 5),
          Text('読み込み中...', style: TextStyle(fontSize: 9, color: Colors.white38)),
        ],
      );
    }

    return Stack(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 2, bottom: 5, right: 10),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFFD700)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Text(
            'AI',
            style: TextStyle(fontSize: 9, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
          ),
        ),

        Positioned(
          right: 0,
          bottom: 0,
          child: Text(
            '${_aiPickupScores[num]} %',
            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  /// 2nd AI だけが選んだ馬のバッジ。1st AI の馬と同じ見た目にし、スコアだけ差し替える。
  Widget _buildSecondOnlyBadge(int num) {
    if (_isSecondAiLoading) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38)),
          SizedBox(width: 5),
          Text('読み込み中...', style: TextStyle(fontSize: 9, color: Colors.white38)),
        ],
      );
    }

    return Stack(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 2, bottom: 5, right: 10),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFFD700)),
            borderRadius: BorderRadius.circular(3),
          ),
          child: const Text(
            'AI',
            style: TextStyle(fontSize: 9, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
          ),
        ),

        if (_secondAiScores[num] != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Text(
              '${_secondAiScores[num]} %',
              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  /// 取得中ならインジケーター、取得済みなら該当するバッジを表示する。
  Widget _buildBadgeOrLoading(int num) {
    final bool isAi = _aiPickupNums.contains(num);

    final bool isSecondOnly = _secondOnlyNums.contains(num);

    if (isAi) {
      return _buildAiBadge(num);
    }

    if (isSecondOnly) {
      return _buildSecondOnlyBadge(num);
    }

    if (_isAiLoading) {
      return _buildAiBadge(num);
    }

    if (_isSecondAiLoading) {
      return _buildSecondOnlyBadge(num);
    }

    return const SizedBox.shrink();
  }

  /// 強調表示する馬を選ぶための馬番一覧を表示する。
  @override
  Widget build(BuildContext context) {
    final int? selectedHorse = ref.watch(appParamProvider).selectedHorseLineNum;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const SizedBox.shrink(),

            GestureDetector(
              onTap: () => ref.read(appParamProvider.notifier).setSelectedHorseLineNum(num: null),
              child: Text(
                'クリア',
                style: TextStyle(color: Colors.green[500], fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        ...List<Widget>.generate(widget.horseNum, (int i) {
          final int num = i + 1;
          final bool isSelected = selectedHorse == num;
          final String name = widget.horseNameMap[num] ?? '';
          final bool isAi = _aiPickupNums.contains(num);
          final bool isSecondOnly = _secondOnlyNums.contains(num);
          return GestureDetector(
            onTap: () => ref.read(appParamProvider.notifier).setSelectedHorseLineNum(num: isSelected ? null : num),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? Colors.green[500]! : Colors.white24,
                  width: isSelected ? 1.5 : 0.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 28,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: <Widget>[
                          Text(
                            '$num',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),

                          const Text('馬番', style: TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name,
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isAi || isSecondOnly || _isAiLoading || _isSecondAiLoading) ...<Widget>[
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const SizedBox.shrink(),
                              Container(child: _buildBadgeOrLoading(num)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////

/// 選んだ馬の順位の推移を線で描く。
class _HorseLinePainter extends CustomPainter {
  const _HorseLinePainter({required this.grid, required this.selectedHorse, required this.colCount});

  final RankingGrid grid;
  final int? selectedHorse;
  final int colCount;

  /// 表の中で、指定した順位・列のセルの中心座標を返す。
  Offset _center(int rank, int colIdx) {
    const double rankCellW = 40;
    const double dataCellW = 50;
    const double cellH = 30;
    return Offset(rankCellW + colIdx * dataCellW + dataCellW / 2, cellH + (rank - 1) * cellH + cellH / 2);
  }

  /// 選択した馬の順位の推移を、セルの中心を結ぶ線で描く。
  @override
  void paint(Canvas canvas, Size size) {
    final int? horse = selectedHorse;
    if (horse == null) {
      return;
    }

    final int rowCount = grid.length;
    final List<Offset> points = <Offset>[];

    for (int col = 0; col < colCount; col++) {
      for (int rank = 1; rank <= rowCount; rank++) {
        if (grid[rank]?[col] == horse) {
          points.add(_center(rank, col));
          break;
        }
      }
    }

    if (points.length < 2) {
      return;
    }

    final Paint linePaint = Paint()
      ..color = Colors.green[500]!.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    final Paint dotPaint = Paint()
      ..color = Colors.green[500]!.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    final Paint borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final Offset p in points) {
      canvas.drawCircle(p, 5, dotPaint);
      canvas.drawCircle(p, 5, borderPaint);
    }
  }

  /// 選択した馬か表のデータが変わったときだけ描き直す。
  @override
  bool shouldRepaint(_HorseLinePainter old) => old.selectedHorse != selectedHorse || old.grid != grid;
}
