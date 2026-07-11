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
import '../../core/shop/shop_provider.dart';
import '../../models/video_model.dart';
import '../../providers/workout_progress_provider.dart';
import '../../services/workout_progress_service.dart';

int _pointsForExercise(int total, int count, int idx) {
  if (count == 0) return 0;
  final base = total ~/ count;
  return idx < total % count ? base + 1 : base;
}

/// Icône associée à un muscle (videos.muscles_primary[].name) — mapping par
/// libellé connu, icône neutre par défaut pour tout nom inconnu (permet
/// d'ajouter de nouveaux muscles en base sans casser l'UI).
IconData _muscleIcon(String name) {
  switch (name) {
    case 'Quadriceps':
    case 'Ischio-jambiers':
    case 'Épaules':      return LucideIcons.zap;
    case 'Fessiers':
    case 'Dos':
    case 'Lombaires':    return LucideIcons.activity;
    case 'Abdominaux':   return LucideIcons.target;
    case 'Pectoraux':    return LucideIcons.heart;
    case 'Biceps':
    case 'Triceps':      return LucideIcons.dumbbell;
    default:             return LucideIcons.activity;
  }
}

/// Icône associée à un conseil (videos.tips[].title) — mapping par libellé
/// connu, icône neutre par défaut pour tout titre inconnu.
IconData _tipIcon(String title) {
  switch (title) {
    case 'Regard':       return LucideIcons.eye;
    case 'Respiration':  return LucideIcons.wind;
    case 'Amplitude':    return LucideIcons.moveVertical;
    case 'Posture':      return LucideIcons.activity;
    case 'Rythme':       return LucideIcons.timer;
    default:             return LucideIcons.info;
  }
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

  /// Contenu pédagogique (technique, muscles, conseils, séries/repos) —
  /// null ou champs vides → l'écran retombe sur son contenu générique.
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
  int _tab = 0;
  bool _showPoints = false;
  int _earnedPoints = 0;

  // Max position reached — used to block forward seeking
  int _maxPositionMs = 0;

  // Dernier palier de 10% déjà enregistré côté serveur — évite de spammer
  // Supabase à chaque frame tout en gardant une trace du visionnage partiel
  // (avant, seul le seuil des 80% était sauvegardé, donc une vidéo vue à
  // moitié puis abandonnée ne laissait aucune trace en base).
  int _lastSavedTenth = -1;

  late final AnimationController _doneCtrl;
  late final Animation<double> _doneScale;

  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;
  bool _isVideoReady = false;

  /// true si videos.url est vide ou si l'initialisation a échoué (fichier
  /// manquant, URL cassée…) — plus de fallback silencieux vers une vidéo
  /// de test : on affiche un état d'erreur explicite à la place.
  bool _videoUnavailable = false;

  /// Détail de l'échec (url tentée + exception) — affiché seulement en
  /// mode debug pour diagnostiquer rapidement (asset non déclaré,
  /// mauvais chemin, pubspec pas rechargé après un restart incomplet…).
  String? _debugErrorDetail;

  /// true si CETTE vidéo était déjà marquée terminée en base AVANT que cet
  /// écran ne s'ouvre (capturé une seule fois, à l'ouverture — contrairement
  /// à _hasWatched80Percent qui redevient true dès qu'on revisionne 80% de
  /// la vidéo). Sert de garde pour n'attribuer les points qu'une seule fois
  /// par vidéo : sans ça, rouvrir une vidéo déjà vue réactivait le bouton
  /// "Terminer" (car _hasWatched80Percent partait déjà à true) et chaque
  /// appui rappelait addPoints, donc les points étaient regagnés à l'infini.
  bool _wasAlreadyCompleted = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _doneCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _doneScale = CurvedAnimation(parent: _doneCtrl, curve: Curves.elasticOut);
    // IMPORTANT : on ATTEND la vérification "déjà terminée ?" avant de
    // démarrer la vidéo. Avant, les deux tournaient en parallèle — une
    // vidéo en asset local s'initialise quasi instantanément (autoplay),
    // alors que isVideoCompleted() est un aller-retour réseau vers
    // Supabase. Le lecteur commençait donc à jouer et _onProgress() à
    // écrire "completed: false" AVANT même que _wasAlreadyCompleted soit
    // positionné à true — le garde-fou dans _onProgress arrivait toujours
    // trop tard, donc une vidéo déjà terminée repassait "non terminée" dès
    // qu'on la rouvrait. En séquençant, _wasAlreadyCompleted est garanti
    // correct avant que la vidéo ne puisse émettre le moindre événement.
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

    // videos.url vide en base — plus de fallback vers une vidéo de test :
    // état d'erreur explicite affiché à l'utilisatrice.
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

    // URL réseau (Supabase Storage, CDN…) vs asset embarqué : .asset() sur
    // une URL http échoue à s'initialiser → aucune progression possible.
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
      // Fichier manquant, URL cassée, format non supporté… — état d'erreur
      // explicite au lieu d'un spinner qui tourne indéfiniment.
      //
      // Causes les plus fréquentes quand l'url en base est correcte
      // (ex : "assets/videos/workout3.mp4") mais que ça échoue quand même :
      //  1. pubspec.yaml modifié sans ARRÊT COMPLET + relance de `flutter
      //     run` — le hot reload/restart ne régénère PAS AssetManifest.json.
      //  2. Build cache obsolète → `flutter clean` puis relancer.
      //  3. Provider Riverpod encore en cache avec l'ancienne donnée
      //     (fetchée avant la mise à jour SQL) → redémarrage complet requis.
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
    // Vidéo déjà terminée avant l'ouverture de cet écran : on ne track/écrit
    // plus rien pendant une relecture. Sans ça, updateVideoProgress() (fire-
    // and-forget, appelé à chaque palier de 10%) upserte "completed: false"
    // dès les premières secondes de la relecture (frac proche de 0), et
    // cette écriture pouvait arriver APRÈS celle de "Terminer" côté réseau
    // — un vrai risque de course qui repassait la vidéo à "non terminée".
    if (_wasAlreadyCompleted) return;

    final ctrl = _videoCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    final dur = ctrl.value.duration.inMilliseconds;
    final pos = ctrl.value.position.inMilliseconds;
    if (dur <= 0) return;

    // ── Block forward seeking ──────────────────────────────────────────────
    // Allow up to 1.5 s ahead of the max reached (buffering tolerance)
    if (pos > _maxPositionMs + 1500) {
      ctrl.seekTo(Duration(milliseconds: _maxPositionMs));
      return;
    }
    if (pos > _maxPositionMs) _maxPositionMs = pos;

    final frac = (pos / dur).clamp(0.0, 1.0);

    // ── Track 80 % threshold (marks the video as fully "done") ────────────
    if (!_hasWatched80Percent && frac >= 0.80) {
      setState(() => _hasWatched80Percent = true);
    }

    // ── Save partial progress every 10% — so a video watched only
    // partway (e.g. abandoned at 40%) still shows up as "in progress"
    // instead of leaving no trace until the 80% mark.
    final tenth = (frac * 10).floor();
    if (tenth > _lastSavedTenth) {
      _lastSavedTenth = tenth;
      WorkoutProgressService.updateVideoProgress(widget.videoId, frac);
    }
  }

  Future<void> _checkAndMarkComplete() async {
    if (widget.workoutId == null || widget.allVideoIds == null || widget.allVideoIds!.isEmpty) {
      return;
    }
    final done = await WorkoutProgressService.getCompletedVideos();
    for (final videoId in widget.allVideoIds!) {
      if (!done.contains(videoId)) return;
    }
    await WorkoutProgressService.markWorkoutComplete(widget.workoutId!);
  }

  Future<void> _complete() async {
    if (_isDone) return;

    if (_videoUnavailable) {
      _showUnavailableWarning();
      return;
    }

    // ── Not watched 80 % → show warning, block completion ─────────────────
    if (!_hasWatched80Percent) {
      _showIncompleteWarning();
      return;
    }

    HapticFeedback.mediumImpact();

    // ── Marque la vidéo comme terminée en base — AVANT tout le reste ──────
    // La sauvegarde par paliers de 10 % (_onProgress) est fire-and-forget :
    // sans cette écriture explicite et attendue, la vidéo pouvait rester
    // non terminée en base, et _checkAndMarkComplete (qui relit les vidéos
    // terminées) ne marquait alors jamais le workout comme complet.
    // (idempotent — sans risque de rappeler sur une vidéo déjà marquée.)
    //
    // IMPORTANT : on VÉRIFIE que l'écriture a réellement abouti avant de
    // continuer. Avant, l'échec était avalé en silence — l'UI passait quand
    // même en "terminé" (état local optimiste) alors que rien n'était
    // persisté, et la vérité n'apparaissait qu'au prochain redémarrage
    // complet de l'app (relecture depuis la base à zéro).
    final saved = await WorkoutProgressService.markVideoComplete(widget.videoId);
    if (!saved) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Impossible d\'enregistrer ta progression. Vérifie ta connexion et réessaie.'),
          duration: Duration(seconds: 3),
        ));
      }
      return; // ne pas attribuer de points ni afficher "terminé" tant que
               // ce n'est pas confirmé en base.
    }

    // ── Award points — UNE SEULE FOIS par vidéo ────────────────────────────
    // Si la vidéo était déjà terminée avant l'ouverture de cet écran, la
    // revisionner ne doit pas régénérer les points (sinon un utilisateur
    // pourrait en gagner à l'infini en rouvrant la même vidéo).
    final pts = _wasAlreadyCompleted
        ? 0
        : _pointsForExercise(
            widget.totalWorkoutPoints, widget.totalExercises, widget.exerciseIndex);
    if (!_wasAlreadyCompleted) {
      widget.ref.read(pointsProvider.notifier).addPoints(pts);
      widget.ref.read(shopProvider.notifier).refresh();
    }

    // Vérifie si tout le workout est terminé (la vidéo vient d'être écrite),
    // PUIS invalide les providers pour qu'ils rechargent l'état à jour.
    await _checkAndMarkComplete();
    widget.ref.invalidate(completedVideosProvider);
    widget.ref.invalidate(workoutCompletionPercentageProvider);
    widget.ref.invalidate(programCompletionPercentageProvider);
    widget.ref.invalidate(programStatusProvider);

    // ── Show floating badge (seulement si des points ont été gagnés) ──────
    setState(() {
      _isDone = true;
      _earnedPoints = pts;
      _showPoints = pts > 0;
    });
    _doneCtrl.forward();
    widget.onCompleted();

    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) Navigator.of(context).pop();
  }

  void _showUnavailableWarning() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Vidéo non disponible pour le moment.'),
      duration: Duration(seconds: 2),
    ));
  }

  void _showIncompleteWarning() {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final t1 = dark ? const Color(0xFFF0F0F0) : const Color(0xFF111111);
    final t2 = dark ? const Color(0xFF888888) : const Color(0xFF666666);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          // Icon
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.alertTriangle,
                color: Color(0xFFF59E0B), size: 28),
          ),
          const SizedBox(height: 16),
          Text('Vidéo non terminée',
            style: GoogleFonts.outfit(
                fontSize: 20, fontWeight: FontWeight.w800, color: t1)),
          const SizedBox(height: 10),
          Text(
            'Tu dois regarder au moins 80 % de la vidéo pour débloquer tes points. Continue à regarder !',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: t2, height: 1.6),
          ),
          const SizedBox(height: 24),
          // Progress bar showing how far she got
          Builder(builder: (_) {
            final ctrl = _videoCtrl;
            final pct = (ctrl != null && ctrl.value.isInitialized &&
                    ctrl.value.duration.inMilliseconds > 0)
                ? (_maxPositionMs / ctrl.value.duration.inMilliseconds).clamp(0.0, 1.0)
                : 0.0;
            return Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Progression', style: GoogleFonts.inter(fontSize: 12, color: t2)),
                Text('${(pct * 100).toInt()} % / 80 %',
                  style: GoogleFonts.outfit(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: pct >= 0.80 ? cs.primary : const Color(0xFFF59E0B))),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 8,
                  backgroundColor:
                      dark ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
                  valueColor: AlwaysStoppedAnimation(
                      pct >= 0.80 ? cs.primary : const Color(0xFFF59E0B)),
                ),
              ),
            ]);
          }),
          const SizedBox(height: 24),
          // CTA — back to video
          SizedBox(
            width: double.infinity,
            height: 52,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.30),
                      blurRadius: 14, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(LucideIcons.play, color: Colors.white, size: 16),
                  const SizedBox(width: 10),
                  Text('Continuer la vidéo',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ),
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

    final bg     = dark ? const Color(0xFF0F0F0F) : const Color(0xFFF6F6F6);
    final cardBg = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final t1     = dark ? const Color(0xFFF0F0F0) : const Color(0xFF111111);
    final t2     = dark ? const Color(0xFF888888) : const Color(0xFF777777);
    final t3     = dark ? const Color(0xFF3A3A3A) : const Color(0xFFE8E8E8);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(children: [
       Column(children: [
        // ── Video zone ─────────────────────────────────────────────────────
        Container(
          color: Colors.black,
          child: SafeArea(
            bottom: false,
            child: Column(children: [
              // Top bar over video
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(LucideIcons.chevronDown, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  // step indicator dots
                  Row(
                    children: List.generate(widget.totalExercises, (i) {
                      final active = i == widget.exerciseIndex;
                      final done   = i < widget.exerciseIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(left: 5),
                        width: active ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: done || active
                              ? cs.primary
                              : Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ]),
              ),
              // 16:9 player
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _videoUnavailable
                    ? _VideoUnavailable(debugDetail: _debugErrorDetail)
                    : _isVideoReady && _chewieCtrl != null
                        ? Chewie(controller: _chewieCtrl!)
                        : Center(child: CircularProgressIndicator(
                            color: cs.primary, strokeWidth: 2)),
              ),
            ]),
          ),
        ),

        // ── Scrollable body ────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Exercise header ──────────────────────────────────────────
              Container(
                color: cardBg,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Eyebrow: workout name + counter
                  Row(children: [
                    Expanded(
                      child: Text(
                        widget.workoutTitle.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w700,
                          letterSpacing: 2, color: cs.primary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.exerciseIndex + 1} / ${widget.totalExercises}',
                        style: GoogleFonts.outfit(
                          fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),

                  // Exercise name
                  Text(
                    widget.exerciseName,
                    style: GoogleFonts.outfit(
                      fontSize: 26, fontWeight: FontWeight.w900,
                      color: t1, height: 1.1, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 16),

                  // Stat chips row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _StatChip(icon: LucideIcons.repeat2, value: '${widget.video?.sets ?? 3}', label: l10n.exStatSets, color: cs.primary, t3: t3, t2: t2),
                      const SizedBox(width: 8),
                      _StatChip(icon: LucideIcons.timer, value: '${widget.video?.workSeconds ?? 45}s', label: l10n.exStatWork, color: const Color(0xFF2563EB), t3: t3, t2: t2),
                      const SizedBox(width: 8),
                      _StatChip(icon: LucideIcons.pause, value: '${widget.video?.restSeconds ?? 15}s', label: l10n.exStatRest, color: const Color(0xFF7C3AED), t3: t3, t2: t2),
                      const SizedBox(width: 8),
                      _StatChip(icon: LucideIcons.star, value: '$pts', label: 'pts', color: const Color(0xFFF59E0B), t3: t3, t2: t2),
                    ]),
                  ),
                  const SizedBox(height: 18),

                  // Segment tabs
                  Row(children: [
                    _TabBtn(label: 'Technique', active: _tab == 0, cs: cs, t2: t2, onTap: () => setState(() => _tab = 0)),
                    const SizedBox(width: 8),
                    _TabBtn(label: 'Muscles', active: _tab == 1, cs: cs, t2: t2, onTap: () => setState(() => _tab = 1)),
                    const SizedBox(width: 8),
                    _TabBtn(label: 'Conseils', active: _tab == 2, cs: cs, t2: t2, onTap: () => setState(() => _tab = 2)),
                  ]),
                  const SizedBox(height: 2),

                  // Tab underline
                  Container(height: 1, color: t3),
                ]),
              ),

              // ── Tab content ──────────────────────────────────────────────
              Container(
                color: cardBg,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _tab == 0
                      ? _TechniqueTab(key: const ValueKey(0), l10n: l10n, t1: t1, t2: t2, cs: cs, video: widget.video)
                      : _tab == 1
                          ? _MusclesTab(key: const ValueKey(1), t1: t1, t2: t2, t3: t3, cs: cs, video: widget.video)
                          : _ConseilsTab(key: const ValueKey(2), l10n: l10n, t1: t1, t2: t2, video: widget.video),
                ),
              ),

              const SizedBox(height: 100), // space for bottom bar
            ]),
          ),
        ),
      ]), // end Column

      // ── Floating +pts badge ──────────────────────────────────────────────
      if (_showPoints)
        Positioned(
          bottom: 100,
          left: 0, right: 0,
          child: _FloatingPoints(pts: _earnedPoints, cs: cs),
        ),
    ]), // end Stack

      // ── Fixed bottom bar ─────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: t3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.40 : 0.08),
              blurRadius: 20, offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(children: [
          // Prev button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t3),
              ),
              child: Icon(LucideIcons.skipBack, size: 18, color: t2),
            ),
          ),
          const SizedBox(width: 12),

          // Complete button — traite "déjà terminé avant l'ouverture" comme
          // "terminé" : bouton désactivé, pas de re-déclenchement possible
          // (évite à la fois un clic inutile et la course décrite ci-dessus).
          Builder(builder: (_) {
            final effectivelyDone = _isDone || _wasAlreadyCompleted;
            return Expanded(
              child: ScaleTransition(
                scale: _isDone ? _doneScale : const AlwaysStoppedAnimation(1.0),
                child: GestureDetector(
                  onTap: effectivelyDone ? null : _complete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 52,
                    decoration: BoxDecoration(
                      color: effectivelyDone
                          ? Colors.green.shade600
                          : _videoUnavailable
                              ? t2
                              : cs.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.35),
                          blurRadius: 16, offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(
                        effectivelyDone
                            ? LucideIcons.checkCircle
                            : _videoUnavailable
                                ? LucideIcons.alertTriangle
                                : LucideIcons.check,
                        color: Colors.white, size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        effectivelyDone
                            ? l10n.exDoneLabel
                            : _videoUnavailable
                                ? 'Indisponible'
                                : l10n.exCompleteBtn,
                        style: GoogleFonts.outfit(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ]),
                  ),
                ),
              ),
            );
          }),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB CONTENTS
// ══════════════════════════════════════════════════════════════════════════════

class _TechniqueTab extends StatelessWidget {
  final AppL10n l10n;
  final Color t1, t2;
  final ColorScheme cs;
  final VideoModel? video;
  const _TechniqueTab({super.key, required this.l10n, required this.t1, required this.t2, required this.cs, this.video});

  @override
  Widget build(BuildContext context) {
    // videos.technique_steps / .technique_description en base — repli sur
    // le contenu générique tant que la vidéo n'a pas été enrichie.
    final steps = video != null && video!.techniqueSteps.isNotEmpty
        ? video!.techniqueSteps
        : [l10n.exTip1, l10n.exTip2, l10n.exTip3];
    final description = video != null && video!.techniqueDescription.isNotEmpty
        ? video!.techniqueDescription
        : l10n.exTechniqueDesc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(description,
          style: GoogleFonts.inter(fontSize: 14, color: t2, height: 1.7)),
        const SizedBox(height: 20),
        Text('Étapes clés',
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: t1)),
        const SizedBox(height: 12),
        ...List.generate(steps.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('${i + 1}',
                  style: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w800, color: cs.primary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(steps[i],
                  style: GoogleFonts.inter(fontSize: 13.5, color: t2, height: 1.6)),
              ),
            ),
          ]),
        )),
      ],
    );
  }
}

class _MusclesTab extends StatelessWidget {
  final Color t1, t2, t3;
  final ColorScheme cs;
  final VideoModel? video;
  const _MusclesTab({super.key, required this.t1, required this.t2, required this.t3, required this.cs, this.video});

  @override
  Widget build(BuildContext context) {
    // videos.muscles_primary / .muscles_secondary en base — repli sur le
    // contenu générique tant que la vidéo n'a pas été enrichie.
    final dbPrimary = video?.musclesPrimary ?? const [];
    final primary = dbPrimary.isNotEmpty
        ? [for (final m in dbPrimary) (icon: _muscleIcon(m.name), name: m.name, level: m.level)]
        : [
            (icon: LucideIcons.zap, name: 'Quadriceps', level: 1.0),
            (icon: LucideIcons.activity, name: 'Fessiers', level: 0.85),
            (icon: LucideIcons.zap, name: 'Ischio-jambiers', level: 0.60),
          ];
    final dbSecondary = video?.musclesSecondary ?? const [];
    final secondary = dbSecondary.isNotEmpty
        ? dbSecondary
        : const ['Mollets', 'Abdominaux', 'Lombaires'];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Muscles principaux',
        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: t1)),
      const SizedBox(height: 14),
      ...primary.map((m) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(m.icon, size: 13, color: cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text(m.name,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: t1))),
            Text('${(m.level * 100).toInt()}%',
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: m.level,
              minHeight: 5,
              backgroundColor: t3,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          ),
        ]),
      )),
      const SizedBox(height: 8),
      Text('Muscles secondaires',
        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: t1)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8,
        children: secondary.map((m) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: t3,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(m,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: t2)),
        )).toList(),
      ),
    ]);
  }
}

class _ConseilsTab extends StatelessWidget {
  final AppL10n l10n;
  final Color t1, t2;
  final VideoModel? video;
  const _ConseilsTab({super.key, required this.l10n, required this.t1, required this.t2, this.video});

  @override
  Widget build(BuildContext context) {
    // videos.tips en base — repli sur le contenu générique tant que la
    // vidéo n'a pas été enrichie.
    final dbTips = video?.tips ?? const [];
    final conseils = dbTips.isNotEmpty
        ? [for (final t in dbTips) (icon: _tipIcon(t.title), title: t.title, tip: t.tip)]
        : [
            (icon: LucideIcons.eye, title: 'Regard', tip: l10n.exTip1),
            (icon: LucideIcons.wind, title: 'Respiration', tip: l10n.exTip2),
            (icon: LucideIcons.moveVertical, title: 'Amplitude', tip: l10n.exTip3),
          ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: conseils.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(c.icon, size: 17, color: const Color(0xFFF59E0B)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.title,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: t1)),
            const SizedBox(height: 3),
            Text(c.tip,
              style: GoogleFonts.inter(fontSize: 13, color: t2, height: 1.55)),
          ])),
        ]),
      )).toList(),
    );
  }
}

// ── Vidéo indisponible (url vide en base ou échec de chargement) ────────────
class _VideoUnavailable extends StatelessWidget {
  final String? debugDetail;
  const _VideoUnavailable({this.debugDetail});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black,
    child: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.videoOff,
            color: Colors.white.withValues(alpha: 0.55), size: 32),
        const SizedBox(height: 10),
        Text('Vidéo non disponible',
            style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.70),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        // Détail visible uniquement en debug — jamais en production.
        if (kDebugMode && debugDetail != null) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(debugDetail!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: Colors.orangeAccent.withValues(alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color, t3, t2;
  const _StatChip({required this.icon, required this.value, required this.label,
    required this.color, required this.t3, required this.t2});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.18)),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(height: 5),
      Text(value, style: GoogleFonts.outfit(
        fontSize: 17, fontWeight: FontWeight.w900, color: color, height: 1)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w500, color: t2)),
    ]),
  );
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final ColorScheme cs;
  final Color t2;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active,
    required this.cs, required this.t2, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Text(label, style: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: active ? FontWeight.w800 : FontWeight.w500,
        color: active ? cs.primary : t2,
      )),
      const SizedBox(height: 10),
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 2,
        width: active ? label.length * 8.5 : 0,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ]),
  );
}

// ── Floating points badge ─────────────────────────────────────────────────────
class _FloatingPoints extends StatefulWidget {
  final int pts;
  final ColorScheme cs;
  const _FloatingPoints({required this.pts, required this.cs});

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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.cs.primary,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: widget.cs.primary.withValues(alpha: 0.45),
                blurRadius: 20, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.star, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              '+${widget.pts} pts',
              style: GoogleFonts.outfit(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.3),
            ),
          ]),
        ),
      ),
    ),
  );
}
