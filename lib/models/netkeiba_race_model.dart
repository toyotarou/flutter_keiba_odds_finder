// class NetkeibaRaceModel {
//   NetkeibaRaceModel({
//     required this.id,
//     required this.date,
//     required this.kaisuu,
//     required this.basho,
//     required this.bashoName,
//     required this.day,
//     required this.raceId,
//     required this.race,
//     required this.raceName,
//     required this.startTime,
//     required this.numHorses,
//   });
//
//   factory NetkeibaRaceModel.fromJson(Map<String, dynamic> json) {
//     return NetkeibaRaceModel(
//       id: (json['id'] as int?) ?? 0,
//       date: (json['date'] as String?) ?? '',
//       kaisuu: (json['kaisuu'] as String?) ?? '',
//       basho: (json['basho'] as String?) ?? '',
//       bashoName: (json['basho_name'] as String?) ?? '',
//       day: int.tryParse((json['day'] as String?) ?? '0') ?? 0,
//       raceId: (json['race_id'] as String?) ?? '',
//       race: (json['race'] as int?) ?? 0,
//       raceName: (json['race_name'] as String?) ?? '',
//       startTime: (json['start_time'] as String?) ?? '',
//       numHorses: (json['num_horses'] as int?) ?? 0,
//     );
//   }
//
//   final int id;
//   final String date;
//   final String kaisuu;
//   final String basho;
//   final String bashoName;
//   final int day;
//   final String raceId;
//   final int race;
//   final String raceName;
//   final String startTime;
//   final int numHorses;
//
//   Map<String, dynamic> toJson() {
//     return <String, dynamic>{
//       'id': id,
//       'date': date,
//       'kaisuu': kaisuu,
//       'basho': basho,
//       'basho_name': bashoName,
//       'day': day,
//       'race_id': raceId,
//       'race': race,
//       'race_name': raceName,
//       'start_time': startTime,
//       'num_horses': numHorses,
//     };
//   }
// }
