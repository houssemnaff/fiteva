import 'dart:math' as math;
import 'package:fiteva/screens/cycle/pregnancy/pregnancy_data.dart';
import 'package:flutter/material.dart';

class PregnancyWheel extends StatefulWidget {
  final int currentWeek;
  final ValueChanged<int> onWeekSelected;

  const PregnancyWheel({
    super.key,
    required this.currentWeek,
    required this.onWeekSelected,
  });

  @override
  State<PregnancyWheel> createState() => _PregnancyWheelState();
}

class _PregnancyWheelState extends State<PregnancyWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  static const int _totalWeeks = 40;
  static const double _ringWidth = 28;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final week = getPregnancyWeek(widget.currentWeek);
    return GestureDetector(
      onTapDown: (details) => _handleTap(details.localPosition, context),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (_, __) => CustomPaint(
          painter: _WheelPainter(
            currentWeek: widget.currentWeek,
            glowOpacity: _glowAnimation.value,
            phaseColor: week.phaseColor,
          ),
          child: Center(child: _CenterInfo(week: week)),
        ),
      ),
    );
  }

  void _handleTap(Offset pos, BuildContext ctx) {
    final size = ctx.size!;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = pos.dx - center.dx;
    final dy = pos.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final outerR = size.width / 2 - 8;
    final innerR = outerR - _ringWidth * 2.5;
    if (dist < innerR || dist > outerR) return;

    double angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    final week = ((angle / (2 * math.pi)) * _totalWeeks).round();
    final clamped = week.clamp(1, _totalWeeks);
    widget.onWeekSelected(clamped);
  }
}

// ── Wheel Painter ────────────────────────────────────────────────────────────

class _WheelPainter extends CustomPainter {
  final int currentWeek;
  final double glowOpacity;
  final Color phaseColor;

  static const _t1Color = Color(0xFFE8A0BF);
  static const _t2Color = Color(0xFF9BC4CB);
  static const _t3Color = Color(0xFFB5A0D6);

  const _WheelPainter({
    required this.currentWeek,
    required this.glowOpacity,
    required this.phaseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 8;
    final ringW = outerR * 0.12;
    final innerR = outerR - ringW * 2.4;
    const gap = 0.012;
    const startAngle = -math.pi / 2;
    const total = 40;
    final sweepPerWeek = (2 * math.pi - gap * total) / total;

    // ── Trimestre background arcs ──
    _drawTrimestreArc(canvas, center, outerR - ringW * 0.5, ringW,
        1, 13, _t1Color.withOpacity(0.18), startAngle, total, sweepPerWeek, gap);
    _drawTrimestreArc(canvas, center, outerR - ringW * 0.5, ringW,
        14, 27, _t2Color.withOpacity(0.18), startAngle, total, sweepPerWeek, gap);
    _drawTrimestreArc(canvas, center, outerR - ringW * 0.5, ringW,
        28, 40, _t3Color.withOpacity(0.18), startAngle, total, sweepPerWeek, gap);

    // ── Week segments ──
    for (int w = 1; w <= total; w++) {
      final isActive = w == currentWeek;
      final isPast = w < currentWeek;
      final segColor = _colorForWeek(w);

      final segStart =
          startAngle + (w - 1) * (sweepPerWeek + gap) + gap / 2;

      // Outer ring
      final outPaint = Paint()
        ..color = isActive
            ? segColor
            : isPast
                ? segColor.withOpacity(0.7)
                : segColor.withOpacity(0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? ringW * 1.3 : ringW
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerR - ringW / 2),
        segStart,
        sweepPerWeek,
        false,
        outPaint,
      );

      // Inner tick
      if (w % 5 == 0 || isActive) {
        final tickPaint = Paint()
          ..color = segColor.withOpacity(isActive ? 0.9 : 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;

        final midAngle = segStart + sweepPerWeek / 2;
        final start = Offset(
          center.dx + (innerR + 4) * math.cos(midAngle),
          center.dy + (innerR + 4) * math.sin(midAngle),
        );
        final end = Offset(
          center.dx + (innerR - 6) * math.cos(midAngle),
          center.dy + (innerR - 6) * math.sin(midAngle),
        );
        canvas.drawLine(start, end, tickPaint);
      }
    }

    // ── Glow on active week ──
    final activeMid = startAngle +
        (currentWeek - 1) * (sweepPerWeek + gap) +
        gap / 2 +
        sweepPerWeek / 2;
    final glowPt = Offset(
      center.dx + (outerR - ringW / 2) * math.cos(activeMid),
      center.dy + (outerR - ringW / 2) * math.sin(activeMid),
    );
    canvas.drawCircle(
      glowPt,
      ringW * 0.9,
      Paint()
        ..color = phaseColor.withOpacity(0.35 * glowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(
      glowPt,
      ringW * 0.55,
      Paint()..color = phaseColor.withOpacity(0.9),
    );

    // ── Inner progress ring ──
    final progressPaint = Paint()
      ..color = phaseColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, innerR - 4, progressPaint);

    final progressFill = Paint()
      ..color = phaseColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerR - 4),
      -math.pi / 2,
      2 * math.pi * currentWeek / 40,
      false,
      progressFill,
    );
  }

  void _drawTrimestreArc(
      Canvas canvas, Offset center, double radius, double width,
      int from, int to, Color color,
      double startAngle, int total, double sweepPerWeek, double gap) {
    final segStart = startAngle + (from - 1) * (sweepPerWeek + gap);
    final segEnd = startAngle + to * (sweepPerWeek + gap) - gap;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 2.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      segStart,
      segEnd - segStart,
      false,
      paint,
    );
  }

  Color _colorForWeek(int week) {
    if (week <= 13) return _t1Color;
    if (week <= 27) return _t2Color;
    return _t3Color;
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.currentWeek != currentWeek ||
      old.glowOpacity != glowOpacity;
}

// ── Center Info ──────────────────────────────────────────────────────────────

class _CenterInfo extends StatelessWidget {
  final dynamic week; // PregnancyWeek
  const _CenterInfo({required this.week});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          week.babySizeEmoji,
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 4),
        Text(
          'SA ${week.week}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: week.phaseColor,
            letterSpacing: -1,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          week.babySize,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: week.phaseColor.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          '${week.babyCm} cm',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9A8880),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: week.phaseColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            week.trimestre,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: week.phaseColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}