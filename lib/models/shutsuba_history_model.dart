// =============================================================================
// ファイル名   : shutsuba_history_model.dart
// 概要         : 出走馬の過去の出走履歴1件分（着順・通過順・上がり3F など）を保持するモデル。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-16
// 最終更新日   : 2026-11-17
// =============================================================================

/// 出走馬の過去の出走履歴1件分。
class ShutsubaHistoryModel {
  ShutsubaHistoryModel({
    required this.id,
    required this.name,
    required this.date,
    required this.basho,
    required this.bashoCode,
    required this.race,
    required this.raceName,
    required this.grade,
    required this.finishingPosition,
    required this.numHorses,
    required this.gate,
    required this.popularity,
    required this.jockey,
    required this.burdenWeight,
    required this.course,
    required this.dist,
    required this.time,
    required this.condition,
    required this.horseWeight,
    required this.corner1,
    required this.corner2,
    required this.corner3,
    required this.corner4,
    required this.last3f,
    required this.finHorse,
    required this.finTimeDiff,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShutsubaHistoryModel.fromJson(Map<String, dynamic> json) {
    final String distRaw = (json['dist'] as String?) ?? '';
    return ShutsubaHistoryModel(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoCode: (json['basho_code'] as String?) ?? '',
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      grade: (json['grade'] as String?) ?? '',
      finishingPosition: (json['finishing_position'] as int?) ?? 0,
      numHorses: (json['num_horses'] as int?) ?? 0,
      gate: (json['gate'] as int?) ?? 0,
      popularity: (json['popularity'] as int?) ?? 0,
      jockey: (json['jockey'] as String?) ?? '',
      burdenWeight: (json['burden_weight'] as String?) ?? '',
      course: _parseCourse(distRaw),
      dist: _parseDist(distRaw),
      time: (json['time'] as String?) ?? '',
      condition: (json['condition'] as String?) ?? '',
      horseWeight: (json['horse_weight'] as String?) ?? '',
      corner1: (json['corner_1'] as int?) ?? 0,
      corner2: (json['corner_2'] as int?) ?? 0,
      corner3: (json['corner_3'] as int?) ?? 0,
      corner4: (json['corner_4'] as int?) ?? 0,
      last3f: (json['last_3f'] as String?) ?? '',
      finHorse: (json['fin_horse'] as String?) ?? '',
      finTimeDiff: (json['fin_time_diff'] as String?) ?? '',
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
    );
  }

  // "1800芝" → "芝" / "1000ダ" → "ダート" / "2000障" → "障害"
  static String _parseCourse(String raw) {
    final String abbr = raw.replaceAll(RegExp(r'\d'), '').trim();
    switch (abbr) {
      case 'ダ':
        return 'ダート';
      case '障':
        return '障害';
      default:
        return abbr.replaceAll('ダ', 'ダート');
    }
  }

  // "1800芝" → 1800
  static int _parseDist(String raw) {
    return int.tryParse(raw.replaceAll(RegExp(r'\D'), '')) ?? 0;
  }

  /// レコードID
  final int id;
  /// 馬名
  final String name;
  /// 開催日
  final String date;
  /// 競馬場
  final String basho;
  /// 競馬場コード
  final String bashoCode;
  /// レース番号
  final int race;
  /// レース名
  final String raceName;
  /// グレード（G1・G2 など）
  final String grade;
  /// 着順
  final int finishingPosition;
  /// 出走頭数
  final int numHorses;
  /// 枠番
  final int gate;
  /// 人気順
  final int popularity;
  /// 騎手名
  final String jockey;
  /// 斤量
  final String burdenWeight;
  /// コース種別（芝・ダート・障害）
  final String course;
  /// 距離（m）
  final int dist;
  /// 走破タイム
  final String time;
  /// 馬場状態
  final String condition;
  /// 馬体重
  final String horseWeight;
  /// 1コーナー通過順
  final int corner1;
  /// 2コーナー通過順
  final int corner2;
  /// 3コーナー通過順
  final int corner3;
  /// 4コーナー通過順
  final int corner4;
  /// 上がり3F
  final String last3f;
  /// 1着馬（自身が1着なら2着馬）
  final String finHorse;
  /// 1着馬とのタイム差
  final String finTimeDiff;
  /// 作成日時
  final String createdAt;
  /// 更新日時
  final String updatedAt;
}

/*

{
    "data": [
        {
            "id": 3390,
            "name": "グロスビーク",
            "date": "2025-03-15",
            "basho": "中山",
            "basho_code": "06",
            "race": 10,
            "race_name": "未勝利",
            "grade": "",
            "finishing_position": 1,
            "num_horses": 16,
            "gate": 8,
            "popularity": 1,
            "jockey": "C.ルメール",
            "burden_weight": "57.0kg",
            "dist": "1800芝",
            "time": "1:48.9",
            "condition": "良",
            "horse_weight": "470kg",
            "corner_1": 7,
            "corner_2": 5,
            "corner_3": 6,
            "corner_4": 6,
            "last_3f": "3F 35.1",
            "fin_horse": "サトノシャルレーヌ",
            "fin_time_diff": "0.3",
            "created_at": "2026-07-17 22:00:39",
            "updated_at": "2026-07-17 22:00:39"
        },

*/
