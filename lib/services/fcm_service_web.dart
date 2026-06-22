import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

@JS('subscribeWebPush')
external JSPromise<JSAny?> _subscribeWebPushJs(JSString vapidKey);

class FcmService {
  static Future<void> registerToken({required String userId}) async {
    if (!kIsWeb) return;
    try {
      final Uri keyUri = Uri.https('baganriki.com', '/api/vapid-public-key');
      final http.Response keyResponse = await http.get(keyUri);
      if (keyResponse.statusCode != 200) return;

      final Map<String, dynamic> keyData =
          jsonDecode(keyResponse.body) as Map<String, dynamic>;
      final String vapidPublicKey = keyData['public_key'] as String;

      final JSAny? jsResult =
          await _subscribeWebPushJs(vapidPublicKey.toJS).toDart;
      if (jsResult == null) return;

      final Map<String, dynamic> subscription =
          jsonDecode(jsResult.dartify() as String) as Map<String, dynamic>;

      final String endpoint = subscription['endpoint'] as String;
      final Map<String, dynamic> keys =
          subscription['keys'] as Map<String, dynamic>;
      final String p256dh = keys['p256dh'] as String;
      final String auth = keys['auth'] as String;

      final Uri subUri =
          Uri.https('baganriki.com', '/api/web-push/subscribe');
      await http.post(
        subUri,
        headers: <String, String>{
          'content-type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'user_id': userId,
          'endpoint': endpoint,
          'p256dh': p256dh,
          'auth': auth,
        }),
      );
    } catch (e) {
      debugPrint('WebPush Error: $e');
    }
  }
}
