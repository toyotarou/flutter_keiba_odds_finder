// =============================================================================
// ファイル名   : error_confirm_dialog.dart
// 概要         : タイトルと本文だけの、シンプルな確認ダイアログを表示する関数。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-06-19
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:flutter/material.dart';

/// タイトルと本文だけの確認ダイアログを表示する。[actions] を渡すとボタンを並べる。
Future<void> errorConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  List<Widget>? actions,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.blueGrey.withOpacity(0.3),
        title: Text(title, style: const TextStyle(fontSize: 12)),
        content: Text(content, style: const TextStyle(fontSize: 12)),
        actions: actions,
      );
    },
  );
}
