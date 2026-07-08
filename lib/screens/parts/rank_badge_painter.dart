import 'package:flutter/material.dart';

class RankBadgePainter extends CustomPainter {
  const RankBadgePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..cubicTo(0, size.height, 0, size.height * 0.3, 0, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(RankBadgePainter old) => old.color != color;
}
