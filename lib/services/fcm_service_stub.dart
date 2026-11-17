// =============================================================================
// ファイル名   : fcm_service_stub.dart
// 概要         : Web 以外の環境用の FcmService（何もしない空の実装）。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-22
// 最終更新日   : 2026-11-17
// =============================================================================

/// Web 以外の環境用の FcmService（何もしない）。
class FcmService {
  /// Web 以外では何もしない。
  static Future<void> registerToken({required String userId}) async {}
}
