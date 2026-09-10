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
}
