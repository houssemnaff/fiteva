import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../models/workout_model.dart';
import '../../services/workout_progress_service.dart';
import 'exercise_player_screen.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutModel workout;
  const ActiveWorkoutScreen({super.key, required this.workout});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  int _completedExercises = 0;
  bool _workoutMarkedComplete = false;
  Set<String> _completedVideos = {};

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  /// Nombre de vidéos de CE workout dont l'id est dans [done].
  int _countDone(Set<String> done) {
    int count = 0;
    for (final v in widget.workout.videos) {
      if (done.contains(v.id)) count++;
    }
    return count;
  }

  /// Premier exercice (vidéo) non terminé (-1 si tout est fait).
  int _firstIncompleteOf(Set<String> done) {
    final videos = widget.workout.videos;
    for (int i = 0; i < videos.length; i++) {
      if (!done.contains(videos[i].id)) return i;
    }
    return -1;
  }

  Future<void> _loadStatus() async {
    final done = await WorkoutProgressService.getCompletedVideos();
    if (mounted) {
      setState(() {
        _completedVideos = done;
        _completedExercises = _countDone(done);
      });
    }
  }

  Future<void> _openFirstIncomplete() async {
    final done = await WorkoutProgressService.getCompletedVideos();
    final idx = _firstIncompleteOf(done);
    if (!mounted || idx < 0) return;
    _openExercise(idx);
  }

  /// Ouvre l'exercice à [index] — dérivé exclusivement de
  /// `widget.workout.videos[index]` (VideoModel = source unique de vérité :
  /// titre, id, url, métadonnées technique/muscles/tips).
  void _openExercise(int index) {
    final video = widget.workout.videoAt(index);
    if (video == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ExercisePlayerScreen(
        ref: ref,
        workoutTitle: widget.workout.title,
        exerciseName: video.title,
        videoId: video.id,
        videoUrl: video.url.isNotEmpty ? video.url : null,
        exerciseIndex: index,
        totalExercises: widget.workout.exerciseCount,
        totalWorkoutPoints: widget.workout.points,
        video: video,
        onCompleted: () {
          // État dérivé du set réel (idempotent) — un compteur incrémenté
          // pouvait dériver si la même vidéo était validée deux fois.
          setState(() {
            _completedVideos = {..._completedVideos, video.id};
            _completedExercises = _countDone(_completedVideos);
          });
        },
        workoutId: widget.workout.id,
        allVideoIds: widget.workout.videos.map((v) => v.id).toList(),
      ),
    )).then((_) => _loadStatus());
  }

  Future<void> _markCompleteIfNeeded() async {
    if (_completedExercises >= widget.workout.exerciseCount && !_workoutMarkedComplete) {
      _workoutMarkedComplete = true;
      await WorkoutProgressService.markWorkoutComplete(widget.workout.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final videos = widget.workout.videos;
    final progress = videos.isEmpty ? 0.0 : _completedExercises / videos.length;
    final l10n = ref.watch(l10nProvider);

    final bg     = dark ? const Color(0xFF0F0F0F) : const Color(0xFFF6F6F6);
    final cardBg = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final t1     = dark ? const Color(0xFFF0F0F0) : const Color(0xFF111111);
    final t2     = dark ? const Color(0xFF888888) : const Color(0xFF666666);
    final t3     = dark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE);

    if (progress >= 1.0) Future.microtask(_markCompleteIfNeeded);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bg,
        body: Column(children: [
          // ── Hero ──────────────────────────────────────────────────────────
          SizedBox(
            height: (MediaQuery.of(context).size.height * 0.30).clamp(200.0, 300.0),
            child: Stack(fit: StackFit.expand, children: [
              // Image
              Image.asset(widget.workout.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: cs.primary)),
              // Gradient
              DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              )),
              // Content
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Category pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primary, borderRadius: BorderRadius.circular(20)),
                        child: Text(widget.workout.category,
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(widget.workout.title,
                        style: GoogleFonts.outfit(
                          color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900,
                          height: 1.1, letterSpacing: -0.5)),
                      const SizedBox(height: 10),
                      // Meta row
                      Row(children: [
                        _HeroPill(icon: LucideIcons.clock, label: widget.workout.duration),
                        const SizedBox(width: 8),
                        _HeroPill(icon: LucideIcons.flame, label: '${widget.workout.calories} kcal'),
                        const SizedBox(width: 8),
                        _HeroPill(icon: LucideIcons.zap, label: widget.workout.level),
                      ]),
                    ]),
                  ),
                ),
              ),
              // Back button
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.40),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 20),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ]),
          ),

          // ── Scrollable body ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                // ── Progress card ──
                Container(
                  color: cardBg,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Column(children: [
                    Row(children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l10n.workoutProgress,
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: t1)),
                        const SizedBox(height: 2),
                        Text(l10n.workoutPossiblePoints(widget.workout.points),
                          style: GoogleFonts.inter(fontSize: 12, color: t2)),
                      ]),
                      const Spacer(),
                      // Circular progress
                      SizedBox(
                        width: 52, height: 52,
                        child: Stack(alignment: Alignment.center, children: [
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4,
                            backgroundColor: t3,
                            valueColor: AlwaysStoppedAnimation(cs.primary),
                            strokeCap: StrokeCap.round,
                          ),
                          Text(
                            '$_completedExercises/${videos.length}',
                            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: t1),
                          ),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    // Segmented bar — chaque segment reflète SA vidéo,
                    // pas un simple compteur ordonné.
                    Row(
                      children: List.generate(videos.length, (i) {
                        final done = _completedVideos.contains(videos[i].id);
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < videos.length - 1 ? 4 : 0),
                            height: 6,
                            decoration: BoxDecoration(
                              color: done ? cs.primary : t3,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                  ]),
                ),

                const SizedBox(height: 8),

                // ── Exercise list — une ligne par vidéo, source unique ──
                Container(
                  color: cardBg,
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                  child: Column(
                    children: List.generate(videos.length, (index) {
                      final video = videos[index];
                      final isDone = _completedVideos.contains(video.id);
                      // Le cadre « en cours » = premier exercice non terminé
                      // (et plus un index-compteur qui sautait de travers
                      // quand une vidéo était finie hors ordre).
                      final isCurrent =
                          !isDone && index == _firstIncompleteOf(_completedVideos);

                      return GestureDetector(
                        onTap: () => _openExercise(index),
                        child: _ExerciseRow(
                          index: index,
                          name: video.title,
                          isDone: isDone,
                          isCurrent: isCurrent,
                          imageUrl: video.thumbnailUrl.isNotEmpty
                              ? video.thumbnailUrl
                              : widget.workout.imageUrl,
                          l10n: l10n,
                          cs: cs, t1: t1, t2: t2, t3: t3, dark: dark,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ]),

        // ── Bottom CTA ────────────────────────────────────────────────────
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(top: BorderSide(color: t3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.35 : 0.07),
                blurRadius: 16, offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SizedBox(
            height: 54,
            child: GestureDetector(
              onTap: progress >= 1.0 ? null : _openFirstIncomplete,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: progress >= 1.0
                      ? Colors.green.shade600
                      : cs.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.30),
                      blurRadius: 16, offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(
                    progress >= 1.0 ? LucideIcons.checkCircle : LucideIcons.play,
                    color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    progress >= 1.0 ? l10n.workoutSessionDone : l10n.workoutSessionStart,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Exercise row ──────────────────────────────────────────────────────────────
class _ExerciseRow extends StatelessWidget {
  final int index;
  final String name, imageUrl;
  final bool isDone, isCurrent, dark;
  final AppL10n l10n;
  final ColorScheme cs;
  final Color t1, t2, t3;

  const _ExerciseRow({
    required this.index, required this.name, required this.imageUrl,
    required this.isDone, required this.isCurrent, required this.dark,
    required this.l10n, required this.cs,
    required this.t1, required this.t2, required this.t3,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: t3, width: 1),
          left: isCurrent
              ? BorderSide(color: cs.primary, width: 3)
              : BorderSide.none,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(isCurrent ? 12 : 0, 14, 0, 14),
        child: Row(children: [
          // Number badge
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: isDone
                  ? cs.primary
                  : isCurrent
                      ? cs.primary.withValues(alpha: 0.12)
                      : t3,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? Icon(LucideIcons.check, color: Colors.white, size: 14)
                  : Text('${index + 1}',
                      style: GoogleFonts.outfit(
                        fontSize: 13, fontWeight: FontWeight.w800,
                        color: isCurrent ? cs.primary : t2)),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                style: GoogleFonts.outfit(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: isDone ? t2 : t1,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: t2,
                )),
              const SizedBox(height: 4),
              Row(children: [
                Icon(LucideIcons.clock3, size: 11, color: t2),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(l10n.workoutExerciseDuration,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 12, color: t2)),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Full Body',
                    style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w600, color: cs.primary)),
                ),
              ]),
            ]),
          ),
          const SizedBox(width: 12),

          // Thumbnail with play/check
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 72, height: 52,
              child: Stack(fit: StackFit.expand, children: [
                Image.asset(imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: t3)),
                Container(color: Colors.black.withValues(alpha: 0.25)),
                Center(
                  child: Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: isDone ? cs.primary : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDone ? LucideIcons.check : LucideIcons.play,
                      size: 12,
                      color: isDone ? Colors.white : cs.primary,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 4),
          Icon(LucideIcons.chevronRight, size: 16, color: t2),
        ]),
      ),
    );
  }
}

// ── Hero pill ─────────────────────────────────────────────────────────────────
class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.40),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: Colors.white),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.inter(
        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}
