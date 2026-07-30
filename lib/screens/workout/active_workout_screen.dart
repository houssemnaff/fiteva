import 'dart:core';
import 'dart:ui';

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

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen>
    with TickerProviderStateMixin {
  int _completedExercises = 0;
  bool _workoutMarkedComplete = false;
  Set<String> _completedVideos = {};
  late final AnimationController _enterCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _loadStatus();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  int _countDone(Set<String> done) {
    int count = 0;
    for (final v in widget.workout.videos) {
      if (done.contains(v.id)) count++;
    }
    return count;
  }

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

  void _openExercise(int index) {
    final video = widget.workout.videoAt(index);
    if (video == null) return;
    HapticFeedback.mediumImpact();
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
    final accent = cs.primary;

    final bg = dark ? const Color(0xFF0A0A0A) : Colors.white;
    final cardBg = dark ? const Color(0xFF161616) : const Color(0xFFF8F8F8);
    final t1 = dark ? Colors.white : const Color(0xFF1A1A1A);
    final t2 = dark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF6B7280);

    if (progress >= 1.0) Future.microtask(_markCompleteIfNeeded);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Immersive Hero ──
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.42,
                  child: Stack(fit: StackFit.expand, children: [
                    // Background image
                    widget.workout.imageUrl.startsWith('http')
                        ? Image.network(widget.workout.imageUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: accent))
                        : Image.asset(widget.workout.imageUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: accent)),

                    // Gradient overlay
                    DecoratedBox(decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        stops: const [0.0, 0.3, 0.7, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.5),
                          bg.withValues(alpha: 1.0),
                        ],
                      ),
                    )),

                    // Back + title content
                    Positioned(
                      left: 0, right: 0, top: 0,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                    ),
                                    child: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),

                    // Bottom content on hero
                    Positioned(
                      left: 20, right: 20, bottom: 30,
                      child: FadeTransition(
                        opacity: CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.2, 0.7)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Category pill
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(widget.workout.category.toUpperCase(),
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 10,
                                        fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(widget.workout.title,
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 30,
                                  fontWeight: FontWeight.w900, height: 1.05, letterSpacing: -0.8)),
                          const SizedBox(height: 12),
                          // Meta pills row
                          Row(children: [
                            _GlassPill(icon: LucideIcons.clock, label: widget.workout.duration),
                            const SizedBox(width: 8),
                            _GlassPill(icon: LucideIcons.flame, label: '${widget.workout.calories} cal'),
                            const SizedBox(width: 8),
                            _GlassPill(icon: LucideIcons.zap, label: widget.workout.level),
                          ]),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),

              // ── Floating progress ring section ──
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: dark ? 0.3 : 0.08),
                            blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Row(children: [
                        // Progress ring
                        SizedBox(
                          width: 60, height: 60,
                          child: Stack(alignment: Alignment.center, children: [
                            SizedBox(
                              width: 60, height: 60,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 5,
                                backgroundColor: accent.withValues(alpha: 0.12),
                                valueColor: AlwaysStoppedAnimation(
                                    progress >= 1.0 ? Colors.green : accent),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(mainAxisSize: MainAxisSize.min, children: [
                              Text('$_completedExercises/${videos.length}',
                                  style: GoogleFonts.outfit(fontSize: 16,
                                      fontWeight: FontWeight.w900, color: t1)),
                            ]),
                          ]),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(progress >= 1.0 ? l10n.workoutSessionDone : l10n.workoutProgress,
                                style: GoogleFonts.outfit(fontSize: 16,
                                    fontWeight: FontWeight.w800, color: t1)),
                            const SizedBox(height: 4),
                            Text(l10n.workoutPossiblePoints(widget.workout.points),
                                style: GoogleFonts.inter(fontSize: 12, color: t2)),
                            const SizedBox(height: 10),
                            // Segment bar
                            Row(
                              children: List.generate(videos.length, (i) {
                                final done = _completedVideos.contains(videos[i].id);
                                return Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: i < videos.length - 1 ? 3 : 0),
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: done ? accent : accent.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),

              // ── Section title ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
                  child: Row(children: [
                    Container(
                      width: 3, height: 18,
                      decoration: BoxDecoration(
                          color: accent, borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 10),
                    Text('Exercices',
                        style: GoogleFonts.outfit(fontSize: 18,
                            fontWeight: FontWeight.w800, color: t1, letterSpacing: -0.3)),
                    const Spacer(),
                    Text('${videos.length} vidéo${videos.length > 1 ? 's' : ''}',
                        style: GoogleFonts.inter(fontSize: 12, color: t2, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),

              // ── Exercise cards ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final video = videos[index];
                      final isDone = _completedVideos.contains(video.id);
                      final isCurrent = !isDone && index == _firstIncompleteOf(_completedVideos);
                      final imageUrl = video.thumbnailUrl.isNotEmpty
                          ? video.thumbnailUrl
                          : widget.workout.imageUrl;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExerciseCard(
                          index: index,
                          name: video.title,
                          imageUrl: imageUrl,
                          points: video.points,
                          isDone: isDone,
                          isCurrent: isCurrent,
                          dark: dark,
                          accent: accent,
                          cardBg: cardBg,
                          t1: t1,
                          t2: t2,
                          pulseCtrl: _pulseCtrl,
                          onTap: () => _openExercise(index),
                        ),
                      );
                    },
                    childCount: videos.length,
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky bottom CTA ──
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
              decoration: BoxDecoration(
                color: bg,
                border: Border(top: BorderSide(
                    color: dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFEEEEEE))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? 0.4 : 0.06),
                    blurRadius: 20, offset: const Offset(0, -6)),
                ],
              ),
              child: GestureDetector(
                onTap: progress >= 1.0 ? null : () {
                  HapticFeedback.mediumImpact();
                  _openFirstIncomplete();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 56,
                  decoration: BoxDecoration(


 gradient: LinearGradient(
                    colors:  progress >= 1.0
                        ? [const Color.fromARGB(255, 17, 63, 18).withValues(alpha: 0.70), Color.fromARGB(255, 17, 63, 18)]
                        : [accent, const Color(0xFF2E7D52)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),

                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: (progress >= 1.0 ? Colors.green : accent).withValues(alpha: 0.35),
                        blurRadius: 18, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(progress >= 1.0 ? LucideIcons.checkCircle : LucideIcons.play,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      progress >= 1.0 ? l10n.workoutSessionDone : l10n.workoutSessionStart,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.w800)),
                    if (progress > 0 && progress < 1.0) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$_completedExercises/${videos.length}',
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Exercise Card — immersive thumbnail with overlay info
// ══════════════════════════════════════════════════════════════════════════════
class _ExerciseCard extends StatefulWidget {
  final int index;
  final String name, imageUrl;
  final int points;
  final bool isDone, isCurrent, dark;
  final Color accent, cardBg, t1, t2;
  final AnimationController pulseCtrl;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.index,
    required this.name,
    required this.imageUrl,
    required this.points,
    required this.isDone,
    required this.isCurrent,
    required this.dark,
    required this.accent,
    required this.cardBg,
    required this.t1,
    required this.t2,
    required this.pulseCtrl,
    required this.onTap,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCurrent = widget.isCurrent;
    final isDone = widget.isDone;
    final accent = widget.accent;
    final cardHeight = isCurrent ? 140.0 : 100.0;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) { _pressCtrl.reverse(); widget.onTap(); },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: isCurrent
                ? Border.all(color: accent.withValues(alpha: 0.5), width: 2)
                : null,
            boxShadow: [
              if (isCurrent)
                BoxShadow(
                    color: accent.withValues(alpha: 0.2),
                    blurRadius: 16, offset: const Offset(0, 6))
              else
                BoxShadow(
                    color: Colors.black.withValues(alpha: widget.dark ? 0.25 : 0.06),
                    blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(fit: StackFit.expand, children: [
              // Background image
              widget.imageUrl.startsWith('http')
                  ? Image.network(widget.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: accent.withValues(alpha: 0.15)))
                  : Image.asset(widget.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: accent.withValues(alpha: 0.15))),

              // Dim overlay for done
              if (isDone)
                Container(color: Colors.black.withValues(alpha: 0.55)),

              // Gradient overlay
              DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft, end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              )),

              // Content overlay
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                child: Row(children: [
                  // Left: number + info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Number badge
                        Row(children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? Colors.green
                                  : isCurrent
                                      ? accent
                                      : Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Center(
                              child: isDone
                                  ? const Icon(LucideIcons.check, color: Colors.white, size: 14)
                                  : Text('${widget.index + 1}',
                                      style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(widget.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: isCurrent ? 17 : 15,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    decorationColor: Colors.white.withValues(alpha: 0.5))),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        // Points + status
                        Row(children: [
                          const SizedBox(width: 38),
                          if (widget.points > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : accent.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(LucideIcons.zap, size: 10,
                                    color: isDone ? Colors.green.shade300 : Colors.white.withValues(alpha: 0.9)),
                                const SizedBox(width: 4),
                                Text('${widget.points} pts',
                                    style: GoogleFonts.inter(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ]),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (isDone)
                            Text('Terminé',
                                style: GoogleFonts.inter(
                                    color: Colors.green.shade300,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600))
                          else if (isCurrent)
                            Text('En cours',
                                style: GoogleFonts.inter(
                                    color: accent.withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                        ]),
                      ],
                    ),
                  ),

                  // Right: play/check button
                  const SizedBox(width: 12),
                  _PlayButton(
                    isDone: isDone,
                    isCurrent: isCurrent,
                    accent: accent,
                    pulseCtrl: widget.pulseCtrl,
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Animated play/check button ───────────────────────────────────────────────
class _PlayButton extends StatelessWidget {
  final bool isDone, isCurrent;
  final Color accent;
  final AnimationController pulseCtrl;

  const _PlayButton({
    required this.isDone,
    required this.isCurrent,
    required this.accent,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.green.withValues(alpha: 0.4),
                blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: const Icon(LucideIcons.check, color: Colors.white, size: 20),
      );
    }

    if (isCurrent) {
      return AnimatedBuilder(
        animation: pulseCtrl,
        builder: (context, child) {
          final glow = 0.15 + (pulseCtrl.value * 0.2);
          return Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: glow),
                    blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: const Icon(LucideIcons.play, color: Colors.white, size: 22),
          );
        },
      );
    }

    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: const Icon(LucideIcons.play, color: Colors.white, size: 18),
    );
  }
}

// ── Glass pill for hero meta ─────────────────────────────────────────────────
class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GlassPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.inter(
              color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ]),
      ),
    ),
  );
}
