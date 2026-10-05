import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';
import '../../extensions/extensions.dart';
import '../../models/horse_model.dart';
import '../../models/race_result_payout_model.dart';
import '../../utility/functions.dart';

// 20261005: OddsFinderDialog(hideRaceOverlay: true) に移したため不要
// import '../parts/odds_finder_overlay.dart';

/// 20261005: 払戻金表示（ざっくり版）
/// 作りは ai_analysis_display_alert.dart に合わせている（Scaffold + DefaultTextStyle + Padding(20)）
class PayoutDataDisplayAlert extends ConsumerStatefulWidget {
  const PayoutDataDisplayAlert({
    super.key,
    required this.raceNumber,
    this.overrideDate,
    this.overrideKaisuuBashoDay,
    this.hitHorseNums = const <int>{},
    this.numToRankMap = const <int, int>{},
  });

  final int raceNumber;

  /// 過去レースから呼ばれた場合は override 値を、そうでなければ appParamState の値を使う
  final String? overrideDate;
  final String? overrideKaisuuBashoDay;

  /// 20261005: 着順バッジ（3着以内）が付いている馬の馬番。
  /// 払戻の組み合わせの馬番がすべてここに含まれるときだけ「獲得」ラベルを出す。
  /// 空（既定）のときは「獲得」を一切出さない。
  final Set<int> hitHorseNums;

  /// 20261005: 馬番 → 着順。空（既定）のときは「1着」「2着」「3着」のラベルを出さない。
  /// AI予想画面・過去レースのオッズ遷移表から開いたときだけ渡す。
  final Map<int, int> numToRankMap;

  @override
  ConsumerState<PayoutDataDisplayAlert> createState() => _PayoutDataDisplayAlertState();
}

class _PayoutDataDisplayAlertState extends ConsumerState<PayoutDataDisplayAlert>
    with ControllersMixin<PayoutDataDisplayAlert> {
  RaceResultPayoutModel? _payout;
  bool _isLoading = true;

  String get _effectiveDate => widget.overrideDate ?? appParamState.selectedScheduleDate;

  String get _effectiveKbd => widget.overrideKaisuuBashoDay ?? appParamState.selectedScheduleKaisuuBashoDay;

  ///
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 20261005: 表示中のレース選択オーバーレイ非表示は OddsFinderDialog(hideRaceOverlay: true) に移したため不要
      // raceOverlayHiddenNotifier.value = true;
      _fetchPayout();
    });
  }

  // 20261005: 閉じたときのレース選択オーバーレイ再表示も OddsFinderDialog 側に移したため不要
  // ///
  // @override
  // void dispose() {
  //   Future<void>(() => raceOverlayHiddenNotifier.value = false);
  //   super.dispose();
  // }

  ///
  Future<void> _fetchPayout() async {
    final String date = _effectiveDate;
    final (:String kaisuu, :String basho, day: _) = parseKbdParts(_effectiveKbd);
    if (kaisuu.isEmpty || basho.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final List<RaceResultPayoutModel> list = await fetchPayoutList(
        ref,
        racesParam: '$date|$kaisuu|$basho|${widget.raceNumber}',
      );
      if (mounted) {
        setState(() {
          _payout = list.isNotEmpty ? list.first : null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 20261005: 馬番 → 枠番。枠連（枠番の組み合わせ）の「獲得」判定に使う。
  /// 馬データ（horse_model の waku）は keepHorseMap にあるので、呼び出し元から引数で渡さなくても自分で引く。
  /// 馬データが無い（古いレースなど）ときは空で、枠連は「獲得」にならない。
  Map<int, int> get _numToWaku {
    final List<HorseModel> horses = appParamState.keepHorseMap['${_effectiveDate}_$_effectiveKbd'] ?? <HorseModel>[];
    return buildNumToWakuMap(horses.where((HorseModel h) => h.race == widget.raceNumber));
  }

  /// 払戻文字列を（組み合わせ, 金額）のリストに分解する。
  ///
  /// 形式: "14|110/5|150/1|480"（"/" で複数、各要素は "組み合わせ|金額"）
  /// 空文字・"-" など組み合わせが取れないものは除く。
  List<({String combo, String amount})> _parseEntries(String raw) {
    if (raw.trim().isEmpty) {
      return <({String combo, String amount})>[];
    }

    final List<({String combo, String amount})> entries = <({String combo, String amount})>[];
    for (final String e in raw.split('/')) {
      final List<String> parts = e.split('|');
      final String combo = parts.first.trim();
      if (combo.isEmpty || combo == '-') {
        continue;
      }
      entries.add((combo: combo, amount: parts.length > 1 ? parts[1].trim() : ''));
    }
    return entries;
  }

  ///
  @override
  Widget build(BuildContext context) {
    final RaceResultPayoutModel? payout = _payout;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          // 20261005: 後ろの画面が透けて払戻金が読みにくいので、黒背景にする（角丸は OddsFinderDialog の Dialog と同じ 30）
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('払戻金', style: TextStyle(fontSize: 12)),

                    if (payout != null)
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '${payout.date} ${payout.basho} ${payout.race}R',
                              style: const TextStyle(fontSize: 11, color: Colors.yellowAccent),
                              overflow: TextOverflow.ellipsis,
                            ),

                            Text(
                              payout.raceName,
                              style: const TextStyle(fontSize: 11, color: Colors.yellowAccent),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                if (widget.numToRankMap.isNotEmpty) ...<Widget>[_buildRankLabels(), const SizedBox(height: 10)],

                Expanded(child: _buildBody(payout)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _buildBody(RaceResultPayoutModel? payout) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (payout == null) {
      return const Center(child: Text('払戻データがありません', style: TextStyle(fontSize: 12)));
    }

    return ListView(
      children: <Widget>[
        _buildSection(label: '単勝', raw: payout.tan, color: Colors.white),
        _buildSection(label: '複勝', raw: payout.fuku, color: Colors.white),
        _buildSection(label: '枠連', raw: payout.waku, color: Colors.white, isWaku: true),
        _buildSection(label: '馬連', raw: payout.umaren, color: Colors.white),
        _buildSection(label: 'ワイド', raw: payout.wide, color: Colors.white),
        _buildSection(label: '馬単', raw: payout.umatan, color: Colors.white),
        _buildSection(label: '三連複', raw: payout.trio, color: Colors.white),
        _buildSection(label: '三連単', raw: payout.trifecta, color: Colors.white),
      ],
    );
  }

  /// 20261005: 金額・組み合わせの Text 共通の行の高さ。
  /// 金額は「円」を含み、日本語フォント（フォールバック）の行高になって数字の縦位置が組み合わせとずれるため、
  /// 行の高さを固定して揃える。
  static const StrutStyle _valueStrut = StrutStyle(fontSize: 13, height: 1.3, forceStrutHeight: true);

  /// 券種ごとのブロック
  ///
  /// 三連複
  /// 99999 1-2-5
  /// の形で、金額 → 組み合わせの順に並べる。
  Widget _buildSection({required String label, required String raw, required Color color, bool isWaku = false}) {
    final List<({String combo, String amount})> entries = _parseEntries(raw);
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),

          const SizedBox(height: 2),

          ...entries.map((({String combo, String amount}) e) {
            // 20261005: 着順バッジが付いた馬の馬番だけで組み合わせが成り立つか（成り立つ行だけ「獲得」と赤文字）
            final bool isHit = isWaku
                ? isWakuComboHit(e.combo, widget.hitHorseNums, _numToWaku)
                : _isHit(e.combo);

            // 獲得した行の金額・馬番の文字色（色を変えるときはここ）。獲得していない行は null（既定の白）
            final TextStyle valueStyle = TextStyle(fontSize: 13, color: isHit ? const Color(0xFFFBB6CE) : null);

            return Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 70,
                    child: Text('${e.amount.toCurrency()} 円', style: valueStyle, strutStyle: _valueStrut),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(e.combo, style: valueStyle, strutStyle: _valueStrut),
                  ),

                  if (isHit) _buildGetLabel(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 20261005: 「1着 5」「2着 13」「3着 1」のように、着順ごとの馬番を並べる。
  /// 同着で同じ着順の馬が複数いるときは、馬番を昇順に並べて続けて表示する。
  Widget _buildRankLabels() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: <int>[1, 2, 3].map((int rank) {
        final List<int> nums =
            widget.numToRankMap.entries.where((MapEntry<int, int> e) => e.value == rank).map((MapEntry<int, int> e) => e.key).toList()
              ..sort();
        if (nums.isEmpty) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // AI予想画面の着順バッジ（$rank位）と同じスタイル（幅32・角丸4・着順色の塗り）
            Container(
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: raceRankColor(rank, fallback: Colors.grey.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('$rank着', style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
            const SizedBox(width: 6),
            Text(nums.join(' '), style: const TextStyle(fontSize: 13)),
          ],
        );
      }).toList(),
    );
  }

  /// 組み合わせ（"1-5-14" など）の馬番がすべて [PayoutDataDisplayAlert.hitHorseNums] に含まれるか。
  /// 順序は問わない（馬単・三連単も馬番の集合で判定）。
  bool _isHit(String combo) => isPayoutComboHit(combo, widget.hitHorseNums);

  /// 「獲得できたか」を表す緑の角丸ラベル
  Widget _buildGetLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBB6CE).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '獲得',
        style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
