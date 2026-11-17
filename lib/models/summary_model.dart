// =============================================================================
// ファイル名   : summary_model.dart
// 概要         : 馬ごとの発走前オッズの推移（30分前〜発走時）と着順をまとめたモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-09
// 最終更新日   : 2026-11-17
// =============================================================================

/// 馬ごとの発走前オッズ推移と着順。
class SummaryModel {
  SummaryModel({
    required this.id,
    required this.horseName,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.waku,
    required this.num,
    required this.oddsTanBefore30,
    required this.oddsTanBefore21,
    required this.oddsTanBefore18,
    required this.oddsTanBefore15,
    required this.oddsTanBefore12,
    required this.oddsTanBefore9,
    required this.oddsTanBefore6,
    required this.oddsTanBefore3,
    required this.oddsTanBefore0,
    required this.result,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: (json['id'] as int?) ?? 0,
      horseName: (json['horse_name'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      waku: (json['waku'] as int?) ?? 0,
      num: (json['num'] as int?) ?? 0,
      oddsTanBefore30: (json['odds_tan_before_24'] as String?) ?? '',
      oddsTanBefore21: (json['odds_tan_before_21'] as String?) ?? '',
      oddsTanBefore18: (json['odds_tan_before_18'] as String?) ?? '',
      oddsTanBefore15: (json['odds_tan_before_15'] as String?) ?? '',
      oddsTanBefore12: (json['odds_tan_before_12'] as String?) ?? '',
      oddsTanBefore9: (json['odds_tan_before_9'] as String?) ?? '',
      oddsTanBefore6: (json['odds_tan_before_6'] as String?) ?? '',
      oddsTanBefore3: (json['odds_tan_before_3'] as String?) ?? '',
      oddsTanBefore0: (json['odds_tan_before_0'] as String?) ?? '',
      result: (json['result'] as int?) ?? 0,
    );
  }

  /// レコードID
  final int id;
  /// 馬名
  final String horseName;
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
  /// 枠番
  final int waku;
  /// 馬番
  final int num;
  /// 発走30分前の単勝オッズ
  final String oddsTanBefore30;
  /// 発走21分前の単勝オッズ
  final String oddsTanBefore21;
  /// 発走18分前の単勝オッズ
  final String oddsTanBefore18;
  /// 発走15分前の単勝オッズ
  final String oddsTanBefore15;
  /// 発走12分前の単勝オッズ
  final String oddsTanBefore12;
  /// 発走9分前の単勝オッズ
  final String oddsTanBefore9;
  /// 発走6分前の単勝オッズ
  final String oddsTanBefore6;
  /// 発走3分前の単勝オッズ
  final String oddsTanBefore3;
  /// 発走時の単勝オッズ
  final String oddsTanBefore0;
  /// 着順
  final int result;
}
