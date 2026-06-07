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
  ///
  @override
  Widget build(BuildContext context) {
    final HorseModel? horse = widget.horse;
    final String mapKey = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';
    final int timingInt = int.tryParse(widget.timing) ?? 0;
    final int targetMinutes;
    if (widget.timing == '0') {
      targetMinutes = -999;
    } else if (timingInt == 24) {
      targetMinutes = 999;
    } else {
      targetMinutes = timingInt;
    }
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
                const SizedBox(height: 10),
                _displayJikuumaArea(horse: horse, ninkiMap: ninkiMap),
                const SizedBox(height: 10),
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
