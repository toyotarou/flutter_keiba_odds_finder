// =============================================================================
// ファイル名   : fcm_service_web.dart
// 概要         : Web Push の購読と、購読情報のサーバー登録を行う FcmService（Web 用）。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-22
// 最終更新日   : 2026-11-17
// =============================================================================

import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

@JS('subscribeWebPush')
external JSPromise<JSAny?> _subscribeWebPushJs(JSString vapidKey);

/// Web Push の購読を行い、購読情報をサーバーに登録するサービス（Web 用）。
class FcmService {
  /// サーバーから VAPID 公開鍵を取得して Web Push を購読し、購読情報をユーザーIDと一緒にサーバーへ登録する。
  /// 失敗してもアプリは止めず、ログだけ出す。
  static Future<void> registerToken({required String userId}) async {
    if (!kIsWeb) {
      return;
    }
    try {
      final Uri keyUri = Uri.https('baganriki.com', '/api/vapid-public-key');
      final http.Response keyResponse = await http.get(keyUri);
      if (keyResponse.statusCode != 200) {
        return;
      }

      final Map<String, dynamic> keyData = jsonDecode(keyResponse.body) as Map<String, dynamic>;
      final String vapidPublicKey = keyData['public_key'] as String;

      final JSAny? jsResult = await _subscribeWebPushJs(vapidPublicKey.toJS).toDart;
      if (jsResult == null) {
        return;
      }

      final Map<String, dynamic> subscription = jsonDecode(jsResult.dartify()! as String) as Map<String, dynamic>;

      final String endpoint = subscription['endpoint'] as String;
      final Map<String, dynamic> keys = subscription['keys'] as Map<String, dynamic>;
      final String p256dh = keys['p256dh'] as String;
      final String auth = keys['auth'] as String;

      final Uri subUri = Uri.https('baganriki.com', '/api/web-push/subscribe');
      await http.post(
        subUri,
        headers: <String, String>{'content-type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(<String, String>{'user_id': userId, 'endpoint': endpoint, 'p256dh': p256dh, 'auth': auth}),
      );
    } catch (e) {
      debugPrint('WebPush Error: $e');
    }
  }
}
