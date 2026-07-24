// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../controllers/controllers_mixin.dart';
// import '../../models/summary_model.dart';
// import '../parts/odds_up_down_icon.dart';
//
// class HorseOddsRecordDisplayAlert extends ConsumerStatefulWidget {
//   const HorseOddsRecordDisplayAlert({super.key, required this.horseName});
//
//   final String horseName;
//
//   @override
//   ConsumerState<HorseOddsRecordDisplayAlert> createState() => _HorseOddsRecordDisplayAlertState();
// }
//
// class _HorseOddsRecordDisplayAlertState extends ConsumerState<HorseOddsRecordDisplayAlert>
//     with ControllersMixin<HorseOddsRecordDisplayAlert> {
//   ///
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: SafeArea(
//         child: DefaultTextStyle(
//           style: const TextStyle(color: Colors.white),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[const Text('オッズ履歴'), Text(widget.horseName)],
//                 ),
//                 Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),
//
//                 Expanded(child: _displayOddsRecordList()),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   ///
//   Widget _displayOddsRecordList() {
//     final List<Widget> list = <Widget>[];
//
//     final List<String> timingLabels = appParamState.configOddsGetTiming.isEmpty
//         ? <String>[]
//         : appParamState.configOddsGetTiming.split('|');
//
//     final Map<String, String Function(SummaryModel)> oddsGetterByLabel = <String, String Function(SummaryModel)>{
//       '30': (SummaryModel m) => m.oddsTanBefore30,
//       '21': (SummaryModel m) => m.oddsTanBefore21,
//       '18': (SummaryModel m) => m.oddsTanBefore18,
//       '15': (SummaryModel m) => m.oddsTanBefore15,
//       '12': (SummaryModel m) => m.oddsTanBefore12,
//       '9': (SummaryModel m) => m.oddsTanBefore9,
//       '6': (SummaryModel m) => m.oddsTanBefore6,
//       '3': (SummaryModel m) => m.oddsTanBefore3,
//       '0': (SummaryModel m) => m.oddsTanBefore0,
//     };
//
//     final List<SummaryModel> matched =
//         appParamState.keepSummaryMap.values
//             .expand((List<SummaryModel> v) => v)
//             .where((SummaryModel e) => e.horseName == widget.horseName)
//             .toList()
//           ..sort((SummaryModel a, SummaryModel b) => b.date.compareTo(a.date));
//
//     for (final SummaryModel element in matched) {
//       final List<String> odds = timingLabels
//           .map((String label) => (oddsGetterByLabel[label] ?? (SummaryModel _) => '')(element))
//           .toList();
//
//       list.add(
//         DefaultTextStyle(
//           style: const TextStyle(fontSize: 12, color: Colors.greenAccent),
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.5))),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Text(element.date),
//                 Text(element.raceName),
//                 SizedBox(
//                   height: 70,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: odds.asMap().entries.map((MapEntry<int, String> entry) {
//                         // 直前の空でない値を探す
//                         String? prevOdds;
//                         for (int i = entry.key - 1; i >= 0; i--) {
//                           if (odds[i].isNotEmpty && odds[i] != '0') {
//                             prevOdds = odds[i];
//                             break;
//                           }
//                         }
//
//                         return Stack(
//                           children: <Widget>[
//                             Positioned(right: 10, bottom: 0, child: Text(timingLabels[entry.key])),
//
//                             Positioned(
//                               right: 5,
//                               top: 0,
//                               child: OddsUpDownIcon(current: entry.value, prev: prevOdds),
//                             ),
//
//                             Container(
//                               margin: const EdgeInsets.symmetric(horizontal: 5),
//                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.6)),
//                               ),
//                               child: Text(entry.value, style: const TextStyle(color: Colors.white)),
//                             ),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     return SingleChildScrollView(child: Column(children: list));
//   }
// }
