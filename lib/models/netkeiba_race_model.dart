import '../extensions/extensions.dart';

class NetkeibaRaceModel {
  NetkeibaRaceModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.raceId,
    required this.race,
    required this.raceName,
    required this.startTime,
    required this.numHorses,
  });

  factory NetkeibaRaceModel.fromJson(Map<String, dynamic> json) {
    return NetkeibaRaceModel(
      id: (json['id'] != null) ? json['id'].toString().toInt() : 0,
      date: json['date']?.toString() ?? '',
      kaisuu: json['kaisuu']?.toString() ?? '',
      basho: json['basho']?.toString() ?? '',
      bashoName: json['basho_name']?.toString() ?? '',
      day: (json['day'] != null) ? json['day'].toString().toInt() : 0,
      raceId: json['race_id']?.toString() ?? '',
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
  final String raceId;
  final int race;
  final String raceName;
  final String startTime;
  final int numHorses;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date,
      'kaisuu': kaisuu,
      'basho': basho,
      'basho_name': bashoName,
      'day': day,
      'race_id': raceId,
      'race': race,
      'race_name': raceName,
      'start_time': startTime,
      'num_horses': numHorses,
    };
  }
}
