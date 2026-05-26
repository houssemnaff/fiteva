import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fiteva/screens/cycle/pregnancy/theme.dart';

/// Animated heartbeat pulse that plays when the user long-presses the
/// current week knot. Renders concentric expanding rings at the knot position.
class HeartbeatPulseOverlay extends StatefulWidget {
  final Offset position;   // local coordinates within the thread canvas
  final Color color;
  final int bpm;
  final VoidCallback onDone;

  const HeartbeatPulseOverlay({
    super.key,
    required this.position,
    required this.color,
    required this.bpm,
    required this.onDone,
  });

  @override
  State<HeartbeatPulseOverlay> createState() => _HeartbeatPulseOverlayState();
}

class _HeartbeatPulseOverlayState extends State<HeartbeatPulseOverlay>
    with TickerProviderStateMixin {
  final List<AnimationController> _pulseControllers = [];
  final List<Animation<double>> _pulseAnimations = [];
  int _beatCount = 0;
  static const int _totalBeats = 5;

  @override
  void initState() {
    super.initState();
    _schedulePulses();
  }

  void _schedulePulses() {
    final intervalMs = (60000 / widget.bpm).round();
    for (int i = 0; i < _totalBeats; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );
      final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
      _pulseControllers.add(controller);
      _pulseAnimations.add(animation);

      Future.delayed(Duration(milliseconds: i * intervalMs), () {
        if (mounted) {
          controller.forward().then((_) {
            _beatCount++;
            if (_beatCount >= _totalBeats) widget.onDone();
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _pulseControllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _PulsePainter(
          animations: _pulseAnimations,
          position: widget.position,
          color: widget.color,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final List<Animation<double>> animations;
  final Offset position;
  final Color color;

  _PulsePainter({
    required this.animations,
    required this.position,
    required this.color,
  }) : super(repaint: Listenable.merge(animations));

  @override
  void paint(Canvas canvas, Size size) {
    for (final anim in animations) {
      if (!anim.isCompleted && anim.value == 0) continue;
      final t = anim.value;
      final radius = t * 50;
      final opacity = (1 - t) * 0.6;
      canvas.drawCircle(
        position,
        radius,
        Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_PulsePainter old) => true;
}

/// A small ECG-style waveform drawn in the detail card.
class EcgWaveform extends StatefulWidget {
  final int bpm;
  final Color color;
  const EcgWaveform({super.key, required this.bpm, required this.color});

  @override
  State<EcgWaveform> createState() => _EcgWaveformState();
}

class _EcgWaveformState extends State<EcgWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (60000 / widget.bpm * 2).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: _EcgPainter(phase: _controller.value, color: widget.color),
        size: const Size(double.infinity, 32),
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final double phase;
  final Color color;
  _EcgPainter({required this.phase, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final w = size.width;
    final midY = size.height / 2;
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    path.moveTo(0, midY);
    for (double x = 0; x <= w; x += 1) {
      final t = (x / w + phase) % 1.0;
      double y = midY;
      // ECG waveform approximation
      if (t < 0.1) y = midY;
      else if (t < 0.13) y = midY - (t - 0.1) / 0.03 * size.height * 0.3;
      else if (t < 0.17) y = midY + (t - 0.13) / 0.04 * size.height * 0.2;
      else if (t < 0.20) y = midY - (t - 0.17) / 0.03 * size.height * 0.8;
      else if (t < 0.24) y = midY + (t - 0.20) / 0.04 * size.height * 0.5;
      else if (t < 0.30) y = midY - (t - 0.24) / 0.06 * size.height * 0.15;
      else y = midY;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_EcgPainter old) => old.phase != phase;
}