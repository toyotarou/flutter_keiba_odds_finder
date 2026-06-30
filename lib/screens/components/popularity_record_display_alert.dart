import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/popularity_rank_odds_average_model.dart';
import '../../models/race_result_history_model.dart';
import '../parts/error_confirm_dialog.dart';

class PopularityRecordDisplayAlert extends ConsumerStatefulWidget {
  const PopularityRecordDisplayAlert({super.key});

  @override
  ConsumerState<PopularityRecordDisplayAlert> createState() => _PopularityRecordDisplayAlertState();
}

class _PopularityRecordDisplayAlertState extends ConsumerState<PopularityRecordDisplayAlert>
    with ControllersMixin<PopularityRecordDisplayAlert> {
  Future<List<RaceResultHistoryModel>>? _future;

  Future<List<RaceResultHistoryModel>> _fetch({required int rank, required int year}) async {
    final HttpClient client = ref.read(httpClientProvider);
    final dynamic value = await client.get(
      path: APIPath.getHorseOddsFinderRaceResultHistory,
      queryParameters: <String, dynamic>{'year': year.toString(), 'popularity_rank': rank.toString()},
    );
    final List<dynamic> data = value['data'] as List<dynamic>;
    return data.map((dynamic e) => RaceResultHistoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  ///
  @override
  Widget build(BuildContext context) {
    final int selectedRank = appParamState.selectedPopularityRank;
    final String selectedYear = appParamState.selectedPopularityRankYear;

    final PopularityRankOddsAverageModel? popularityRankOddsAverageModel =
        appParamState.keepPopularityRankOddsAverageMap[selectedRank];

    List<int> yearList = [];
    for (int i = 2023; i <= DateTime.now().year; i++) {
      yearList.add(i);
    }

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
                const Text('過去オッズレコード', style: TextStyle(fontSize: 12)),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                Container(
                  width: double.infinity,
                  height: context.screenSize.height * 0.2,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: <Widget>[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          // ignore: always_specify_types
                          children: List.generate(
                            18,
                            (int index) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                              child: GestureDetector(
                                onTap: () {
                                  final int newRank = index + 1;
                                  appParamNotifier.setSelectedPopularityRank(rank: newRank);

                                  if (selectedYear.isNotEmpty) {
                                    setState(() {
                                      _future = _fetch(rank: newRank, year: int.parse(selectedYear));
                                    });
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: (selectedRank == index + 1)
                                      ? Colors.green[500]!.withValues(alpha: 0.4)
                                      : Colors.black.withValues(alpha: 0.8),
                                  child: Text(
                                    (index + 1).toString(),
                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: Text(
                                (popularityRankOddsAverageModel != null)
                                    ? '${popularityRankOddsAverageModel.startDate} 〜 ${popularityRankOddsAverageModel.endDate}'
                                    : '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),

                            Positioned(
                              top: 5,
                              left: 5,
                              child: Text(
                                (popularityRankOddsAverageModel != null)
                                    ? '${popularityRankOddsAverageModel.count}回の平均'
                                    : '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),

                            Center(
                              child: Text(
                                (popularityRankOddsAverageModel != null)
                                    ? popularityRankOddsAverageModel.oddsAverage
                                    : '-----',
                                style: const TextStyle(fontSize: 50, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: yearList.map((e) {
                      return TextButton(
                        onPressed: () {
                          if (selectedRank == 0) {
                            errorConfirmDialog(context: context, title: 'エラー', content: 'リストを表示する人気順が選択されていません。');
                            return;
                          }

                          appParamNotifier.setSelectedPopularityRankYear(year: e.toString());

                          setState(() {
                            _future = _fetch(rank: selectedRank, year: e);
                          });
                        },
                        child: Text(
                          e.toString(),
                          style: TextStyle(color: (selectedYear == e.toString()) ? Colors.greenAccent : Colors.grey),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Expanded(
                  child: FutureBuilder<List<RaceResultHistoryModel>>(
                    future: _future,
                    builder: (BuildContext context, AsyncSnapshot<List<RaceResultHistoryModel>> snapshot) {
                      if (_future == null) {
                        return const SizedBox.shrink();
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'エラー: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        );
                      }

                      final List<RaceResultHistoryModel> list = snapshot.data ?? [];

                      if (list.isEmpty) {
                        return const Center(
                          child: Text('データなし', style: TextStyle(color: Colors.white)),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('件数: ${list.length}', style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
                          Expanded(
                            child: ListView.builder(
                              itemCount: list.length,
                              itemBuilder: (BuildContext context, int index) {
                                final RaceResultHistoryModel item = list[index];
                                return Text(
                                  '${item.date}  ${item.name}  単:${item.tan}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                );
                              },
                            ),
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
    );
  }
}
