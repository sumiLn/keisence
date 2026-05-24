import 'package:flutter/material.dart';

class JapaneseWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (double y = size.height * 0.15; y < size.height; y += 46) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x < size.width; x += 30) {
        path.quadraticBezierTo(x + 15, y - 14, x + 30, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
