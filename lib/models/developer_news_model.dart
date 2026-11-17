// =============================================================================
// ファイル名   : developer_news_model.dart
// 概要         : 開発者向けお知らせ（プッシュ送信ログ）1件分を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-08-25
// 最終更新日   : 2026-11-17
// =============================================================================

/// 開発者向けお知らせ1件分。
class DeveloperNewsModel {
  DeveloperNewsModel({
    required this.kind,
    required this.sentDate,
    required this.diffSeconds,
    required this.time,
    required this.description,
  });

  factory DeveloperNewsModel.fromJson(Map<String, dynamic> json) {
    return DeveloperNewsModel(
      kind: (json['kind'] as String?) ?? '',
      sentDate: (json['sent_date'] as String?) ?? '',
      diffSeconds: (json['diff_seconds'] as int?) ?? 0,
      time: (json['time'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }

  /// お知らせの種類
  final String kind;
  /// 送信日時
  final String sentDate;
  /// 経過秒数
  final int diffSeconds;
  /// 時刻
  final String time;
  /// 内容
  final String description;
}
