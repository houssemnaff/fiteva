import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/points_provider.dart';
import '../services/step_service.dart';
import '../l10n/app_localizations.dart';

// ── Design tokens — alignés sur le reste de l'accueil (cartes claires,
// badges d'icône colorés) plutôt que la carte dégradée sombre précédente.
const _kGreen   = Color(0xFF1C4D30);
const _kGreenBg = Color(0xFFEAF3EC);
const _kGold    = Color(0xFFB8860B);
const _kGoldBg  = Color(0xFFFFF8E7);

class MesPasCard extends ConsumerStatefulWidget {
  const MesPasCard({super.key});

  @override
  ConsumerState<MesPasCard> createState() => _MesPasCardState();
}

class _MesPasCardState extends ConsumerState<MesPasCard>
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
  bool _goalAlreadyRewarded = false;

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
    _checkIfAlreadyRewarded();
  }

  Future<void> _checkIfAlreadyRewarded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    if (mounted) {
      setState(() {
        _goalAlreadyRewarded = prefs.getBool(today) ?? false;
      });
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return 'step_goal_rewarded_${now.year}-${now.month}-${now.day}';
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
            _checkGoalCompletion();
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

  Future<void> _checkGoalCompletion() async {
    if (_progress < 1.0 || _goalAlreadyRewarded) return;
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    if (prefs.getBool(today) ?? false) {
      if (mounted) setState(() => _goalAlreadyRewarded = true);
      return;
    }
    await prefs.setBool(today, true);
    if (mounted) setState(() => _goalAlreadyRewarded = true);
    await ref.read(pointsProvider.notifier).addPoints(50);
    if (mounted) _showGoalNotification();
  }

  void _showGoalNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        backgroundColor: _kGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
        content: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _kGold.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.trophy, color: _kGold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ref.read(l10nProvider).stepObjectifAtteint,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    )),
                Text(ref.read(l10nProvider).stepPtsAjoutes,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFFD89B),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ]),
      ),
    );
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
  bool get _isGoalDone => _progress >= 1.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: _kGreenBg, borderRadius: BorderRadius.circular(11)),
                child: const Icon(LucideIcons.footprints, size: 16, color: _kGreen),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MES PAS',
                      style: GoogleFonts.inter(
                        color: cs.onSurfaceVariant,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "Aujourd'hui",
                      style: GoogleFonts.outfit(
                        color: cs.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Sync button
              GestureDetector(
                onTap: _isSyncing ? null : _handleSync,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: _isSyncing
                      ? Padding(
                          padding: const EdgeInsets.all(9),
                          child: CircularProgressIndicator(
                              color: _kGreen, strokeWidth: 2))
                      : Icon(LucideIcons.refreshCw,
                          color: cs.onSurfaceVariant, size: 15),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Anneau + infos ──────────────────────────────────────────────
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(
              width: 96, height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _arcAnim,
                    builder: (_, __) => CustomPaint(
                      size: const Size(96, 96),
                      painter: _ArcPainter(
                        progress: _isLoading || _errorMessage != null
                            ? 0
                            : _arcAnim.value,
                        goalDone: _isGoalDone,
                        track: cs.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: _kGreen, strokeWidth: 2.5))
                  else if (_errorMessage != null)
                    Icon(LucideIcons.wifiOff, color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 24)
                  else if (_isGoalDone)
                    ScaleTransition(scale: _pulseAnim, child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: _kGoldBg, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.trophy, size: 18, color: _kGold)))
                  else
                    ScaleTransition(scale: _pulseAnim, child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: _kGreenBg, shape: BoxShape.circle),
                      child: const Icon(LucideIcons.footprints, size: 17, color: _kGreen))),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_isLoading)
                Text('Chargement…', style: GoogleFonts.inter(fontSize: 12.5, color: cs.onSurfaceVariant))
              else if (_errorMessage != null)
                Text(_errorMessage!, style: GoogleFonts.inter(fontSize: 12.5, color: cs.onSurfaceVariant))
              else ...[
                Text(StepService.formatNumber(_stepsToday), style: GoogleFonts.outfit(
                  color: cs.onSurface, fontSize: 30, fontWeight: FontWeight.w900,
                  height: 1, letterSpacing: -1)),
                const SizedBox(height: 3),
                Text('/ 10 000 pas', style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                const SizedBox(height: 8),
                if (_isGoalDone)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: _kGoldBg, borderRadius: BorderRadius.circular(50)),
                    child: Text(ref.watch(l10nProvider).stepObjectifAtteint, style: GoogleFonts.outfit(
                      fontSize: 11, fontWeight: FontWeight.w800, color: _kGold)))
                else
                  Text('${(_progress * 100).toStringAsFixed(0)}% de l\'objectif', style: GoogleFonts.outfit(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: _kGreen)),
              ],
            ])),
          ]),

          if (!_isLoading && _errorMessage == null) ...[
            const SizedBox(height: 18),
            _StatRow(steps: _stepsToday),
          ],
        ],
      ),
    );
  }
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
            label: 'Distance',
            color: const Color.fromARGB(255, 3, 78, 199), bg: const Color.fromARGB(255, 113, 142, 183)),
        const SizedBox(width: 10),
        _StatTile(
            icon: LucideIcons.flame,
            value: '$calories kcal',
            label: 'Brûlées',
            color: const Color.fromARGB(255, 224, 112, 60), bg: const Color.fromARGB(255, 255, 206, 231)),
        const SizedBox(width: 10),
        _StatTile(
            icon: LucideIcons.clock,
            value: minutes < 60
                ? '${minutes}m'
                : '${minutes ~/ 60}h ${minutes % 60}m',
            label: 'Durée',
                       color: const Color.fromARGB(255, 46, 105, 87), bg: const Color.fromARGB(255, 133, 212, 186)),

      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bg;
  const _StatTile({
    required this.icon, required this.value, required this.label,
    required this.color, required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                color: cs.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                color: cs.onSurfaceVariant,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Arc painter ───────────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final double progress;
  final bool goalDone;
  final Color track;
  const _ArcPainter({required this.progress, this.goalDone = false, required this.track});

  static const double _startAngle = math.pi * 0.65;
  static const double _sweepFull  = math.pi * 1.70;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.43;
    const strokeWidth = 8.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawArc(
      rect,
      _startAngle,
      _sweepFull,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    canvas.drawArc(
      rect,
      _startAngle,
      _sweepFull * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: _startAngle,
          endAngle: _startAngle + _sweepFull,
          colors: goalDone
              ? const [_kGold, Color(0xFFFFD89B), _kGold]
              : const [_kGreen, Color(0xFF52B788), _kGreen],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = goalDone ? 9.5 : strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.goalDone != goalDone || old.track != track;
}
