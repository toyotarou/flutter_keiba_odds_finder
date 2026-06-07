class OddsModel {
  OddsModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.day,
    required this.race,
    required this.num,
    required this.odds,
    required this.fukuMin,
    required this.fukuMax,
    required this.minutesBeforeStart,
  });

  factory OddsModel.fromJson(Map<String, dynamic> json) {
    return OddsModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      num: (json['num'] as int?) ?? 0,
      odds: (json['odds'] as String?) ?? '',
      fukuMin: (json['fuku_min'] as String?) ?? '',
      fukuMax: (json['fuku_max'] as String?) ?? '',
      minutesBeforeStart: (json['minutes_before_start'] as int?) ?? 0,
    );
  }

  final int id;
  final String date;
  final String kaisuu;
  final String basho;
  final int day;
  final int race;
  final int num;
  final String odds;
  final String fukuMin;
  final String fukuMax;
  final int minutesBeforeStart;
}
