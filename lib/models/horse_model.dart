import '../extensions/extensions.dart';

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
      id: (json['id'] != null) ? json['id'].toString().toInt() : 0,
      date: json['date']?.toString() ?? '',
      kaisuu: json['kaisuu']?.toString() ?? '',
      basho: json['basho']?.toString() ?? '',
      bashoName: json['basho_name']?.toString() ?? '',
      day: (json['day'] != null) ? json['day'].toString().toInt() : 0,
      race: (json['race'] != null) ? json['race'].toString().toInt() : 0,
      waku: (json['waku'] != null) ? json['waku'].toString().toInt() : 0,
      num: (json['num'] != null) ? json['num'].toString().toInt() : 0,
      name: json['name']?.toString() ?? '',
      horseUrl: json['horse_url']?.toString() ?? '',
      jockey: json['jockey']?.toString() ?? '',
      trainer: json['trainer']?.toString() ?? '',
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
