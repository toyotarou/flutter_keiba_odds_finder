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
  final ScrollController _calendarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final AppParamState appParam = ref.read(appParamProvider);
    _selectedDate = appParam.selectedScheduleDate;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedRace(appParam));
  }

  void _scrollToSelectedRace(AppParamState appParam) {
    if (!_calendarScrollController.hasClients) return;
    final String key = '${appParam.selectedScheduleDate}_${appParam.selectedScheduleKaisuuBashoDay}';
    final List<RaceModel> races = appParam.keepRaceMap[key] ?? <RaceModel>[];
    final RaceModel? race = races.where((RaceModel r) => r.race == appParam.selectedRaceNumber).firstOrNull;
    if (race == null) return;
    final List<String> parts = race.startTime.split(':');
    if (parts.length < 2) return;
    final int startMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    const double blockH = 30 * _kPxPerMinute;
    final double top = ((startMinutes - _kStartHour * 60) * _kPxPerMinute - blockH).clamp(
      0.0,
      _calendarScrollController.position.maxScrollExtent,
    );
    _calendarScrollController.animateTo(top, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  double get _gridHeight => (_kEndHour - _kStartHour) * 60 * _kPxPerMinute;

  List<String> get _dates {
    final List<String> list = appParamState.keepScheduleDateBashoMap.keys.toList()..sort();
    return list;
  }

  String get _effectiveDate {
    final List<String> d = _dates;
    if (d.isEmpty) {
      return '';
    }
    return d.contains(_selectedDate) ? _selectedDate : d.first;
  }

  List<ScheduleModel> get _schedulesForDate {
    final List<ScheduleModel> list = List<ScheduleModel>.from(
      appParamState.keepScheduleDateBashoMap[_effectiveDate] ?? <ScheduleModel>[],
    );
    list.sort((ScheduleModel a, ScheduleModel b) => a.basho.compareTo(b.basho));
    return list;
  }

  List<RaceModel> _racesForSchedule(ScheduleModel schedule) {
    final String key = '${schedule.date}_${schedule.kaisuu}_${schedule.basho}_${schedule.day}';
    return appParamState.keepRaceMap[key] ?? <RaceModel>[];
  }

  @override
  void dispose() {
    _gutterController.dispose();
    _calendarScrollController.dispose();
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
    final String effective = _effectiveDate;
    return Row(
      children: dates.map((String date) {
        final bool isAppSelected = date == effective;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isAppSelected ? Colors.green[800]!.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.5),
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
                      ? Colors.green[800]!.withValues(alpha: 0.4)
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
        if (parts.length < 2) {
          continue;
        }
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
    return Stack(
      children: <Widget>[
        Positioned(bottom: 5, right: 5, child: Text('${race.race}R')),

        Positioned(
          bottom: -2,
          left: 0,
          right: 0,
          child: Column(
            children: <Widget>[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(Icons.arrow_downward, color: Colors.yellowAccent, size: 20),
                  SizedBox.shrink(),
                ],
              ),
              Container(height: 5, color: Colors.yellowAccent.withValues(alpha: 0.5)),
            ],
          ),
        ),

        Container(
          width: double.infinity,
          height: double.infinity,

          decoration: BoxDecoration(
            color: isSelected ? Colors.green[800]!.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.5),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(3),
          ),

          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${race.startTime.split(':')[0]}:${race.startTime.split(':')[1]}',

                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),

              Flexible(
                child: Text(
                  race.raceName,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Text(
                '${race.course}${race.dist}m',
                style: const TextStyle(fontSize: 8, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ],
          ),
        ),
      ],
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
    final Paint majorLine = Paint()..color = Colors.transparent;

    for (int h = startHour; h <= endHour; h++) {
      final double y = (h - startHour) * 60 * pxPerMinute;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), (h % 3 == 0) ? majorLine : majorLine);
    }

    final Paint vertLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;

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
              style: const TextStyle(fontSize: 9, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
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
      child: IgnorePointer(child: Container(height: 2, color: Colors.orangeAccent)),
    );
  }
}
