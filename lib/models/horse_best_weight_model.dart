class HorseBestWeightModel {
  HorseBestWeightModel({
    required this.name,
    required this.bestFinishingPosition,
    required this.date,
    required this.basho,
    required this.bashoCode,
    required this.kaisuu,
    required this.day,
    required this.race,
    required this.raceName,
    required this.horseWeight,
  });

  factory HorseBestWeightModel.fromJson(Map<String, dynamic> json) {
    return HorseBestWeightModel(
      name: (json['name'] as String?) ?? '',
      bestFinishingPosition: (json['best_finishing_position'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoCode: (json['basho_code'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as int?) ?? 0,
      day: (json['day'] as int?) ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      horseWeight: (json['horse_weight'] as String?) ?? '',
    );
  }

  final String name;
  final int bestFinishingPosition;
  final String date;
  final String basho;
  final String bashoCode;
  final int kaisuu;
  final int day;
  final int race;
  final String raceName;
  final String horseWeight;
}
