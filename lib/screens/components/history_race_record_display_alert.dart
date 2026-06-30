import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../models/race_result_history_model.dart';

class HistoryRaceRecordDisplayAlert extends ConsumerStatefulWidget {
  const HistoryRaceRecordDisplayAlert({super.key});

  @override
  ConsumerState<HistoryRaceRecordDisplayAlert> createState() => _HistoryRaceRecordDisplayAlertState();
}

class _HistoryRaceRecordDisplayAlertState extends ConsumerState<HistoryRaceRecordDisplayAlert>
    with ControllersMixin<HistoryRaceRecordDisplayAlert> {
  Future<List<RaceResultHistoryModel>>? _future;

  ///
  Future<List<RaceResultHistoryModel>> _fetch({required int year}) async {
    final HttpClient client = ref.read(httpClientProvider);

    final dynamic value = await client.get(
      path: APIPath.getHorseOddsFinderRaceResultHistoryRaceList,
      queryParameters: <String, dynamic>{'year': year.toString()},
    );

    // ignore: avoid_dynamic_calls
    final List<dynamic> data = value['data'] as List<dynamic>;
    return data.map((dynamic e) => RaceResultHistoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  ///
  @override
  Widget build(BuildContext context) {
    final List<int> yearList = List<int>.generate(DateTime.now().year - 2022, (int i) => 2023 + i);
    final String selectedYear = appParamState.selectedHistoryYear;

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
                const Text('過去データ', style: TextStyle(fontSize: 12)),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: yearList.map((int year) {
                      return TextButton(
                        onPressed: () {
                          appParamNotifier.setSelectedHistoryYear(year: year.toString());
                          setState(() {
                            _future = _fetch(year: year);
                          });
                        },
                        child: Text(
                          year.toString(),
                          style: TextStyle(color: (selectedYear == year.toString()) ? Colors.greenAccent : Colors.grey),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Expanded(
                  child: _future == null
                      ? const Center(
                          child: Text('年を選択してください', style: TextStyle(color: Colors.grey)),
                        )
                      : FutureBuilder<List<RaceResultHistoryModel>>(
                          future: _future,
                          builder: (BuildContext context, AsyncSnapshot<List<RaceResultHistoryModel>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('エラー: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)),
                              );
                            }
                            final List<RaceResultHistoryModel> list = snapshot.data ?? <RaceResultHistoryModel>[];
                            if (list.isEmpty) {
                              return const Center(
                                child: Text('データがありません', style: TextStyle(color: Colors.grey)),
                              );
                            }
                            // (date, kaisuu, bashoCode, day) でグループ化（挿入順を維持）
                            final Map<String, List<RaceResultHistoryModel>> grouped =
                                <String, List<RaceResultHistoryModel>>{};
                            for (final RaceResultHistoryModel item in list) {
                              final String key = '${item.date}_${item.kaisuu}_${item.bashoCode}_${item.day}';
                              grouped.putIfAbsent(key, () => <RaceResultHistoryModel>[]).add(item);
                            }
                            final List<List<RaceResultHistoryModel>> groups = grouped.values.toList();

                            return ListView.builder(
                              itemCount: groups.length,
                              itemBuilder: (BuildContext context, int index) {
                                final List<RaceResultHistoryModel> group = groups[index];
                                final RaceResultHistoryModel head = group.first;
                                return ExpansionTile(
                                  dense: true,
                                  collapsedIconColor: Colors.white54,
                                  iconColor: Colors.white70,
                                  title: Row(
                                    children: <Widget>[
                                      Text(head.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${head.kaisuu}回 ${head.basho} ${head.day}日目',
                                        style: const TextStyle(fontSize: 13, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  children: group.map((RaceResultHistoryModel item) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 16, bottom: 6),
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 32,
                                            child: Text(
                                              'R${item.race}',
                                              style: const TextStyle(fontSize: 12, color: Colors.greenAccent),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              item.raceName,
                                              style: const TextStyle(fontSize: 12, color: Colors.white),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
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
