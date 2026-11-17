// =============================================================================
// ファイル名   : fcm_service.dart
// 概要         : 実行環境に応じて FcmService の実装を切り替える（Web は fcm_service_web.dart、
//                それ以外は fcm_service_stub.dart）。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-22
// 最終更新日   : 2026-11-17
// =============================================================================

export 'fcm_service_stub.dart'
    if (dart.library.js_interop) 'fcm_service_web.dart';
