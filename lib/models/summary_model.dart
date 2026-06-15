class SummaryModel {
  SummaryModel({
    required this.id,
    required this.horseName,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.waku,
    required this.num,
    required this.oddsTanBefore24,
    required this.oddsTanBefore21,
    required this.oddsTanBefore18,
    required this.oddsTanBefore15,
    required this.oddsTanBefore12,
    required this.oddsTanBefore9,
    required this.oddsTanBefore6,
    required this.oddsTanBefore3,
    required this.oddsTanBefore0,
    required this.result,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: (json['id'] as int?) ?? 0,
      horseName: (json['horse_name'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      waku: (json['waku'] as int?) ?? 0,
      num: (json['num'] as int?) ?? 0,
      oddsTanBefore24: (json['odds_tan_before_24'] as String?) ?? '',
      oddsTanBefore21: (json['odds_tan_before_21'] as String?) ?? '',
      oddsTanBefore18: (json['odds_tan_before_18'] as String?) ?? '',
      oddsTanBefore15: (json['odds_tan_before_15'] as String?) ?? '',
      oddsTanBefore12: (json['odds_tan_before_12'] as String?) ?? '',
      oddsTanBefore9: (json['odds_tan_before_9'] as String?) ?? '',
      oddsTanBefore6: (json['odds_tan_before_6'] as String?) ?? '',
      oddsTanBefore3: (json['odds_tan_before_3'] as String?) ?? '',
      oddsTanBefore0: (json['odds_tan_before_0'] as String?) ?? '',
      result: (json['result'] as int?) ?? 0,
    );
  }

  final int id;
  final String horseName;
  final String date;
  final String kaisuu;
  final String basho;
  final String bashoName;
  final int day;
  final int race;
  final String raceName;
  final int waku;
  final int num;
  final String oddsTanBefore24;
  final String oddsTanBefore21;
  final String oddsTanBefore18;
  final String oddsTanBefore15;
  final String oddsTanBefore12;
  final String oddsTanBefore9;
  final String oddsTanBefore6;
  final String oddsTanBefore3;
  final String oddsTanBefore0;
  final int result;
}
