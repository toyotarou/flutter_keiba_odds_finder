class OddsWideModel {
  OddsWideModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.day,
    required this.race,
    required this.uma1,
    required this.uma2,
    required this.oddsMin,
    required this.oddsMax,
    required this.minutesBeforeStart,
  });

  factory OddsWideModel.fromJson(Map<String, dynamic> json) {
    return OddsWideModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      uma1: (json['uma1'] as int?) ?? 0,
      uma2: (json['uma2'] as int?) ?? 0,
      oddsMin: (json['odds_min'] as String?) ?? '',
      oddsMax: (json['odds_max'] as String?) ?? '',
      minutesBeforeStart: (json['minutes_before_start'] as int?) ?? 0,
    );
  }

  final int id;
  final String date;
  final String kaisuu;
  final String basho;
  final int day;
  final int race;
  final int uma1;
  final int uma2;
  final String oddsMin;
  final String oddsMax;
  final int minutesBeforeStart;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date,
      'kaisuu': kaisuu,
      'basho': basho,
      'day': day,
      'race': race,
      'uma1': uma1,
      'uma2': uma2,
      'odds_min': oddsMin,
      'odds_max': oddsMax,
      'minutes_before_start': minutesBeforeStart,
    };
  }
}
