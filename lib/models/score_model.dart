// =============================================================================
// ファイル名   : score_model.dart
// 概要         : 馬・騎手などの名前ごとのスコアと集計件数を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-29
// 最終更新日   : 2026-11-17
// =============================================================================

/// 名前ごとのスコアと集計件数。
class ScoreModel {
  ScoreModel({required this.id, required this.name, required this.count, required this.score});

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      count: (json['count'] as int?) ?? 0,
      score: (json['score'] as int?) ?? 0,
    );
  }

  /// レコードID
  final int id;
  /// 名前（馬名・騎手名など）
  final String name;
  /// 集計件数
  final int count;
  /// スコア
  final int score;
}
