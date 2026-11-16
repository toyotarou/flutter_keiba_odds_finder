class AiResponseRecommendHorseModel {
  AiResponseRecommendHorseModel({
    required this.num,
    required this.name,
    required this.popularity,
    required this.odds,
    required this.score,
    required this.reason,
    this.category = 'first_only',
    this.score1st,
    this.score2nd,
    this.reasonSecond,
    // 20261026 なる回答（C案）で画面の印をやめたため、受け取らない
    // this.fillSlot = false,
    // this.purchaseRecommended = true,
    this.fillSlot = false,   // 20261115 よっしー11/14 B案：頭数に足りない分の「補充」を戻した
    this.metricsSlot = false,   // 20261116 3指標の選出連動（なる11/15 RACE_METRICS_SELECTION_V1）
  });

  final int num;
  final String name;
  final String popularity;
  final String odds;
  final int score;
  final String reason;

  /// 候補区分: 'matched' | 'first_only' | 'second_only'
  final String category;

  /// 一致馬・1st AI 独自馬のおすすめ度（1st AI スコア）
  final int? score1st;

  /// 一致馬・2nd AI 独自馬のおすすめ度（2nd AI スコア）
  final int? score2nd;

  /// 一致馬の 2nd AI 選出理由（matched のみ非 null）
  final String? reasonSecond;

  /// 20261115 頭数に足りない分を補った馬か（サーバーの fill_slot）。
  /// 根拠を確かめられた馬だけでは頭数に届かないとき、同じ人気帯から補った馬。
  /// おすすめ度は付かず、購入推奨にも入らない。
  final bool fillSlot;

  /// 20261116 3指標（波乱度・下位進入度・大穴進入度）で、サーバーが最終の枠を1頭動かしたときに入った馬か（サーバーの metrics_slot）。
  /// AIの評価で選んだ馬であることは変わらない。おすすめ度のかさ上げや購入推奨は付かない。
  final bool metricsSlot;

  // 20261026 なる回答（C案）で画面の印をやめたため、受け取らない
  // /// 補充枠で入った馬か（サーバーの fill_slot_unqualified）。
  // ///
  // /// 目標頭数に届かないとき、人気薄の資格を満たしていない7番人気以下を
  // /// おすすめ度の順で補った馬。通常の選出と区別して表示する。
  // /// 補充方式が現行（A）のあいだは常に false。
  // final bool fillSlot;
  //
  // /// 購入推奨の対象か（サーバーの purchase_recommended）。
  // ///
  // /// 補充枠の馬、最低基準点に届かない馬、購入回避の印が付いた馬は false。
  // /// 候補として画面に出すことと、買う価値があることを分けている。
  // final bool purchaseRecommended;
}
