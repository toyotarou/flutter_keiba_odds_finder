import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/horse_model.dart';
import '../../models/odds_model.dart';
import '../../models/odds_wide_model.dart';

class HorseOddsWideDisplayAlert extends ConsumerStatefulWidget {
  const HorseOddsWideDisplayAlert({super.key, required this.timing, this.horse});

  final String timing;
  final HorseModel? horse;

  @override
  ConsumerState<HorseOddsWideDisplayAlert> createState() => _HorseOddsWideDisplayAlertState();
}

class _HorseOddsWideDisplayAlertState extends ConsumerState<HorseOddsWideDisplayAlert>
    with ControllersMixin<HorseOddsWideDisplayAlert> {
  late String _selectedTiming;
  String _sortKey = 'num';
  bool _sortAsc = true;

  ///
  @override
  void initState() {
    super.initState();
    _selectedTiming = widget.timing;
  }

  ///
  int _toTargetMinutes(String timing) {
    final int timingInt = int.tryParse(timing) ?? 0;
    if (timing == '0') {
      return -999;
    }
    if (timingInt == 24) {
      return 999;
    }
    return timingInt;
  }

  ///
  @override
  Widget build(BuildContext context) {
    final HorseModel? horse = widget.horse;
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';
    final int targetMinutes = _toTargetMinutes(_selectedTiming);
    final int timingInt = int.tryParse(_selectedTiming) ?? 0;
    final int race = appParamState.selectedRaceNumber;

    final List<OddsModel> sortedTansho =
        (appParamState.keepOddsMap[mapKey] ?? <OddsModel>[])
            .where((OddsModel e) => e.race == race && e.minutesBeforeStart == targetMinutes)
            .toList()
          ..sort((OddsModel a, OddsModel b) => (double.tryParse(a.odds) ?? 0).compareTo(double.tryParse(b.odds) ?? 0));

    final Map<int, int> ninkiMap = <int, int>{for (int i = 0; i < sortedTansho.length; i++) sortedTansho[i].num: i + 1};

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontSize: 12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[const Text('ワイド情報'), Text(timingInt == 0 ? '出走時' : '$timingInt分前')],
                ),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                _displayTimingRow(),

                const SizedBox(height: 10),
                _displayJikuumaArea(horse: horse, ninkiMap: ninkiMap),
                const SizedBox(height: 10),

                _displaySortRow(),

                Divider(color: Colors.greenAccent.withValues(alpha: 0.4)),

                Expanded(
                  child: _displayWideOddsList(
                    horse: horse,
                    mapKey: mapKey,
                    targetMinutes: targetMinutes,
                    race: race,
                    ninkiMap: ninkiMap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _displaySortRow() {
    Widget sortButton({required String key, required String label}) {
      final bool isActive = _sortKey == key;
      final IconData icon = isActive ? (_sortAsc ? Icons.arrow_upward : Icons.arrow_downward) : Icons.swap_vert;
      final Color color = isActive ? Colors.greenAccent : Colors.white38;
      return GestureDetector(
        onTap: () => setState(() {
          if (_sortKey == key) {
            _sortAsc = !_sortAsc;
          } else {
            _sortKey = key;
            _sortAsc = true;
          }
        }),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 2),
            Text(label, style: TextStyle(color: isActive ? Colors.greenAccent : Colors.white54, fontSize: 11)),
            const SizedBox(width: 2),
            Icon(icon, color: color, size: 16),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              sortButton(key: 'num', label: '番号'),
              const SizedBox(width: 20),
              sortButton(key: 'ninki', label: '人気'),
            ],
          ),

          sortButton(key: 'oddsMin', label: 'オッズ最小'),
        ],
      ),
    );
  }

  ///
  Widget _displayTimingRow() {
    final List<String> timingParts = appParamState.configOddsGetTiming.split('|');

    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: timingParts.map((String t) {
            final bool isSelected = t == _selectedTiming;
            final String label = t == timingParts.first
                ? 'S'
                : t == timingParts.last
                ? 'E'
                : t;
            return GestureDetector(
              onTap: () => setState(() => _selectedTiming = t),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CircleAvatar(
                  backgroundColor: isSelected
                      ? Colors.greenAccent.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.4),
                  radius: 16,
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  ///
  Widget _displayJikuumaArea({required HorseModel? horse, required Map<int, int> ninkiMap}) {
    if (horse == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: <Widget>[
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: const Text(
              '軸馬',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.5))),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('${ninkiMap[horse.num] ?? 0}番人気'),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  SizedBox(width: 40, child: Text(horse.num.toString())),
                  Text(horse.name),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///
  Widget _displayWideOddsList({
    required HorseModel? horse,
    required String mapKey,
    required int targetMinutes,
    required int race,
    required Map<int, int> ninkiMap,
  }) {
    if (horse == null || appParamState.keepOddsWideMap[mapKey] == null || appParamState.keepHorseMap[mapKey] == null) {
      return const SizedBox.shrink();
    }

    final List<OddsWideModel> oddsWideModelList =
        appParamState.keepOddsWideMap[mapKey]!
            .where((OddsWideModel e) => e.race == race && e.minutesBeforeStart == targetMinutes)
            .toList()
          ..sort((OddsWideModel a, OddsWideModel b) {
            final int cmp = a.uma1.compareTo(b.uma1);
            return cmp != 0 ? cmp : a.uma2.compareTo(b.uma2);
          });

    final Map<int, String> horseNames = <int, String>{
      for (final HorseModel e in appParamState.keepHorseMap[mapKey]!.where((HorseModel e) => e.race == race))
        e.num: e.name,
    };

    final List<({int aiteNum, String aiteName, String oddsMin, String oddsMax})> aiteDataList = oddsWideModelList
        .where((OddsWideModel e) => e.uma1 == horse.num || e.uma2 == horse.num)
        .map((OddsWideModel e) {
          final int aiteNum = e.uma1 == horse.num ? e.uma2 : e.uma1;
          return (aiteNum: aiteNum, aiteName: horseNames[aiteNum] ?? '', oddsMin: e.oddsMin, oddsMax: e.oddsMax);
        })
        .toList();

    if (_sortKey == 'num') {
      aiteDataList.sort((
        ({String aiteName, int aiteNum, String oddsMax, String oddsMin}) a,
        ({String aiteName, int aiteNum, String oddsMax, String oddsMin}) b,
      ) {
        final int cmp = a.aiteNum.compareTo(b.aiteNum);
        return _sortAsc ? cmp : -cmp;
      });
    } else if (_sortKey == 'ninki') {
      aiteDataList.sort((
        ({String aiteName, int aiteNum, String oddsMax, String oddsMin}) a,
        ({String aiteName, int aiteNum, String oddsMax, String oddsMin}) b,
      ) {
        final int cmp = (ninkiMap[a.aiteNum] ?? 0).compareTo(ninkiMap[b.aiteNum] ?? 0);
        return _sortAsc ? cmp : -cmp;
      });
    } else {
      aiteDataList.sort((
        ({String aiteName, int aiteNum, String oddsMax, String oddsMin}) a,
        ({String aiteName, int aiteNum, String oddsMax, String oddsMin}) b,
      ) {
        final double aVal = double.tryParse(a.oddsMin) ?? 0;
        final double bVal = double.tryParse(b.oddsMin) ?? 0;
        final int cmp = aVal.compareTo(bVal);
        return _sortAsc ? cmp : -cmp;
      });
    }

    if (aiteDataList.isEmpty) {
      return const Center(
        child: Text('データがありません', style: TextStyle(color: Colors.white54, fontSize: 12)),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: aiteDataList.map((({String aiteName, int aiteNum, String oddsMax, String oddsMin}) e) {
          final int ninki = ninkiMap[e.aiteNum] ?? 0;
          return Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
            ),
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 40, child: Text('${e.aiteNum}', textAlign: TextAlign.center)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(e.aiteName),
                          Text('単勝人気：$ninki', style: const TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    SizedBox(width: 50, child: Text(e.oddsMin, textAlign: TextAlign.right)),
                    SizedBox(width: 50, child: Text(e.oddsMax, textAlign: TextAlign.right)),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
