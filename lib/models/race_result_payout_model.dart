// =============================================================================
// ファイル名   : race_result_payout_model.dart
// 概要         : レースごとの払戻金（単勝〜3連単）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-06
// 最終更新日   : 2026-11-17
// =============================================================================

/// レースごとの払戻金。
class RaceResultPayoutModel {
  RaceResultPayoutModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoCode,
    required this.day,
    required this.race,
    required this.raceName,
    required this.tan,
    required this.fuku,
    required this.waku,
    required this.wide,
    required this.umaren,
    required this.umatan,
    required this.trio,
    required this.trifecta,

    required this.grade,
    required this.course,
    required this.dist,
    required this.innerOuter,
  });

  factory RaceResultPayoutModel.fromJson(Map<String, dynamic> json) {
    return RaceResultPayoutModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as int?) ?? 0,
      basho: (json['basho'] as String?) ?? '',
      bashoCode: (json['basho_code'] as String?) ?? '',
      day: (json['day'] as int?) ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      tan: (json['tan'] as String?) ?? '',
      fuku: (json['fuku'] as String?) ?? '',
      waku: (json['waku'] as String?) ?? '',
      wide: (json['wide'] as String?) ?? '',
      umaren: (json['umaren'] as String?) ?? '',
      umatan: (json['umatan'] as String?) ?? '',
      trio: (json['trio'] as String?) ?? '',
      trifecta: (json['trifecta'] as String?) ?? '',

      grade: (json['grade'] as String?) ?? '',
      course: (json['course'] as String?) ?? '',
      dist: json['dist']?.toString() ?? '',
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

  /// 単勝の払戻金
  final String tan;
  /// 複勝の払戻金
  final String fuku;
  /// 枠連の払戻金
  final String waku;
  /// ワイドの払戻金
  final String wide;
  /// 馬連の払戻金
  final String umaren;
  /// 馬単の払戻金
  final String umatan;
  /// 3連複の払戻金
  final String trio;
  /// 3連単の払戻金
  final String trifecta;

  /// グレード（G1・G2 など）
  final String grade;
  /// コース種別（芝・ダート・障害）
  final String course;
  /// 距離（m）
  final String dist;
  /// 内回り・外回りの区分
  final String innerOuter;
}
