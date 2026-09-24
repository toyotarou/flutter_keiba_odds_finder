import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/odds_model.dart';
import '../../utility/utility.dart';

part 'odds.freezed.dart';

part 'odds.g.dart';

@freezed
class OddsState with _$OddsState {
  const factory OddsState({
    @Default(<OddsModel>[]) List<OddsModel> oddsList,

    @Default(<String, List<OddsModel>>{}) Map<String, List<OddsModel>> oddsMap,
  }) = _OddsState;
}

@riverpod
class Odds extends _$Odds {
  final Utility utility = Utility();

  ///
  @override
  OddsState build() => const OddsState();

  //============================================== api

  ///
  Future<OddsState> fetchAllOddsData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final List<OddsModel> list = <OddsModel>[];

      final Map<String, List<OddsModel>> map = <String, List<OddsModel>>{};

      // ignore: always_specify_types
      await client.get(path: APIPath.getHorseOddsFinderOdds).then((value) {
        // ignore: avoid_dynamic_calls
        for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
          // ignore: avoid_dynamic_calls
          final OddsModel val = OddsModel.fromJson(value['data'][i] as Map<String, dynamic>);

          list.add(val);

          (map['${val.date}_${val.kaisuu}_${val.basho}_${val.day}'] ??= <OddsModel>[]).add(val);
        }
      });

      return state.copyWith(oddsList: list, oddsMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllOddsData() async {
    try {
      final OddsState newState = await fetchAllOddsData();

      state = newState;
    } catch (_) {}
  }

  /// 指定した1レース分のオッズだけを再取得して oddsList / oddsMap に差し替える（20260924 追加）
  ///
  /// WebSocket のオッズ更新通知（1レース単位）を受けたときに使う。
  /// 従来は通知のたびに全レース・全時点のオッズ（数千件）を再取得していたため、
  /// 該当レース分（数十〜200件程度）だけ取得して差し替えることで通信量と処理を軽くする。
  /// サーバーが絞り込みパラメータに未対応でも、受信データを該当レース分に絞ってから差し替えるので結果は同じ。
  /// 取得に失敗した場合・該当データが0件の場合は、従来どおり全件再取得に切り替える。
  Future<void> refreshRaceOdds({
    required String date,
    required String kaisuu,
    required String basho,
    required String day,
    required int race,
  }) async {
    final HttpClient client = ref.read(httpClientProvider);

    final int dayInt = int.tryParse(day) ?? 0;

    try {
      final List<OddsModel> fetched = <OddsModel>[];

      // ignore: always_specify_types
      await client
          .get(
            path: APIPath.getHorseOddsFinderOdds,
            queryParameters: <String, dynamic>{
              'date': date,
              'kaisuu': kaisuu,
              'basho': basho,
              'day': day,
              'race': race.toString(),
            },
          )
          // ignore: always_specify_types
          .then((value) {
            // ignore: avoid_dynamic_calls
            for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
              // ignore: avoid_dynamic_calls
              final OddsModel val = OddsModel.fromJson(value['data'][i] as Map<String, dynamic>);

              if (val.date == date &&
                  val.kaisuu == kaisuu &&
                  val.basho == basho &&
                  val.day == dayInt &&
                  val.race == race) {
                fetched.add(val);
              }
            }
          });

      if (fetched.isEmpty) {
        await getAllOddsData();
        return;
      }

      bool isTargetRace(OddsModel e) =>
          e.date == date && e.kaisuu == kaisuu && e.basho == basho && e.day == dayInt && e.race == race;

      // 並び順は全件取得時（race → num → minutes_before_start の昇順）に合わせる
      int compareOdds(OddsModel a, OddsModel b) {
        final int r = a.race.compareTo(b.race);
        if (r != 0) {
          return r;
        }
        final int n = a.num.compareTo(b.num);
        if (n != 0) {
          return n;
        }
        return a.minutesBeforeStart.compareTo(b.minutesBeforeStart);
      }

      final String mapKey = '${date}_${kaisuu}_${basho}_$dayInt';

      final List<OddsModel> newList = <OddsModel>[
        ...state.oddsList.where((OddsModel e) => !isTargetRace(e)),
        ...fetched,
      ];

      final Map<String, List<OddsModel>> newMap = <String, List<OddsModel>>{...state.oddsMap};
      newMap[mapKey] = <OddsModel>[
        ...(state.oddsMap[mapKey] ?? <OddsModel>[]).where((OddsModel e) => !isTargetRace(e)),
        ...fetched,
      ]..sort(compareOdds);

      state = state.copyWith(oddsList: newList, oddsMap: newMap);
    } catch (_) {
      await getAllOddsData();
    }
  }

  //============================================== api
}
