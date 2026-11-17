// =============================================================================
// ファイル名   : race_introspection_model.dart
// 概要         : レース後の振り返り（反省文）1件分を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-08-03
// 最終更新日   : 2026-11-17
// =============================================================================

/// レース後の振り返り1件分。
class RaceIntrospectionModel {
  RaceIntrospectionModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoCode,
    required this.day,
    required this.race,
    required this.raceName,
    required this.introspection,
    required this.finish,
  });

  factory RaceIntrospectionModel.fromJson(Map<String, dynamic> json) {
    return RaceIntrospectionModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as int?) ?? 0,
      basho: (json['basho'] as String?) ?? '',
      bashoCode: (json['basho_code'] as String?) ?? '',
      day: (json['day'] as int?) ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      introspection: (json['introspection'] as String?) ?? '',
      finish: (json['finish'] as int?) ?? 0,
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
  /// 振り返りの本文
  final String introspection;
  final int finish;
}
