import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../data/http/client.dart';
import '../../data/http/path.dart';

class HorseNameInitialPanelAlert extends ConsumerStatefulWidget {
  const HorseNameInitialPanelAlert({super.key});

  @override
  ConsumerState<HorseNameInitialPanelAlert> createState() => _HorseNameInitialPanelAlertState();
}

class _HorseNameInitialPanelAlertState extends ConsumerState<HorseNameInitialPanelAlert>
    with ControllersMixin<HorseNameInitialPanelAlert> {
  final ScrollController _kanaScrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();

  String? _selectedKana;
  List<String>? _names;
  bool _loading = false;
  String? _error;

  static const double _cellSize = 40;
  static const double _itemExtent = 32;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_kanaScrollController.hasClients) {
        _kanaScrollController.jumpTo(_kanaScrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _kanaScrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNames(String initial) async {
    setState(() {
      _loading = true;
      _error = null;
      _names = null;
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

  // 結果リストの2文字目を重複なく順番に返す
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
    return result;
  }

  void _scrollToSecondChar(String c) {
    final List<String>? names = _names;
    if (names == null) {
      return;
    }
    final int index = names.indexWhere((String name) => name.length >= 2 && name[1] == c);
    if (index < 0) {
      return;
    }
    _listScrollController.animateTo(
      index * _itemExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

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

                // 五十音表
                SingleChildScrollView(
                  controller: _kanaScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _kanaColumns.map((List<String> col) {
                      return Column(
                        children: col.map((String kana) {
                          final bool isSelected = _selectedKana == kana;
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
                              setState(() => _selectedKana = kana);
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
                if (secondChars.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: secondChars.map((String c) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => _scrollToSecondChar(c),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              child: Text(c, style: const TextStyle(fontSize: 13, color: Colors.white)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                if (secondChars.isNotEmpty) const SizedBox(height: 8),

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
                          itemExtent: _itemExtent,
                          itemBuilder: (BuildContext context, int index) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(_names![index], style: const TextStyle(fontSize: 13, color: Colors.white)),
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
