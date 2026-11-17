// =============================================================================
// ファイル名   : races_popularity_ratio_model.dart
// 概要         : レースごとの人気比率（人気の偏り具合）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-06
// 最終更新日   : 2026-11-17
// =============================================================================

/// レースごとの人気比率。
class RacesPopularityRatioModel {
  RacesPopularityRatioModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.numHorses,
    required this.popularityRatio,
  });

  factory RacesPopularityRatioModel.fromJson(Map<String, dynamic> json) {
    return RacesPopularityRatioModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: (json['day'] as String?) ?? '',
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      numHorses: (json['num_horses'] as int?) ?? 0,
      popularityRatio: (json['popularity_ratio'] as String?) ?? '',
    );
  }

  /// レコードID
  final int id;
  /// 開催日
  final String date;
  /// 開催回（第何回の開催か）
  final String kaisuu;
  /// 競馬場
  final String basho;
  /// 競馬場名
  final String bashoName;
  /// 開催日目（何日目か）
  final String day;
  /// レース番号
  final int race;
  /// レース名
  final String raceName;
  /// 出走頭数
  final int numHorses;
  /// 人気比率
  final String popularityRatio;
}
