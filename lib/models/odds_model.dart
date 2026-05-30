import '../extensions/extensions.dart';

class OddsModel {
  OddsModel({
    required this.id,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.day,
    required this.race,
    required this.num,
    required this.odds,
    required this.minutesBeforeStart,
  });

  factory OddsModel.fromJson(Map<String, dynamic> json) {
    return OddsModel(
      id: (json['id'] != null) ? json['id'].toString().toInt() : 0,
      date: json['date']?.toString() ?? '',
      kaisuu: json['kaisuu']?.toString() ?? '',
      basho: json['basho']?.toString() ?? '',
      day: (json['day'] != null) ? json['day'].toString().toInt() : 0,
      race: (json['race'] != null) ? json['race'].toString().toInt() : 0,
      num: (json['num'] != null) ? json['num'].toString().toInt() : 0,
      odds: json['odds']?.toString() ?? '',
      minutesBeforeStart: (json['minutes_before_start'] != null) ? json['minutes_before_start'].toString().toInt() : 0,
    );
  }

  final int id;
  final String date;
  final String kaisuu;
  final String basho;
  final int day;
  final int race;
  final int num;
  final String odds;
  final int minutesBeforeStart;
}
