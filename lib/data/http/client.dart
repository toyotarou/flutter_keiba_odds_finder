// =============================================================================
// ファイル名   : client.dart
// 概要         : サーバー API と通信する HTTP クライアントと、接続先の設定。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-05-30
// 最終更新日   : 2026-11-17
// =============================================================================

// ignore_for_file: public_member_api_docs, depend_on_referenced_packages
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';

import 'path.dart';

///////////////////////////////////////////////////////////////////
/// HttpClient を提供する Provider。
final Provider<HttpClient> httpClientProvider = Provider<HttpClient>(
  // ignore: deprecated_member_use
  (ProviderRef<HttpClient> ref) => HttpClient(),
);

///////////////////////////////////////////////////////////////////
/// サーバー API に GET / POST を送り、レスポンスを JSON として返すクライアント。
class HttpClient {
  HttpClient() {
    _client = Client();
  }

  late Client _client;

  /// GETリクエストを送信し、レスポンスをJSONとして返す
  ///
  /// [pathSuffix] を渡すと、パスの末尾に `/値` を付けて送る。渡さなければ通常の URL になる。
  Future<dynamic> get({
    required APIPath path,
    Map<String, dynamic>? queryParameters,
    String? pathSuffix,
  }) async {
    final String basePath = '/${Environment.apiBasePath}/${path.value}';
    final Uri uri = Uri.https(
      Environment.apiEndPoint,
      (pathSuffix == null || pathSuffix.isEmpty) ? basePath : '$basePath/$pathSuffix',
      queryParameters,
    );

    // ネットワークエラー
    final Response response;
    try {
      response = await _client.get(uri, headers: await _headers);
    } catch (e) {
      throw Exception('network error: $e  [url=$uri]');
    }

    // HTTPエラー
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('http ${response.statusCode} [url=$uri]');
    }

    // JSONパースエラー
    final String bodyString = utf8.decode(response.bodyBytes);
    try {
      if (bodyString.isEmpty) {
        throw Exception();
      }
      return jsonDecode(bodyString);
    } on Exception catch (_) {
      throw Exception('json parse error');
    }
  }

  /// POSTリクエストを送信し、レスポンスをJSONとして返す
  Future<dynamic> post({required APIPath path, required Map<String, dynamic> body}) async {
    final Uri uri = Uri.https(Environment.apiEndPoint, '/${Environment.apiBasePath}/${path.value}');

    final Response response;
    try {
      response = await _client.post(uri, headers: await _headers, body: jsonEncode(body));
    } catch (e) {
      throw Exception('network error: $e  [url=$uri]');
    }

    // 5xx はサーバー障害として例外。4xx はAPIレベルのエラーなのでボディをそのまま返す。
    if (response.statusCode >= 500) {
      throw Exception('http ${response.statusCode} [url=$uri]');
    }

    final String bodyString = utf8.decode(response.bodyBytes);
    try {
      if (bodyString.isEmpty) {
        throw Exception();
      }
      return jsonDecode(bodyString);
    } on Exception catch (_) {
      throw Exception('json parse error');
    }
  }

  /// リクエストヘッダー
  Future<Map<String, String>> get _headers async {
    return <String, String>{'content-type': 'application/json', 'Accept': 'application/json'};
  }
}

///////////////////////////////////////////////////////////////////
/// 接続先サーバーの情報。
class Environment {
  Environment._();

  /// APIのエンドポイント（本番サーバー）
  static String get apiEndPoint => 'baganriki.com';

  /// APIのベースパス
  static String get apiBasePath => 'api';
}
