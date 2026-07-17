class RaceModel {
  RaceModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.startTime,
    required this.numHorses,
    required this.popularityRatio,
    required this.popularityRatioTableIds,
    required this.popularityRatioMatchPercent,

    required this.course,
    required this.dist,
  });

  factory RaceModel.fromJson(Map<String, dynamic> json) {
    return RaceModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      startTime: (json['start_time'] as String?) ?? '',
      numHorses: (json['num_horses'] as int?) ?? 0,
      popularityRatio: (json['popularity_ratio'] as String?) ?? '',
      popularityRatioTableIds: (json['popularity_ratio_table_ids'] as String?) ?? '',
      popularityRatioMatchPercent: (json['popularity_ratio_match_percent'] as String?) ?? '',

      course: (json['course'] as String?) ?? '',
      dist: (json['dist'] as int?) ?? 0,
    );
  }

  final int id;
  final String date;
  final String kaisuu;
  final String basho;
  final String bashoName;
  final int day;
  final int race;
  final String raceName;
  final String startTime;
  final int numHorses;
  final String popularityRatio;
  final String popularityRatioTableIds;
  final String popularityRatioMatchPercent;

  final String course;
  final int dist;
}
