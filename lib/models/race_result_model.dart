// =============================================================================
// ファイル名   : race_result_model.dart
// 概要         : レース結果の馬ごとの着順を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-15
// 最終更新日   : 2026-11-17
// =============================================================================

/// レース結果の馬ごとの着順。
class RaceResultModel {
  RaceResultModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.num,
    required this.horseName,
    required this.result,
  });

  factory RaceResultModel.fromJson(Map<String, dynamic> json) {
    return RaceResultModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      num: (json['num'] as int?) ?? 0,
      horseName: (json['horse_name'] as String?) ?? '',
      result: (json['result'] as int?) ?? 0,
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
  /// 馬番
  final int num;
  /// 馬名
  final String horseName;
  /// 着順
  final int result;
}
