// ── 20261025: 「r12.2」確認ボタンを外したので、このファイルは使いません。ファイルごとコメントアウトしています（消していません）──
// // @ANCHOR-20261020-R122-FLUTTER  r12.2 読取APIのコントローラ
// //   GET /api/baganriki/r12-2/races/{race_id}
// //
// //   読み取りだけです。AIの送信も再選出も起こしません。
// //   race_id をキーにして、1レースぶんずつ持ちます。
// import 'package:freezed_annotation/freezed_annotation.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// import '../../data/http/client.dart';
// import '../../data/http/path.dart';
// import '../../models/baganriki_published_prediction_model.dart';
// import '../../utility/utility.dart';
//
// part 'baganriki_published_prediction.freezed.dart';
//
// part 'baganriki_published_prediction.g.dart';
//
// @freezed
// class BaganrikiPublishedPredictionState with _$BaganrikiPublishedPredictionState {
//   const factory BaganrikiPublishedPredictionState({
//     @Default(<String, BaganrikiPublishedPredictionModel>{}) Map<String, BaganrikiPublishedPredictionModel> raceMap,
//     @Default(<String>{}) Set<String> loadingRaceIds,
//     @Default(<String, String>{}) Map<String, String> errorMap,
//   }) = _BaganrikiPublishedPredictionState;
// }
//
// @riverpod
// class BaganrikiPublishedPrediction extends _$BaganrikiPublishedPrediction {
//   final Utility utility = Utility();
//
//   ///
//   @override
//   BaganrikiPublishedPredictionState build() => const BaganrikiPublishedPredictionState();
//
//   //============================================== api
//
//   /// 1レースぶん読みます。読めなければ errorMap に理由を残します。
//   Future<BaganrikiPublishedPredictionState> fetchPublishedPrediction({required String raceId}) async {
//     final HttpClient client = ref.read(httpClientProvider);
//
//     final Map<String, BaganrikiPublishedPredictionModel> map = Map<String, BaganrikiPublishedPredictionModel>.of(state.raceMap);
//     final Map<String, String> errors = Map<String, String>.of(state.errorMap);
//
//     try {
//       // ignore: always_specify_types
//       final value = await client.get(path: APIPath.getBaganrikiPublishedPredictionRace, pathSuffix: raceId);
//
//       if (value is Map<String, dynamic>) {
//         map[raceId] = BaganrikiPublishedPredictionModel.fromJson(value);
//         errors.remove(raceId);
//       } else {
//         errors[raceId] = '読取APIの形が違います';
//       }
//     } catch (e) {
//       // 404（そのレースが正本に無い）や通信失敗を、画面を止めずに持ちます。
//       errors[raceId] = e.toString();
//     }
//
//     return state.copyWith(raceMap: map, errorMap: errors);
//   }
//
//   /// 画面から呼ぶ入口。読み込み中の race_id を持っておき、二重に呼びません。
//   Future<void> getPublishedPrediction({required String raceId}) async {
//     if (raceId.isEmpty) {
//       return;
//     }
//     if (state.loadingRaceIds.contains(raceId)) {
//       return;
//     }
//
//     state = state.copyWith(loadingRaceIds: <String>{...state.loadingRaceIds, raceId});
//
//     try {
//       final BaganrikiPublishedPredictionState newState = await fetchPublishedPrediction(raceId: raceId);
//
//       final Set<String> loading = <String>{...newState.loadingRaceIds}..remove(raceId);
//
//       state = newState.copyWith(loadingRaceIds: loading);
//     } catch (_) {
//       final Set<String> loading = <String>{...state.loadingRaceIds}..remove(raceId);
//
//       state = state.copyWith(loadingRaceIds: loading);
//     }
//   }
//
//   /// 取り直します（取消やライブ状態が動いたあと）。
//   Future<void> reloadPublishedPrediction({required String raceId}) async {
//     final Set<String> loading = <String>{...state.loadingRaceIds}..remove(raceId);
//
//     state = state.copyWith(loadingRaceIds: loading);
//
//     await getPublishedPrediction(raceId: raceId);
//   }
//
//   //============================================== api
//
//   /// 読み込み済みの1レース（無ければ null）
//   BaganrikiPublishedPredictionModel? raceOf(String raceId) => state.raceMap[raceId];
//
//   /// その race_id の読み込み中かどうか
//   bool isLoading(String raceId) => state.loadingRaceIds.contains(raceId);
//
//   /// その race_id の読めなかった理由（無ければ空）
//   String errorOf(String raceId) => state.errorMap[raceId] ?? '';
// }
