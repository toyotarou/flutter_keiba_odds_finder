// =============================================================================
// ファイル名   : race_result_history_model.dart
// 概要         : 過去レースの馬ごとの結果（オッズ・人気・着順）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-27
// 最終更新日   : 2026-11-17
// =============================================================================

/// 過去レースの馬ごとの結果。
class RaceResultHistoryModel {
  RaceResultHistoryModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoCode,
    required this.day,
    required this.race,
    required this.raceName,
    required this.num,
    required this.name,
    required this.tan,
    required this.fukuMin,
    required this.fukuMax,
    required this.popularityRank,
    required this.finishingPosition,
    required this.course,
    required this.dist,
    required this.innerOuter,
  });

  factory RaceResultHistoryModel.fromJson(Map<String, dynamic> json) {
    return RaceResultHistoryModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as int?) ?? 0,
      basho: (json['basho'] as String?) ?? '',
      bashoCode: (json['basho_code'] as String?) ?? '',
      day: (json['day'] as int?) ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      num: (json['num'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      tan: (json['tan'] as String?) ?? '',
      fukuMin: (json['fuku_min'] as String?) ?? '',
      fukuMax: (json['fuku_max'] as String?) ?? '',
      popularityRank: (json['popularity_rank'] as int?) ?? 0,
      finishingPosition: (json['finishing_position'] as int?) ?? 0,

      course: (json['course'] as String?) ?? '',
      dist: (json['dist'] as int?) ?? 0,
      innerOuter: (json['inner_outer'] as String?) ?? '',
    );
  }

  /// レコードID
  final int id;
  /// 開催日
  final String date;
  /// 開催回（第何回の開催か）
  final int kaisuu;
  /// 競馬場
  final String basho;
  /// 競馬場コード
  final String bashoCode;
  /// 開催日目（何日目か）
  final int day;
  /// レース番号
  final int race;
  /// レース名
  final String raceName;
  /// 馬番
  final int num;
  /// 馬名
  final String name;
  /// 単勝オッズ
  final String tan;
  /// 複勝オッズ（下限）
  final String fukuMin;
  /// 複勝オッズ（上限）
  final String fukuMax;
  /// 人気順
  final int popularityRank;
  /// 着順
  final int finishingPosition;

  /// コース種別（芝・ダート・障害）
  final String course;
  /// 距離（m）
  final int dist;
  /// 内回り・外回りの区分
  final String innerOuter;
}
