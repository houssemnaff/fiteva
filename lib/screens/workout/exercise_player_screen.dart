import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../providers/points_provider.dart';
import '../../services/workout_progress_service.dart';

// ── Design tokens (always dark — immersive player) ────────────────────────────
const _kGreen = Color(0xFF1C4D30);
const _kGreenMid = Color(0xFF2E7D52);
const _kGold = Color(0xFFB8966E);
const _kGoldFade = Color(0x33B8966E);
const _kSheet = Color(0xFF111111);
const _kCard = Color(0xFF1C1C1C);
const _kBorder = Color(0xFF2C2C2C);
const _kMuted = Color(0xFF8A8A8A);
const _kWhite = Colors.white;

int _calculatePointsForExercise(int totalPoints, int totalExercises, int exerciseIndex) {
  if (totalExercises == 0) return 0;
  final base = totalPoints ~/ totalExercises;
  final remainder = totalPoints % totalExercises;
  return exerciseIndex < remainder ? base + 1 : base;
}

class ExercisePlayerScreen extends StatefulWidget {
  final WidgetRef ref;
  final String workoutTitle;
  final String exerciseName;
  final String videoId;
  final int exerciseIndex;
  final int totalExercises;
  final int totalWorkoutPoints;
  final VoidCallback onCompleted;

  const ExercisePlayerScreen({
    super.key,
    required this.ref,
    required this.workoutTitle,
    required this.exerciseName,
    required this.videoId,
    required this.exerciseIndex,
    required this.totalExercises,
    required this.totalWorkoutPoints,
    required this.onCompleted,
  });

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  bool _isDone = false;
  bool _pointsAwarded = false;
  bool _hasWatched80Percent = false;

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _doneCtrl;
  late final Animation<double> _doneAnim;

  // ── Video ──────────────────────────────────────────────────────────────────
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;
  bool _isVideoReady = false;

  static const _videoUrls = [
    'assets/videos/workout1.mp4',
    'assets/videos/workout2.mp4',
    'assets/videos/workout3.mp4',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _doneCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _doneAnim = CurvedAnimation(parent: _doneCtrl, curve: Curves.elasticOut);

    _checkVideoCompletion();
    _initVideo();
  }

  Future<void> _checkVideoCompletion() async {
    final isCompleted = await WorkoutProgressService.isVideoCompleted(widget.videoId);
    if (mounted) {
      setState(() => _hasWatched80Percent = isCompleted);
    }
  }

  Future<void> _initVideo() async {
    final url = _videoUrls[widget.exerciseIndex % _videoUrls.length];
    _videoCtrl = VideoPlayerController.asset(url);
    try {
      await _videoCtrl!.initialize();
      _videoCtrl!.addListener(_onVideoProgress);
      if (!mounted) return;
      _chewieCtrl = ChewieController(
        videoPlayerController: _videoCtrl!,
        autoPlay: true,
        looping: true,
        showControls: true,
        aspectRatio: _videoCtrl!.value.aspectRatio,
        placeholder: const ColoredBox(color: Colors.black),
      );
      setState(() => _isVideoReady = true);
    } catch (e) {
      debugPrint('Video error: $e');
    }
  }

  void _onVideoProgress() {
    if (_pointsAwarded) return;
    final ctrl = _videoCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    final dur = ctrl.value.duration.inMilliseconds;
    final pos = ctrl.value.position.inMilliseconds;
    if (dur <= 0) return;
    if (pos / dur >= 0.80) {
      _pointsAwarded = true;

      if (!_hasWatched80Percent) {
        setState(() => _hasWatched80Percent = true);
        final points = _calculatePointsForExercise(widget.totalWorkoutPoints, widget.totalExercises, widget.exerciseIndex);
        widget.ref.read(pointsProvider.notifier).addPoints(points);
        WorkoutProgressService.updateVideoProgress(widget.videoId, 0.80);
        final total = widget.ref.read(pointsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(LucideIcons.checkCircle,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text('+$points pts gagnés! Total: $total pts'),
                ],
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: _kGreen,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _doneCtrl.dispose();
    _chewieCtrl?.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  Future<void> _completExercise() async {
    if (_isDone) return;
    HapticFeedback.mediumImpact();
    setState(() => _isDone = true);

    if (!_hasWatched80Percent) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.alertCircle,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Regardez au moins 80% pour gagner les points'),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
            backgroundColor: const Color(0xFFFFA500),
          ),
        );
      }
    }

    _doneCtrl.forward();
    widget.onCompleted();
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.exerciseIndex + 1) / widget.totalExercises;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Video fullscreen ─────────────────────────────────────────────
          Positioned.fill(
            child: _isVideoReady && _chewieCtrl != null
                ? Chewie(controller: _chewieCtrl!)
                : const _VideoPlaceholder(),
          ),

          // ── Top progress bar ─────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(
              workoutTitle: widget.workoutTitle,
              exerciseName: widget.exerciseName,
              exerciseIndex: widget.exerciseIndex,
              totalExercises: widget.totalExercises,
              progress: progress,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),

          // ── Bottom sheet ─────────────────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.14,
            minChildSize: 0.14,
            maxChildSize: 0.72,
            snap: true,
            snapSizes: const [0.14, 0.72],
            builder: (context, scrollCtrl) => _BottomPanel(
              scrollCtrl: scrollCtrl,
              exerciseName: widget.exerciseName,
              isDone: _isDone,
              doneAnim: _doneAnim,
              onCompleteAll: _completExercise,
              onPrev: () => Navigator.of(context).pop(),
              onNext: () {},
              pointsPerExercise: _calculatePointsForExercise(widget.totalWorkoutPoints, widget.totalExercises, widget.exerciseIndex),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TOP BAR
// ══════════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String workoutTitle;
  final String exerciseName;
  final int exerciseIndex;
  final int totalExercises;
  final double progress;
  final VoidCallback onBack;

  const _TopBar({
    required this.workoutTitle,
    required this.exerciseName,
    required this.exerciseIndex,
    required this.totalExercises,
    required this.progress,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Thin gold progress bar
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          valueColor: const AlwaysStoppedAnimation<Color>(_kGold),
          minHeight: 2,
        ),

        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Back button
                _GlassBtn(icon: LucideIcons.arrowLeft, onTap: onBack),
                const SizedBox(width: 12),

                // Title block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workoutTitle.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: _kGold,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exerciseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: _kWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          shadows: const [
                            Shadow(blurRadius: 12, color: Colors.black54)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Counter pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kGoldFade,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kGold.withValues(alpha: 0.40)),
                  ),
                  child: Text(
                    '${exerciseIndex + 1} / $totalExercises',
                    style: GoogleFonts.inter(
                      color: _kGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOTTOM PANEL
// ══════════════════════════════════════════════════════════════════════════════
class _BottomPanel extends StatelessWidget {
    final int pointsPerExercise;

  final ScrollController scrollCtrl;
  final String exerciseName;
  final bool isDone;
  final Animation<double> doneAnim;
  final VoidCallback onCompleteAll;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _BottomPanel({
    required this.scrollCtrl,
    required this.exerciseName,
    required this.isDone,
    required this.doneAnim,
    required this.onCompleteAll,
    required this.onPrev,
    required this.onNext, required this.pointsPerExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.60),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: ListView(
        controller: scrollCtrl,
        padding: EdgeInsets.zero,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Exercise name ─────────────────────────────────────────
                Text(
                  exerciseName,
                  style: GoogleFonts.outfit(
                    color: _kWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Tags ──────────────────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: const [
                    _Tag(label: 'Fessiers', icon: LucideIcons.zap),
                    _Tag(label: 'Tapis', icon: LucideIcons.layoutDashboard),
                    _Tag(
                        label: 'Modéré',
                        icon: LucideIcons.flame,
                        isAccent: true),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Stats row ─────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Row(
                    children: [
                      const _StatCell(value: '3', label: 'Séries'),
                      _VertDivider(),
                      const _StatCell(value: '45s', label: 'Travail'),
                      _VertDivider(),
                      const _StatCell(value: '15s', label: 'Repos'),
                      _VertDivider(),
                       _StatCell(
                        value: '$pointsPerExercise',
                        label: 'Points',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ── Description ───────────────────────────────────────────
                _SectionLabel(label: 'Technique'),
                const SizedBox(height: 10),
                Text(
                  'Debout, pieds écartés largeur épaules. Descends en pliant les genoux à 90° en gardant le dos droit et la poitrine sortie. Pousse sur tes talons pour remonter.',
                  style: GoogleFonts.inter(
                    color: _kMuted,
                    fontSize: 13.5,
                    height: 1.65,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 22),

                // ── Tips card ─────────────────────────────────────────────
                _TipsCard(),
                const SizedBox(height: 22),

                // ── Prev / Next ───────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                        child: _NavBtn(
                            icon: LucideIcons.skipBack,
                            label: 'Précédent',
                            onTap: onPrev)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _NavBtn(
                            icon: LucideIcons.skipForward,
                            label: 'Suivant',
                            onTap: onNext,
                            isPrimary: true)),
                  ],
                ),
                const SizedBox(height: 16),

                // ── CTA ───────────────────────────────────────────────────
                ScaleTransition(
                  scale: isDone ? doneAnim : const AlwaysStoppedAnimation(1.0),
                  child: GestureDetector(
                    onTap: isDone ? null : onCompleteAll,
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              isDone ? [_kGold, _kGold] : [_kGreen, _kGreenMid],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: (isDone ? _kGold : _kGreen)
                                .withValues(alpha: 0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isDone
                                ? LucideIcons.checkCircle
                                : LucideIcons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isDone
                                ? 'Exercice terminé !'
                                : 'Terminer l\'exercice',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tips card ─────────────────────────────────────────────────────────────────
class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kGoldFade,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kGold.withValues(alpha: 0.28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(LucideIcons.lightbulb, size: 15, color: _kGold),
              const SizedBox(width: 8),
              Text(
                'Conseils de forme',
                style: GoogleFonts.inter(
                  color: _kGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            _TipRow('Garde les genoux alignés avec tes orteils.'),
            const SizedBox(height: 6),
            _TipRow('Engage ta sangle abdominale pendant tout le mouvement.'),
            const SizedBox(height: 6),
            _TipRow('Expire à la montée, inspire à la descente.'),
          ],
        ),
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Icon(icon, color: _kWhite, size: 17),
            ),
          ),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
          width: 14,
          height: 2,
          decoration: BoxDecoration(
              color: _kGold, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: _kWhite,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ]);
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isAccent;
  const _Tag({required this.label, required this.icon, this.isAccent = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isAccent
              ? _kGold.withValues(alpha: 0.12)
              : _kGreen.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAccent
                ? _kGold.withValues(alpha: 0.30)
                : _kGreen.withValues(alpha: 0.35),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 11, color: isAccent ? _kGold : const Color(0xFF7ABB98)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isAccent ? _kGold : const Color(0xFF9ED4B5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ]),
      );
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                color: _kWhite,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                  color: _kMuted, fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ]),
        ),
      );
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: _kBorder);
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow(this.text);

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(LucideIcons.dot, size: 12, color: _kGold),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: _kWhite.withValues(alpha: 0.70),
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ),
        ],
      );
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  const _NavBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary ? _kGreen.withValues(alpha: 0.18) : _kCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPrimary ? _kGreen.withValues(alpha: 0.40) : _kBorder,
            ),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 14, color: isPrimary ? const Color(0xFF7ABB98) : _kMuted),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isPrimary ? const Color(0xFF9ED4B5) : _kMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ),
      );
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _kGreen.withValues(alpha: 0.30)),
                ),
                child: const CircularProgressIndicator(
                  color: _kGold,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chargement…',
                style: GoogleFonts.inter(
                    color: _kMuted, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
}
