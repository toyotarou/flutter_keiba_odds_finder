class OddsGetTimingModel {
  OddsGetTimingModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.day,
    required this.race,
    required this.timing,
    required this.getDatetime,
    required this.oddsFrom,
  });

  factory OddsGetTimingModel.fromJson(Map<String, dynamic> json) {
    return OddsGetTimingModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      timing: (json['timing'] as int?) ?? 0,
      getDatetime: (json['get_datetime'] as String?) ?? '',
      oddsFrom: (json['odds_from'] as String?) ?? '',
    );
  }

  final int id;
  final String date;
  final String kaisuu;
  final String basho;
  final int day;
  final int race;
  final int timing;
  final String getDatetime;
  final String oddsFrom;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date,
      'kaisuu': kaisuu,
      'basho': basho,
      'day': day,
      'race': race,
      'timing': timing,
      'get_datetime': getDatetime,
      'odds_from': oddsFrom,
    };
  }
}
