import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../models/race_result_history_model.dart';

class HorseNameInitialPanelAlert extends ConsumerStatefulWidget {
  const HorseNameInitialPanelAlert({super.key});

  @override
  ConsumerState<HorseNameInitialPanelAlert> createState() => _HorseNameInitialPanelAlertState();
}

class _HorseNameInitialPanelAlertState extends ConsumerState<HorseNameInitialPanelAlert>
    with ControllersMixin<HorseNameInitialPanelAlert> {
  final ScrollController _kanaScrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();

  List<String>? _names;
  bool _loading = false;
  String? _error;

  final Map<int, List<RaceResultHistoryModel>> _battleRecords = <int, List<RaceResultHistoryModel>>{};
  final Map<int, bool> _battleLoading = <int, bool>{};
  final Map<int, bool> _expandedStates = <int, bool>{};
  final Map<int, GlobalKey> _itemKeys = <int, GlobalKey>{};

  static const double _cellSize = 40;

  // 左から右へ: 半濁音 → 濁音(+ヴ) → ン → 清音（右端がア行）
  // 上から下へ: ア段 → オ段
  static const List<List<String>> _kanaColumns = <List<String>>[
    <String>['パ', 'ピ', 'プ', 'ペ', 'ポ'], // 半濁音
    <String>['バ', 'ビ', 'ブ', 'ベ', 'ボ'], // 濁音
    <String>['ダ', 'ヂ', 'ヅ', 'デ', 'ド'],
    <String>['ザ', 'ジ', 'ズ', 'ゼ', 'ゾ'],
    <String>['ガ', 'ギ', 'グ', 'ゲ', 'ゴ'],
    <String>['ヴ', '', '', '', ''], // ヴ単独列
    <String>['ン', '', '', '', ''], // ン単独列
    <String>['ワ', '', '', '', 'ヲ'], // 清音
    <String>['ラ', 'リ', 'ル', 'レ', 'ロ'],
    <String>['ヤ', '', 'ユ', '', 'ヨ'],
    <String>['マ', 'ミ', 'ム', 'メ', 'モ'],
    <String>['ハ', 'ヒ', 'フ', 'ヘ', 'ホ'],
    <String>['ナ', 'ニ', 'ヌ', 'ネ', 'ノ'],
    <String>['タ', 'チ', 'ツ', 'テ', 'ト'],
    <String>['サ', 'シ', 'ス', 'セ', 'ソ'],
    <String>['カ', 'キ', 'ク', 'ケ', 'コ'],
    <String>['ア', 'イ', 'ウ', 'エ', 'オ'],
  ];

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_kanaScrollController.hasClients) {
        _kanaScrollController.jumpTo(_kanaScrollController.position.maxScrollExtent);
      }
    });
  }

  ///
  @override
  void dispose() {
    _kanaScrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  ///
  Future<void> _fetchNames(String initial) async {
    setState(() {
      _loading = true;
      _error = null;
      _names = null;
      _battleRecords.clear();
      _battleLoading.clear();
      _expandedStates.clear();
      _itemKeys.clear();
    });
    try {
      final HttpClient client = ref.read(httpClientProvider);
      final dynamic value = await client.get(
        path: APIPath.getHorseOddsFinderHorseName,
        queryParameters: <String, dynamic>{'initial': initial},
      );
      // ignore: avoid_dynamic_calls
      final List<dynamic> data = value['data'] as List<dynamic>;
      final List<String> names = data.map((dynamic e) => (e as Map<String, dynamic>)['name'] as String).toList();
      setState(() {
        _names = names;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  ///
  List<String> get _secondChars {
    final List<String>? names = _names;
    if (names == null) {
      return <String>[];
    }
    final Set<String> seen = <String>{};
    final List<String> result = <String>[];
    for (final String name in names) {
      if (name.length >= 2) {
        final String c = name[1];
        if (seen.add(c)) {
          result.add(c);
        }
      }
    }
    final List<String> kanaOrder = _kanaColumns.reversed
        .expand((List<String> col) => col)
        .where((String k) => k.isNotEmpty)
        .toList();
    result.sort((String a, String b) {
      final int ai = kanaOrder.indexOf(a);
      final int bi = kanaOrder.indexOf(b);
      return (ai < 0 ? kanaOrder.length : ai).compareTo(bi < 0 ? kanaOrder.length : bi);
    });
    return result;
  }

  ///
  Future<void> _fetchBattleRecord(int index, String name) async {
    setState(() => _battleLoading[index] = true);
    try {
      final HttpClient client = ref.read(httpClientProvider);
      final dynamic value = await client.get(
        path: APIPath.getHorseOddsFinderHorseBattleRecord,
        queryParameters: <String, dynamic>{'name': name},
      );
      // ignore: avoid_dynamic_calls
      final List<dynamic> data = value['data'] as List<dynamic>;
      final List<RaceResultHistoryModel> records = data
          .map((dynamic e) => RaceResultHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _battleRecords[index] = records;
        _battleLoading[index] = false;
      });
    } catch (e) {
      setState(() => _battleLoading[index] = false);
    }
  }

  ///
  void _scrollToSecondChar(String c) {
    final List<String>? names = _names;
    if (names == null) {
      return;
    }
    final int index = names.indexWhere((String name) => name.length >= 2 && name[1] == c);
    if (index < 0) {
      return;
    }
    final GlobalKey? key = _itemKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    final List<String> secondChars = _secondChars;

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
                const Text('馬名検索', style: TextStyle(fontSize: 12)),
                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                Row(
                  children: <Widget>[
                    Container(
                      width: 10,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.5)),
                      child: const Text(''),
                    ),
                    const Text('ひともじめ'),
                  ],
                ),

                const SizedBox(height: 5),

                // 五十音表
                SingleChildScrollView(
                  controller: _kanaScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _kanaColumns.map((List<String> col) {
                      return Column(
                        children: col.map((String kana) {
                          final bool isSelected = kana.isNotEmpty && appParamState.selectedHorseNameChar1 == kana;

                          final Widget cell = Container(
                            width: _cellSize,
                            height: _cellSize,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.greenAccent.withValues(alpha: 0.3) : null,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: kana.isEmpty
                                ? null
                                : Center(
                                    child: Text(kana, style: const TextStyle(fontSize: 14, color: Colors.white)),
                                  ),
                          );

                          if (kana.isEmpty) {
                            return cell;
                          }

                          return GestureDetector(
                            onTap: () {
                              appParamNotifier.setSelectedHorseNameChar1(char: kana);
                              _fetchNames(kana);
                            },
                            child: cell,
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                ///2文字目ナビゲーション
                if (secondChars.isNotEmpty) ...<Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 10,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.5)),
                        child: const Text(''),
                      ),
                      const Text('ふたもじめ'),
                    ],
                  ),

                  const SizedBox(height: 5),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: secondChars.map((String c) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () {
                              appParamNotifier.setSelectedHorseNameChar2(char: c);
                              _scrollToSecondChar(c);
                            },

                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: appParamState.selectedHorseNameChar2 == c
                                  ? Colors.greenAccent.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.15),
                              child: Text(c, style: const TextStyle(fontSize: 13, color: Colors.white)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],

                Divider(color: Colors.white.withValues(alpha: 0.3)),

                // 結果リスト
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                          child: Text('エラー: $_error', style: const TextStyle(color: Colors.redAccent)),
                        )
                      : _names == null
                      ? const Center(
                          child: Text('文字を選択してください', style: TextStyle(color: Colors.grey)),
                        )
                      : _names!.isEmpty
                      ? const Center(
                          child: Text('該当する馬名はありません', style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          controller: _listScrollController,
                          itemCount: _names!.length,
                          cacheExtent: 100000,
                          itemBuilder: (BuildContext context, int index) {
                            final String name = _names![index];
                            final bool isLoadingRecord = _battleLoading[index] ?? false;
                            final List<RaceResultHistoryModel>? records = _battleRecords[index];
                            final GlobalKey key = _itemKeys.putIfAbsent(index, () => GlobalKey());

                            return ExpansionTile(
                              key: key,
                              title: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.double_arrow_sharp,
                                    color: (_expandedStates[index] ?? false)
                                        ? Colors.green.withValues(alpha: 0.5)
                                        : Colors.white.withValues(alpha: 0.5),
                                  ),

                                  const SizedBox(width: 10),

                                  Text(name, style: const TextStyle(fontSize: 13, color: Colors.white)),
                                ],
                              ),

                              onExpansionChanged: (bool expanded) {
                                setState(() => _expandedStates[index] = expanded);
                                if (expanded && !_battleRecords.containsKey(index)) {
                                  _fetchBattleRecord(index, name);
                                }
                              },
                              children: <Widget>[
                                if (isLoadingRecord)
                                  const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())
                                else if (records == null || records.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text('データなし', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  )
                                else
                                  ...records.map((RaceResultHistoryModel r) {
                                    return Row(
                                      children: <Widget>[
                                        const SizedBox(width: 50),

                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 5),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.white.withValues(alpha: 0.3),
                                                  width: 2,
                                                ),
                                              ),
                                            ),

                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(r.date, style: const TextStyle(fontSize: 12, color: Colors.white)),
                                                Text(
                                                  r.raceName,
                                                  style: const TextStyle(fontSize: 12, color: Colors.white),
                                                ),

                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    const SizedBox.shrink(),
                                                    Row(
                                                      children: <Widget>[
                                                        Container(
                                                          width: 40,
                                                          alignment: Alignment.center,
                                                          decoration: BoxDecoration(
                                                            color: switch (r.finishingPosition) {
                                                              1 => const Color(0xFFFFD700).withValues(alpha: 0.5),
                                                              2 => const Color(0xFFC0C0C0).withValues(alpha: 0.5),
                                                              3 => const Color(0xFFCD7F32).withValues(alpha: 0.5),
                                                              _ => Colors.transparent,
                                                            },
                                                          ),
                                                          child: Text(
                                                            '${r.finishingPosition}着',

                                                            style: const TextStyle(fontSize: 12),
                                                          ),
                                                        ),

                                                        Container(
                                                          width: 40,
                                                          alignment: Alignment.center,

                                                          child: Text(
                                                            '${r.popularityRank}人気',
                                                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 3),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
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
