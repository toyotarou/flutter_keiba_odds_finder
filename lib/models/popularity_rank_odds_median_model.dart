class PopularityRankOddsMedianModel {
  PopularityRankOddsMedianModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.median01,
    required this.median02,
    required this.median03,
    required this.median04,
    required this.median05,
    required this.median06,
    required this.median07,
    required this.median08,
    required this.median09,
    required this.median10,
    required this.median11,
    required this.median12,
    required this.median13,
    required this.median14,
    required this.median15,
    required this.median16,
    required this.median17,
    required this.median18,
  });

  factory PopularityRankOddsMedianModel.fromJson(Map<String, dynamic> json) {
    return PopularityRankOddsMedianModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: (json['day'] as String?) ?? '',
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',

      median01: (json['median_01'] as String?) ?? '',
      median02: (json['median_02'] as String?) ?? '',
      median03: (json['median_03'] as String?) ?? '',
      median04: (json['median_04'] as String?) ?? '',
      median05: (json['median_05'] as String?) ?? '',
      median06: (json['median_06'] as String?) ?? '',
      median07: (json['median_07'] as String?) ?? '',
      median08: (json['median_08'] as String?) ?? '',
      median09: (json['median_09'] as String?) ?? '',
      median10: (json['median_10'] as String?) ?? '',
      median11: (json['median_11'] as String?) ?? '',
      median12: (json['median_12'] as String?) ?? '',
      median13: (json['median_13'] as String?) ?? '',
      median14: (json['median_14'] as String?) ?? '',
      median15: (json['median_15'] as String?) ?? '',
      median16: (json['median_16'] as String?) ?? '',
      median17: (json['median_17'] as String?) ?? '',
      median18: (json['median_18'] as String?) ?? '',
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

  final String median01;
  final String median02;
  final String median03;
  final String median04;
  final String median05;
  final String median06;
  final String median07;
  final String median08;
  final String median09;
  final String median10;
  final String median11;
  final String median12;
  final String median13;
  final String median14;
  final String median15;
  final String median16;
  final String median17;
  final String median18;
}
