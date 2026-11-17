// =============================================================================
// ファイル名   : horse_best_weight_model.dart
// 概要         : 馬ごとの最高着順と、そのときの馬体重を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-23
// 最終更新日   : 2026-11-17
// =============================================================================

/// 馬ごとの最高着順と、そのときの馬体重。
class HorseBestWeightModel {
  HorseBestWeightModel({
    required this.name,
    required this.bestFinishingPosition,
    required this.date,
    required this.basho,
    required this.bashoCode,
    required this.kaisuu,
    required this.day,
    required this.race,
    required this.raceName,
    required this.horseWeight,
  });

  factory HorseBestWeightModel.fromJson(Map<String, dynamic> json) {
    return HorseBestWeightModel(
      name: (json['name'] as String?) ?? '',
      bestFinishingPosition: (json['best_finishing_position'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoCode: (json['basho_code'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as int?) ?? 0,
      day: (json['day'] as int?) ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      horseWeight: (json['horse_weight'] as String?) ?? '',
    );
  }

  /// 馬名
  final String name;
  /// 最高着順
  final int bestFinishingPosition;
  /// 開催日
  final String date;
  /// 競馬場
  final String basho;
  /// 競馬場コード
  final String bashoCode;
  /// 開催回（第何回の開催か）
  final int kaisuu;
  /// 開催日目（何日目か）
  final int day;
  /// レース番号
  final int race;
  /// レース名
  final String raceName;
  /// 最高着順だったときの馬体重
  final String horseWeight;
}
