import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../models/horse_model.dart';
import '../../models/odds_model.dart';

class TotalForecastDisplayAlert extends ConsumerStatefulWidget {
  const TotalForecastDisplayAlert({
    super.key,
    required this.displayList,
    required this.horseModelMap,
    required this.numToRankMap,
    required this.raceNumber,
  });

  final List<OddsModel> displayList;
  final Map<int, HorseModel> horseModelMap;
  final Map<int, int> numToRankMap;
  final int raceNumber;

  @override
  ConsumerState<TotalForecastDisplayAlert> createState() => _TotalForecastDisplayAlertState();
}

class _TotalForecastDisplayAlertState extends ConsumerState<TotalForecastDisplayAlert>
    with ControllersMixin<TotalForecastDisplayAlert> {
  Set<int> _aiPickupNums = <int>{};

  static const Map<int, Color> _rankColors = <int, Color>{
    1: Color(0xFFFFD700),
    2: Color(0xFFC0C0C0),
    3: Color(0xFFCD7F32),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAiPickup());
  }

  Future<void> _fetchAiPickup() async {
    final String date = appParamState.selectedScheduleDate;
    final List<String> kbdParts = appParamState.selectedScheduleKaisuuBashoDay.split('_');
    final String kaisuu = kbdParts.isNotEmpty ? kbdParts[0] : '';
    final String basho = kbdParts.length > 1 ? kbdParts[1] : '';
    final String day = kbdParts.length > 2 ? kbdParts[2] : '';

    debugPrint(
      '[TotalForecast] fetch params: date=$date kaisuu=$kaisuu basho=$basho day=$day race=${widget.raceNumber}',
    );

    try {
      final dynamic response = await ref
          .read(httpClientProvider)
          .get(
            path: APIPath.getHorseOddsFinderAiAnalysis,
            queryParameters: <String, dynamic>{
              'date': date,
              'kaisuu': kaisuu,
              'basho': basho,
              'day': day,
              'race': widget.raceNumber.toString(),
            },
          );

      debugPrint('[TotalForecast] response: $response');

      final Map<String, dynamic> data =
          (response as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
      final String pickupRaw = (data['pickup_horse'] as String?) ?? '';

      debugPrint('[TotalForecast] pickup_horse raw: $pickupRaw');

      Set<int> nums = <int>{};

      if (pickupRaw.isNotEmpty) {
        for (final String part in pickupRaw.split('/')) {
          final String trimmed = part.trim();
          if (trimmed.isEmpty) {
            continue;
          }
          final int? num = int.tryParse(trimmed.split('|').first.trim());
          if (num != null) {
            nums.add(num);
          }
        }
      } else {
        final String analysisText = (data['analysis_text'] as String?) ?? '';
        nums = _parsePickupFromAnalysis(analysisText);
      }

      debugPrint('[TotalForecast] parsed pickup nums: $nums');

      if (mounted) {
        setState(() => _aiPickupNums = nums);
      }
    } catch (e) {
      debugPrint('[TotalForecast] error: $e');
    }
  }

  Set<int> _parsePickupFromAnalysis(String analysisText) {
    final int sec1Start = analysisText.indexOf('## 1.');
    final int sec2Start = analysisText.indexOf('## 2.');
    if (sec1Start == -1) {
      return <int>{};
    }
    final String section1 = sec2Start != -1
        ? analysisText.substring(sec1Start, sec2Start)
        : analysisText.substring(sec1Start);
    final RegExp numPattern = RegExp(r'（(\d+)番）');
    final Set<int> nums = <int>{};
    for (final RegExpMatch m in numPattern.allMatches(section1)) {
      final int? num = int.tryParse(m.group(1) ?? '');
      if (num != null) {
        nums.add(num);
      }
    }
    return nums;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: widget.displayList.length,
        itemBuilder: (BuildContext context, int index) {
          final OddsModel item = widget.displayList[index];
          final int popularity = index + 1;
          final String horseName = widget.horseModelMap[item.num]?.name ?? '';
          final int? rank = widget.numToRankMap[item.num];
          final bool isAiPickup = _aiPickupNums.contains(item.num);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 13, color: Colors.white),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 30, child: Text(popularity.toString())),
                  SizedBox(width: 40, child: Text(item.num.toString())),
                  Expanded(child: Text(horseName, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 60, child: Text(item.odds)),

                  SizedBox(
                    width: 40,
                    child: rank != null
                        ? Text(
                            '$rank着',
                            style: TextStyle(
                              fontSize: 13,
                              color: _rankColors[rank] ?? Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  SizedBox(
                    width: 36,
                    child: isAiPickup
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFFFD700)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'AI',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 10, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
