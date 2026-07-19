import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/schedule_model.dart';

const int _kStartHour = 9;
const int _kEndHour = 17;
const double _kPxPerMinute = 2.0;
const double _kGutterWidth = 38.0;
const List<String> _kVenues = <String>['福島', '小倉', '函館'];

/////////////////////////////////////////////////////////////////////////////////////////

class WeekendRaceCalendarAlert extends ConsumerStatefulWidget {
  const WeekendRaceCalendarAlert({super.key});

  @override
  ConsumerState<WeekendRaceCalendarAlert> createState() => _WeekendRaceCalendarAlertState();
}

class _WeekendRaceCalendarAlertState extends ConsumerState<WeekendRaceCalendarAlert>
    with ControllersMixin<WeekendRaceCalendarAlert> {
  String _selectedDate = '2026-07-19';

  final ScrollController _gutterController = ScrollController();

  double get _gridHeight => (_kEndHour - _kStartHour) * 60 * _kPxPerMinute;

  @override
  void dispose() {
    _gutterController.dispose();
    super.dispose();
  }

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
              _buildDateButtons(),
              const SizedBox(height: 4),
              _buildVenueHeader(),
              Expanded(child: _buildCalendar()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateButtons() {
    return Row(
      children: <String>['2026-07-18', '2026-07-19'].map((String date) {
        final bool selected = _selectedDate == date;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: selected ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(date, style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVenueHeader() {
    return Row(
      children: <Widget>[
        const SizedBox(width: _kGutterWidth),
        ..._kVenues.map((String venue) {
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
              ),
              child: Text(
                venue,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ),
          );
        }),
      ],
    );
  }

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
            child: SizedBox(
              height: _gridHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: _kGutterWidth),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext ctx, BoxConstraints constraints) {
                        final double colW = constraints.maxWidth / 3;
                        return Stack(
                          children: <Widget>[
                            CustomPaint(
                              size: Size(constraints.maxWidth, _gridHeight),
                              painter: _RaceGridPainter(
                                startHour: _kStartHour,
                                endHour: _kEndHour,
                                pxPerMinute: _kPxPerMinute,
                                columnWidth: colW,
                              ),
                            ),
                            ..._buildRaceBlocks(colW),
                            const _NowIndicatorLine(
                              startHour: _kStartHour,
                              endHour: _kEndHour,
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
                child: const _TimeGutter(startHour: _kStartHour, endHour: _kEndHour, pxPerMinute: _kPxPerMinute),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onRaceTap(_RaceEntry entry) {
    final List<ScheduleModel>? schedules = appParamState.keepScheduleDateBashoMap[entry.date];
    final ScheduleModel? schedule = schedules?.where((ScheduleModel s) => s.bashoName == entry.venue).firstOrNull;
    if (schedule == null) {
      return;
    }
    appParamNotifier.setSelectedScheduleDate(date: entry.date);
    appParamNotifier.setSelectedScheduleKaisuuBashoDay(
      kbd: '${schedule.kaisuu}_${schedule.basho}_${schedule.day}',
      name: '${schedule.kaisuu}回 ${schedule.bashoName} ${schedule.day}日',
    );
    appParamNotifier.setSelectedRaceNumber(num: entry.race);
    appParamNotifier.setSelectedTiming(timing: '');
    Navigator.pop(context);
  }

  List<Widget> _buildRaceBlocks(double colW) {
    final List<Widget> widgets = <Widget>[];
    const double blockH = 30 * _kPxPerMinute;

    final List<_RaceEntry> races = _kRaces.where((_RaceEntry e) => e.date == _selectedDate).toList();

    for (final _RaceEntry entry in races) {
      final int venueIndex = _kVenues.indexOf(entry.venue);
      if (venueIndex < 0) {
        continue;
      }

      final double endTop = (entry.startMinutes - _kStartHour * 60) * _kPxPerMinute;
      final double top = (endTop - blockH).clamp(0.0, _gridHeight - blockH);
      final double left = venueIndex * colW;

      widgets.add(
        Positioned(
          top: top,
          left: left + 2,
          width: colW - 4,
          height: blockH,
          child: GestureDetector(
            onTap: () => _onRaceTap(entry),
            child: _RaceBlock(entry: entry),
          ),
        ),
      );
    }

    return widgets;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////

class _RaceBlock extends StatelessWidget {
  const _RaceBlock({required this.entry});

  final _RaceEntry entry;

  @override
  Widget build(BuildContext context) {
    final Color color = entry.surface == '芝' ? Colors.green : Colors.amber;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${entry.race}R  ${entry.startTime}',
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          Text(
            '${entry.surface}${entry.distance}m',
            style: TextStyle(fontSize: 7, color: Colors.white.withValues(alpha: 0.85)),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          Flexible(
            child: Text(
              entry.name,
              style: TextStyle(fontSize: 7, color: Colors.white.withValues(alpha: 0.7)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////

class _RaceGridPainter extends CustomPainter {
  _RaceGridPainter({
    required this.startHour,
    required this.endHour,
    required this.pxPerMinute,
    required this.columnWidth,
  });

  final int startHour, endHour;
  final double pxPerMinute, columnWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint hourLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    final Paint majorLine = Paint()
      ..color = Colors.yellowAccent.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    for (int h = startHour; h <= endHour; h++) {
      final double y = (h - startHour) * 60 * pxPerMinute;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), (h % 3 == 0) ? majorLine : hourLine);
    }

    final Paint vertLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 3; i++) {
      canvas.drawLine(Offset(i * columnWidth, 0), Offset(i * columnWidth, size.height), vertLine);
    }
  }

  @override
  bool shouldRepaint(covariant _RaceGridPainter old) =>
      old.startHour != startHour ||
      old.endHour != endHour ||
      old.pxPerMinute != pxPerMinute ||
      old.columnWidth != columnWidth;
}

/////////////////////////////////////////////////////////////////////////////////////////

class _TimeGutter extends StatelessWidget {
  const _TimeGutter({required this.startHour, required this.endHour, required this.pxPerMinute});

  final int startHour, endHour;
  final double pxPerMinute;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        for (int h = startHour; h <= endHour; h++)
          Positioned(
            top: (h - startHour) * 60 * pxPerMinute - 7,
            left: 2,
            child: Text(
              '${h.toString().padLeft(2, '0')}:00',
              style: const TextStyle(fontSize: 9, color: Colors.white70),
            ),
          ),
      ],
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////

class _NowIndicatorLine extends StatelessWidget {
  const _NowIndicatorLine({required this.startHour, required this.endHour, required this.pxPerMinute});

  final int startHour, endHour;
  final double pxPerMinute;

  @override
  Widget build(BuildContext context) {
    final TimeOfDay now = TimeOfDay.now();
    final int nowMinutes = now.hour * 60 + now.minute;
    final int s = startHour * 60;
    final int e = endHour * 60;
    if (nowMinutes < s || nowMinutes > e) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: (nowMinutes - s) * pxPerMinute,
      left: 0,
      right: 0,
      child: IgnorePointer(child: Container(height: 2, color: Colors.redAccent.withValues(alpha: 0.5))),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////////////////

class _RaceEntry {
  const _RaceEntry({
    required this.date,
    required this.venue,
    required this.race,
    required this.name,
    required this.surface,
    required this.distance,
    required this.startTime,
  });

  final String date;
  final String venue;
  final int race;
  final String name;
  final String surface;
  final int distance;
  final String startTime;

  int get startMinutes {
    final List<String> parts = startTime.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////

// ignore: prefer_const_declarations
const List<_RaceEntry> _kRaces = <_RaceEntry>[
  // 2026-07-18 函館
  _RaceEntry(
    date: '2026-07-18',
    venue: '函館',
    race: 1,
    name: '2歳未勝利（混合）［指定］',
    surface: '芝',
    distance: 1800,
    startTime: '09:50',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '函館',
    race: 2,
    name: '3歳未勝利牝［指定］',
    surface: 'ダート',
    distance: 1000,
    startTime: '10:20',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '函館',
    race: 3,
    name: '3歳未勝利（混合）［指定］',
    surface: 'ダート',
    distance: 2400,
    startTime: '10:50',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '函館',
    race: 4,
    name: '3歳未勝利[指定]',
    surface: '芝',
    distance: 1200,
    startTime: '11:20',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '函館',
    race: 5,
    name: '3歳未勝利[指定]',
    surface: 'ダート',
    distance: 1700,
    startTime: '12:10',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '函館',
    race: 6,
    name: '3歳未勝利[指定]',
    surface: '芝',
    distance: 1800,
    startTime: '12:40',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '函館',
    race: 7,
    name: '3歳以上1勝クラス（混合）［指定］',
    surface: 'ダート',
    distance: 1700,
    startTime: '13:10',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '函館',
    race: 8,
    name: '3歳以上1勝クラス（混合）（特指）',
    surface: '芝',
    distance: 2600,
    startTime: '13:40',
  ),
  _RaceEntry(date: '2026-07-18', venue: '函館', race: 9, name: '湯浜特別', surface: '芝', distance: 1800, startTime: '14:10'),
  _RaceEntry(date: '2026-07-18', venue: '函館', race: 10, name: '潮騒特別', surface: '芝', distance: 1200, startTime: '14:45'),
  _RaceEntry(
    date: '2026-07-18',
    venue: '函館',
    race: 11,
    name: 'マリーンステークス',
    surface: 'ダート',
    distance: 1700,
    startTime: '15:20',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '函館',
    race: 12,
    name: '3歳以上1勝クラス牝［指定］',
    surface: '芝',
    distance: 1200,
    startTime: '16:05',
  ),
  // 2026-07-18 小倉
  _RaceEntry(
    date: '2026-07-18',
    venue: '小倉',
    race: 1,
    name: '障害3歳以上未勝利（混合）',
    surface: '芝',
    distance: 2860,
    startTime: '09:55',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '小倉',
    race: 2,
    name: '2歳未勝利（混合）［指定］',
    surface: '芝',
    distance: 1800,
    startTime: '10:30',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '小倉',
    race: 3,
    name: '3歳未勝利（混合）［指定］',
    surface: 'ダート',
    distance: 1000,
    startTime: '11:00',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '小倉',
    race: 4,
    name: 'ソレイユジャンプS',
    surface: '芝',
    distance: 3390,
    startTime: '11:30',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '小倉',
    race: 5,
    name: 'メイクデビュー小倉',
    surface: '芝',
    distance: 1200,
    startTime: '12:20',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '小倉',
    race: 6,
    name: '3歳未勝利[指定]',
    surface: 'ダート',
    distance: 1700,
    startTime: '12:50',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '小倉',
    race: 7,
    name: '3歳未勝利（混合）［指定］',
    surface: '芝',
    distance: 1800,
    startTime: '13:20',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '小倉',
    race: 8,
    name: '3歳以上1勝クラス[指定]',
    surface: '芝',
    distance: 2000,
    startTime: '13:50',
  ),
  _RaceEntry(date: '2026-07-18', venue: '小倉', race: 9, name: 'ひまわり賞', surface: '芝', distance: 1200, startTime: '14:20'),
  _RaceEntry(
    date: '2026-07-18',
    venue: '小倉',
    race: 10,
    name: '熊本城特別',
    surface: 'ダート',
    distance: 1700,
    startTime: '14:55',
  ),
  _RaceEntry(date: '2026-07-18', venue: '小倉', race: 11, name: 'テレQ杯', surface: '芝', distance: 1200, startTime: '15:30'),
  _RaceEntry(
    date: '2026-07-18',
    venue: '小倉',
    race: 12,
    name: '3歳以上1勝クラス（混合）［指定］',
    surface: 'ダート',
    distance: 1700,
    startTime: '16:15',
  ),
  // 2026-07-18 福島
  _RaceEntry(
    date: '2026-07-18',
    venue: '福島',
    race: 1,
    name: '2歳未勝利（混合）［指定］',
    surface: '芝',
    distance: 1200,
    startTime: '10:05',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '福島',
    race: 2,
    name: '2歳未勝利[指定]',
    surface: '芝',
    distance: 1800,
    startTime: '10:40',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '福島',
    race: 3,
    name: '3歳未勝利[指定]',
    surface: 'ダート',
    distance: 1150,
    startTime: '11:10',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '福島',
    race: 4,
    name: '3歳未勝利（混合）［指定］',
    surface: '芝',
    distance: 1200,
    startTime: '11:40',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '福島',
    race: 5,
    name: 'メイクデビュー福島',
    surface: '芝',
    distance: 1800,
    startTime: '12:30',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '福島',
    race: 6,
    name: '3歳未勝利[指定]',
    surface: 'ダート',
    distance: 1700,
    startTime: '13:00',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '福島',
    race: 7,
    name: '3歳未勝利（混合）［指定］',
    surface: '芝',
    distance: 2000,
    startTime: '13:30',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '福島',
    race: 8,
    name: '3歳以上1勝クラス（混合）［指定］',
    surface: '芝',
    distance: 1200,
    startTime: '14:00',
  ),
  _RaceEntry(date: '2026-07-18', venue: '福島', race: 9, name: '開成山特別', surface: '芝', distance: 2600, startTime: '14:35'),
  _RaceEntry(
    date: '2026-07-18',
    venue: '福島',
    race: 10,
    name: '米沢特別',
    surface: 'ダート',
    distance: 1700,
    startTime: '15:10',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '福島',
    race: 11,
    name: '阿武隈ステークス',
    surface: '芝',
    distance: 1800,
    startTime: '15:45',
  ),
  _RaceEntry(
    date: '2026-07-18',
    venue: '福島',
    race: 12,
    name: '3歳以上1勝クラス（混合）［指定］',
    surface: 'ダート',
    distance: 1150,
    startTime: '16:30',
  ),
  // 2026-07-19 函館
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 1,
    name: '2歳未勝利（混合）［指定］',
    surface: '芝',
    distance: 1200,
    startTime: '09:50',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 2,
    name: '3歳未勝利[指定]',
    surface: 'ダート',
    distance: 1000,
    startTime: '10:20',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 3,
    name: '3歳未勝利[指定]',
    surface: 'ダート',
    distance: 1700,
    startTime: '10:50',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 4,
    name: '3歳未勝利（混合）［指定］',
    surface: '芝',
    distance: 2000,
    startTime: '11:20',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 5,
    name: 'メイクデビュー函館',
    surface: '芝',
    distance: 1800,
    startTime: '12:10',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 6,
    name: '3歳未勝利（混合）［指定］',
    surface: '芝',
    distance: 1200,
    startTime: '12:40',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 7,
    name: '3歳以上1勝クラス牝［指定］',
    surface: 'ダート',
    distance: 1700,
    startTime: '13:10',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 8,
    name: '3歳以上1勝クラス[指定]',
    surface: 'ダート',
    distance: 1000,
    startTime: '13:40',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 9,
    name: 'かもめ島特別',
    surface: '芝',
    distance: 1800,
    startTime: '14:10',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 10,
    name: '駒場特別',
    surface: 'ダート',
    distance: 1700,
    startTime: '14:45',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 11,
    name: '函館2歳ステークス',
    surface: '芝',
    distance: 1200,
    startTime: '15:20',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '函館',
    race: 12,
    name: '3歳以上1勝クラス（混合）（特指）',
    surface: '芝',
    distance: 1200,
    startTime: '16:05',
  ),
  // 2026-07-19 小倉
  _RaceEntry(
    date: '2026-07-19',
    venue: '小倉',
    race: 1,
    name: '障害3歳以上未勝利',
    surface: '芝',
    distance: 2860,
    startTime: '10:05',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '小倉',
    race: 2,
    name: '3歳未勝利[指定]',
    surface: '芝',
    distance: 1200,
    startTime: '10:40',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '小倉',
    race: 3,
    name: '3歳未勝利牝［指定］',
    surface: 'ダート',
    distance: 1700,
    startTime: '11:10',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '小倉',
    race: 4,
    name: '3歳未勝利[指定]',
    surface: '芝',
    distance: 2000,
    startTime: '11:40',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '小倉',
    race: 5,
    name: 'メイクデビュー小倉',
    surface: '芝',
    distance: 1800,
    startTime: '12:30',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '小倉',
    race: 6,
    name: '3歳未勝利（混合）［指定］',
    surface: 'ダート',
    distance: 1700,
    startTime: '13:00',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '小倉',
    race: 7,
    name: '3歳以上1勝クラス（混合）［指定］',
    surface: '芝',
    distance: 1200,
    startTime: '13:30',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '小倉',
    race: 8,
    name: '3歳以上1勝クラス（混合）［指定］',
    surface: 'ダート',
    distance: 1000,
    startTime: '14:00',
  ),
  _RaceEntry(date: '2026-07-19', venue: '小倉', race: 9, name: '不知火特別', surface: '芝', distance: 1800, startTime: '14:35'),
  _RaceEntry(
    date: '2026-07-19',
    venue: '小倉',
    race: 10,
    name: '宮崎ステークス',
    surface: 'ダート',
    distance: 1700,
    startTime: '15:10',
  ),
  _RaceEntry(date: '2026-07-19', venue: '小倉', race: 11, name: '小倉記念', surface: '芝', distance: 2000, startTime: '15:45'),
  _RaceEntry(date: '2026-07-19', venue: '小倉', race: 12, name: '筑紫特別', surface: '芝', distance: 1800, startTime: '16:30'),
  // 2026-07-19 福島
  _RaceEntry(
    date: '2026-07-19',
    venue: '福島',
    race: 1,
    name: '2歳未勝利（混合）［指定］',
    surface: 'ダート',
    distance: 1150,
    startTime: '09:55',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '福島',
    race: 2,
    name: '3歳未勝利牝［指定］',
    surface: '芝',
    distance: 2000,
    startTime: '10:30',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '福島',
    race: 3,
    name: '3歳未勝利[指定]',
    surface: '芝',
    distance: 1800,
    startTime: '11:00',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '福島',
    race: 4,
    name: '3歳未勝利牝［指定］',
    surface: 'ダート',
    distance: 1700,
    startTime: '11:30',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '福島',
    race: 5,
    name: 'メイクデビュー福島',
    surface: '芝',
    distance: 2000,
    startTime: '12:20',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '福島',
    race: 6,
    name: 'メイクデビュー福島',
    surface: '芝',
    distance: 1200,
    startTime: '12:50',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '福島',
    race: 7,
    name: '3歳未勝利（混合）［指定］',
    surface: 'ダート',
    distance: 1700,
    startTime: '13:20',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '福島',
    race: 8,
    name: '3歳以上1勝クラス[指定]',
    surface: '芝',
    distance: 1800,
    startTime: '13:50',
  ),
  _RaceEntry(date: '2026-07-19', venue: '福島', race: 9, name: '南相馬特別', surface: '芝', distance: 1200, startTime: '14:20'),
  _RaceEntry(
    date: '2026-07-19',
    venue: '福島',
    race: 10,
    name: '猪苗代特別',
    surface: '芝',
    distance: 2000,
    startTime: '14:55',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '福島',
    race: 11,
    name: '福島テレビ賞',
    surface: 'ダート',
    distance: 1150,
    startTime: '15:30',
  ),
  _RaceEntry(
    date: '2026-07-19',
    venue: '福島',
    race: 12,
    name: '3歳以上1勝クラス[指定]',
    surface: 'ダート',
    distance: 1700,
    startTime: '16:15',
  ),
];
