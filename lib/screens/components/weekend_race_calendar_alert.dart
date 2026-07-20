import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_param/app_param.dart';
import '../../controllers/controllers_mixin.dart';
import '../../models/race_model.dart';
import '../../models/schedule_model.dart';

const int _kStartHour = 9;
const int _kEndHour = 17;
const double _kPxPerMinute = 2.0;
const double _kGutterWidth = 38.0;

/////////////////////////////////////////////////////////////////////////////////////////

class WeekendRaceCalendarAlert extends ConsumerStatefulWidget {
  const WeekendRaceCalendarAlert({super.key});

  @override
  ConsumerState<WeekendRaceCalendarAlert> createState() => _WeekendRaceCalendarAlertState();
}

class _WeekendRaceCalendarAlertState extends ConsumerState<WeekendRaceCalendarAlert>
    with ControllersMixin<WeekendRaceCalendarAlert> {
  String _selectedDate = '';

  final ScrollController _gutterController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = ref.read(appParamProvider).selectedScheduleDate;
  }

  double get _gridHeight => (_kEndHour - _kStartHour) * 60 * _kPxPerMinute;

  List<String> get _dates {
    final List<String> list = appParamState.keepScheduleDateBashoMap.keys.toList()..sort();
    return list;
  }

  String get _effectiveDate {
    final List<String> d = _dates;
    if (d.isEmpty) return '';
    return d.contains(_selectedDate) ? _selectedDate : d.first;
  }

  List<ScheduleModel> get _schedulesForDate =>
      appParamState.keepScheduleDateBashoMap[_effectiveDate] ?? <ScheduleModel>[];

  List<RaceModel> _racesForSchedule(ScheduleModel schedule) {
    final String key = '${schedule.date}_${schedule.kaisuu}_${schedule.basho}_${schedule.day}';
    return appParamState.keepRaceMap[key] ?? <RaceModel>[];
  }

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
    final List<String> dates = _dates;
    final String appSelected = appParamState.selectedScheduleDate;
    return Row(
      children: dates.map((String date) {
        final bool isAppSelected = date == appSelected;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isAppSelected ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.5),
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
    final List<ScheduleModel> schedules = _schedulesForDate;
    return Row(
      children: <Widget>[
        const SizedBox(width: _kGutterWidth),
        ...schedules.map((ScheduleModel s) {
          final bool isVenueSelected =
              s.date == appParamState.selectedScheduleDate &&
              '${s.kaisuu}_${s.basho}_${s.day}' == appParamState.selectedScheduleKaisuuBashoDay;
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isVenueSelected
                      ? Colors.greenAccent.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  s.bashoName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCalendar() {
    final List<ScheduleModel> schedules = _schedulesForDate;
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
                        final int count = schedules.isEmpty ? 1 : schedules.length;
                        final double colW = constraints.maxWidth / count;
                        return Stack(
                          children: <Widget>[
                            CustomPaint(
                              size: Size(constraints.maxWidth, _gridHeight),
                              painter: _RaceGridPainter(
                                startHour: _kStartHour,
                                endHour: _kEndHour,
                                pxPerMinute: _kPxPerMinute,
                                columnWidth: colW,
                                columnCount: count,
                              ),
                            ),
                            ..._buildRaceBlocks(colW, schedules),
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

  void _onRaceTap(RaceModel race) {
    appParamNotifier.setSelectedScheduleDate(date: race.date);
    appParamNotifier.setSelectedScheduleKaisuuBashoDay(
      kbd: '${race.kaisuu}_${race.basho}_${race.day}',
      name: '${race.kaisuu}回 ${race.bashoName} ${race.day}日',
    );
    appParamNotifier.setSelectedRaceNumber(num: race.race);
    appParamNotifier.setSelectedTiming(timing: '');
    Navigator.pop(context);
  }

  List<Widget> _buildRaceBlocks(double colW, List<ScheduleModel> schedules) {
    final List<Widget> widgets = <Widget>[];
    const double blockH = 30 * _kPxPerMinute;

    final String appDate = appParamState.selectedScheduleDate;
    final String appKbd = appParamState.selectedScheduleKaisuuBashoDay;
    final int appRaceNum = appParamState.selectedRaceNumber;

    for (int i = 0; i < schedules.length; i++) {
      final ScheduleModel schedule = schedules[i];
      final List<RaceModel> races = _racesForSchedule(schedule);

      for (final RaceModel race in races) {
        final List<String> parts = race.startTime.split(':');
        if (parts.length < 2) continue;
        final int startMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);

        final double endTop = (startMinutes - _kStartHour * 60) * _kPxPerMinute;
        final double top = (endTop - blockH).clamp(0.0, _gridHeight - blockH);
        final double left = i * colW;

        final bool isSelected =
            race.date == appDate && '${race.kaisuu}_${race.basho}_${race.day}' == appKbd && race.race == appRaceNum;

        widgets.add(
          Positioned(
            top: top,
            left: left + 2,
            width: colW - 4,
            height: blockH,
            child: GestureDetector(
              onTap: () => _onRaceTap(race),
              child: _RaceBlock(race: race, isSelected: isSelected),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////

class _RaceBlock extends StatelessWidget {
  const _RaceBlock({required this.race, required this.isSelected});

  final RaceModel race;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${race.race}R  ${race.startTime}',
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          Text(
            '${race.course}${race.dist}m',
            style: TextStyle(fontSize: 7, color: Colors.white.withValues(alpha: 0.85)),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
          Flexible(
            child: Text(
              race.raceName,
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
    required this.columnCount,
  });

  final int startHour, endHour;
  final double pxPerMinute, columnWidth;
  final int columnCount;

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

    for (int i = 0; i <= columnCount; i++) {
      canvas.drawLine(Offset(i * columnWidth, 0), Offset(i * columnWidth, size.height), vertLine);
    }
  }

  @override
  bool shouldRepaint(covariant _RaceGridPainter old) =>
      old.startHour != startHour ||
      old.endHour != endHour ||
      old.pxPerMinute != pxPerMinute ||
      old.columnWidth != columnWidth ||
      old.columnCount != columnCount;
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
