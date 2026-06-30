import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../models/race_result_history_model.dart';
import '../parts/race_top_three_widget.dart';

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
                                return _DateGroupExpansionTile(group: groups[index]);
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

///
class _DateGroupExpansionTile extends StatefulWidget {
  const _DateGroupExpansionTile({required this.group});

  final List<RaceResultHistoryModel> group;

  @override
  State<_DateGroupExpansionTile> createState() => _DateGroupExpansionTileState();
}

class _DateGroupExpansionTileState extends State<_DateGroupExpansionTile> {
  bool _isExpanded = false;

  ///
  @override
  Widget build(BuildContext context) {
    final RaceResultHistoryModel head = widget.group.first;
    return ExpansionTile(
      dense: true,
      collapsedIconColor: Colors.white54,
      iconColor: Colors.white70,
      shape: const Border(),
      collapsedShape: const Border(),
      onExpansionChanged: (bool expanded) => setState(() => _isExpanded = expanded),
      title: Container(
        decoration: BoxDecoration(
          border: _isExpanded
              ? Border(bottom: BorderSide(color: Colors.greenAccent.withValues(alpha: 0.3), width: 2))
              : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2)),
        ),
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: <Widget>[
            Text(
              '${head.date.split('-')[1]}-${head.date.split('-')[2]}',
              style: const TextStyle(fontSize: 12, color: Colors.greenAccent),
            ),
            const SizedBox(width: 10),
            Text(
              '${head.kaisuu}回 ${head.basho} ${head.day}日目',
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
      ),
      children: widget.group.map((RaceResultHistoryModel item) => _RaceExpansionTile(item: item)).toList(),
    );
  }
}

///
class _RaceExpansionTile extends ConsumerStatefulWidget {
  const _RaceExpansionTile({required this.item});

  final RaceResultHistoryModel item;

  @override
  ConsumerState<_RaceExpansionTile> createState() => _RaceExpansionTileState();
}

class _RaceExpansionTileState extends ConsumerState<_RaceExpansionTile> {
  Future<List<RaceResultHistoryModel>>? _future;
  bool _isExpanded = false;

  ///
  Future<List<RaceResultHistoryModel>> _fetch() async {
    final RaceResultHistoryModel m = widget.item;
    final HttpClient client = ref.read(httpClientProvider);

    final dynamic value = await client.get(
      path: APIPath.getHorseOddsFinderRaceResultHistoryRaceContents,
      queryParameters: <String, dynamic>{
        'date': m.date,
        'kaisuu': m.kaisuu.toString(),
        'basho_code': m.bashoCode,
        'day': m.day.toString(),
        'race': m.race.toString(),
      },
    );

    // ignore: avoid_dynamic_calls
    final List<dynamic> data = value['data'] as List<dynamic>;
    final List<RaceResultHistoryModel> list = data
        .map((dynamic e) => RaceResultHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort(
      (RaceResultHistoryModel a, RaceResultHistoryModel b) => a.finishingPosition.compareTo(b.finishingPosition),
    );
    return list;
  }

  ///
  @override
  Widget build(BuildContext context) {
    final RaceResultHistoryModel m = widget.item;

    return ExpansionTile(
      dense: true,
      collapsedIconColor: Colors.white38,
      iconColor: Colors.white60,
      tilePadding: const EdgeInsets.only(left: 16, right: 8),
      title: Row(
        children: <Widget>[
          Icon(Icons.double_arrow_sharp, color: _isExpanded ? Colors.green : Colors.white),

          const SizedBox(width: 10),

          SizedBox(
            width: 32,
            child: Text('R${m.race}', style: const TextStyle(fontSize: 12, color: Colors.greenAccent)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              m.raceName,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      onExpansionChanged: (bool expanded) {
        setState(() => _isExpanded = expanded);
        if (expanded && _future == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final Future<List<RaceResultHistoryModel>> f = _fetch();
              setState(() {
                _future = f;
              });
            }
          });
        }
      },
      children: <Widget>[
        FutureBuilder<List<RaceResultHistoryModel>>(
          future: _future,
          builder: (BuildContext context, AsyncSnapshot<List<RaceResultHistoryModel>> snapshot) {
            if (snapshot.connectionState == ConnectionState.none) {
              return const SizedBox.shrink();
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Text('エラー: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
              );
            }
            final List<RaceResultHistoryModel> horses = snapshot.data ?? <RaceResultHistoryModel>[];
            final Map<int, RaceTopThreeEntry> entries = <int, RaceTopThreeEntry>{
              for (final RaceResultHistoryModel h in horses)
                h.finishingPosition: RaceTopThreeEntry(
                  num: h.num,
                  name: h.name,
                  odds: double.tryParse(h.tan)?.toStringAsFixed(1) ?? h.tan,
                  popularity: h.popularityRank,
                ),
            };
            return RaceTopThreeWidget(entries: entries);
          },
        ),
      ],
    );
  }
}
