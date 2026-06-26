class PopularityRankOddsAverageModel {
  PopularityRankOddsAverageModel({
    required this.id,
    required this.popularityRank,
    required this.oddsAverage,
    required this.count,
    required this.startDate,
    required this.endDate,
  });

  factory PopularityRankOddsAverageModel.fromJson(Map<String, dynamic> json) {
    return PopularityRankOddsAverageModel(
      id: (json['id'] as int?) ?? 0,
      popularityRank: (json['popularity_rank'] as int?) ?? 0,
      oddsAverage: (json['odds_average'] as String?) ?? '',
      count: (json['count'] as int?) ?? 0,
      startDate: (json['start_date'] as String?) ?? '',
      endDate: (json['end_date'] as String?) ?? '',
    );
  }

  final int id;
  final int popularityRank;
  final String oddsAverage;
  final int count;
  final String startDate;
  final String endDate;
}
