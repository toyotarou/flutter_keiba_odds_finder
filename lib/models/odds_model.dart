// =============================================================================
// ファイル名   : odds_model.dart
// 概要         : 馬1頭・取得タイミング1回分のオッズ（単勝・複勝）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-30
// 最終更新日   : 2026-11-17
// =============================================================================

/// 馬1頭・取得タイミング1回分のオッズ。
class OddsModel {
  OddsModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.day,
    required this.race,
    required this.num,
    required this.odds,
    required this.fukuMin,
    required this.fukuMax,
    required this.minutesBeforeStart,
  });

  factory OddsModel.fromJson(Map<String, dynamic> json) {
    return OddsModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      num: (json['num'] as int?) ?? 0,
      odds: (json['odds'] as String?) ?? '',
      fukuMin: (json['fuku_min'] as String?) ?? '',
      fukuMax: (json['fuku_max'] as String?) ?? '',
      minutesBeforeStart: (json['minutes_before_start'] as int?) ?? 0,
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
  /// 馬番
  final int num;
  /// 単勝オッズ
  final String odds;
  /// 複勝オッズ（下限）
  final String fukuMin;
  /// 複勝オッズ（上限）
  final String fukuMax;
  /// 発走何分前のオッズか
  final int minutesBeforeStart;
}
