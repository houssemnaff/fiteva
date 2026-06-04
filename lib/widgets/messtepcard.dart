import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pedometer/pedometer.dart';
import '../services/step_service.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kGreen     = Color(0xFF1C4D30);
const _kGreenDark = Color(0xFF0E2B1A);
const _kGold      = Color(0xFFB8966E);
const _kGoldLight = Color(0xFFFFD89B);

class MesPasCard extends StatefulWidget {
  const MesPasCard({super.key});

  @override
  State<MesPasCard> createState() => _MesPasCardState();
}

class _MesPasCardState extends State<MesPasCard>
    with TickerProviderStateMixin {
  late AnimationController _arcCtrl;
  late Animation<double> _arcAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  late StepService _stepService;
  StreamSubscription<StepCount>? _stepSubscription;

  int _stepsToday   = 0;
  static const int _goalSteps = 10000;
  bool _isSyncing   = false;
  bool _isLoading   = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _arcCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _arcAnim = Tween<double>(begin: 0, end: 0).animate(
        CurvedAnimation(parent: _arcCtrl, curve: Curves.easeOutCubic));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _initializeStepService();
  }

  void _animateTo(double target) {
    _arcAnim = Tween<double>(begin: _arcAnim.value, end: target).animate(
        CurvedAnimation(parent: _arcCtrl, curve: Curves.easeOutCubic));
    _arcCtrl
      ..reset()
      ..forward();
  }

  Future<void> _initializeStepService() async {
    if (kIsWeb) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Capteur non disponible sur web';
          _isLoading = false;
        });
      }
      return;
    }
    try {
      _stepService = StepService();
      await _stepService.initialize();
      _stepSubscription = _stepService.getStepStream().listen(
        (StepCount event) {
          if (mounted) {
            setState(() {
              _stepService.onStepEvent(event);
              _stepsToday = _stepService.getStepsToday();
              _isLoading = false;
            });
            _animateTo(_progress);
          }
        },
        onError: (_) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Capteur non disponible';
              _isLoading = false;
            });
          }
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur d\'initialisation';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _arcCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 950));
    if (mounted) setState(() => _isSyncing = false);
  }

  double get _progress => (_stepsToday / _goalSteps).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kGreen, _kGreenDark],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ──────────────────────────────────────────────────
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MES PAS',
                      style: GoogleFonts.inter(
                        color: _kGold,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Aujourd'hui",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Sync button
                GestureDetector(
                  onTap: _isSyncing ? null : _handleSync,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20)),
                    ),
                    child: _isSyncing
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                                color: _kGold, strokeWidth: 2))
                        : const Icon(LucideIcons.refreshCw,
                            color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Arc + step count ──────────────────────────────────────────
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Arc painter
                    AnimatedBuilder(
                      animation: _arcAnim,
                      builder: (_, __) => CustomPaint(
                        size: const Size(200, 200),
                        painter: _ArcPainter(
                          progress: _isLoading || _errorMessage != null
                              ? 0
                              : _arcAnim.value,
                        ),
                      ),
                    ),

                    // Inner content
                    if (_isLoading)
                      _LoadingCenter()
                    else if (_errorMessage != null)
                      _ErrorCenter()
                    else
                      _StepCenter(
                          steps: _stepsToday,
                          progress: _progress,
                          pulseAnim: _pulseAnim),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Stat tiles ────────────────────────────────────────────────
            if (!_isLoading && _errorMessage == null)
              _StatRow(steps: _stepsToday),

            if (_isLoading || _errorMessage != null)
              Center(
                child: Text(
                  _errorMessage ?? '',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

// ── Step center ───────────────────────────────────────────────────────────────
class _StepCenter extends StatelessWidget {
  final int steps;
  final double progress;
  final Animation<double> pulseAnim;
  const _StepCenter(
      {required this.steps,
      required this.progress,
      required this.pulseAnim});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated footstep icon
          ScaleTransition(
            scale: pulseAnim,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.footprints,
                  size: 18, color: _kGold),
            ),
          ),
          const SizedBox(height: 8),

          // Step count
          Text(
            StepService.formatNumber(steps),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '/ 10 000 pas',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          // Gold percentage
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.outfit(
              color: _kGold,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
}

class _LoadingCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
                color: _kGold, strokeWidth: 2.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Chargement…',
            style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12),
          ),
        ],
      );
}

class _ErrorCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.wifiOff,
              color: Colors.white.withValues(alpha: 0.40), size: 28),
          const SizedBox(height: 10),
          Text(
            'Non disponible',
            style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ],
      );
}

// ── Stat row ──────────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  final int steps;
  const _StatRow({required this.steps});

  @override
  Widget build(BuildContext context) {
    final distanceKm = steps * 0.0007;
    final calories   = (steps * 0.042).round();
    final minutes    = (steps * 0.0097).round();

    return Row(
      children: [
        _StatTile(
            icon: LucideIcons.mapPin,
            value: '${distanceKm.toStringAsFixed(1)} km',
            label: 'Distance'),
        const SizedBox(width: 10),
        _StatTile(
            icon: LucideIcons.flame,
            value: '$calories kcal',
            label: 'Brûlées'),
        const SizedBox(width: 10),
        _StatTile(
            icon: LucideIcons.clock,
            value: minutes < 60
                ? '${minutes}m'
                : '${minutes ~/ 60}h ${minutes % 60}m',
            label: 'Durée'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatTile(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 14, color: _kGold),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Arc painter ───────────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress;
  const _ArcPainter({required this.progress});

  static const double _startAngle = math.pi * 0.65;
  static const double _sweepFull  = math.pi * 1.70;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.43;
    const strokeWidth = 11.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawArc(
      rect,
      _startAngle,
      _sweepFull,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    // Gold gradient progress arc
    canvas.drawArc(
      rect,
      _startAngle,
      _sweepFull * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: _startAngle,
          endAngle: _startAngle + _sweepFull,
          colors: const [_kGold, _kGoldLight, _kGold],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Tip glow dot
    final tipAngle = _startAngle + _sweepFull * progress;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);
    canvas.drawCircle(
      Offset(tipX, tipY),
      7,
      Paint()
        ..color = _kGoldLight
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      Offset(tipX, tipY),
      4,
      Paint()..color = _kGoldLight,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}
