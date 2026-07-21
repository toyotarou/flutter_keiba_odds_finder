const int kOddsTimingFirst = 999;
const int kOddsTimingLast = -999;
const String kOddsTimingLastLabel = '0'; // タイミング文字列における発走時刻ラベル

// 着順上位N着（3着以内など）
const int kRaceTopFinishers = 3;

// 急落判定に使うタイミング（発走何分前のオッズを比較対象にするか）
const int kOddsJudgeTiming = 6;
const String kOddsJudgeTimingLabel = '6';

// judgeOdds の閾値
const double kOddsNoDropRatio = 0.7; // この比率以上なら急落なしとみなす
const double kOddsHonmeiMax = 5.0; // 本命オッズの上限
const double kOddsChuAnaMax = 15.0; // 中穴オッズの上限

// データカウントアラートに表示するSQL
const Map<String, String> dataCountSqlMap = <String, String>{
  'summaryCount': ' select date, count(date) as count from t_horse_odds_finder_summary group by date; ',
  'historyCount': ' select date, count(date) as count from t_horse_odds_finder_race_result_history group by date; ',
  'historyPopularityRankCount':
      ' select date, count(date) as count from t_horse_odds_finder_race_result_history where popularity_rank is not null group by date; ',
  'historyFinishingPositionCount':
      ' select date, count(date) as count from t_horse_odds_finder_race_result_history where finishing_position is not null group by date; ',
  'payoutCount': ' select date, count(date) as count from t_horse_odds_finder_race_result_payout group by date; ',
  'ratioCount': ' select date, count(date) as count from t_horse_odds_finder_races_popularity_ratio group by date; ',
  'medianCount': ' select date, count(date) as count from t_horse_odds_finder_popularity_rank_median group by date; ',
  'raceResultsCount': ' select date, count(date) as count from t_horse_odds_finder_race_results group by date; ',
};
