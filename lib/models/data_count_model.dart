class DataCountModel {
  DataCountModel({
    required this.date,
    required this.summaryCount,
    required this.historyCount,
    required this.historyPopularityRankCount,
    required this.historyFinishingPositionCount,
    required this.payoutCount,
    required this.ratioCount,
  });

  factory DataCountModel.fromJson(Map<String, dynamic> json) {
    return DataCountModel(
      date: (json['date'] as String?) ?? '',
      summaryCount: (json['summary_count'] as int?) ?? 0,
      historyCount: (json['history_count'] as int?) ?? 0,
      historyPopularityRankCount: (json['history_popularity_rank_count'] as int?) ?? 0,
      historyFinishingPositionCount: (json['history_finishing_position_count'] as int?) ?? 0,
      payoutCount: (json['payout_count'] as int?) ?? 0,
      ratioCount: (json['ratio_count'] as int?) ?? 0,
    );
  }

  final String date;
  final int summaryCount;
  final int historyCount;
  final int historyPopularityRankCount;
  final int historyFinishingPositionCount;
  final int payoutCount;
  final int ratioCount;
}
