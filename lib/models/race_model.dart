// =============================================================================
// ファイル名   : race_model.dart
// 概要         : レース1件分の情報（発走時刻・頭数・コース・距離・グレード・人気比率など）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-30
// 最終更新日   : 2026-11-17
// =============================================================================

/// レース1件分の情報。
class RaceModel {
  RaceModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.startTime,
    required this.numHorses,
    required this.popularityRatio,
    required this.popularityRatioTableIds,
    required this.popularityRatioMatchPercent,

    required this.course,
    required this.dist,

    required this.grade,
  });

  factory RaceModel.fromJson(Map<String, dynamic> json) {
    return RaceModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      startTime: (json['start_time'] as String?) ?? '',
      numHorses: (json['num_horses'] as int?) ?? 0,
      popularityRatio: (json['popularity_ratio'] as String?) ?? '',
      popularityRatioTableIds: (json['popularity_ratio_table_ids'] as String?) ?? '',
      popularityRatioMatchPercent: (json['popularity_ratio_match_percent'] as String?) ?? '',

      course: (json['course'] as String?) ?? '',
      dist: (json['dist'] as int?) ?? 0,

      grade: (json['grade'] as String?) ?? '',
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
  final int day;
  /// レース番号
  final int race;
  /// レース名
  final String raceName;
  /// 発走時刻
  final String startTime;
  /// 出走頭数
  final int numHorses;
  /// 人気比率
  final String popularityRatio;
  /// 人気比率の比較に使ったレースID
  final String popularityRatioTableIds;
  /// 人気比率の一致率
  final String popularityRatioMatchPercent;

  /// コース種別（芝・ダート・障害）
  final String course;
  /// 距離（m）
  final int dist;

  /// グレード（G1・G2 など）
  final String grade;
}
