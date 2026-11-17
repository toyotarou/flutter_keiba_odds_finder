// =============================================================================
// ファイル名   : data_count_model.dart
// 概要         : 日付ごとの各テーブルのデータ件数を保持するモデル（データ件数確認画面で使用）。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-07
// 最終更新日   : 2026-11-17
// =============================================================================

/// 日付ごとの各テーブルのデータ件数。
class DataCountModel {
  DataCountModel({
    required this.date,
    required this.summaryCount,
    required this.historyCount,
    required this.historyPopularityRankCount,
    required this.historyFinishingPositionCount,
    required this.payoutCount,
    required this.ratioCount,
    required this.medianCount,
    required this.raceResultsCount,
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

      medianCount: (json['median_count'] as int?) ?? 0,
      raceResultsCount: (json['race_results_count'] as int?) ?? 0,
    );
  }

  /// 集計日
  final String date;
  /// サマリーの件数
  final int summaryCount;
  /// レース結果履歴の件数
  final int historyCount;
  /// レース結果履歴のうち人気順が入っている件数
  final int historyPopularityRankCount;
  /// レース結果履歴のうち着順が入っている件数
  final int historyFinishingPositionCount;
  /// 払戻金の件数
  final int payoutCount;
  /// 人気比率の件数
  final int ratioCount;

  /// 人気順別オッズ中央値の件数
  final int medianCount;
  /// レース結果の件数
  final int raceResultsCount;
}
