import 'dart:math' as math;
import 'package:fiteva/screens/cycle/pregnancy/theme.dart';
import 'package:flutter/material.dart';

/// Renders the living thread — a vertical organic fiber that evolves visually
/// across all 40 weeks of pregnancy.
class ThreadPainter extends CustomPainter {
  final int currentWeek;
  final double breathPhase;     // 0..2π — drives organic sway animation
  final double scrollOffset;    // normalised 0..1 (0 = top of thread visible)
  final int? hoveredWeek;       // week the user is pressing/hovering

  ThreadPainter({
    required this.currentWeek,
    required this.breathPhase,
    required this.scrollOffset,
    this.hoveredWeek,
  });

  // Layout constants
  static const double _segmentPitch = 22.0;  // px between week nodes
  static const double _threadCX = 0.5;       // fractional centre X

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * _threadCX;
    _drawTrimestreZones(canvas, size, cx);
    _drawFutureGuide(canvas, size, cx);
    _drawPastThread(canvas, size, cx);
    _drawConceptionSeed(canvas, size, cx);
    _drawCurrentKnot(canvas, size, cx);
    _drawBirthBloom(canvas, size, cx);
  }

  // ── Week Y position ─────────────────────────────────────────────────────
  double weekY(int week, Size size) {
    // Week 40 near top, week 1 near bottom
    final fraction = 1.0 - (week - 1) / 39.0;
    return fraction * (size.height - 80) + 40;
  }

  // ── Organic sway offset ─────────────────────────────────────────────────
  double swayX(int week, double y) {
    final amp = week <= 13 ? 3.0 : week <= 27 ? 6.0 : 8.0;
    return math.sin(breathPhase + y * 0.025 + week * 0.3) * amp;
  }

  // ── Trimestre background zones ──────────────────────────────────────────
  void _drawTrimestreZones(Canvas canvas, Size size, double cx) {
  final zones = [
    (from: 1, to: 13),
    (from: 14, to: 27),
    (from: 28, to: 40),
  ];

  for (final z in zones) {
    final yTop = weekY(z.to, size) - _segmentPitch / 2;
    final yBot = weekY(z.from, size) + _segmentPitch / 2;

    final rect = Rect.fromLTRB(cx - 34, yTop, cx + 34, yBot);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF3E8A5C).withOpacity(0.25), // glow highlight
          const Color(0xFF2A6B45).withOpacity(0.18), // mid shine
          const Color(0xFF1C4D30).withOpacity(0.35), // base depth
        ],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      paint,
    );

    // subtle inner glow line (premium touch)
    final borderPaint = Paint()
      ..color = const Color(0xFF3E8A5C).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      borderPaint,
    );
  }
}

  // ── Future thread — translucent silver guide ────────────────────────────
  void _drawFutureGuide(Canvas canvas, Size size, double cx) {
    if (currentWeek >= 40) return;
    final path = Path();
    bool first = true;
    for (int w = currentWeek + 1; w <= 40; w++) {
      final y = weekY(w, size);
      final x = cx + swayX(w, y) * 0.3;
      if (first) { path.moveTo(x, y); first = false; }
      else { path.lineTo(x, y); }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1C4D30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (int w = currentWeek + 1; w <= 40; w += 4) {
      final y = weekY(w, size);
      final x = cx + swayX(w, y) * 0.3;
      canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = const Color(0xFF3A3850));
    }
  }

  // ── Past thread — rich, glowing, braided ───────────────────────────────
  void _drawPastThread(Canvas canvas, Size size, double cx) {
    for (int w = 1; w < currentWeek; w++) {
      final y = weekY(w, size);
      final color = ThreadTheme.threadColorForWeek(w);
      final strands = ThreadTheme.strandCountForWeek(w);
      final baseW = ThreadTheme.threadBaseWidthForWeek(w);

      for (int s = 0; s < strands; s++) {
        final spread = strands == 1 ? 0.0 : (s - (strands - 1) / 2.0) * (baseW * 1.2);
        final phaseOffset = s * math.pi * 0.7;
        final strandSway = math.sin(breathPhase * 1.1 + y * 0.04 + phaseOffset) * (strands > 1 ? 2.5 : 0);
        final x = cx + swayX(w, y) + spread + strandSway;

        // Inner core
        canvas.drawCircle(
          Offset(x, y),
          baseW / 2,
          Paint()
            ..color = color
            ..maskFilter = MaskFilter.blur(BlurStyle.solid, 0),
        );

        // Soft outer glow for past weeks
        if (w % 5 == 0) {
          canvas.drawCircle(
            Offset(x, y),
            baseW,
            Paint()
              ..color = color.withOpacity(0.15)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
          );
        }
      }

      // Subtle connector between weeks
      if (w < currentWeek - 1) {
        final y2 = weekY(w + 1, size);
        final x2 = cx + swayX(w + 1, y2);
        final x1 = cx + swayX(w, y);
        canvas.drawLine(
          Offset(x1, y),
          Offset(x2, y2),
          Paint()
            ..color = ThreadTheme.threadColorForWeek(w).withOpacity(0.3)
            ..strokeWidth = ThreadTheme.threadBaseWidthForWeek(w) * 0.5
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  // ── Conception seed — luminous point at bottom ──────────────────────────
  void _drawConceptionSeed(Canvas canvas, Size size, double cx) {
    final y = weekY(1, size);
    final pulse = (math.sin(breathPhase * 1.5) + 1) / 2;

    // Outer aura
    canvas.drawCircle(
      Offset(cx, y),
      10 + pulse * 4,
      Paint()
        ..color = const Color(0xFF1C4D30).withOpacity(0.08 + pulse * 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Mid ring
    canvas.drawCircle(
      Offset(cx, y),
      5 + pulse * 2,
      Paint()
        ..color = const Color(0xFF1C4D30).withOpacity(0.25 + pulse * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // Core
    canvas.drawCircle(
      Offset(cx, y),
      3,
      Paint()..color = const Color(0xFF1C4D30).withOpacity(0.9),
    );
  }

  // ── Current week knot — glowing tightening in the thread ───────────────
  void _drawCurrentKnot(Canvas canvas, Size size, double cx) {
    final y = weekY(currentWeek, size);
    final x = cx + swayX(currentWeek, y);
    final color = ThreadTheme.threadColorForWeek(currentWeek);
    final pulse = (math.sin(breathPhase * 2.0) + 1) / 2;
    final baseW = ThreadTheme.threadBaseWidthForWeek(currentWeek);

    // Outer glow aura — breathes
    canvas.drawCircle(
      Offset(x, y),
      baseW * 4 + pulse * 6,
      Paint()
        ..color = color.withOpacity(0.12 + pulse * 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    // Mid glow
    canvas.drawCircle(
      Offset(x, y),
      baseW * 2.2,
      Paint()
        ..color = color.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // The knot core — wider than surrounding thread
    canvas.drawCircle(
      Offset(x, y),
      baseW * 1.4,
      Paint()..color = color,
    );
    // Inner bright point
    canvas.drawCircle(
      Offset(x, y),
      baseW * 0.6,
      Paint()..color = Color(0xFF1C4D30),
    );

    // Week number label
    _drawWeekLabel(canvas, Offset(x, y), currentWeek, color);
  }

  void _drawWeekLabel(Canvas canvas, Offset center, int week, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'W$week',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx + 14, center.dy - tp.height / 2));
  }

  // ── Birth bloom — opens at week 40 ─────────────────────────────────────
  void _drawBirthBloom(Canvas canvas, Size size, double cx) {
    final y = weekY(40, size);
    final x = cx + swayX(40, y);
    final color = ThreadTheme.t3End;
    final bloomProgress = (currentWeek - 28).clamp(0, 12) / 12.0;
    if (bloomProgress <= 0) return;

    final petalCount = 8;
    for (int i = 0; i < petalCount; i++) {
      final angle = (i / petalCount) * math.pi * 2 + breathPhase * 0.2;
      final r = (6 + bloomProgress * 10) * bloomProgress;
      final px = x + math.cos(angle) * r;
      final py = y + math.sin(angle) * r * 0.5;
      canvas.drawCircle(
        Offset(px, py),
        2.5 * bloomProgress,
        Paint()..color = color.withOpacity(0.5 * bloomProgress),
      );
    }
    // Centre
    canvas.drawCircle(
      Offset(x, y),
      4 * bloomProgress,
      Paint()
        ..color = color.withOpacity(0.8 * bloomProgress)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  // ── Hit testing ─────────────────────────────────────────────────────────
  /// Returns the week number closest to the given local Y position, or null
  /// if the tap is too far from any thread node.
  int? hitTestWeek(Offset localPosition, Size size) {
    double minDist = 24.0;
    int? result;
    for (int w = 1; w <= 40; w++) {
      final y = weekY(w, size);
      final dy = (localPosition.dy - y).abs();
      if (dy < minDist) {
        minDist = dy;
        result = w;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(ThreadPainter old) =>
      old.currentWeek != currentWeek ||
      old.breathPhase != breathPhase ||
      old.hoveredWeek != hoveredWeek;
}