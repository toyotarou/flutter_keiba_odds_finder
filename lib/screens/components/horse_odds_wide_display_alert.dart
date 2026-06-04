import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../models/horse_model.dart';

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
    /*
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.waku,
    required this.num,
    required this.name,
    required this.horseUrl,
    required this.jockey,
    required this.trainer,


    */

    final String _ = '${appParamState.selectedScheduleDate}_${appParamState.selectedScheduleKaisuuBashoDay}';

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
                  children: <Widget>[Text('詳細情報'), SizedBox.shrink()],
                ),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                Text(widget.timing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
