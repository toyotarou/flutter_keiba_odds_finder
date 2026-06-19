import 'package:flutter/material.dart';

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
