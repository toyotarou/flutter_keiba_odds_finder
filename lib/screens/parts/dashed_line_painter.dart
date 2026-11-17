// =============================================================================
// ファイル名   : dashed_line_painter.dart
// 概要         : 横向きの破線を描く CustomPainter。
// 作成者       : Hideyuki Toyoda
// 作成日       : 2026-07-16
// 最終更新日   : 2026-11-17
// =============================================================================

import 'package:flutter/material.dart';

/// 横向きの破線を描く。
class DashedLinePainter extends CustomPainter {
  const DashedLinePainter({
    this.color = Colors.red,
    this.strokeWidth = 5,
    this.dashWidth = 8,
    this.dashSpace = 5,
    this.strokeCap = StrokeCap.butt,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final StrokeCap strokeCap;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = strokeCap;
    double x = 0;
    final double y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashWidth != oldDelegate.dashWidth ||
      dashSpace != oldDelegate.dashSpace ||
      strokeCap != oldDelegate.strokeCap;
}
