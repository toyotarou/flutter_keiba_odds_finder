class AiResponseRecommendHorseModel {
  AiResponseRecommendHorseModel({
    required this.num,
    required this.name,
    required this.popularity,
    required this.odds,
    required this.score,
    required this.reason,
  });

  final int num;
  final String name;
  final String popularity;
  final String odds;
  final int score;
  final String reason;
}
