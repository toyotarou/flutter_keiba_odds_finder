class HorseModel {
  HorseModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.waku,
    required this.num,
    required this.name,
    required this.horseUrl,
    required this.jockey,
    required this.trainer,
  });

  factory HorseModel.fromJson(Map<String, dynamic> json) {
    return HorseModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
      race: (json['race'] as int?) ?? 0,
      waku: (json['waku'] as int?) ?? 0,
      num: (json['num'] as int?) ?? 0,
      name: (json['name'] as String?) ?? '',
      horseUrl: (json['horse_url'] as String?) ?? '',
      jockey: (json['jockey'] as String?) ?? '',
      trainer: (json['trainer'] as String?) ?? '',
    );
  }

  final int id;
  final String date;
  final String kaisuu;
  final String basho;
  final String bashoName;
  final int day;
  final int race;
  final int waku;
  final int num;
  final String name;
  final String horseUrl;
  final String jockey;
  final String trainer;
}
