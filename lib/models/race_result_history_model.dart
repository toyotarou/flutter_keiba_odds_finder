class RaceResultHistoryModel {
  RaceResultHistoryModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoCode,
    required this.day,
    required this.race,
    required this.raceName,
    required this.num,
    required this.name,
    required this.tan,
    required this.fukuMin,
    required this.fukuMax,
    required this.popularityRank,
  });

  factory RaceResultHistoryModel.fromJson(Map<String, dynamic> json) {
    return RaceResultHistoryModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as int?) ?? 0,
      basho: (json['basho'] as String?) ?? '',
      bashoCode: (json['basho_code'] as String?) ?? '',
      day: (json['day'] as int?) ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      num: (json['num'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      tan: (json['tan'] as String?) ?? '',
      fukuMin: (json['fuku_min'] as String?) ?? '',
      fukuMax: (json['fuku_max'] as String?) ?? '',
      popularityRank: (json['popularity_rank'] as int?) ?? 0,
    );
  }

  final int id;
  final String date;
  final int kaisuu;
  final String basho;
  final String bashoCode;
  final int day;
  final int race;
  final String raceName;
  final int num;
  final String name;
  final String tan;
  final String fukuMin;
  final String fukuMax;
  final int popularityRank;
}

/*

https://baganriki.com/api/getHorseOddsFinderRaceResultHistory?rank=1


*/
