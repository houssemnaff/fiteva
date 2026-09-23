import 'dart:ui';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/points_provider.dart';
import '../../models/video_model.dart';
import '../../providers/workout_progress_provider.dart';
import '../../services/workout_progress_service.dart';

int _pointsForExercise(int total, int count, int idx) {
  if (count == 0) return 0;
  final base = total ~/ count;
  return idx < total % count ? base + 1 : base;
}

// ══════════════════════════════════════════════════════════════════════════════
class ExercisePlayerScreen extends StatefulWidget {
  final WidgetRef ref;
  final String workoutTitle;
  final String exerciseName;
  final String videoId;
  final String? videoUrl;
  final int exerciseIndex;
  final int totalExercises;
  final int totalWorkoutPoints;
  final VoidCallback onCompleted;
  final String? workoutId;
  final List<String>? allVideoIds;
  final VideoModel? video;

  const ExercisePlayerScreen({
    super.key,
    required this.ref,
    required this.workoutTitle,
    required this.exerciseName,
    required this.videoId,
    this.videoUrl,
    required this.exerciseIndex,
    required this.totalExercises,
    required this.totalWorkoutPoints,
    required this.onCompleted,
    this.workoutId,
    this.allVideoIds,
    this.video,
  });

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen>
    with TickerProviderStateMixin {
  bool _isDone = false;
  bool _hasWatched80Percent = false;
  bool _showPoints = false;
  int _earnedPoints = 0;
  int _maxPositionMs = 0;
  int _lastSavedTenth = -1;

  late final AnimationController _doneCtrl;
  late final Animation<double> _doneScale;

  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;
  bool _isVideoReady = false;
  bool _videoUnavailable = false;
  String? _debugErrorDetail;
  bool _wasAlreadyCompleted = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _doneCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _doneScale = CurvedAnimation(parent: _doneCtrl, curve: Curves.elasticOut);
    _initAfterCompletionCheck();
  }

  Future<void> _initAfterCompletionCheck() async {
    await _checkVideoCompletion();
    if (!mounted) return;
    await _initVideo();
  }

  Future<void> _checkVideoCompletion() async {
    final done = await WorkoutProgressService.isVideoCompleted(widget.videoId);
    if (mounted) {
      setState(() {
        _hasWatched80Percent = done;
        _wasAlreadyCompleted = done;
      });
    }
  }

  Future<void> _initVideo() async {
    final url = widget.videoUrl;
    if (url == null || url.isEmpty) {
      if (mounted) {
        setState(() {
          _videoUnavailable = true;
          _debugErrorDetail = 'videos.url est vide (NULL ou "") en base '
              'pour videoId=${widget.videoId}.';
        });
      }
      return;
    }
    _videoCtrl = url.startsWith('http')
        ? VideoPlayerController.networkUrl(Uri.parse(url))
        : VideoPlayerController.asset(url);
    try {
      await _videoCtrl!.initialize();
      _videoCtrl!.addListener(_onProgress);
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      _chewieCtrl = ChewieController(
        videoPlayerController: _videoCtrl!,
        autoPlay: true,
        looping: false,
        showControls: true,
        aspectRatio: _videoCtrl!.value.aspectRatio,
        placeholder: const ColoredBox(color: Colors.black),
        materialProgressColors: ChewieProgressColors(
          playedColor: cs.primary,
          handleColor: cs.primary,
          bufferedColor: Colors.white30,
          backgroundColor: Colors.white12,
        ),
      );
      setState(() => _isVideoReady = true);
    } catch (e) {
      debugPrint('Video error for url="$url": $e');
      if (mounted) {
        setState(() {
          _videoUnavailable = true;
          _debugErrorDetail = 'url="$url"\n$e';
        });
      }
    }
  }

  void _onProgress() {
    if (_wasAlreadyCompleted) return;
    final ctrl = _videoCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    final dur = ctrl.value.duration.inMilliseconds;
    final pos = ctrl.value.position.inMilliseconds;
    if (dur <= 0) return;
    if (pos > _maxPositionMs + 1500) {
      ctrl.seekTo(Duration(milliseconds: _maxPositionMs));
      return;
    }
    if (pos > _maxPositionMs) _maxPositionMs = pos;
    final frac = (pos / dur).clamp(0.0, 1.0);
    if (!_hasWatched80Percent && frac >= 0.80) {
      setState(() => _hasWatched80Percent = true);
    }
    final tenth = (frac * 10).floor();
    if (tenth > _lastSavedTenth) {
      _lastSavedTenth = tenth;
      WorkoutProgressService.updateVideoProgress(widget.videoId, frac);
    }
  }

  Future<void> _checkAndMarkComplete() async {
    if (widget.workoutId == null || widget.allVideoIds == null || widget.allVideoIds!.isEmpty) return;
    final done = await WorkoutProgressService.getCompletedVideos();
    for (final videoId in widget.allVideoIds!) {
      if (!done.contains(videoId)) return;
    }
    await WorkoutProgressService.markWorkoutComplete(widget.workoutId!);
  }

  Future<void> _complete() async {
    if (_isDone) return;
    if (_videoUnavailable) { _showUnavailableWarning(); return; }
    if (!_hasWatched80Percent) { _showIncompleteWarning(); return; }

    HapticFeedback.mediumImpact();
    final saved = await WorkoutProgressService.markVideoComplete(widget.videoId);
    if (!saved) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Impossible d\'enregistrer ta progression. Vérifie ta connexion.'),
          duration: Duration(seconds: 3)));
      }
      return;
    }
    final pts = _wasAlreadyCompleted ? 0
        : _pointsForExercise(widget.totalWorkoutPoints, widget.totalExercises, widget.exerciseIndex);
    if (!_wasAlreadyCompleted) {
      widget.ref.read(pointsProvider.notifier).addWorkoutPoints(pts);
    }
    await _checkAndMarkComplete();
    widget.ref.invalidate(completedVideosProvider);
    widget.ref.invalidate(workoutCompletionPercentageProvider);
    widget.ref.invalidate(programCompletionPercentageProvider);
    widget.ref.invalidate(programStatusProvider);
    setState(() { _isDone = true; _earnedPoints = pts; _showPoints = pts > 0; });
    _doneCtrl.forward();
    widget.onCompleted();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) Navigator.of(context).pop();
  }

  void _showUnavailableWarning() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vidéo non disponible pour le moment.'), duration: Duration(seconds: 2)));
  }

  void _showIncompleteWarning() {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final t1 = dark ? const Color(0xFFF0F0F0) : const Color(0xFF111111);
    final t2 = dark ? const Color(0xFF888888) : const Color(0xFF666666);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
        decoration: BoxDecoration(color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: dark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Container(width: 64, height: 64,
            decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(LucideIcons.alertTriangle, color: Color(0xFFF59E0B), size: 28)),
          const SizedBox(height: 16),
          Text('Vidéo non terminée',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: t1)),
          const SizedBox(height: 10),
          Text('Tu dois regarder au moins 80 % de la vidéo pour débloquer tes points.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: t2, height: 1.6)),
          const SizedBox(height: 24),
          Builder(builder: (_) {
            final ctrl = _videoCtrl;
            final pct = (ctrl != null && ctrl.value.isInitialized && ctrl.value.duration.inMilliseconds > 0)
                ? (_maxPositionMs / ctrl.value.duration.inMilliseconds).clamp(0.0, 1.0) : 0.0;
            return Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Progression', style: GoogleFonts.inter(fontSize: 12, color: t2)),
                Text('${(pct * 100).toInt()} % / 80 %',
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700,
                        color: pct >= 0.80 ? cs.primary : const Color(0xFFF59E0B))),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: pct, minHeight: 8,
                    backgroundColor: dark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
                    valueColor: AlwaysStoppedAnimation(pct >= 0.80 ? cs.primary : const Color(0xFFF59E0B)))),
            ]);
          }),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(color: cs.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.30),
                        blurRadius: 14, offset: const Offset(0, 5))]),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(LucideIcons.play, color: Colors.white, size: 16),
                  const SizedBox(width: 10),
                  Text('Continuer la vidéo',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                ])))),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _doneCtrl.dispose();
    _chewieCtrl?.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final l10n = widget.ref.read(l10nProvider);
    final pts = _pointsForExercise(widget.totalWorkoutPoints, widget.totalExercises, widget.exerciseIndex);
    final accent = cs.primary;

    final bg = dark ? const Color(0xFF0A0A0A) : Colors.white;
    final t1 = dark ? Colors.white : const Color(0xFF1A1A1A);
    final t2 = dark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF8E8E93);

    final video = widget.video;
    final isStandalone = widget.workoutId == null && widget.totalExercises == 1;
    final description = video?.techniqueDescription ?? '';
    final hasDetailContent = description.isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(children: [
        Column(children: [
          // ── Video ──
          Container(
            color: Colors.black,
            child: SafeArea(
              bottom: false,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
                  child: Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const SizedBox(width: 40, height: 40,
                        child: Icon(LucideIcons.chevronDown, color: Colors.white, size: 22)),
                    ),
                    const Spacer(),
                    // Minimal step dots
                    ...List.generate(widget.totalExercises, (i) {
                      final active = i == widget.exerciseIndex;
                      final done = i < widget.exerciseIndex;
                      return Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: done || active ? accent : Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(3)),
                      );
                    }),
                  ]),
                ),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _videoUnavailable
                      ? _VideoUnavailable(debugDetail: _debugErrorDetail)
                      : _isVideoReady && _chewieCtrl != null
                          ? Chewie(controller: _chewieCtrl!)
                          : Center(child: CircularProgressIndicator(color: accent, strokeWidth: 2)),
                ),
              ]),
            ),
          ),

          // ── Content — single editorial scroll ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Title block ──
                Text(widget.workoutTitle.toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                        letterSpacing: 1.8, color: t2)),
                const SizedBox(height: 8),
                Text(widget.exerciseName,
                    style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900,
                        color: t1, height: 1.05, letterSpacing: -0.8)),
                const SizedBox(height: 20),

                if (isStandalone && !hasDetailContent) ...[
                  // ── Standalone video — clean layout ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withValues(alpha: dark ? 0.12 : 0.08),
                          accent.withValues(alpha: dark ? 0.04 : 0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withValues(alpha: 0.10)),
                    ),
                    child: Column(children: [
                      // Stats row
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        _StandaloneStatItem(icon: LucideIcons.clock, value: video?.duration ?? '', label: 'Durée', accent: accent, t1: t1, t2: t2),
                        Container(width: 1, height: 36, color: accent.withValues(alpha: 0.15)),
                        _StandaloneStatItem(icon: LucideIcons.zap, value: '$pts', label: 'Points', accent: accent, t1: t1, t2: t2),
                        Container(width: 1, height: 36, color: accent.withValues(alpha: 0.15)),
                        _StandaloneStatItem(icon: LucideIcons.flame, value: video?.category ?? '', label: 'Type', accent: accent, t1: t1, t2: t2),
                      ]),
                    ]),
                  ),

                  if (video?.coach != null) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF141414) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withValues(alpha: dark ? 0.25 : 0.06),
                            blurRadius: 16, offset: const Offset(0, 4))],
                        ),
                        child: Row(children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: accent.withValues(alpha: 0.3), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: video!.coach!.avatarUrl.isNotEmpty
                                  ? NetworkImage(video.coach!.avatarUrl)
                                  : null,
                              backgroundColor: accent.withValues(alpha: 0.10),
                              child: video.coach!.avatarUrl.isEmpty
                                  ? Icon(LucideIcons.user, size: 20, color: accent)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Avec', style: GoogleFonts.inter(fontSize: 11, color: t2, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                              const SizedBox(height: 3),
                              Text(video.coach!.name, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: t1, letterSpacing: -0.3)),
                            ],
                          )),
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(LucideIcons.atSign, size: 18, color: accent),
                          ),
                        ]),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── CTA card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(
                        color: accent.withValues(alpha: 0.35),
                        blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Column(children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.play, size: 24, color: Colors.white),
                      ),
                      const SizedBox(height: 14),
                      Text('Lancez la vidéo\net suivez le rythme !',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w700, height: 1.4)),
                      const SizedBox(height: 6),
                      Text('Appuyez sur play pour commencer',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ] else ...[
                // ── Stat pills row ──
                Row(children: [
                  Expanded(child: _StatPill(value: '${video?.sets ?? 3}', label: 'Sets', icon: LucideIcons.repeat, accent: accent)),
                  const SizedBox(width: 8),
                  Expanded(child: _StatPill(value: '${video?.workSeconds ?? 45}s', label: 'Work', icon: LucideIcons.timer, accent: accent)),
                  const SizedBox(width: 8),
                  Expanded(child: _StatPill(value: '${video?.restSeconds ?? 15}s', label: 'Rest', icon: LucideIcons.pause, accent: accent)),
                  const SizedBox(width: 8),
                  Expanded(child: _StatPill(value: '$pts', label: 'Pts', icon: LucideIcons.zap, accent: accent)),
                ]),

                const SizedBox(height: 24),

                // ── Technique card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: dark ? accent.withValues(alpha: 0.06) : accent.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: accent.withValues(alpha: 0.12)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(LucideIcons.bookOpen, size: 14, color: accent),
                      const SizedBox(width: 8),
                      Text('Technique', style: GoogleFonts.outfit(
                          fontSize: 13, fontWeight: FontWeight.w700, color: accent)),
                    ]),
                    const SizedBox(height: 12),
                    description.isEmpty
                        ? _NoDataInline(t2: t2)
                        : Text(description,
                            style: GoogleFonts.inter(fontSize: 14, color: t2, height: 1.75, letterSpacing: -0.1)),
                  ]),
                ),

                ], // end of else (program detail sections)
              ]),
            ),
          ),
        ]),

        // Floating points
        if (_showPoints)
          Positioned(bottom: 100, left: 0, right: 0,
            child: _FloatingPoints(pts: _earnedPoints, accent: accent)),
      ]),

      // ── Bottom bar ──
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 20),
        decoration: BoxDecoration(
          color: bg,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? 0.35 : 0.05),
              blurRadius: 20, offset: const Offset(0, -6))],
        ),
        child: Builder(builder: (_) {
          final effectivelyDone = _isDone || _wasAlreadyCompleted;
          return ScaleTransition(
            scale: _isDone ? _doneScale : const AlwaysStoppedAnimation(1.0),
            child: GestureDetector(
              onTap: effectivelyDone ? null : _complete,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: effectivelyDone
                        ? [Colors.green.shade600, Colors.green.shade700]
                        : _videoUnavailable ? [t2, t2]
                        : [accent, Color.lerp(accent, Colors.black, 0.18)!],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow(
                    color: (effectivelyDone ? Colors.green : accent).withValues(alpha: 0.35),
                    blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(effectivelyDone ? LucideIcons.checkCircle
                      : _videoUnavailable ? LucideIcons.alertTriangle : LucideIcons.check,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(effectivelyDone ? l10n.exDoneLabel
                      : _videoUnavailable ? 'Indisponible' : l10n.exCompleteBtn,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MINIMAL WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _StandaloneStatItem extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color accent, t1, t2;
  const _StandaloneStatItem({required this.icon, required this.value, required this.label, required this.accent, required this.t1, required this.t2});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 17, color: accent),
      ),
      const SizedBox(height: 8),
      Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: t1)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: t2, fontWeight: FontWeight.w500)),
    ]);
  }
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color accent;
  const _StatPill({required this.value, required this.label, required this.icon, required this.accent});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final t1 = dark ? Colors.white : const Color(0xFF1A1A1A);
    final t2 = dark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF8E8E93);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF141414) : const Color(0xFFF8F8F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dark ? const Color(0xFF2A2A2A) : const Color(0xFFEDEDEB)),
      ),
      child: Column(children: [
        Icon(icon, size: 13, color: accent),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w900,
            color: t1, height: 1)),
        const SizedBox(height: 3),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500,
            color: t2, letterSpacing: 0.3)),
      ]),
    );
  }
}

class _NoDataInline extends StatelessWidget {
  final Color t2;
  const _NoDataInline({required this.t2});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(LucideIcons.info, size: 14, color: t2),
    const SizedBox(width: 8),
    Expanded(
      child: Text('Pas encore de données pour le moment.',
          style: GoogleFonts.inter(fontSize: 13, color: t2, height: 1.5,
              fontStyle: FontStyle.italic)),
    ),
  ]);
}


class _VideoUnavailable extends StatelessWidget {
  final String? debugDetail;
  const _VideoUnavailable({this.debugDetail});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black,
    child: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.videoOff, color: Colors.white.withValues(alpha: 0.55), size: 32),
        const SizedBox(height: 10),
        Text('Vidéo non disponible',
            style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.70),
                fontSize: 13, fontWeight: FontWeight.w600)),
        if (kDebugMode && debugDetail != null) ...[
          const SizedBox(height: 10),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(debugDetail!, textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.orangeAccent.withValues(alpha: 0.85),
                    fontSize: 10, fontWeight: FontWeight.w500))),
        ],
      ]),
    ),
  );
}

class _FloatingPoints extends StatefulWidget {
  final int pts;
  final Color accent;
  const _FloatingPoints({required this.pts, required this.accent});

  @override
  State<_FloatingPoints> createState() => _FloatingPointsState();
}

class _FloatingPointsState extends State<_FloatingPoints>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
    _slide = Tween(begin: Offset.zero, end: const Offset(0, -1.2))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SlideTransition(
    position: _slide,
    child: FadeTransition(
      opacity: _opacity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: widget.accent,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [BoxShadow(color: widget.accent.withValues(alpha: 0.45),
                blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.zap, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('+${widget.pts} pts',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.w900, letterSpacing: -0.3)),
          ]),
        ),
      ),
    ),
  );
}
