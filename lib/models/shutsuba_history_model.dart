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
      dist: (json['dist'] as String?) ?? '',
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

  final int id;
  final String name;
  final String date;
  final String basho;
  final String bashoCode;
  final int race;
  final String raceName;
  final String grade;
  final int finishingPosition;
  final int numHorses;
  final int gate;
  final int popularity;
  final String jockey;
  final String burdenWeight;
  final String dist;
  final String time;
  final String condition;
  final String horseWeight;
  final int corner1;
  final int corner2;
  final int corner3;
  final int corner4;
  final String last3f;
  final String finHorse;
  final String finTimeDiff;
  final String createdAt;
  final String updatedAt;
}
