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
