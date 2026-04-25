import 'dart:math' as math;
import 'package:fiteva/screens/nutrition/theme/app_colors.dart';
import 'package:flutter/material.dart';


// ── Multi-color Donut (home tracking card) ────────────────────────────────────
class DonutPainter extends CustomPainter {
  final double proteinRatio, carbsRatio, fatRatio, animValue;
  const DonutPainter({
    required this.proteinRatio,
    required this.carbsRatio,
    required this.fatRatio,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width * 0.42;
    const strokeW = 13.0, gap = 0.04;

    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = const Color(0xFFEEE8E0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    final total = (proteinRatio + carbsRatio + fatRatio).clamp(0.01, 10.0);
    final pA = (proteinRatio / total) * 2 * math.pi * animValue;
    final cA = (carbsRatio  / total) * 2 * math.pi * animValue;
    final fA = (fatRatio    / total) * 2 * math.pi * animValue;

    void arc(double start, double sweep, Color color) {
      if (sweep < 0.01) return;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start, sweep - gap, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
    }

    arc(-math.pi / 2, pA, kPink);
    arc(-math.pi / 2 + pA, cA, kBlue);
    arc(-math.pi / 2 + pA + cA, fA, kLime);
  }

  @override
  bool shouldRepaint(DonutPainter old) => old.animValue != animValue;
}

// ── Simple Single-color Donut (suivi screen) ──────────────────────────────────
class SimpleDonutPainter extends CustomPainter {
  final double pct;
  const SimpleDonutPainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width * 0.43;

    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = const Color(0xFFEEE8E0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2, 2 * math.pi * pct, false,
      Paint()
        ..color = kYellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(SimpleDonutPainter old) => old.pct != pct;
}