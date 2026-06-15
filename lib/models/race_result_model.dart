class RaceResultModel {
  RaceResultModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.num,
    required this.horseName,
    required this.result,
  });

  factory RaceResultModel.fromJson(Map<String, dynamic> json) {
    return RaceResultModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      num: (json['num'] as int?) ?? 0,
      horseName: (json['horse_name'] as String?) ?? '',
      result: (json['result'] as int?) ?? 0,
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
  final int num;
  final String horseName;
  final int result;
}
