class RaceIntrospectionModel {
  RaceIntrospectionModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoCode,
    required this.day,
    required this.race,
    required this.raceName,
    required this.introspection,
    required this.finish,
  });

  factory RaceIntrospectionModel.fromJson(Map<String, dynamic> json) {
    return RaceIntrospectionModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as int?) ?? 0,
      basho: (json['basho'] as String?) ?? '',
      bashoCode: (json['basho_code'] as String?) ?? '',
      day: (json['day'] as int?) ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      introspection: (json['introspection'] as String?) ?? '',
      finish: (json['finish'] as int?) ?? 0,
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
  final String introspection;
  final int finish;
}
