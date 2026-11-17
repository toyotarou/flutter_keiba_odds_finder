// =============================================================================
// ファイル名   : path.dart
// 概要         : サーバー API のパス一覧（enum）と、パス文字列への変換。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-30
// 最終更新日   : 2026-11-17
// =============================================================================

/// サーバー API のパス一覧。
enum APIPath {
  getHorseOddsFinderSchedules,
  getHorseOddsFinderRaces,
  getHorseOddsFinderHorses,
  getHorseOddsFinderOdds,
  getHorseOddsFinderConfigs,
  getHorseOddsFinderOddsGetTiming,
  getHorseDetail,
  getHorseOddsFinderSummary,
  getHorseOddsFinderSummaryOneRace,
  getHorseOddsFinderRaceOneResult,
  signup,
  signin,
  getHorseOddsFinderLoginUsers,
  changeAdmin,
  changeDelete,
  saveFcmToken,
  getHorseOddsFinderPushSubscriptions,
  changePushNotifierUserDelete,
  getHorseOddsFinderRaceResultHistory,
  getHorseOddsFinderRaceResultHistoryRaceList,
  getHorseOddsFinderRaceResultHistoryRaceContents,
  getHorseOddsFinderHorseName,
  getHorseOddsFinderHorseBattleRecord,
  getHorseOddsFinderRacesPopularityRatio,
  getHorseOddsFinderRaceResultPayout,
  getHorseOddsFinderSummaryTableCount,
  getHorseOddsFinderHighProbabilityHorses,
  getHorseOddsFinderAiAnalysis,
  getHorseOddsFinderShutsubaHistory,
  getHorseOddsFinderPopularityRankMedian,
  getHorseOddsFinderBestHorseWeight,
  getHorseOddsFinderHorseScores,
  getHorseOddsFinderJockeyScores,
  getHorseOddsFinderKitaichi,
  getHorseOddsFinderRaceIntrospection,
  getHorseOddsFinderSecondAiOpinion,
  getHorseOddsFinderBaganrikiIndex,
  getHorseOddsFinderPushSendLogsDeveloperNews,
  getHorseOddsFinderAiAnalysisRecord,
  getHorseOddsFinderAiAnalysisRecord2,
  getHorseOddsFinderAiAnalysisByDate,   // 1日分のAI結果をまとめて取得
  getMyPushReceive,   // ホーム画面の「通知」スイッチ — 受信設定の取得
  changeMyPushReceive,   // ホーム画面の「通知」スイッチ — 受信/非受信の切替

}

/// APIPath を実際の URL パス文字列に変換するための拡張。
extension APIPathExtension on APIPath {
  String? get value {
    switch (this) {
      case APIPath.getHorseOddsFinderSchedules:
        return 'getHorseOddsFinderSchedules';

      case APIPath.getHorseOddsFinderRaces:
        return 'getHorseOddsFinderRaces';

      case APIPath.getHorseOddsFinderHorses:
        return 'getHorseOddsFinderHorses';

      case APIPath.getHorseOddsFinderOdds:
        return 'getHorseOddsFinderOdds';

      case APIPath.getHorseOddsFinderConfigs:
        return 'getHorseOddsFinderConfigs';

      case APIPath.getHorseOddsFinderOddsGetTiming:
        return 'getHorseOddsFinderOddsGetTiming';

      case APIPath.getHorseDetail:
        return 'getHorseDetail';

      case APIPath.getHorseOddsFinderSummary:
        return 'getHorseOddsFinderSummary';

      case APIPath.getHorseOddsFinderSummaryOneRace:
        return 'getHorseOddsFinderSummaryOneRace';

      case APIPath.getHorseOddsFinderRaceOneResult:
        return 'getHorseOddsFinderRaceOneResult';

      case APIPath.signup:
        return 'signup';

      case APIPath.signin:
        return 'signin';

      case APIPath.getHorseOddsFinderLoginUsers:
        return 'getHorseOddsFinderLoginUsers';

      case APIPath.changeAdmin:
        return 'changeAdmin';

      case APIPath.changeDelete:
        return 'changeDelete';

      case APIPath.saveFcmToken:
        return 'fcm-token';
      case APIPath.getHorseOddsFinderPushSubscriptions:
        return 'getHorseOddsFinderPushSubscriptions';

      case APIPath.changePushNotifierUserDelete:
        return 'changePushNotifierUserDelete';

      case APIPath.getHorseOddsFinderRaceResultHistory:
        return 'getHorseOddsFinderRaceResultHistory';

      case APIPath.getHorseOddsFinderRaceResultHistoryRaceList:
        return 'getHorseOddsFinderRaceResultHistoryRaceList';
      case APIPath.getHorseOddsFinderRaceResultHistoryRaceContents:
        return 'getHorseOddsFinderRaceResultHistoryRaceContents';

      case APIPath.getHorseOddsFinderHorseName:
        return 'getHorseOddsFinderHorseName';
      case APIPath.getHorseOddsFinderHorseBattleRecord:
        return 'getHorseOddsFinderHorseBattleRecord';

      case APIPath.getHorseOddsFinderRacesPopularityRatio:
        return 'getHorseOddsFinderRacesPopularityRatio';

      case APIPath.getHorseOddsFinderRaceResultPayout:
        return 'getHorseOddsFinderRaceResultPayout';

      case APIPath.getHorseOddsFinderSummaryTableCount:
        return 'getHorseOddsFinderSummaryTableCount';

      case APIPath.getHorseOddsFinderHighProbabilityHorses:
        return 'getHorseOddsFinderHighProbabilityHorses';

      case APIPath.getHorseOddsFinderAiAnalysis:
        return 'getHorseOddsFinderAiAnalysis';

      case APIPath.getHorseOddsFinderShutsubaHistory:
        return 'getHorseOddsFinderShutsubaHistory';
      case APIPath.getHorseOddsFinderPopularityRankMedian:
        return 'getHorseOddsFinderPopularityRankMedian';
      case APIPath.getHorseOddsFinderBestHorseWeight:
        return 'getHorseOddsFinderBestHorseWeight';
      case APIPath.getHorseOddsFinderHorseScores:
        return 'getHorseOddsFinderHorseScores';

      case APIPath.getHorseOddsFinderJockeyScores:
        return 'getHorseOddsFinderJockeyScores';

      case APIPath.getHorseOddsFinderKitaichi:
        return 'getHorseOddsFinderKitaichi';
      case APIPath.getHorseOddsFinderRaceIntrospection:
        return 'getHorseOddsFinderRaceIntrospection';

      case APIPath.getHorseOddsFinderSecondAiOpinion:
        return 'getHorseOddsFinderSecondAiOpinion';

      case APIPath.getHorseOddsFinderBaganrikiIndex:
        return 'getHorseOddsFinderBaganrikiIndex';
      case APIPath.getHorseOddsFinderPushSendLogsDeveloperNews:
        return 'getHorseOddsFinderPushSendLogsDeveloperNews';

      case APIPath.getHorseOddsFinderAiAnalysisRecord:
        return 'getHorseOddsFinderAiAnalysisRecord';
      case APIPath.getHorseOddsFinderAiAnalysisRecord2:
        return 'getHorseOddsFinderAiAnalysisRecord2';
      case APIPath.getHorseOddsFinderAiAnalysisByDate:
        return 'getHorseOddsFinderAiAnalysisByDate';

      // ホーム画面の「通知」スイッチ
      case APIPath.getMyPushReceive:
        return 'getMyPushReceive';
      case APIPath.changeMyPushReceive:
        return 'changeMyPushReceive';

    }
  }
}
