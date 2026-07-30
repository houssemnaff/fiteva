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
import '../widgets/points_toast.dart';
import '../l10n/app_localizations.dart';

// ── Design tokens — alignés sur le reste de l'accueil (cartes claires,
// badges d'icône colorés) plutôt que la carte dégradée sombre précédente.
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
    if (mounted) setState(() => _goalAlreadyRewarded = true);
    // Garde-fou 1×/jour vérifié CÔTÉ SERVEUR (points_progress_history) — les
    // prefs ne servent que de cache local pour éviter de re-requêter.
    final granted =
        await ref.read(pointsProvider.notifier).rewardStepGoalReached();
    await prefs.setBool(today, true);
    if (granted && mounted) {
      _showGoalNotification();
      maybeShowLevelUpToast(context, ref);
    }
  }

  void _showGoalNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // ── Compact header + step count + progress ────────────────────
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13)),
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox(width: 42, height: 42, child: CircularProgressIndicator(
                    value: _isLoading || _errorMessage != null ? 0 : _progress,
                    strokeWidth: 3, strokeCap: StrokeCap.round,
                    backgroundColor: cs.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      _isGoalDone ? _kGold : cs.primary))),
                  Icon(_isGoalDone ? LucideIcons.trophy : LucideIcons.footprints,
                    size: 15, color: _isGoalDone ? _kGold : cs.primary),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading)
                    Text('Chargement…', style: GoogleFonts.inter(
                      fontSize: 13, color: cs.onSurfaceVariant))
                  else if (_errorMessage != null)
                    Text(_errorMessage!, style: GoogleFonts.inter(
                      fontSize: 13, color: cs.onSurfaceVariant))
                  else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(StepService.formatNumber(_stepsToday),
                          style: GoogleFonts.outfit(
                            color: cs.onSurface, fontSize: 22,
                            fontWeight: FontWeight.w900, height: 1,
                            letterSpacing: -0.5)),
                        const SizedBox(width: 4),
                        Text('/ 10 000 pas', style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w500,
                          color: cs.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Slim progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        height: 4,
                        child: AnimatedBuilder(
                          animation: _arcAnim,
                          builder: (_, __) => LinearProgressIndicator(
                            value: _isLoading ? 0 : _arcAnim.value,
                            backgroundColor: cs.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              _isGoalDone ? _kGold : cs.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              )),
              const SizedBox(width: 10),
              if (_isGoalDone)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kGoldBg,
                    borderRadius: BorderRadius.circular(50)),
                  child: Text(ref.watch(l10nProvider).stepObjectifAtteint,
                    style: GoogleFonts.outfit(
                      fontSize: 10, fontWeight: FontWeight.w800, color: _kGold)))
              else if (!_isLoading && _errorMessage == null)
                Text('${(_progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: cs.primary))
              else
                const SizedBox.shrink(),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _isSyncing ? null : _handleSync,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    shape: BoxShape.circle),
                  child: _isSyncing
                      ? Padding(padding: const EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            color: cs.primary, strokeWidth: 2))
                      : Icon(LucideIcons.refreshCw,
                          color: cs.onSurfaceVariant, size: 13),
                ),
              ),
            ],
          ),

          if (!_isLoading && _errorMessage == null) ...[
            const SizedBox(height: 14),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark
        ? color.withValues(alpha: 0.10)
        : bg;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(14),
          border: isDark
              ? Border.all(color: color.withValues(alpha: 0.15))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                color: cs.onSurface,
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
  final Color accent;
  const _ArcPainter({required this.progress, this.goalDone = false, required this.track, required this.accent});

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
              : [accent, accent.withValues(alpha: 0.6), accent],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = goalDone ? 9.5 : strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.goalDone != goalDone || old.track != track || old.accent != accent;
}
