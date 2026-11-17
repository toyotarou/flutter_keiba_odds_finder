// =============================================================================
// ファイル名   : race_analysis_model.dart
// 概要         : 類似レース分析の結果（レース単位と、馬ごとの勝率・回収率など）を保持するモデル群。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-13
// 最終更新日   : 2026-11-17
// =============================================================================

/// 類似レース分析の結果（レース単位）。
class RaceAnalysisModel {

  RaceAnalysisModel({
    required this.date,
    required this.kaisuu,
    required this.basho,
    required this.bashoName,
    required this.day,
    required this.race,
    required this.raceName,
    required this.similarCount,
    required this.similarIds,
    required this.horses,
  });

  factory RaceAnalysisModel.fromJson(Map<String, dynamic> json) {
    return RaceAnalysisModel(
      date: (json['date'] as String?) ?? '',
      kaisuu: (json['kaisuu'] as String?) ?? '',
      basho: (json['basho'] as String?) ?? '',
      bashoName: (json['basho_name'] as String?) ?? '',
      day: (json['day'] as String?) ?? '',
      race: (json['race'] as int?) ?? 0,
      raceName: (json['race_name'] as String?) ?? '',
      similarCount: (json['similar_count'] as int?) ?? 0,
      // ignore: always_specify_types
      similarIds: (json['similar_ids'] as List<dynamic>? ?? <dynamic>[]).map((e) => e as String).toList(),
      horses: (json['horses'] as List<dynamic>? ?? <dynamic>[])
          // ignore: always_specify_types
          .map((e) => HorseOddsFinderSimilarRaceHorseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
  /// 開催日
  final String date;
  /// 開催回（第何回の開催か）
  final String kaisuu;
  /// 競馬場
  final String basho;
  /// 競馬場名
  final String bashoName;
  /// 開催日目（何日目か）
  final String day;
  /// レース番号
  final int race;
  /// レース名
  final String raceName;
  /// 類似レースの件数
  final int similarCount;
  /// 類似レースのID一覧
  final List<String> similarIds;
  /// 馬ごとの分析結果
  final List<HorseOddsFinderSimilarRaceHorseModel> horses;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date,
      'kaisuu': kaisuu,
      'basho': basho,
      'basho_name': bashoName,
      'day': day,
      'race': race,
      'race_name': raceName,
      'similar_count': similarCount,
      'similar_ids': similarIds,
      'horses': horses.map((HorseOddsFinderSimilarRaceHorseModel e) => e.toJson()).toList(),
    };
  }
}

/// 類似レース分析の結果（馬1頭分）。
class HorseOddsFinderSimilarRaceHorseModel {

  HorseOddsFinderSimilarRaceHorseModel({
    required this.num,
    required this.popularityRank,
    required this.oddsBase,
    required this.oddsNow,
    required this.oddsChangeRate,
    required this.fukuMin,
    required this.winCount,
    required this.placeCount,
    required this.winRate,
    required this.placeRate,
    required this.tanReturnRate,
    required this.fukuReturnRate,
    required this.analysis,
  });

  factory HorseOddsFinderSimilarRaceHorseModel.fromJson(Map<String, dynamic> json) {
    return HorseOddsFinderSimilarRaceHorseModel(
      num: (json['num'] as int?) ?? 0,
      popularityRank: (json['popularity_rank'] as int?) ?? 0,
      oddsBase: _d(json['odds_base']),
      oddsNow: _d(json['odds_now']),
      oddsChangeRate: _d(json['odds_change_rate']),
      fukuMin: _d(json['fuku_min']),
      winCount: (json['win_count'] as int?) ?? 0,
      placeCount: (json['place_count'] as int?) ?? 0,
      winRate: _d(json['win_rate']),
      placeRate: _d(json['place_rate']),
      tanReturnRate: _d(json['tan_return_rate']),
      fukuReturnRate: _d(json['fuku_return_rate']),
      analysis: (json['analysis'] as String?) ?? '',
    );
  }
  /// 馬番
  final int num;
  /// 人気順
  final int popularityRank;
  /// 基準時点の単勝オッズ
  final double oddsBase;
  /// 現在の単勝オッズ
  final double oddsNow;
  /// オッズの変化率
  final double oddsChangeRate;
  /// 複勝オッズ（下限）
  final double fukuMin;
  /// 類似レースでの1着回数
  final int winCount;
  /// 類似レースでの3着以内回数
  final int placeCount;
  /// 勝率
  final double winRate;
  /// 複勝率
  final double placeRate;
  /// 単勝回収率
  final double tanReturnRate;
  /// 複勝回収率
  final double fukuReturnRate;
  /// 分析コメント
  final String analysis;

  static double _d(dynamic v) => v is int ? v.toDouble() : (v as double?) ?? 0.0;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'num': num,
      'popularity_rank': popularityRank,
      'odds_base': oddsBase,
      'odds_now': oddsNow,
      'odds_change_rate': oddsChangeRate,
      'fuku_min': fukuMin,
      'win_count': winCount,
      'place_count': placeCount,
      'win_rate': winRate,
      'place_rate': placeRate,
      'tan_return_rate': tanReturnRate,
      'fuku_return_rate': fukuReturnRate,
      'analysis': analysis,
    };
  }
}
