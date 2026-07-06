class RaceResultPayoutModel {
  RaceResultPayoutModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoCode,
    required this.day,
    required this.race,
    required this.raceName,
    required this.tan,
    required this.fuku,
    required this.waku,
    required this.wide,
    required this.umaren,
    required this.umatan,
    required this.trio,
    required this.trifecta,
  });

  factory RaceResultPayoutModel.fromJson(Map<String, dynamic> json) {
    return RaceResultPayoutModel(
      id: (json['id'] as int?) ?? 0,
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as int?) ?? 0,
      basho: (json['basho'] as String?) ?? '',
      bashoCode: (json['basho_code'] as String?) ?? '',
      day: (json['day'] as int?) ?? 0,
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      tan: (json['tan'] as String?) ?? '',
      fuku: (json['fuku'] as String?) ?? '',
      waku: (json['waku'] as String?) ?? '',
      wide: (json['wide'] as String?) ?? '',
      umaren: (json['umaren'] as String?) ?? '',
      umatan: (json['umatan'] as String?) ?? '',
      trio: (json['trio'] as String?) ?? '',
      trifecta: (json['trifecta'] as String?) ?? '',
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

  final String tan;
  final String fuku;
  final String waku;
  final String wide;
  final String umaren;
  final String umatan;
  final String trio;
  final String trifecta;
}
