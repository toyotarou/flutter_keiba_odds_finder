class HorseOddsKitaichiModel {
  HorseOddsKitaichiModel({
    required this.num,
    required this.popularityRank,
    required this.currentOdds,
    required this.fukuMin,
    required this.fukuMax,
    required this.winRatePct,
    required this.placeRatePct,
    required this.sampleCount,
    required this.tanEvScore,
    required this.fukuEvScore,
  });

  factory HorseOddsKitaichiModel.fromJson(Map<String, dynamic> json) {
    return HorseOddsKitaichiModel(
      num: (json['num'] as int?) ?? 0,
      popularityRank: (json['popularity_rank'] as int?) ?? 0,
      currentOdds: (json['current_odds'] as String?) ?? '',
      fukuMin: (json['fuku_min'] as String?) ?? '',
      fukuMax: (json['fuku_max'] as String?) ?? '',
      winRatePct: (json['win_rate_pct'] as String?) ?? '',
      placeRatePct: (json['place_rate_pct'] as String?) ?? '',
      sampleCount: (json['sample_count'] as int?) ?? 0,
      tanEvScore: (json['tan_ev_score'] as String?) ?? '',
      fukuEvScore: (json['fuku_ev_score'] as String?) ?? '',
    );
  }

  final int num;
  final int popularityRank;
  final String currentOdds;
  final String fukuMin;
  final String fukuMax;
  final String winRatePct;
  final String placeRatePct;
  final int sampleCount;
  final String tanEvScore;
  final String fukuEvScore;
}
