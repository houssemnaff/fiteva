import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:fiteva/screens/workout/widgets/DanceSection.dart';
import 'package:fiteva/screens/workout/widgets/GrossesseSection.dart';
import 'package:fiteva/screens/workout/widgets/MaisonSection.dart';
import 'package:fiteva/screens/workout/widgets/RecuperationSection.dart';
import 'package:fiteva/screens/workout/widgets/SalleSection.dart';
import 'package:fiteva/screens/workout/widgets/ZonesSection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/video_model.dart';
import '../../models/workout_model.dart';
import '../../providers/mock_data_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/workout_progress_provider.dart';
import 'favorites_screen.dart';
import 'theme/color.dart';
import 'theme/cycle_theme.dart';
import 'programme_detail_screen.dart';
import 'active_workout_screen.dart';
import 'exercise_player_screen.dart';
import 'weekly_plan_screen.dart';

// ── Filtre étendu : les 4 phases du cycle + grossesse + post-partum ─────────
enum _FilterKind { menstruation, follicular, ovulation, luteal, pregnancy, postpartum }

extension _FilterKindX on _FilterKind {
  String get label {
    switch (this) {
      case _FilterKind.menstruation: return 'Règles';
      case _FilterKind.follicular:   return 'Follic.';
      case _FilterKind.ovulation:    return 'Ovul.';
      case _FilterKind.luteal:       return 'Lutéale';
      case _FilterKind.pregnancy:    return 'Grossesse';
      case _FilterKind.postpartum:   return 'Post-partum';
    }
  }

  Color get color {
    switch (this) {
      case _FilterKind.menstruation: return CyclePhase.menstruation.color;
      case _FilterKind.follicular:   return CyclePhase.follicular.color;
      case _FilterKind.ovulation:    return CyclePhase.ovulation.color;
      case _FilterKind.luteal:       return CyclePhase.luteal.color;
      case _FilterKind.pregnancy:    return const Color(0xFF9B3E6A);
      case _FilterKind.postpartum:   return const Color(0xFF1C7A6E);
    }
  }

  IconData get icon {
    switch (this) {
      case _FilterKind.menstruation: return LucideIcons.droplets;
      case _FilterKind.follicular:   return LucideIcons.sprout;
      case _FilterKind.ovulation:    return LucideIcons.sun;
      case _FilterKind.luteal:       return LucideIcons.moon;
      case _FilterKind.pregnancy:    return Icons.child_friendly_rounded;
      case _FilterKind.postpartum:  return Icons.favorite_rounded;
    }
  }

  /// null pour grossesse/post-partum — ces filtres agissent sur les
  /// sections affichées, pas sur le tag "phases" des programmes.
  CyclePhase? get cyclePhase {
    switch (this) {
      case _FilterKind.menstruation: return CyclePhase.menstruation;
      case _FilterKind.follicular:   return CyclePhase.follicular;
      case _FilterKind.ovulation:    return CyclePhase.ovulation;
      case _FilterKind.luteal:       return CyclePhase.luteal;
      case _FilterKind.pregnancy:
      case _FilterKind.postpartum:
        return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  int _selectedChip = 0;
  _FilterKind? _selectedPhase;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Recharge les favoris depuis Supabase (le build initial peut précéder l'auth)
    Future.microtask(() => ref.read(favoritesProvider.notifier).reload());
  }

  final _keySalle     = GlobalKey();
  final _keyMaison    = GlobalKey();
  final _keyDance     = GlobalKey();
  final _keyRecup     = GlobalKey();
  final _keyZones     = GlobalKey();
  final _keyGrossesse = GlobalKey();

  static const _chipIcons = [
    LucideIcons.layoutGrid,
    LucideIcons.dumbbell,
    LucideIcons.house,
    LucideIcons.music,
    LucideIcons.wind,
    LucideIcons.heart,
  ];

  static const _chipColors = [
    WorkoutColors.zone,
    WorkoutColors.salle,
    WorkoutColors.maison,
    WorkoutColors.dance,
    WorkoutColors.recuperation,
    WorkoutColors.grossesse,
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void _onChipTap(int index) {
    setState(() => _selectedChip = index);
    final keys = [null, _keySalle, _keyMaison, _keyDance, _keyRecup, _keyGrossesse];
    if (index == 0) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    } else if (index < keys.length && keys[index] != null) {
      Future.delayed(const Duration(milliseconds: 100),
          () => _scrollToKey(keys[index]!));
    }
  }

  void _showProgramsSheet({
    required String title,
    required Color color,
    required IconData icon,
    required List<HomeProgramModel> programs,
    required String category,
  }) {
    final favorites = ref.read(favoritesProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProgramsFilterSheet(
        title: title,
        color: color,
        icon: icon,
        programs: programs,
        favorites: favorites,
        onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
        onSelectProgram: (p) {
          Navigator.pop(ctx);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => WorkoutDetailScreen(program: p)));
        },
      ),
    );
  }

  void _showWorkoutsSheet({
    required String title,
    required Color color,
    required IconData icon,
    required List<WorkoutModel> workouts,
  }) {
    final favorites = ref.read(favoritesProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WorkoutsFilterSheet(
        title: title,
        color: color,
        icon: icon,
        workouts: workouts,
        favorites: favorites,
        onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
        onSelectWorkout: (w) {
          Navigator.pop(ctx);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(workout: w)));
        },
      ),
    );
  }

  void _showVideosSheet({
    required String title,
    required Color color,
    required IconData icon,
    required List<VideoModel> videos,
  }) {
    final favorites = ref.read(favoritesProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VideosFilterSheet(
        title: title,
        color: color,
        icon: icon,
        videos: videos,
        favorites: favorites,
        onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
        onSelectVideo: (v) {
          Navigator.pop(ctx);
          Navigator.push(context, MaterialPageRoute(builder: (_) => ExercisePlayerScreen(
            ref: ref,
            workoutTitle: title,
            exerciseName: v.title,
            videoId: v.id,
            videoUrl: v.url.isNotEmpty ? v.url : null,
            exerciseIndex: 0,
            totalExercises: 1,
            totalWorkoutPoints: v.points,
            onCompleted: () {},
            workoutId: null,
            allVideoIds: null,
            video: v,
          )));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final dark      = Theme.of(context).brightness == Brightness.dark;
    final l10n      = ref.watch(l10nProvider);
    final workouts  = ref.watch(workoutsProvider);
    final cycle     = ref.watch(cycleProvider);
    final bodyZones = ref.watch(bodyZonesProvider).asData?.value ?? const [];
    final sallePrograms       = ref.watch(salleProgramsProvider);
    final homePrograms        = ref.watch(homeProgramsProvider);
    final dancePrograms       = ref.watch(danceProgramsProvider);
    final recuperationPrograms = ref.watch(recuperationProgramsProvider);
    final grossessePrograms   = ref.watch(grossesseProgramsProvider);
    final danceVideos         = ref.watch(danceVideosProvider);
    final recuperationVideos  = ref.watch(recuperationVideosProvider);
    final favorites = ref.watch(favoritesProvider);
    final profile   = ref.watch(userProfileProvider);

    final screenH  = MediaQuery.of(context).size.height;
    final bottomGap = screenH < 700 ? 80.0 : 110.0;

    // Grossesse/post-partum ne filtrent pas par tag "phases" (pas de sens
    // pour ces programmes) — ils contrôlent plutôt quelles sections
    // s'affichent (voir showCycleSections/showGrossesse/showRecuperation).
    bool matchesPhase(String phases) {
      final cp = _selectedPhase?.cyclePhase;
      if (cp == null) return true;
      return parseCyclePhases(phases).contains(cp);
    }

    List<HomeProgramModel> fp(List<HomeProgramModel> list) =>
        list.where((p) => matchesPhase(p.phases)).toList();
    List<VideoModel> fpv(List<VideoModel> list) =>
        list.where((v) => matchesPhase(v.phases)).toList();

    final filteredSalle       = fp(sallePrograms);
    final filteredMaison      = fp(homePrograms);
    final filteredGrossesse   = fp(grossessePrograms);
    final filteredDanceVideos = fpv(danceVideos);
    final filteredRecuperationVideos = fpv(recuperationVideos);

    final showCycleSections = _selectedPhase == null || _selectedPhase!.cyclePhase != null;
    final showGrossesse     = _selectedPhase == null || _selectedPhase == _FilterKind.pregnancy;
    final showRecuperationSection = _selectedPhase == null || _selectedPhase == _FilterKind.postpartum;

    // ── Recommandations selon l'état réel (grossesse / post-partum / phase
    // du cycle) — indépendant du filtre manuel _selectedPhase ci-dessus.
    CyclePhase? currentPhase;
    switch (cycle.name) {
      case 'Règles':       currentPhase = CyclePhase.menstruation; break;
      case 'Folliculaire': currentPhase = CyclePhase.follicular;   break;
      case 'Ovulation':    currentPhase = CyclePhase.ovulation;    break;
      case 'Lutéale':      currentPhase = CyclePhase.luteal;       break;
    }
    final List<HomeProgramModel> recommendedPrograms;
    if (profile.healthStatus == 'pregnant') {
      recommendedPrograms = grossessePrograms;
    } else if (profile.healthStatus == 'postpartum') {
      recommendedPrograms = recuperationPrograms;
    } else {
      final all = [...sallePrograms, ...homePrograms, ...dancePrograms];
      recommendedPrograms = currentPhase == null
          ? all
          : all.where((p) => parseCyclePhases(p.phases).contains(currentPhase)).toList();
    }

    final chips = [
      l10n.workoutChipAll,
      l10n.workoutChipSalle,
      l10n.workoutChipMaison,
      l10n.workoutChipDance,
      l10n.workoutChipRecup,
      l10n.workoutChipGrossesse,
    ];

    final bg = cs.surface;

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ────────────────────────────────────────────────────
            SharedAppHeader(
              eyebrow: 'Workout',
              title: l10n.workoutMyTrainings,
              accentColor: WorkoutColors.salle,
              actions: [
                Stack(clipBehavior: Clip.none, children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: WorkoutColors.grossesse.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.favorite_rounded,
                          size: 18, color: WorkoutColors.grossesse),
                    ),
                  ),
                  if (favorites.isNotEmpty)
                    Positioned(
                      top: -2, right: -2,
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: WorkoutColors.salle,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${favorites.length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const WeeklyPlanScreen())),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: WorkoutColors.salle.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.calendarDays,
                        size: 17, color: WorkoutColors.salle),
                  ),
                ),
              ],
            ),

            // ── Phase Hero Card ───────────────────────────────────────────
            _PhaseBanner(
              cycle: cycle,
              healthStatus: profile.healthStatus,
              dark: dark,
              cs: cs,
              onSeeRecommended: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _RecommendedSheet(
                  programs: recommendedPrograms,
                  favorites: favorites,
                  onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
                  onSelectProgram: (p) {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => WorkoutDetailScreen(program: p)));
                  },
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ── Category chips ────────────────────────────────────────────
            _CategoryChips(
              chips: chips,
              icons: _chipIcons,
              colors: _chipColors,
              selected: _selectedChip,
              onTap: _onChipTap,
            ),

            const SizedBox(height: 18),

            // ── Phase filter ──────────────────────────────────────────────
            _PhaseFilterRow(
              selected: _selectedPhase,
              onSelect: (p) =>
                  setState(() => _selectedPhase = _selectedPhase == p ? null : p),
              l10n: l10n,
            ),

            const SizedBox(height: 8),

            // ── Sections ──────────────────────────────────────────────────
            if (showCycleSections) ...[
              KeyedSubtree(
                key: _keySalle,
                child: SalleSection(
                  sallePrograms: filteredSalle,
                  favorites: favorites,
                  onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
                  onSeeAll: () => _showProgramsSheet(
                    title: l10n.workoutSalleTitle,
                    color: WorkoutColors.salle,
                    icon: LucideIcons.dumbbell,
                    programs: filteredSalle,
                    category: 'SALLE',
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            if (showCycleSections) ...[
              KeyedSubtree(
                key: _keyMaison,
                child: MaisonSection(
                  homePrograms: filteredMaison,
                  favorites: favorites,
                  onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
                  onSeeAll: () => _showProgramsSheet(
                    title: l10n.workoutMaisonTitle,
                    color: WorkoutColors.maison,
                    icon: LucideIcons.house,
                    programs: filteredMaison,
                    category: 'MAISON',
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            if (showCycleSections) ...[
              KeyedSubtree(
                key: _keyDance,
                child: DanceSection(
                  danceVideos: filteredDanceVideos,
                  favorites: favorites,
                  onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
                  onSeeAll: () => _showVideosSheet(
                    title: l10n.workoutDanceTitle,
                    color: WorkoutColors.dance,
                    icon: LucideIcons.music,
                    videos: filteredDanceVideos,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            if (showRecuperationSection) ...[
              KeyedSubtree(
                key: _keyRecup,
                child: RecuperationSection(
                  recuperationVideos: filteredRecuperationVideos,
                  favorites: favorites,
                  onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
                  onSeeAll: () => _showVideosSheet(
                    title: l10n.workoutRecupTitle,
                    color: WorkoutColors.recuperation,
                    icon: LucideIcons.wind,
                    videos: filteredRecuperationVideos,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            if (showGrossesse) ...[
              KeyedSubtree(
                key: _keyGrossesse,
                child: GrossesseSection(
                  grossessePrograms: filteredGrossesse,
                  favorites: favorites,
                  onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
                  onSeeAll: () => _showProgramsSheet(
                    title: l10n.workoutGrossesseTitle,
                    color: WorkoutColors.grossesse,
                    icon: LucideIcons.heart,
                    programs: filteredGrossesse,
                    category: 'GROSSESSE',
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            KeyedSubtree(
              key: _keyZones,
              child: ZonesSection(bodyZones: bodyZones),
            ),

            SizedBox(height: bottomGap),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PHASE BANNER
// ══════════════════════════════════════════════════════════════════════════════
class _PhaseBanner extends StatelessWidget {
  final CycleStatus cycle;
  final String? healthStatus;
  final bool dark;
  final ColorScheme cs;
  final VoidCallback onSeeRecommended;
  const _PhaseBanner({
    required this.cycle, required this.healthStatus,
    required this.dark, required this.cs, required this.onSeeRecommended,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;
    Color accent;
    if (healthStatus == 'pregnant') {
      label = 'GROSSESSE'; icon = Icons.child_friendly_rounded; accent = const Color(0xFF9B3E6A);
    } else if (healthStatus == 'postpartum') {
      label = 'POST-PARTUM'; icon = Icons.favorite_rounded; accent = const Color(0xFF1C7A6E);
    } else {
      label = cycle.name.toUpperCase(); icon = LucideIcons.leaf; accent = cs.primary;
    }
    final surface = cs.surfaceContainerHigh;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(icon, size: 13, color: accent),
                      const SizedBox(width: 6),
                      Text(label,
                          style: GoogleFonts.inter(
                              color: accent,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)),
                    ]),
                    const SizedBox(height: 6),
                    Text(cycle.advice,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            color: cs.onSurface,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.35)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: onSeeRecommended,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('Voir mes séances recommandées',
                              style: GoogleFonts.inter(
                                  color: accent,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          Icon(LucideIcons.arrowRight, size: 12, color: accent),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RECOMMENDED SHEET — séances recommandées selon la phase / grossesse / post-partum
// ══════════════════════════════════════════════════════════════════════════════
class _RecommendedSheet extends StatelessWidget {
  final List<HomeProgramModel> programs;
  final Set<String> favorites;
  final void Function(String) onToggleFav;
  final void Function(HomeProgramModel) onSelectProgram;
  const _RecommendedSheet({
    required this.programs, required this.favorites,
    required this.onToggleFav, required this.onSelectProgram,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, ctrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          _SheetHandle(
              title: 'Recommandées pour toi',
              color: cs.primary,
              icon: LucideIcons.sparkles,
              onClose: () => Navigator.pop(context)),
          Expanded(
            child: programs.isEmpty
                ? const _EmptySearch(label: 'Aucune séance recommandée pour le moment')
                : ListView.separated(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: programs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final p = programs[i];
                      return _RecommendedCard(
                        program: p,
                        isFav: favorites.contains('prog:${p.id}'),
                        onToggleFav: () => onToggleFav('prog:${p.id}'),
                        onTap: () => onSelectProgram(p),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

// Carte photo pleine largeur (au lieu d'une rangée avec petite vignette) —
// plus proche visuellement des cartes de programme déjà utilisées ailleurs
// dans l'app, pour donner plus de présence aux recommandations.
class _RecommendedCard extends StatelessWidget {
  final HomeProgramModel program;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onTap;
  const _RecommendedCard({
    required this.program, required this.isFav,
    required this.onToggleFav, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14, offset: const Offset(0, 5))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(
            program.imageUrl, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: cs.primary.withValues(alpha: 0.15),
              child: Icon(LucideIcons.dumbbell, size: 32, color: cs.primary)),
          ),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [Color(0x00000000), Color(0x33000000), Color(0xCC000000)]))),

          Positioned(top: 10, right: 10, child: GestureDetector(
            onTap: onToggleFav,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: isFav ? Colors.white.withValues(alpha: 0.95) : Colors.black.withValues(alpha: 0.30),
                shape: BoxShape.circle),
              child: Icon(LucideIcons.heart, size: 14,
                color: isFav ? const Color(0xFFE53935) : Colors.white),
            ),
          )),

          Positioned(left: 14, right: 14, bottom: 12, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
            children: [
              Text(program.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 3),
              Text(program.duration,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
              if (program.phases.isNotEmpty) ...[
                const SizedBox(height: 6),
                CycleBadgeRow(phases: program.phases),
              ],
            ],
          )),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CATEGORY CHIPS
// ══════════════════════════════════════════════════════════════════════════════
class _CategoryChips extends StatelessWidget {
  final List<String> chips;
  final List<IconData> icons;
  final List<Color> colors;
  final int selected;
  final void Function(int) onTap;

  const _CategoryChips({
    required this.chips,
    required this.icons,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Segmented control minimal — un seul bloc neutre, le libellé actif
    // se distingue juste par un fond plein, sans bordures ni ombres.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final sel   = selected == i;
            final color = colors[i];

            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: sel ? color : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icons[i], size: 13, color: sel ? Colors.white : cs.onSurfaceVariant),
                  const SizedBox(width: 7),
                  Text(chips[i],
                      style: GoogleFonts.inter(
                          color: sel ? Colors.white : cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5)),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PHASE FILTER ROW
// ══════════════════════════════════════════════════════════════════════════════
class _PhaseFilterRow extends StatelessWidget {
  final _FilterKind? selected;
  final void Function(_FilterKind) onSelect;
  final AppL10n l10n;
  const _PhaseFilterRow(
      {required this.selected, required this.onSelect, required this.l10n});

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhaseFilterSheet(
        selected: selected,
        onSelect: (phase) {
          Navigator.pop(context);
          onSelect(phase);
        },
        l10n: l10n,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Bouton icône circulaire à droite (avec pastille si un filtre est actif)
    // au lieu du bandeau de chips précédent — ouvre une grille de phases +
    // grossesse/post-partum.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Expanded(
          child: Text('Filtrer',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withValues(alpha: 0.45),
                  letterSpacing: 0.3)),
        ),
        GestureDetector(
          onTap: () => _openSheet(context),
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: selected != null
                    ? selected!.color.withValues(alpha: 0.12)
                    : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: selected != null
                    ? Border.all(color: selected!.color.withValues(alpha: 0.35))
                    : null,
              ),
              child: Icon(
                selected?.icon ?? LucideIcons.slidersHorizontal,
                size: 16, color: selected?.color ?? cs.onSurfaceVariant),
            ),
            if (selected != null)
              Positioned(top: -2, right: -2, child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: selected!.color, shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 1.5)),
              )),
          ]),
        ),
      ]),
    );
  }
}

// ── Bottom sheet — grille de phases (icône + label) ─────────────────────────
class _PhaseFilterSheet extends StatelessWidget {
  final _FilterKind? selected;
  final void Function(_FilterKind) onSelect;
  final AppL10n l10n;
  const _PhaseFilterSheet(
      {required this.selected, required this.onSelect, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4,
          decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: Text('Filtrer',
            style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: cs.onSurface))),
          if (selected != null)
            GestureDetector(
              onTap: () => onSelect(selected!),
              child: Text(l10n.workoutShowAll, style: GoogleFonts.inter(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: selected!.color)),
            ),
        ]),
        const SizedBox(height: 18),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: _FilterKind.values.map((phase) {
            final isSel = selected == phase;
            return GestureDetector(
              onTap: () => onSelect(phase),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSel ? phase.color : phase.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: phase.color.withValues(alpha: isSel ? 0 : 0.25)),
                  boxShadow: isSel ? [BoxShadow(
                    color: phase.color.withValues(alpha: 0.35),
                    blurRadius: 12, offset: const Offset(0, 4))] : [],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(phase.icon, size: 20,
                    color: isSel ? Colors.white : phase.color),
                  const Spacer(),
                  Text(phase.label, style: GoogleFonts.outfit(
                    fontSize: 13.5, fontWeight: FontWeight.w800,
                    color: isSel ? Colors.white : cs.onSurface)),
                ]),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEETS (unchanged logic, same design)
// ══════════════════════════════════════════════════════════════════════════════
class _ProgramsFilterSheet extends ConsumerStatefulWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<HomeProgramModel> programs;
  final Set<String> favorites;
  final void Function(String) onToggleFav;
  final void Function(HomeProgramModel) onSelectProgram;

  const _ProgramsFilterSheet({
    required this.title,
    required this.color,
    required this.icon,
    required this.programs,
    required this.favorites,
    required this.onToggleFav,
    required this.onSelectProgram,
  });

  @override
  ConsumerState<_ProgramsFilterSheet> createState() =>
      _ProgramsFilterSheetState();
}

class _ProgramsFilterSheetState
    extends ConsumerState<_ProgramsFilterSheet> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<HomeProgramModel> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return widget.programs;
    return widget.programs.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, ctrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          _SheetHandle(
              title: widget.title,
              color: widget.color,
              icon: widget.icon,
              onClose: () => Navigator.pop(context)),
          _SearchBar(
              ctrl: _searchCtrl,
              color: widget.color,
              hint: l10n.workoutSearchHint,
              onChanged: () => setState(() {})),
          Expanded(
            child: _filtered.isEmpty
                ? _EmptySearch(label: l10n.workoutNoProgramFound)
                : ListView.builder(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final p = _filtered[i];
                      return _ProgramTile(
                        imageUrl: p.imageUrl,
                        title: p.name,
                        subtitle: p.duration,
                        phases: p.phases,
                        color: widget.color,
                        isFav: widget.favorites.contains('prog:${p.id}'),
                        onToggleFav: () => widget.onToggleFav('prog:${p.id}'),
                        onTap: () => widget.onSelectProgram(p),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

class _WorkoutsFilterSheet extends ConsumerStatefulWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<WorkoutModel> workouts;
  final Set<String> favorites;
  final void Function(String) onToggleFav;
  final void Function(WorkoutModel) onSelectWorkout;

  const _WorkoutsFilterSheet({
    required this.title,
    required this.color,
    required this.icon,
    required this.workouts,
    required this.favorites,
    required this.onToggleFav,
    required this.onSelectWorkout,
  });

  @override
  ConsumerState<_WorkoutsFilterSheet> createState() =>
      _WorkoutsFilterSheetState();
}

class _WorkoutsFilterSheetState
    extends ConsumerState<_WorkoutsFilterSheet> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<WorkoutModel> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return widget.workouts;
    return widget.workouts.where((w) => w.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, ctrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          _SheetHandle(
              title: widget.title,
              color: widget.color,
              icon: widget.icon,
              onClose: () => Navigator.pop(context)),
          _SearchBar(
              ctrl: _searchCtrl,
              color: widget.color,
              hint: l10n.workoutSearchHint,
              onChanged: () => setState(() {})),
          Expanded(
            child: _filtered.isEmpty
                ? _EmptySearch(label: l10n.workoutNoWorkoutFound)
                : ListView.builder(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final w = _filtered[i];
                      return _ProgramTile(
                        imageUrl: w.imageUrl,
                        title: w.title,
                        subtitle: '${w.duration} · ${w.level}',
                        phases: w.phases,
                        color: widget.color,
                        isFav: widget.favorites.contains(w.id),
                        onToggleFav: () => widget.onToggleFav(w.id),
                        onTap: () => widget.onSelectWorkout(w),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

class _VideosFilterSheet extends ConsumerStatefulWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<VideoModel> videos;
  final Set<String> favorites;
  final void Function(String) onToggleFav;
  final void Function(VideoModel) onSelectVideo;

  const _VideosFilterSheet({
    required this.title,
    required this.color,
    required this.icon,
    required this.videos,
    required this.favorites,
    required this.onToggleFav,
    required this.onSelectVideo,
  });

  @override
  ConsumerState<_VideosFilterSheet> createState() =>
      _VideosFilterSheetState();
}

class _VideosFilterSheetState extends ConsumerState<_VideosFilterSheet> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<VideoModel> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return widget.videos;
    return widget.videos.where((v) => v.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, ctrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          _SheetHandle(
              title: widget.title,
              color: widget.color,
              icon: widget.icon,
              onClose: () => Navigator.pop(context)),
          _SearchBar(
              ctrl: _searchCtrl,
              color: widget.color,
              hint: l10n.workoutSearchHint,
              onChanged: () => setState(() {})),
          Expanded(
            child: _filtered.isEmpty
                ? _EmptySearch(label: l10n.workoutNoWorkoutFound)
                : ListView.builder(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final v = _filtered[i];
                      return _ProgramTile(
                        imageUrl: v.thumbnailUrl,
                        title: v.title,
                        subtitle: '${v.duration} · ${v.points} pts',
                        phases: v.phases,
                        color: widget.color,
                        isFav: widget.favorites.contains('video:${v.id}'),
                        onToggleFav: () => widget.onToggleFav('video:${v.id}'),
                        onTap: () => widget.onSelectVideo(v),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

// ── Shared sheet sub-widgets ──────────────────────────────────────────────────
class _SheetHandle extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onClose;
  const _SheetHandle(
      {required this.title,
      required this.color,
      required this.icon,
      required this.onClose});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2))),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: cs.onSurface,
                      letterSpacing: -0.3))),
          GestureDetector(
              onTap: onClose,
              child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.08),
                      shape: BoxShape.circle),
                  child: Icon(LucideIcons.x,
                      size: 17,
                      color: cs.onSurface.withValues(alpha: 0.55)))),
        ]),
      ),
      Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.10)),
    ]);
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final Color color;
  final String hint;
  final VoidCallback onChanged;
  const _SearchBar(
      {required this.ctrl,
      required this.color,
      required this.hint,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: cs.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: TextField(
          controller: ctrl,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                color: cs.onSurface.withValues(alpha: 0.45), fontSize: 14),
            prefixIcon: Icon(LucideIcons.search, color: color, size: 18),
            suffixIcon: ctrl.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      ctrl.clear();
                      onChanged();
                    },
                    child: Icon(LucideIcons.x,
                        color: cs.onSurface.withValues(alpha: 0.45), size: 18))
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
          style: GoogleFonts.inter(color: cs.onSurface, fontSize: 14),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String label;
  const _EmptySearch({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.search, size: 48, color: cs.onSurface.withValues(alpha: 0.25)),
        const SizedBox(height: 12),
        Text(label,
            style: GoogleFonts.inter(
                color: cs.onSurface.withValues(alpha: 0.45), fontSize: 14)),
      ]),
    );
  }
}

class _ProgramTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String phases;
  final Color color;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onTap;

  const _ProgramTile({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.phases,
    required this.color,
    required this.isFav,
    required this.onToggleFav,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
                color: cs.shadow.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(18)),
            child: Image.asset(imageUrl,
                width: 82,
                height: 82,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: 82,
                    height: 82,
                    color: color.withValues(alpha: 0.12))),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: cs.onSurface,
                          letterSpacing: -0.2)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.50))),
                  if (phases.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(phases,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ),
                  ],
                ]),
          )),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(LucideIcons.chevronRight,
                size: 16, color: color.withValues(alpha: 0.70)),
          ),
        ]),
      ),
    );
  }
}
