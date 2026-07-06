class RacesPopularityRatioModel {
  RacesPopularityRatioModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.numHorses,
    required this.popularityRatio,
  });

  factory RacesPopularityRatioModel.fromJson(Map<String, dynamic> json) {
    return RacesPopularityRatioModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: (json['day'] as String?) ?? '',
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      numHorses: (json['num_horses'] as int?) ?? 0,
      popularityRatio: (json['popularity_ratio'] as String?) ?? '',
    );
  }

  final int id;
  final String date;
  final String kaisuu;
  final String basho;
  final String bashoName;
  final String day;
  final int race;
  final String raceName;
  final int numHorses;
  final String popularityRatio;
}
