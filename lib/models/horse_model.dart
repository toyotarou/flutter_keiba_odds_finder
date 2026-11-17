// =============================================================================
// ファイル名   : horse_model.dart
// 概要         : 出走馬1頭分の情報（開催・レース・枠番・馬番・馬名・騎手・調教師）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-30
// 最終更新日   : 2026-11-17
// =============================================================================

/// 出走馬1頭分の情報。
class HorseModel {
  HorseModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.waku,
    required this.num,
    required this.name,
    required this.horseUrl,
    required this.jockey,
    required this.trainer,
  });

  factory HorseModel.fromJson(Map<String, dynamic> json) {
    return HorseModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      waku: (json['waku'] as int?) ?? 0,
      num: (json['num'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      horseUrl: (json['horse_url'] as String?) ?? '',
      jockey: (json['jockey'] as String?) ?? '',
      trainer: (json['trainer'] as String?) ?? '',
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
  /// 枠番
  final int waku;
  /// 馬番
  final int num;
  /// 馬名
  final String name;
  /// 馬の詳細ページのURL
  final String horseUrl;
  /// 騎手名
  final String jockey;
  /// 調教師名
  final String trainer;
}
