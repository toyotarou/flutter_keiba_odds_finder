// =============================================================================
// ファイル名   : odds_get_timing_model.dart
// 概要         : レースごとのオッズ取得タイミング（発走何分前に・いつ取得したか）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-31
// 最終更新日   : 2026-11-17
// =============================================================================

/// オッズ取得タイミング1件分。
class OddsGetTimingModel {
  OddsGetTimingModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.day,
    required this.race,
    required this.timing,
    required this.getDatetime,
    required this.oddsFrom,
  });

  factory OddsGetTimingModel.fromJson(Map<String, dynamic> json) {
    return OddsGetTimingModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      timing: (json['timing'] as int?) ?? 0,
      getDatetime: (json['get_datetime'] as String?) ?? '',
      oddsFrom: (json['odds_from'] as String?) ?? '',
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
  /// 開催日目（何日目か）
  final int day;
  /// レース番号
  final int race;
  /// 取得タイミング（発走何分前か）
  final int timing;
  /// 取得日時
  final String getDatetime;
  /// オッズの取得元
  final String oddsFrom;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date,
      'kaisuu': kaisuu,
      'basho': basho,
      'day': day,
      'race': race,
      'timing': timing,
      'get_datetime': getDatetime,
      'odds_from': oddsFrom,
    };
  }
}
