import 'package:flutter/material.dart';

import '../models/odds_model.dart';
import '../models/popularity_rank_odds_median_model.dart';

/// 着順に応じた色を返す。
Color raceRankColor(int? rank, {double alpha = 0.5, Color fallback = Colors.transparent}) => switch (rank) {
  1 => const Color(0xFFFFD700).withValues(alpha: alpha),
  2 => const Color(0xFFC0C0C0).withValues(alpha: alpha),
  3 => const Color(0xFFCD7F32).withValues(alpha: alpha),
  _ => fallback,
};

/// 人気順位に対応する過去中央値オッズを返す（rank は 1 始まり）。
String medianByRank(PopularityRankOddsMedianModel model, int rank) {
  final List<String> medians = <String>[
    model.median01,
    model.median02,
    model.median03,
    model.median04,
    model.median05,
    model.median06,
    model.median07,
    model.median08,
    model.median09,
    model.median10,
    model.median11,
    model.median12,
    model.median13,
    model.median14,
    model.median15,
    model.median16,
    model.median17,
    model.median18,
  ];
  if (rank < 1 || rank > medians.length) {
    return '';
  }
  return medians[rank - 1];
}

/// 6分前オッズを昇順に並べ、馬番 → 人気順位（1始まり）のマップを返す。
Map<int, int> buildSixMinRankMap(Map<int, String> sixMinOddsMap) {
  final List<MapEntry<int, double>> sorted =
      sixMinOddsMap.entries
          .map((MapEntry<int, String> e) => MapEntry<int, double>(e.key, double.tryParse(e.value) ?? double.infinity))
          .toList()
        ..sort((MapEntry<int, double> a, MapEntry<int, double> b) => a.value.compareTo(b.value));
  return <int, int>{for (int i = 0; i < sorted.length; i++) sorted[i].key: i + 1};
}

/// 期待数値スコア（過去中央値オッズ ÷ 現在オッズ）の上位 pickupCount 頭の
/// displayList 内インデックス（1始まり）を Set で返す。
///
/// sixMinOddsMap を渡すと 6分前オッズ基準でスコアを計算する（予想総括ダイアログ用）。
/// 省略した場合は displayList のオッズと順位をそのまま使う（メイン行・選択タイミング基準）。
/// score > 1.0 → 過去より割安、score < 1.0 → 過去より割高。
Set<int> calcPickupPopularitySet(
  List<OddsModel> displayList,
  PopularityRankOddsMedianModel medianModel,
  int pickupCount, {
  Map<int, String>? sixMinOddsMap,
}) {
  final Map<int, int> sixMinRankMap = (sixMinOddsMap != null && sixMinOddsMap.isNotEmpty)
      ? buildSixMinRankMap(sixMinOddsMap)
      : <int, int>{};

  final List<MapEntry<int, double>> scored = displayList.asMap().entries.map((MapEntry<int, OddsModel> e) {
    final int displayRank = e.key + 1;
    final int medianRank = sixMinRankMap[e.value.num] ?? displayRank;

    final double? parsedSixMin = double.tryParse(sixMinOddsMap?[e.value.num] ?? '');
    final double oddsVal = (parsedSixMin != null && parsedSixMin > 0)
        ? parsedSixMin
        : (double.tryParse(e.value.odds) ?? 0);

    double score = 0;
    if (oddsVal > 0) {
      final double median = double.tryParse(medianByRank(medianModel, medianRank)) ?? 0;
      if (median > 0) {
        score = median / oddsVal;
      }
    }
    return MapEntry<int, double>(displayRank, score);
  }).toList()..sort((MapEntry<int, double> a, MapEntry<int, double> b) => b.value.compareTo(a.value));

  return scored.take(pickupCount).map((MapEntry<int, double> e) => e.key).toSet();
}
