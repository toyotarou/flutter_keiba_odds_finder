import '../extensions/extensions.dart';

class OddsWideModel {
  OddsWideModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.day,
    required this.race,
    required this.uma1,
    required this.uma2,
    required this.oddsMin,
    required this.oddsMax,
    required this.minutesBeforeStart,
  });

  factory OddsWideModel.fromJson(Map<String, dynamic> json) {
    return OddsWideModel(
      id: (json['id'] != null) ? json['id'].toString().toInt() : 0,
      date: json['date']?.toString() ?? '',
      kaisuu: json['kaisuu']?.toString() ?? '',
      basho: json['basho']?.toString() ?? '',
      day: (json['day'] != null) ? json['day'].toString().toInt() : 0,
      race: (json['race'] != null) ? json['race'].toString().toInt() : 0,
      uma1: (json['uma1'] != null) ? json['uma1'].toString().toInt() : 0,
      uma2: (json['uma2'] != null) ? json['uma2'].toString().toInt() : 0,
      oddsMin: json['odds_min']?.toString() ?? '',
      oddsMax: json['odds_max']?.toString() ?? '',
      minutesBeforeStart: (json['minutes_before_start'] != null) ? json['minutes_before_start'].toString().toInt() : 0,
    );
  }

  final int id;
  final String date;
  final String kaisuu;
  final String basho;
  final int day;
  final int race;
  final int uma1;
  final int uma2;
  final String oddsMin;
  final String oddsMax;
  final int minutesBeforeStart;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date,
      'kaisuu': kaisuu,
      'basho': basho,
      'day': day,
      'race': race,
      'uma1': uma1,
      'uma2': uma2,
      'odds_min': oddsMin,
      'odds_max': oddsMax,
      'minutes_before_start': minutesBeforeStart,
    };
  }
}
