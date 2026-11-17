// =============================================================================
// ファイル名   : baganriki_brain_display_alert.dart
// 概要         : 「AI予想の判断基準」の画面。サーバーの設定値に入っている文章を表示する。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-08-03
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/controllers_mixin.dart';

/// 「AI予想の判断基準」の画面。
class BaganrikiBrainDisplayAlert extends ConsumerStatefulWidget {
  const BaganrikiBrainDisplayAlert({super.key});

  @override
  ConsumerState<BaganrikiBrainDisplayAlert> createState() => _BaganrikiBrainDisplayAlertState();
}

/// 「AI予想の判断基準」の画面の状態。
class _BaganrikiBrainDisplayAlertState extends ConsumerState<BaganrikiBrainDisplayAlert>
    with ControllersMixin<BaganrikiBrainDisplayAlert> {
  /// 「AI予想の判断基準」の画面を組み立てる。
  @override
  Widget build(BuildContext context) {
    final String content = appParamState.configBaganrikiBrain;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            Divider(color: Colors.white.withValues(alpha: 0.5), thickness: 5),
            Expanded(child: _buildBody(content)),
          ],
        ),
      ),
    );
  }

  /// 画面上部の見出しを表示する。
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Text('AI予想の判断基準', style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  /// サーバーの設定値から取得した判断基準の文章を表示する。空のときは「データがありません」と表示する。
  Widget _buildBody(String content) {
    if (content.isEmpty) {
      return const Center(
        child: Text('データがありません', style: TextStyle(color: Colors.white54, fontSize: 13)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5)),
        child: MarkdownBody(
          data: content,
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontSize: 13, color: Colors.greenAccent, fontWeight: FontWeight.bold),
            h3: const TextStyle(fontSize: 12, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
            p: const TextStyle(fontSize: 11, color: Colors.white, letterSpacing: 0.8, height: 1.8),
            strong: const TextStyle(fontSize: 11, color: Colors.white, letterSpacing: 0.8, height: 1.8),
            listBullet: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.8),
            horizontalRuleDecoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white24)),
            ),
            codeblockDecoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24),
            ),
            code: const TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}
