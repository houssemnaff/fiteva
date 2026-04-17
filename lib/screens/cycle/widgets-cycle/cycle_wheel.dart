import 'dart:math';
import 'package:flutter/material.dart';

// ──────────────────────────────────────────────
//  Phase model
// ──────────────────────────────────────────────
class CyclePhase {
  final String name;
  final String description;
  final Color color;
  final List<int> days;

  const CyclePhase({
    required this.name,
    required this.description,
    required this.color,
    required this.days,
  });
}

const List<CyclePhase> kPhases = [
  CyclePhase(
    name: 'Règles',
    description: 'Corps au repos · Prends soin de toi',
    color: Color(0xFFD94F6B),
    days: [1, 2, 3, 4, 5],
  ),
  CyclePhase(
    name: 'Folliculaire',
    description: 'Énergie en hausse · Peau lumineuse',
    color: Color(0xFF5BAE8A),
    days: [6, 7, 8, 9, 10, 11, 12, 13],
  ),
  CyclePhase(
    name: 'Ovulation',
    description: 'Pic de fertilité · Humeur au top',
    color: Color(0xFFE8A030),
    days: [14, 15, 16],
  ),
  CyclePhase(
    name: 'Lutéale',
    description: 'Corps se prépare · Écoute tes besoins',
    color: Color(0xFF6B8FD4),
    days: [17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
  ),
];

CyclePhase phaseForDay(int day) =>
    kPhases.firstWhere((p) => p.days.contains(day), orElse: () => kPhases.last);

// ──────────────────────────────────────────────
//  Petal painter
// ──────────────────────────────────────────────
class _PetalWheelPainter extends CustomPainter {
  final int currentDay;
  final int totalDays;
  final double pulseValue; // 0..1 animation for selected petal glow

  _PetalWheelPainter({
    required this.currentDay,
    this.totalDays = 30,
    this.pulseValue = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Subtle outer glow ring
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFD94F6B).withOpacity(0.06)
      ..strokeWidth = 20;
    canvas.drawCircle(Offset(cx, cy), cx * 0.80, glowPaint);

    // Draw each day petal
    for (int i = 0; i < totalDays; i++) {
      final day = i + 1;
      final isSelected = day == currentDay;
      final phase = phaseForDay(day);
      final color = phase.color;

      final angle = -pi / 2 + (2 * pi / totalDays) * i;

      // Petal dimensions: selected petal blooms larger
      final outerR = isSelected ? cx * 0.795 + sin(pulseValue) * 4 : cx * 0.695;
      final innerR = cx * 0.32;
      final segW = (2 * pi * outerR / totalDays);
      final halfW = segW * (isSelected ? 0.40 : 0.31);

      _drawPetal(
        canvas: canvas,
        cx: cx, cy: cy,
        angle: angle,
        outerR: outerR,
        innerR: innerR,
        halfWidth: halfW,
        color: color,
        isSelected: isSelected,
        pulseValue: pulseValue,
      );

      // Day number label
      final labelR = (innerR + outerR) / 2;
      final tx = cx + labelR * cos(angle);
      final ty = cy + labelR * sin(angle);

      final tp = TextPainter(
        text: TextSpan(
          text: '$day',
          style: TextStyle(
            fontSize: isSelected ? 10.5 : 8.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : color.withOpacity(0.85),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(tx - tp.width / 2, ty - tp.height / 2));
    }
  }

  void _drawPetal({
    required Canvas canvas,
    required double cx,
    required double cy,
    required double angle,
    required double outerR,
    required double innerR,
    required double halfWidth,
    required Color color,
    required bool isSelected,
    required double pulseValue,
  }) {
    final cosA = cos(angle);
    final sinA = sin(angle);
    // Perpendicular direction
    final perpX = -sinA;
    final perpY = cosA;

    // Anchor points
    final ix = cx + innerR * cosA;
    final iy = cy + innerR * sinA;
    final ox = cx + outerR * cosA;
    final oy = cy + outerR * sinA;

    // Bezier bulge factor – organic petal curve
    const bulge = 1.15;

    // Control points: left side (going out)
    final ctrl1x = cx + (innerR + (outerR - innerR) * 0.35) * cosA + perpX * halfWidth * bulge;
    final ctrl1y = cy + (innerR + (outerR - innerR) * 0.35) * sinA + perpY * halfWidth * bulge;
    final ctrl2x = cx + (innerR + (outerR - innerR) * 0.65) * cosA + perpX * halfWidth * bulge;
    final ctrl2y = cy + (innerR + (outerR - innerR) * 0.65) * sinA + perpY * halfWidth * bulge;

    // Control points: right side (coming back)
    final ctrl3x = cx + (innerR + (outerR - innerR) * 0.65) * cosA - perpX * halfWidth * bulge;
    final ctrl3y = cy + (innerR + (outerR - innerR) * 0.65) * sinA - perpY * halfWidth * bulge;
    final ctrl4x = cx + (innerR + (outerR - innerR) * 0.35) * cosA - perpX * halfWidth * bulge;
    final ctrl4y = cy + (innerR + (outerR - innerR) * 0.35) * sinA - perpY * halfWidth * bulge;

    final path = Path()
      ..moveTo(ix, iy)
      ..cubicTo(ctrl1x, ctrl1y, ctrl2x, ctrl2y, ox, oy)
      ..cubicTo(ctrl3x, ctrl3y, ctrl4x, ctrl4y, ix, iy)
      ..close();

    if (isSelected) {
      // Radial gradient fill for bloom effect
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [color.withOpacity(0.75), color],
      );
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: outerR);
      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      // Soft glow shadow
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.25 + sin(pulseValue) * 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawPath(path, paint);
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withOpacity(0.18)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_PetalWheelPainter old) =>
      old.currentDay != currentDay || old.pulseValue != pulseValue;
}

// ──────────────────────────────────────────────
//  Tap detection
// ──────────────────────────────────────────────
int? _dayFromTap(Offset local, Size size, int totalDays) {
  final cx = size.width / 2;
  final cy = size.height / 2;
  final outerR = cx * 0.82;
  final innerR = cx * 0.30;

  final dx = local.dx - cx;
  final dy = local.dy - cy;
  final dist = sqrt(dx * dx + dy * dy);

  if (dist < innerR || dist > outerR) return null;

  final angle = (atan2(dy, dx) + pi / 2 + 2 * pi) % (2 * pi);
  final segAngle = (2 * pi) / totalDays;
  final day = (angle / segAngle).floor() + 1;
  return day.clamp(1, totalDays);
}

// ──────────────────────────────────────────────
//  Public animated widget
// ──────────────────────────────────────────────
class CycleWheel extends StatefulWidget {
  final int currentDay;
  final Function(int) onDaySelected;

  const CycleWheel({
    super.key,
    required this.currentDay,
    required this.onDaySelected,
  });

  @override
  State<CycleWheel> createState() => _CycleWheelState();
}

class _CycleWheelState extends State<CycleWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


@override
Widget build(BuildContext context) {
  const totalDays = 30;
  final phase = phaseForDay(widget.currentDay);

 return LayoutBuilder(
  builder: (context, constraints) {
    final size = constraints.maxWidth * 0.95; // utilise largeur seulement

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTapDown: (d) {
                    final day = _dayFromTap(
                      d.localPosition,
                      Size(size, size),
                      totalDays,
                    );
                    if (day != null) widget.onDaySelected(day);
                  },
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: _PetalWheelPainter(
                      currentDay: widget.currentDay,
                      pulseValue: _controller.value * 2 * pi,
                    ),
                  ),
                ),

                Container(
                  width: size * 0.30,
                  height: size * 0.30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: phase.color.withOpacity(0.15),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${widget.currentDay}',
                      style: TextStyle(
                        fontSize: size * 0.10,
                        fontWeight: FontWeight.bold,
                        color: phase.color,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  },
);
}
    }