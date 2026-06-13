// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ─── Types & humeurs ──────────────────────────────────────────────────────────
enum MascotType { blob, sun, star, cloud, leaf }
enum MascotMood { happy, excited, sleepy, proud, celebrating }

// ─────────────────────────────────────────────────────────────────────────────
// MascotWidget
// ─────────────────────────────────────────────────────────────────────────────
class MascotWidget extends StatefulWidget {
  final MascotType type;
  final MascotMood mood;
  final double     size;

  const MascotWidget({
    super.key,
    this.type = MascotType.blob,
    this.mood = MascotMood.happy,
    this.size = 120,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with TickerProviderStateMixin {

  late final AnimationController _bounceCtrl;
  late final AnimationController _celebrateCtrl;
  late final Animation<double>   _bounce;
  late final Animation<double>   _squish;
  late final Animation<double>   _spin;

  bool   _isBlinking = false;
  Timer? _blinkTimer;
  final  _rng = Random();

  @override
  void initState() {
    super.initState();

    _bounceCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    _bounce = CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut);

    _squish = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.93), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.93, end: 1.04), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 1.0),  weight: 30),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut));

    _celebrateCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
    _spin = Tween<double>(begin: -0.10, end: 0.10).animate(
      CurvedAnimation(parent: _celebrateCtrl, curve: Curves.easeInOut));

    if (widget.mood == MascotMood.celebrating) {
      _celebrateCtrl.repeat(reverse: true);
    }
    _scheduleBlink();
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 2500 + _rng.nextInt(3000)), () {
      if (!mounted) return;
      setState(() => _isBlinking = true);
      Future.delayed(const Duration(milliseconds: 140), () {
        if (!mounted) return;
        setState(() => _isBlinking = false);
        _scheduleBlink();
      });
    });
  }

  @override
  void didUpdateWidget(MascotWidget old) {
    super.didUpdateWidget(old);
    if (widget.mood == MascotMood.celebrating) {
      _celebrateCtrl.repeat(reverse: true);
    } else {
      _celebrateCtrl
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _celebrateCtrl.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  CustomPainter _painterFor() {
    switch (widget.type) {
      case MascotType.blob:  return _BlobPainter( mood: widget.mood, isBlinking: _isBlinking);
      case MascotType.sun:   return _SunPainter(  mood: widget.mood, isBlinking: _isBlinking);
      case MascotType.star:  return _StarPainter(  mood: widget.mood, isBlinking: _isBlinking);
      case MascotType.cloud: return _CloudPainter( mood: widget.mood, isBlinking: _isBlinking);
      case MascotType.leaf:  return _LeafPainter(  mood: widget.mood, isBlinking: _isBlinking);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceCtrl, _celebrateCtrl]),
      builder: (_, __) {
        final offsetY = (_bounce.value - 0.5) * 7;
        final scaleX  = _squish.value;
        final scaleY  = 2.0 - _squish.value;
        final rot     = widget.mood == MascotMood.celebrating ? _spin.value : 0.0;

        return Transform.rotate(
          angle: rot,
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _painterFor(),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared face helpers
// ─────────────────────────────────────────────────────────────────────────────
mixin _FaceMixin {
  static const _eyeWhite = Colors.white;
  static const _shine    = Colors.white;
  static const _star     = Color(0xFFFFD700);

  Color get pupilColor;
  Color get mouthColor;
  Color get cheekColor;

  void drawFace(Canvas c, Size size, MascotMood mood, bool isBlinking) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2;
    _drawCheeks(c, cx, cy, r);
    if (mood == MascotMood.excited) {
      _drawStarEyes(c, cx, cy, r);
    } else {
      _drawEyes(c, cx, cy, r, mood, isBlinking);
    }
    _drawMouth(c, cx, cy, r, mood);
    if (mood == MascotMood.celebrating) _drawSparkles(c, cx, cy, r);
  }

  void _drawEyes(Canvas c, double cx, double cy, double r, MascotMood mood, bool blink) {
    final eyeY = cy - r * 0.10;
    final er   = r * 0.13;
    _drawSingleEye(c, cx - r * 0.27, eyeY, er, mood, blink);
    _drawSingleEye(c, cx + r * 0.27, eyeY, er, mood, blink);
  }

  void _drawSingleEye(Canvas c, double ex, double ey, double er, MascotMood mood, bool blink) {
    if (blink || mood == MascotMood.sleepy) {
      c.drawLine(
        Offset(ex - er * 0.7, ey),
        Offset(ex + er * 0.7, mood == MascotMood.sleepy ? ey - er * 0.3 : ey),
        Paint()
          ..color = pupilColor
          ..strokeWidth = er * 0.55
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      return;
    }
    c.drawCircle(Offset(ex, ey), er, Paint()..color = _eyeWhite);
    c.drawCircle(Offset(ex + er * 0.12, ey + er * 0.1), er * 0.62, Paint()..color = pupilColor);
    c.drawCircle(Offset(ex - er * 0.15, ey - er * 0.22), er * 0.22, Paint()..color = _shine);
  }

  void _drawStarEyes(Canvas c, double cx, double cy, double r) {
    _drawStarShape(c, cx - r * 0.27, cy - r * 0.10, r * 0.16);
    _drawStarShape(c, cx + r * 0.27, cy - r * 0.10, r * 0.16);
  }

  void _drawStarShape(Canvas c, double x, double y, double s) {
    final paint = Paint()..color = _star;
    final path  = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * pi / 5) - pi / 2;
      final dist  = i.isEven ? s : s * 0.45;
      final px = x + cos(angle) * dist;
      final py = y + sin(angle) * dist;
      i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
    }
    path.close();
    c.drawPath(path, paint);
  }

  void _drawCheeks(Canvas c, double cx, double cy, double r) {
    final p = Paint()..color = cheekColor.withOpacity(0.28);
    c.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.50, cy + r * 0.12), width: r * 0.36, height: r * 0.20), p);
    c.drawOval(Rect.fromCenter(center: Offset(cx + r * 0.50, cy + r * 0.12), width: r * 0.36, height: r * 0.20), p);
  }

  void _drawMouth(Canvas c, double cx, double cy, double r, MascotMood mood) {
    final p = Paint()
      ..color = mouthColor
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final my = cy + r * 0.32;

    switch (mood) {
      case MascotMood.happy:
      case MascotMood.proud:
        c.drawPath(Path()
          ..moveTo(cx - r * 0.22, my)
          ..quadraticBezierTo(cx, my + r * 0.20, cx + r * 0.22, my), p);
        break;
      case MascotMood.excited:
      case MascotMood.celebrating:
        final path = Path()
          ..moveTo(cx - r * 0.28, my - r * 0.04)
          ..quadraticBezierTo(cx, my + r * 0.28, cx + r * 0.28, my - r * 0.04);
        c.drawPath(path, p);
        c.save();
        c.clipPath(path);
        c.drawRect(Rect.fromLTWH(cx - r * 0.28, my - r * 0.04, r * 0.56, r * 0.18),
            Paint()..color = Colors.white);
        c.restore();
        break;
      case MascotMood.sleepy:
        c.drawPath(Path()
          ..moveTo(cx - r * 0.13, my + r * 0.02)
          ..quadraticBezierTo(cx, my + r * 0.10, cx + r * 0.13, my + r * 0.02), p);
        _drawZ(c, cx + r * 0.52, cy - r * 0.45, r * 0.10,
            Paint()..color = mouthColor.withOpacity(0.4)
              ..strokeWidth = r * 0.04 ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);
        _drawZ(c, cx + r * 0.70, cy - r * 0.62, r * 0.07,
            Paint()..color = mouthColor.withOpacity(0.3)
              ..strokeWidth = r * 0.035 ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);
        break;
    }
  }

  void _drawZ(Canvas c, double x, double y, double s, Paint p) {
    c.drawPath(Path()
      ..moveTo(x, y) ..lineTo(x + s, y)
      ..lineTo(x, y + s) ..lineTo(x + s, y + s), p);
  }

  void _drawSparkles(Canvas c, double cx, double cy, double r) {
    for (final pos in [
      Offset(cx - r * 0.88, cy - r * 0.62),
      Offset(cx + r * 0.88, cy - r * 0.62),
      Offset(cx - r * 1.0,  cy + r * 0.12),
      Offset(cx + r * 1.0,  cy + r * 0.12),
    ]) {
      _drawStarShape(c, pos.dx, pos.dy, r * 0.10);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. BLOB — vert app
// ─────────────────────────────────────────────────────────────────────────────
class _BlobPainter extends CustomPainter with _FaceMixin {
  final MascotMood mood;
  final bool isBlinking;
  const _BlobPainter({required this.mood, required this.isBlinking});

  @override Color get pupilColor => const Color(0xFF1A2E20);
  @override Color get mouthColor => const Color(0xFF1A2E20);
  @override Color get cheekColor => const Color(0xFF4A9E70);

  @override
  void paint(Canvas c, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2;

    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [const Color(0xFFB8D9C4), const Color(0xFF7ABB98)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    final path = Path()
      ..moveTo(cx, cy - r * 0.95)
      ..cubicTo(cx + r * 0.55, cy - r * 1.05, cx + r * 1.08, cy - r * 0.35, cx + r * 1.0, cy + r * 0.30)
      ..cubicTo(cx + r * 0.90, cy + r * 0.85, cx + r * 0.40, cy + r * 1.05, cx, cy + r * 1.0)
      ..cubicTo(cx - r * 0.40, cy + r * 1.05, cx - r * 0.90, cy + r * 0.85, cx - r * 1.0, cy + r * 0.30)
      ..cubicTo(cx - r * 1.08, cy - r * 0.35, cx - r * 0.55, cy - r * 1.05, cx, cy - r * 0.95)
      ..close();
    c.drawPath(path, paint);
    c.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.28, cy - r * 0.42), width: r * 0.42, height: r * 0.26),
        Paint()..color = Colors.white.withOpacity(0.22));

    drawFace(c, size, mood, isBlinking);
  }

  @override
  bool shouldRepaint(_BlobPainter o) => o.mood != mood || o.isBlinking != isBlinking;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. SOLEIL — jaune/ambre
// ─────────────────────────────────────────────────────────────────────────────
class _SunPainter extends CustomPainter with _FaceMixin {
  final MascotMood mood;
  final bool isBlinking;
  const _SunPainter({required this.mood, required this.isBlinking});

  @override Color get pupilColor => const Color(0xFF7A3800);
  @override Color get mouthColor => const Color(0xFF7A3800);
  @override Color get cheekColor => const Color(0xFFFF8C00);

  static const _yellow  = Color(0xFFFFD84D);
  static const _orange  = Color(0xFFFFA726);
  static const _rayCol  = Color(0xFFFFE066);

  @override
  void paint(Canvas c, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2;

    // rayons
    final rayPaint = Paint()..color = _rayCol ..strokeWidth = r * 0.12 ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke;
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final inner = r * 0.62, outer = r * 0.95;
      c.drawLine(
        Offset(cx + cos(angle) * inner, cy + sin(angle) * inner),
        Offset(cx + cos(angle) * outer, cy + sin(angle) * outer),
        rayPaint,
      );
    }

    // corps
    c.drawCircle(Offset(cx, cy), r * 0.58,
        Paint()..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [_yellow, _orange],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.58)));
    c.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.16, cy - r * 0.25), width: r * 0.28, height: r * 0.18),
        Paint()..color = Colors.white.withOpacity(0.30));

    drawFace(c, size, mood, isBlinking);
  }

  @override
  bool shouldRepaint(_SunPainter o) => o.mood != mood || o.isBlinking != isBlinking;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. ÉTOILE — lavande/violet
// ─────────────────────────────────────────────────────────────────────────────
class _StarPainter extends CustomPainter with _FaceMixin {
  final MascotMood mood;
  final bool isBlinking;
  const _StarPainter({required this.mood, required this.isBlinking});

  @override Color get pupilColor => const Color(0xFF3A1A5E);
  @override Color get mouthColor => const Color(0xFF3A1A5E);
  @override Color get cheekColor => const Color(0xFFAA72DD);

  static const _purple1 = Color(0xFFCFAEF0);
  static const _purple2 = Color(0xFFA374D5);

  @override
  void paint(Canvas c, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 * 0.90;

    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [_purple1, _purple2],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    // forme étoile 5 branches
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * pi / 5) - pi / 2;
      final dist  = i.isEven ? r : r * 0.50;
      final px = cx + cos(angle) * dist;
      final py = cy + sin(angle) * dist;
      i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
    }
    path.close();
    c.drawPath(path, paint);
    c.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.18, cy - r * 0.28), width: r * 0.30, height: r * 0.18),
        Paint()..color = Colors.white.withOpacity(0.25));

    drawFace(c, size, mood, isBlinking);
  }

  @override
  bool shouldRepaint(_StarPainter o) => o.mood != mood || o.isBlinking != isBlinking;
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. NUAGE — bleu ciel
// ─────────────────────────────────────────────────────────────────────────────
class _CloudPainter extends CustomPainter with _FaceMixin {
  final MascotMood mood;
  final bool isBlinking;
  const _CloudPainter({required this.mood, required this.isBlinking});

  @override Color get pupilColor => const Color(0xFF1A3A5E);
  @override Color get mouthColor => const Color(0xFF1A3A5E);
  @override Color get cheekColor => const Color(0xFF5AAAD4);

  static const _sky1 = Color(0xFFD6EEFF);
  static const _sky2 = Color(0xFF90C8F0);

  @override
  void paint(Canvas c, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2;

    final cloudPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [_sky1, _sky2],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // forme nuage — plusieurs cercles
    void blob(double dx, double dy, double br) =>
        c.drawCircle(Offset(cx + dx * r, cy + dy * r), br * r, cloudPaint);

    blob(0,    0.10,  0.52); // centre
    blob(-0.38, 0.18, 0.36); // gauche bas
    blob( 0.38, 0.18, 0.36); // droite bas
    blob(-0.22,-0.10, 0.40); // gauche haut
    blob( 0.22,-0.10, 0.40); // droite haut
    blob( 0,   -0.20, 0.36); // centre haut

    c.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.18, cy - r * 0.18), width: r * 0.28, height: r * 0.16),
        Paint()..color = Colors.white.withOpacity(0.45));

    drawFace(c, size, mood, isBlinking);
  }

  @override
  bool shouldRepaint(_CloudPainter o) => o.mood != mood || o.isBlinking != isBlinking;
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. FEUILLE — vert forêt
// ─────────────────────────────────────────────────────────────────────────────
class _LeafPainter extends CustomPainter with _FaceMixin {
  final MascotMood mood;
  final bool isBlinking;
  const _LeafPainter({required this.mood, required this.isBlinking});

  @override Color get pupilColor => const Color(0xFF0D2010);
  @override Color get mouthColor => const Color(0xFF0D2010);
  @override Color get cheekColor => const Color(0xFF2D7A45);

  static const _green1 = Color(0xFF8FCC9E);
  static const _green2 = Color(0xFF2D8A50);

  @override
  void paint(Canvas c, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2;

    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.5),
        colors: [_green1, _green2],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    // forme feuille
    final path = Path()
      ..moveTo(cx, cy - r * 0.95)
      ..cubicTo(cx + r * 1.10, cy - r * 0.95, cx + r * 1.10, cy + r * 0.95, cx, cy + r * 0.95)
      ..cubicTo(cx - r * 1.10, cy + r * 0.95, cx - r * 1.10, cy - r * 0.95, cx, cy - r * 0.95)
      ..close();
    c.drawPath(path, paint);

    // nervure centrale
    c.drawLine(Offset(cx, cy - r * 0.80), Offset(cx, cy + r * 0.80),
        Paint()..color = Colors.white.withOpacity(0.18) ..strokeWidth = r * 0.05 ..strokeCap = StrokeCap.round ..style = PaintingStyle.stroke);

    c.drawOval(Rect.fromCenter(center: Offset(cx - r * 0.18, cy - r * 0.38), width: r * 0.30, height: r * 0.18),
        Paint()..color = Colors.white.withOpacity(0.22));

    drawFace(c, size, mood, isBlinking);
  }

  @override
  bool shouldRepaint(_LeafPainter o) => o.mood != mood || o.isBlinking != isBlinking;
}
