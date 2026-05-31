import '../extensions/extensions.dart';

class OddsGetTimingModel {
  OddsGetTimingModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.day,
    required this.race,
    required this.timing,
    required this.getDatetime,
    required this.oddsFrom,
  });

  factory OddsGetTimingModel.fromJson(Map<String, dynamic> json) {
    return OddsGetTimingModel(
      id: (json['id'] != null) ? json['id'].toString().toInt() : 0,
      date: json['date']?.toString() ?? '',
      kaisuu: json['kaisuu']?.toString() ?? '',
      basho: json['basho']?.toString() ?? '',
      day: (json['day'] != null) ? json['day'].toString().toInt() : 0,
      race: (json['race'] != null) ? json['race'].toString().toInt() : 0,
      timing: (json['timing'] != null) ? json['timing'].toString().toInt() : 0,
      getDatetime: json['get_datetime']?.toString() ?? '',
      oddsFrom: json['odds_from']?.toString() ?? '',
    );
  }

  final int id;
  final String date;
  final String kaisuu;
  final String basho;
  final int day;
  final int race;
  final int timing;
  final String getDatetime;
  final String oddsFrom;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'date': date,
      'kaisuu': kaisuu,
      'basho': basho,
      'day': day,
      'race': race,
      'timing': timing,
      'get_datetime': getDatetime,
      'odds_from': oddsFrom,
    };
  }
}
