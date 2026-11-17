// =============================================================================
// ファイル名   : ai_response_recommend_horse_model.dart
// 概要         : AI が推奨した馬1頭分（馬番・おすすめ度・選出理由・候補区分など）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-08-11
// 最終更新日   : 2026-11-17
// =============================================================================

/// AI が推奨した馬1頭分。
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
    this.fillSlot = false,   // 頭数に足りない分の「補充」を戻した
    this.metricsSlot = false,   // 3指標の選出連動
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

  /// 頭数に足りない分を補った馬か（サーバーの fill_slot）。
  /// 根拠を確かめられた馬だけでは頭数に届かないとき、同じ人気帯から補った馬。
  /// おすすめ度は付かず、購入推奨にも入らない。
  final bool fillSlot;

  /// 3指標（波乱度・下位進入度・大穴進入度）で、サーバーが最終の枠を1頭動かしたときに入った馬か（サーバーの metrics_slot）。
  /// AIの評価で選んだ馬であることは変わらない。おすすめ度のかさ上げや購入推奨は付かない。
  final bool metricsSlot;

}
