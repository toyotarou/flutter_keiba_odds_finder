// =============================================================================
// ファイル名   : developer_news_minutes_display_alert.dart
// 概要         : 開発者向けお知らせの画面（管理者用）。1週間の時間割カレンダー形式で表示する。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-08-25
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/developer_news_model.dart';
import '../parts/widget_display_overlay.dart';

const int _kStartMinutes = 330; // 5:30
const int _kEndMinutes = 1480; // 24:40（翌0:00・0:10 の送信も表示するため。0:10 のブロックの高さぶん余白を取る）
const double _kPxPerMinute = 2.0;
const double _kGutterWidth = 38.0;

/////////////////////////////////////////////////////////////////////////////////////////

/// 開発者向けお知らせの画面。
class DeveloperNewsMinutesDisplayAlert extends ConsumerStatefulWidget {
  const DeveloperNewsMinutesDisplayAlert({super.key});

  @override
  ConsumerState<DeveloperNewsMinutesDisplayAlert> createState() => _DeveloperNewsMinutesDisplayAlertState();
}

/// 開発者向けお知らせの画面の状態。
class _DeveloperNewsMinutesDisplayAlertState extends ConsumerState<DeveloperNewsMinutesDisplayAlert>
    with ControllersMixin<DeveloperNewsMinutesDisplayAlert> {
  final ScrollController _gutterController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();

  /// 画面表示後に、最初のお知らせの位置までスクロールする。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFirstNews());
  }

  /// 今週いちばん早い時刻のお知らせが見える位置まで、カレンダーを縦にスクロールする。
  void _scrollToFirstNews() {
    if (!_calendarScrollController.hasClients) {
      return;
    }
    for (int h = _kStartMinutes ~/ 60; h <= _kEndMinutes ~/ 60; h++) {
      for (int m = 0; m <= 59; m++) {
        final String time = '${h % 24}:${m.toString().padLeft(2, '0')}';
        if (appParamState.keepDeveloperNewsTimeMap[time] != null &&
            appParamState.keepDeveloperNewsTimeMap[time]!.isNotEmpty) {
          final int minutes = h * 60 + m;
          final double top = ((minutes - _kStartMinutes) * _kPxPerMinute).clamp(
            0.0,
            _calendarScrollController.position.maxScrollExtent,
          );
          _calendarScrollController.animateTo(top, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          return;
        }
      }
    }
  }

  /// スクロールの制御を破棄する。
  @override
  void dispose() {
    _gutterController.dispose();
    _calendarScrollController.dispose();
    super.dispose();
  }

  /// カレンダー部分の高さ（表示する時間帯 × 1分あたりのピクセル数）。
  double get _gridHeight => (_kEndMinutes - _kStartMinutes) * _kPxPerMinute;

  /// 直近の土曜日から始まる1週間（土〜金）の日付一覧。
  List<DateTime> get _weekDates {
    final DateTime today = DateTime.now();
    final int daysSinceSaturday = (today.weekday + 1) % 7;
    final DateTime lastSaturday = DateTime(today.year, today.month, today.day - daysSinceSaturday);
    return List<DateTime>.generate(7, (int i) => lastSaturday.add(Duration(days: i)));
  }

  /// 開発者向けお知らせを、1週間の時間割カレンダー形式で表示する画面を組み立てる。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('developer news minutes', style: TextStyle(fontSize: 12)),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5, height: 10),
              _buildDayHeader(),
              Expanded(child: _buildCalendar()),
              Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5, height: 10),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// 曜日と日付の見出し行を表示する（今日の列は強調する）。
  Widget _buildDayHeader() {
    const List<String> dayNames = <String>['土', '日', '月', '火', '水', '木', '金'];
    final List<DateTime> dates = _weekDates;
    final DateTime today = DateTime.now();

    return Row(
      children: <Widget>[
        const SizedBox(width: _kGutterWidth),
        ...List<Widget>.generate(7, (int i) {
          final DateTime date = dates[i];
          final bool isToday = date.year == today.year && date.month == today.month && date.day == today.day;
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
              ),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isToday ? Colors.green[800]!.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                  child: Column(
                    children: <Widget>[
                      Text(dayNames[i]),
                      Text(date.month.toString().padLeft(2, '0')),
                      Text(date.day.toString().padLeft(2, '0')),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 時刻の目盛りと、お知らせのブロックを並べたカレンダー本体を表示する。
  Widget _buildCalendar() {
    return Stack(
      children: <Widget>[
        NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification n) {
            if (n.metrics.axis == Axis.vertical && _gutterController.hasClients) {
              _gutterController.jumpTo(n.metrics.pixels.clamp(0.0, _gutterController.position.maxScrollExtent));
            }
            return false;
          },
          child: SingleChildScrollView(
            controller: _calendarScrollController,
            child: SizedBox(
              height: _gridHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: _kGutterWidth),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext ctx, BoxConstraints constraints) {
                        final double colW = constraints.maxWidth / 7;
                        return Stack(
                          children: <Widget>[
                            CustomPaint(
                              size: Size(constraints.maxWidth, _gridHeight),
                              painter: _NewsGridPainter(
                                startMinutes: _kStartMinutes,
                                endMinutes: _kEndMinutes,
                                pxPerMinute: _kPxPerMinute,
                                columnWidth: colW,
                                columnCount: 7,
                              ),
                            ),
                            ..._buildNewsBlocks(colW),
                            const _NowIndicatorLine(
                              startMinutes: _kStartMinutes,
                              endMinutes: _kEndMinutes,
                              pxPerMinute: _kPxPerMinute,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: _kGutterWidth,
          child: IgnorePointer(
            child: SingleChildScrollView(
              controller: _gutterController,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                height: _gridHeight,
                child: const _TimeGutter(
                  startMinutes: _kStartMinutes,
                  endMinutes: _kEndMinutes,
                  pxPerMinute: _kPxPerMinute,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// お知らせ1件ずつを、送信した曜日の列・時刻の位置にブロックとして配置する。
  /// 0時台の送信は前日の夜の処理なので、前日の列に表示する。
  List<Widget> _buildNewsBlocks(double colW) {
    final List<Widget> widgets = <Widget>[];
    const double blockH = 30 * _kPxPerMinute;
    final List<DateTime> dates = _weekDates;

    final Map<String, Map<String, List<DeveloperNewsModel>>> dateMap =
        <String, Map<String, List<DeveloperNewsModel>>>{};

    for (int h = _kStartMinutes ~/ 60; h <= _kEndMinutes ~/ 60; h++) {
      for (int m = 0; m <= 59; m++) {
        final String time = '${h % 24}:${m.toString().padLeft(2, '0')}';
        if (appParamState.keepDeveloperNewsTimeMap[time] != null) {
          for (final DeveloperNewsModel item in appParamState.keepDeveloperNewsTimeMap[time]!) {
            // 0時台（5:30より前）の送信は前日の夜の処理なので、前日の列に表示する
            DateTime itemDate = DateTime.parse(item.sentDate.split(' ')[0]);
            if (h >= 24) {
              itemDate = itemDate.subtract(const Duration(days: 1));
            }
            final String dateKey =
                '${itemDate.year}-${itemDate.month.toString().padLeft(2, '0')}-${itemDate.day.toString().padLeft(2, '0')}';
            dateMap.putIfAbsent(dateKey, () => <String, List<DeveloperNewsModel>>{});
            dateMap[dateKey]!.putIfAbsent(time, () => <DeveloperNewsModel>[]);
            dateMap[dateKey]![time]!.add(item);
          }
        }
      }
    }

    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final DateTime date = dates[dayIndex];
      final String dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (dateMap[dateKey] == null) {
        continue;
      }

      for (final MapEntry<String, List<DeveloperNewsModel>> timeEntry in dateMap[dateKey]!.entries) {
        final String time = timeEntry.key;
        final List<DeveloperNewsModel> items = timeEntry.value;

        final List<String> parts = time.split(':');
        if (parts.length < 2) {
          continue;
        }

        int minutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        // 0時台（5:30より前）は 24:xx として扱い、23:50 の下に表示する
        if (minutes < _kStartMinutes) {
          minutes += 1440;
        }
        if (minutes < _kStartMinutes || minutes > _kEndMinutes) {
          continue;
        }

        final double top = (minutes - _kStartMinutes) * _kPxPerMinute;
        final double left = dayIndex * colW;

        widgets.add(
          Positioned(
            top: top,
            left: left + 2,
            width: colW - 4,
            height: blockH,
            child: _NewsBlock(time: time, items: items),
          ),
        );
      }
    }

    return widgets;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////

/// お知らせ1件ぶんのブロック。
class _NewsBlock extends StatefulWidget {
  const _NewsBlock({required this.time, required this.items});

  final String time;
  final List<DeveloperNewsModel> items;

  @override
  State<_NewsBlock> createState() => _NewsBlockState();
}

/// お知らせのブロックの状態（タップで内容の表示を切り替える）。
class _NewsBlockState extends State<_NewsBlock> {
  bool _isTapped = false;

  /// お知らせのブロックを表示する。タップすると内容を表示する。
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        setState(() {
          _isTapped = true;
        });
        widgetDisplayOverlay(
          context: context,
          tapPosition: details.globalPosition,
          displayDuration: const Duration(seconds: 3),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final DeveloperNewsModel item in widget.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: DefaultTextStyle(
                      style: const TextStyle(fontSize: 12, color: Colors.white),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(item.kind),
                          Text(
                            '（${(item.diffSeconds >= 60) ? '${item.diffSeconds ~/ 60}分${item.diffSeconds % 60}秒' : '${item.diffSeconds}秒'}）',
                          ),
                          Text(item.description),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
        Future<void>.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isTapped = false;
            });
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _isTapped
              ? Colors.green[800]!.withValues(alpha: 0.4)
              : widget.items.any((DeveloperNewsModel item) => item.diffSeconds <= 5)
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.blueAccent.withValues(alpha: 0.5),

          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.time,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.yellowAccent),
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ],
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////

/// カレンダーの罫線（曜日の区切りと1時間ごとの線）を描く。
class _NewsGridPainter extends CustomPainter {
  _NewsGridPainter({
    required this.startMinutes,
    required this.endMinutes,
    required this.pxPerMinute,
    required this.columnWidth,
    required this.columnCount,
  });

  final int startMinutes, endMinutes;
  final double pxPerMinute, columnWidth;
  final int columnCount;

  /// 曜日の区切り線と、1時間ごとの横線を描く。
  @override
  void paint(Canvas canvas, Size size) {
    final Paint vertLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (int i = 0; i <= columnCount; i++) {
      canvas.drawLine(Offset(i * columnWidth, 0), Offset(i * columnWidth, size.height), vertLine);
    }
  }

  /// 表示範囲や列の数が変わったときだけ描き直す。
  @override
  bool shouldRepaint(covariant _NewsGridPainter old) =>
      old.startMinutes != startMinutes ||
      old.endMinutes != endMinutes ||
      old.pxPerMinute != pxPerMinute ||
      old.columnWidth != columnWidth ||
      old.columnCount != columnCount;
}

/////////////////////////////////////////////////////////////////////////////////////////

/// カレンダー左端の時刻の目盛り。
class _TimeGutter extends StatelessWidget {
  const _TimeGutter({required this.startMinutes, required this.endMinutes, required this.pxPerMinute});

  final int startMinutes, endMinutes;
  final double pxPerMinute;

  /// 左端に時刻の目盛りを表示する。
  @override
  Widget build(BuildContext context) {
    final int startHour = startMinutes ~/ 60;
    final int endHour = endMinutes ~/ 60;
    return Stack(
      children: <Widget>[
        for (int h = startHour; h <= endHour; h++)
          Positioned(
            top: (h * 60 - startMinutes) * pxPerMinute - 7,
            left: 2,
            child: Column(
              children: <Widget>[
                Text(
                  '${(h % 24).toString().padLeft(2, '0')}:00',
                  style: const TextStyle(fontSize: 9, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////

/// 今の時刻を示す横線。
class _NowIndicatorLine extends StatelessWidget {
  const _NowIndicatorLine({required this.startMinutes, required this.endMinutes, required this.pxPerMinute});

  final int startMinutes, endMinutes;
  final double pxPerMinute;

  /// 今の時刻の位置に横線を表示する（表示範囲外のときは何も出さない）。
  @override
  Widget build(BuildContext context) {
    final TimeOfDay now = TimeOfDay.now();
    final int nowMinutes = now.hour * 60 + now.minute;
    if (nowMinutes < startMinutes || nowMinutes > endMinutes) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: (nowMinutes - startMinutes) * pxPerMinute,
      left: 0,
      right: 0,
      child: IgnorePointer(child: Container(height: 2, color: Colors.orangeAccent)),
    );
  }
}
