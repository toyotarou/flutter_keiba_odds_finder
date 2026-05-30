import '../extensions/extensions.dart';

class RaceModel {
  RaceModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.startTime,
    required this.numHorses,
  });

  factory RaceModel.fromJson(Map<String, dynamic> json) {
    return RaceModel(
      id: (json['id'] != null) ? json['id'].toString().toInt() : 0,
      date: json['date']?.toString() ?? '',
      kaisuu: json['kaisuu']?.toString() ?? '',
      basho: json['basho']?.toString() ?? '',
      bashoName: json['basho_name']?.toString() ?? '',
      day: (json['day'] != null) ? json['day'].toString().toInt() : 0,
      race: (json['race'] != null) ? json['race'].toString().toInt() : 0,
      raceName: json['race_name']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      numHorses: (json['num_horses'] != null) ? json['num_horses'].toString().toInt() : 0,
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
  final String startTime;
  final int numHorses;
}
