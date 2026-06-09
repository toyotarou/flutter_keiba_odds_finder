import '../extensions/extensions.dart';

class SummaryModel {
  SummaryModel({
    required this.id,
    required this.horseName,
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.waku,
    required this.num,
    required this.oddsTanBefore24,
    required this.oddsTanBefore21,
    required this.oddsTanBefore18,
    required this.oddsTanBefore15,
    required this.oddsTanBefore12,
    required this.oddsTanBefore9,
    required this.oddsTanBefore6,
    required this.oddsTanBefore3,
    required this.oddsTanBefore0,
    required this.result,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      id: (json['id'] != null) ? json['id'].toString().toInt() : 0,
      horseName: json['horse_name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      kaisuu: json['kaisuu']?.toString() ?? '',
      basho: json['basho']?.toString() ?? '',
      bashoName: json['basho_name']?.toString() ?? '',
      day: (json['day'] != null) ? json['day'].toString().toInt() : 0,
      race: (json['race'] != null) ? json['race'].toString().toInt() : 0,
      raceName: json['race_name']?.toString() ?? '',
      waku: (json['waku'] != null) ? json['waku'].toString().toInt() : 0,
      num: (json['num'] != null) ? json['num'].toString().toInt() : 0,
      oddsTanBefore24: json['odds_tan_before_24']?.toString() ?? '',
      oddsTanBefore21: json['odds_tan_before_21']?.toString() ?? '',
      oddsTanBefore18: json['odds_tan_before_18']?.toString() ?? '',
      oddsTanBefore15: json['odds_tan_before_15']?.toString() ?? '',
      oddsTanBefore12: json['odds_tan_before_12']?.toString() ?? '',
      oddsTanBefore9: json['odds_tan_before_9']?.toString() ?? '',
      oddsTanBefore6: json['odds_tan_before_6']?.toString() ?? '',
      oddsTanBefore3: json['odds_tan_before_3']?.toString() ?? '',
      oddsTanBefore0: json['odds_tan_before_0']?.toString() ?? '',
      result: (json['result'] != null) ? json['result'].toString().toInt() : 0,
    );
  }

  final int id;
  final String horseName;
  final String date;
  final String kaisuu;
  final String basho;
  final String bashoName;
  final int day;
  final int race;
  final String raceName;
  final int waku;
  final int num;
  final String oddsTanBefore24;
  final String oddsTanBefore21;
  final String oddsTanBefore18;
  final String oddsTanBefore15;
  final String oddsTanBefore12;
  final String oddsTanBefore9;
  final String oddsTanBefore6;
  final String oddsTanBefore3;
  final String oddsTanBefore0;
  final int result;
}
