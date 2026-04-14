
import 'package:flutter/material.dart';
import 'dart:math' as math;


class CycleCirclePainter extends CustomPainter {
  final double value;

  CycleCirclePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    const startAngle = -math.pi / 2;
    const sweepAngle = math.pi * 2;

    // 🔘 Background circle
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // 🟢 Progress circle (gradient)
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5CD57A), Color(0xFF1C4D30)],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * value.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    // 📍 Tick marks
    final tickPaint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 30; i++) {
      final angle = (2 * math.pi / 30) * i - math.pi / 2;

      final inner = radius - 20;
      final outer = radius - 8;

      canvas.drawLine(
        Offset(
          center.dx + inner * math.cos(angle),
          center.dy + inner * math.sin(angle),
        ),
        Offset(
          center.dx + outer * math.cos(angle),
          center.dy + outer * math.sin(angle),
        ),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CycleCirclePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}