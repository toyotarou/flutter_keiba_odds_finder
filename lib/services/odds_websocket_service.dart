import 'dart:async';
import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:web_socket_channel/web_socket_channel.dart';

/// beyondcode/laravel-websockets（Pusherプロトコル）に接続し、
/// オッズ更新イベントを受信してコールバックを呼ぶサービス。
/// nginxが wss://baganriki.com/app/ → ws://127.0.0.1:8084 にプロキシする。
class OddsWebSocketService {
  // ─── 接続設定 ────────────────────────────────────────────────────
  static const String _appKey = 'mySecretKey123'; // PUSHER_APP_KEY
  static const String _host = 'baganriki.com'; // ポート不要（nginx経由）
  static const String _channelName = 'baganriki-odds-sent'; // BaganrikiOddsSent.broadcastOn()
  static const String _eventName = 'BaganrikiOddsSent'; // BaganrikiOddsSent.broadcastAs()
  // ─────────────────────────────────────────────────────────────────

  WebSocketChannel? _ws;
  StreamSubscription<dynamic>? _sub;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _disposed = false;

  /// オッズ更新イベント到着時に呼ばれるコールバック
  void Function()? onOddsUpdated;

  /// 接続を開始する（HomeScreen.initState から呼ぶ）
  void connect() {
    _disposed = false;
    _connectInternal();
  }

  void _connectInternal() {
    if (_disposed) {
      return;
    }
    try {
      final Uri uri = Uri.parse(
        'wss://$_host/app/$_appKey'
        '?protocol=7&client=flutter&version=1.0.0&flash=false',
      );
      _ws = WebSocketChannel.connect(uri);
      _sub = _ws!.stream.listen(
        _onMessage,
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: false,
      );
      // 30秒ごとにpingを送り、サーバー側のタイムアウトを防ぐ
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _ping());
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final Map<String, dynamic> msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final String? event = msg['event'] as String?;

      switch (event) {
        case 'pusher:connection_established':
          // 接続確立 → チャンネルを購読する
          _ws?.sink.add(
            jsonEncode(<String, dynamic>{
              'event': 'pusher:subscribe',
              'data': <String, dynamic>{'channel': _channelName},
            }),
          );

        case 'pusher:pong':
          break; // pong受信 → 正常、何もしない

        case _eventName: // 'BaganrikiOddsSent'
          onOddsUpdated?.call();
      }
    } catch (_) {
      // パースエラーは無視して接続を維持
    }
  }

  void _ping() {
    try {
      _ws?.sink.add(jsonEncode(<String, dynamic>{'event': 'pusher:ping', 'data': <String, dynamic>{}}));
    } catch (_) {}
  }

  void _scheduleReconnect() {
    _pingTimer?.cancel();
    _sub?.cancel();
    if (_disposed) {
      return;
    }
    _reconnectTimer?.cancel();
    // 5秒後に再接続（ネットワーク瞬断などへの対応）
    _reconnectTimer = Timer(const Duration(seconds: 5), _connectInternal);
  }

  /// 接続を切断する（HomeScreen.dispose から呼ぶ）
  void dispose() {
    _disposed = true;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _sub?.cancel();
    _ws?.sink.close();
  }
}
