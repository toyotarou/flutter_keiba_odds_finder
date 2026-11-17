// =============================================================================
// ファイル名   : ai_analysis_model.dart
// 概要         : レースごとの AI 分析結果（分析文）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-08-30
// 最終更新日   : 2026-11-17
// =============================================================================

/// レースごとの AI 分析結果。
class AiAnalysisModel {

  AiAnalysisModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoCode,
    required this.day,
    required this.race,
    required this.raceName,
    required this.analysisText,
  });

  factory AiAnalysisModel.fromJson(Map<String, dynamic> json) {
    return AiAnalysisModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as int?) ?? 0,
      basho: (json['basho'] as String?) ?? '',
      bashoCode: (json['basho_code'] as String?) ?? '',
      day: (json['day'] as int?) ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      analysisText: (json['analysis_text'] as String?) ?? '',
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
  /// AI の分析文
  final String analysisText;
}
