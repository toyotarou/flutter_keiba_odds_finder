// =============================================================================
// ファイル名   : schedule_model.dart
// 概要         : 開催スケジュール1件分（開催日・開催回・競馬場・日目）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-30
// 最終更新日   : 2026-11-17
// =============================================================================

/// 開催スケジュール1件分。
class ScheduleModel {
  ScheduleModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: (json['day'] as int?) ?? 0,
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
}
