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
    this.aiHorseNums = const <int>[],
    this.payout,
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

  /// 20261006: AIが予想した馬の馬番。空（既定）のときは一覧を出さない。
  /// AI予想画面・過去レースのオッズ遷移表から開いたときだけ渡す。
  final List<int> aiHorseNums;

  /// 20261008: 呼び出し元で取得済みの払戻データ。渡されたときはAPIを呼ばずにこれを表示する。
  /// null（既定）のときは、これまで通り自分でAPIから取得する。
  final RaceResultPayoutModel? payout;

  @override
  ConsumerState<PayoutDataDisplayAlert> createState() => _PayoutDataDisplayAlertState();
}

class _PayoutDataDisplayAlertState extends ConsumerState<PayoutDataDisplayAlert>
    with ControllersMixin<PayoutDataDisplayAlert> {
  RaceResultPayoutModel? _payout;
  bool _isLoading = true;

  /// 20261008: 通信に失敗したか（「払戻データがありません」と区別して表示するため）
  bool _hasError = false;

  String get _effectiveDate => widget.overrideDate ?? appParamState.selectedScheduleDate;

  String get _effectiveKbd => widget.overrideKaisuuBashoDay ?? appParamState.selectedScheduleKaisuuBashoDay;

  ///
  @override
  void initState() {
    super.initState();

    // 20261008: 取得済みの払戻データが渡されたときはAPIを呼ばない（通信失敗・遅延を避ける）
    final RaceResultPayoutModel? given = widget.payout;
    if (given != null) {
      _payout = given;
      _isLoading = false;
      return;
    }

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

    // 20261008: 一時的な通信失敗に備えて、最大3回まで自動で再試行する（間隔1秒）
    const int maxAttempts = 3;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
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
        return;
      } catch (e) {
        debugPrint('payout fetch failed ($attempt/$maxAttempts): $e');
        if (attempt < maxAttempts) {
          await Future<void>.delayed(const Duration(seconds: 1));
          if (!mounted) {
            return;
          }
          continue;
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
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

  /// 20261006: 出走頭数（「X頭立て」）。馬データ（keepHorseMap）のそのレースの頭数。
  /// 馬データが無い（古いレースなど）ときは 0。
  int get _fieldSize {
    final List<HorseModel> horses = appParamState.keepHorseMap['${_effectiveDate}_$_effectiveKbd'] ?? <HorseModel>[];
    return horses.where((HorseModel h) => h.race == widget.raceNumber).length;
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
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 12, color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('払戻金', style: TextStyle(fontSize: 12, color: Colors.white)),

                      if (payout != null)
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${payout.date} ${payout.basho} ${payout.race}R',
                                style: const TextStyle(fontSize: 12, color: Colors.yellowAccent),
                                overflow: TextOverflow.ellipsis,
                              ),

                              Text(
                                payout.raceName,
                                style: const TextStyle(fontSize: 12, color: Colors.yellowAccent),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 5),

                  if (widget.aiHorseNums.isNotEmpty) ...<Widget>[
                    _buildAiHorseNums(),
                    const SizedBox(height: 10),
                    Divider(color: Colors.white.withValues(alpha: 0.4), thickness: 2),
                  ],

                  if (widget.numToRankMap.isNotEmpty) ...<Widget>[_buildRankLabels(), const SizedBox(height: 10)],

                  Expanded(child: _buildBody(payout)),
                ],
              ),
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

    // 20261008: 通信失敗は「データなし」と区別し、再読み込みできるようにする
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('通信に失敗しました', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                });
                _fetchPayout();
              },
              child: const Text('再読み込み', style: TextStyle(fontSize: 12, color: Colors.white)),
            ),
          ],
        ),
      );
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
  static const StrutStyle _valueStrut = StrutStyle(fontSize: 12, height: 1.3, forceStrutHeight: true);

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
            final bool isHit = isWaku ? isWakuComboHit(e.combo, widget.hitHorseNums, _numToWaku) : _isHit(e.combo);

            // 獲得した行の金額・馬番の文字色（色を変えるときはここ）。獲得していない行は null（既定の白）
            final TextStyle valueStyle = TextStyle(fontSize: 12, color: isHit ? const Color(0xFFFBB6CE) : null);

            return Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 70,
                    child: Text('${e.amount.toCurrency()} 円', style: valueStyle, strutStyle: _valueStrut),
                  ),
                  Container(
                    width: 80,
                    padding: const EdgeInsets.only(left: 10),
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

  /// 20261006: 「AIが予想した馬番：X頭」の下に、馬番を白枠で囲んで並べる。
  Widget _buildAiHorseNums() {
    // 3着以内に入った（合致した）馬の頭数。3頭合致のときだけピンクの文字にする（AI予想画面の結果文と同じ色）
    final int matchedCount = widget.aiHorseNums.where(widget.hitHorseNums.contains).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          // 出走頭数が分かるときだけ「 / X頭立て」を付ける
          'AIが予想した馬番：${widget.aiHorseNums.length}頭${_fieldSize > 0 ? ' / $_fieldSize頭立て' : ''}',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          // 馬番の昇順に並べる（元のリストは変更しない）
          children: (List<int>.of(widget.aiHorseNums)..sort())
              .map(
                (int n) => Container(
                  // 1桁・2桁で幅が変わらないよう固定幅にする
                  width: 32,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // 的中（3着以内に入った馬）は背景をピンクにする（「獲得」ラベルと同じ色）
                    color: widget.hitHorseNums.contains(n) ? const Color(0xFFFBB6CE).withValues(alpha: 0.4) : null,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('$n', style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
        ),
        // 0頭合致のときは出さない
        if (matchedCount > 0) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            '$matchedCount頭合致',
            style: TextStyle(fontSize: 12, color: matchedCount >= 3 ? const Color(0xFFFBB6CE) : Colors.white),
          ),
        ],
      ],
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
            widget.numToRankMap.entries
                .where((MapEntry<int, int> e) => e.value == rank)
                .map((MapEntry<int, int> e) => e.key)
                .toList()
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
            Text(nums.join(' '), style: const TextStyle(fontSize: 12)),
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
        style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
