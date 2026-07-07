import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/models/video_model.dart';
import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/providers/mock_data_provider.dart';
import 'package:fiteva/providers/workout_progress_provider.dart';
import 'package:fiteva/screens/workout/corpszone_playerscreen.dart';
import 'package:fiteva/screens/workout/active_workout_screen.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/theme/cycle_theme.dart';
import 'package:fiteva/screens/workout/programme_detail_screen.dart';
import 'package:fiteva/screens/workout/exercise_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kGreen  = Color(0xFF1C4D30);
const _kDark   = Color(0xFF1A1A1A);
const _kGrey   = Color(0xFF6B7280);
const _kBorder = Color(0xFFECECE8);

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111111) : Colors.white;
    final sallePrograms  = ref.watch(salleProgramsProvider);
    final homePrograms   = ref.watch(homeProgramsProvider);
    final workouts       = ref.watch(workoutsProvider);
    final danceVideos        = ref.watch(danceVideosProvider);
    final recuperationVideos = ref.watch(recuperationVideosProvider);
    final favorites      = ref.watch(favoritesProvider);

    final favSalle  = sallePrograms.where((p) => favorites.contains('prog:${p.id}')).toList();
    final favMaison = homePrograms.where((p) => favorites.contains('prog:${p.id}')).toList();
    final favWorkouts = workouts.where((w) => favorites.contains(w.id)).toList();
    final favVideos = [...danceVideos, ...recuperationVideos]
        .where((v) => favorites.contains('video:${v.id}'))
        .toList();
    final totalCount = favSalle.length + favMaison.length + favWorkouts.length + favVideos.length;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.arrowLeft,
                    size: 18, color: _kGreen),
              ),
            ),
            title: Row(
              children: [
                Text(
                  'Mes Favoris',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : _kDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(width: 10),
                if (totalCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalCount',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Empty state ───────────────────────────────────────────────────
          if (totalCount == 0)
            SliverFillRemaining(
              child: _EmptyState(isDark: isDark),
            )
          else ...[
            // ── Salle programs ────────────────────────────────────────────
            if (favSalle.isNotEmpty) ...[
              _GroupHeader(
                  label: 'Programmes Salle',
                  icon: LucideIcons.dumbbell,
                  color: WorkoutColors.salle,
                  isDark: isDark),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                sliver: SliverList.separated(
                  itemCount: favSalle.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ProgramFavCard(
                    program: favSalle[i],
                    sectionColor: WorkoutColors.salle,
                    sectionLabel: 'SALLE',
                    isFav: true,
                    onToggleFav: () => ref.read(favoritesProvider.notifier).toggleFavorite('prog:${favSalle[i].id}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutDetailScreen(
                          program: favSalle[i],
                        ),
                      ),
                    ),
                    isDark: isDark,
                  ),
                ),
              ),
            ],

            // ── Maison programs ───────────────────────────────────────────
            if (favMaison.isNotEmpty) ...[
              _GroupHeader(
                  label: 'Programmes Maison',
                  icon: LucideIcons.house,
                  color: WorkoutColors.maison,
                  isDark: isDark),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                sliver: SliverList.separated(
                  itemCount: favMaison.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ProgramFavCard(
                    program: favMaison[i],
                    sectionColor: WorkoutColors.maison,
                    sectionLabel: 'MAISON',
                    isFav: true,
                    onToggleFav: () => ref.read(favoritesProvider.notifier).toggleFavorite('prog:${favMaison[i].id}'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutDetailScreen(
                          program: favMaison[i],
                        ),
                      ),
                    ),
                    isDark: isDark,
                  ),
                ),
              ),
            ],

            // ── Individual workouts ───────────────────────────────────────
            if (favWorkouts.isNotEmpty) ...[
              _GroupHeader(
                  label: 'Séances',
                  icon: LucideIcons.play,
                  color: WorkoutColors.zone,
                  isDark: isDark),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                sliver: SliverList.separated(
                  itemCount: favWorkouts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final w = favWorkouts[i];
                    return _WorkoutFavCard(
                      workout: w,
                      isFav: true,
                      onToggleFav: () => ref.read(favoritesProvider.notifier).toggleFavorite(w.id),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _isCorpsZone(w.category)
                              ? CorpsZonePlayerScreen(
                                  workout: w,
                                  zoneName: w.category)
                              : ActiveWorkoutScreen(workout: w),
                        ),
                      ),
                      isDark: isDark,
                    );
                  },
                ),
              ),
            ],

            // ── Vidéos Dance/Cardio/Récupération ──────────────────────────
            if (favVideos.isNotEmpty) ...[
              _GroupHeader(
                  label: 'Vidéos Dance & Récupération',
                  icon: LucideIcons.playCircle,
                  color: WorkoutColors.dance,
                  isDark: isDark),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList.separated(
                  itemCount: favVideos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final v = favVideos[i];
                    return _VideoFavCard(
                      video: v,
                      isFav: true,
                      onToggleFav: () => ref.read(favoritesProvider.notifier).toggleFavorite('video:${v.id}'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExercisePlayerScreen(
                            ref: ref,
                            workoutTitle: v.category == 'recuperation'
                                ? 'Récupération'
                                : 'Danse & Cardio',
                            exerciseName: v.title,
                            videoId: v.id,
                            videoUrl: v.url.isNotEmpty ? v.url : null,
                            exerciseIndex: 0,
                            totalExercises: 1,
                            totalWorkoutPoints: v.points,
                            onCompleted: () {},
                            workoutId: null,
                            allVideoIds: null,
                          ),
                        ),
                      ),
                      isDark: isDark,
                    );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  bool _isCorpsZone(String cat) {
    final c = cat.toUpperCase();
    return c == 'DANCE' || c == 'RECUPERATION' || c == 'GROSSESSE';
  }
}

// ── Group header sliver ───────────────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _GroupHeader(
      {required this.label,
      required this.icon,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : _kDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Program card (HomeProgramModel) ──────────────────────────────────────────
class _ProgramFavCard extends StatelessWidget {
  final HomeProgramModel program;
  final Color sectionColor;
  final String sectionLabel;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onTap;
  final bool isDark;

  const _ProgramFavCard({
    required this.program,
    required this.sectionColor,
    required this.sectionLabel,
    required this.isFav,
    required this.onToggleFav,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.asset(
                  program.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: sectionColor.withValues(alpha: 0.15)),
                ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: sectionColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sectionLabel,
                        style: GoogleFonts.inter(
                          color: sectionColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Name
                    Text(
                      program.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : _kDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Meta
                    Row(children: [
                      Icon(LucideIcons.calendarDays,
                          size: 10, color: _kGrey),
                      const SizedBox(width: 4),
                      Text(program.duration,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _kGrey,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 10),
                      Icon(LucideIcons.dumbbell,
                          size: 10, color: _kGrey),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(program.sessions,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: _kGrey,
                                fontWeight: FontWeight.w500)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    CycleBadgeRow(phases: program.phases),
                  ],
                ),
              ),
            ),

            // Heart + arrow
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onToggleFav,
                    child: Icon(
                      LucideIcons.heart,
                      size: 18,
                      color: isFav
                          ? const Color(0xFFE53935)
                          : _kGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Icon(LucideIcons.chevronRight,
                      size: 16, color: _kGrey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Workout card (WorkoutModel) ───────────────────────────────────────────────
class _WorkoutFavCard extends StatelessWidget {
  final WorkoutModel workout;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onTap;
  final bool isDark;

  const _WorkoutFavCard({
    required this.workout,
    required this.isFav,
    required this.onToggleFav,
    required this.onTap,
    required this.isDark,
  });

  Color get _catColor {
    switch (workout.category.toUpperCase()) {
      case 'DANCE': return WorkoutColors.dance;
      case 'RECUPERATION': return WorkoutColors.recuperation;
      case 'GROSSESSE': return WorkoutColors.grossesse;
      case 'SALLE': return WorkoutColors.salle;
      case 'MAISON': return WorkoutColors.maison;
      default: return WorkoutColors.zone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _catColor;
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.asset(
                  workout.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: color.withValues(alpha: 0.15)),
                ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        workout.category.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      workout.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : _kDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(LucideIcons.clock, size: 10, color: _kGrey),
                      const SizedBox(width: 4),
                      Text(workout.duration,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _kGrey,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 10),
                      Icon(LucideIcons.flame, size: 10, color: _kGrey),
                      const SizedBox(width: 4),
                      Text('${workout.calories} kcal',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _kGrey,
                              fontWeight: FontWeight.w500)),
                    ]),
                    const SizedBox(height: 6),
                    CycleBadgeRow(phases: workout.phases),
                  ],
                ),
              ),
            ),

            // Heart + arrow
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onToggleFav,
                    child: Icon(
                      LucideIcons.heart,
                      size: 18,
                      color: isFav
                          ? const Color(0xFFE53935)
                          : _kGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Icon(LucideIcons.chevronRight,
                      size: 16, color: _kGrey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Video card (VideoModel — vidéo autonome Dance/Cardio/Récupération) ───────
class _VideoFavCard extends StatelessWidget {
  final VideoModel video;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onTap;
  final bool isDark;

  const _VideoFavCard({
    required this.video,
    required this.isFav,
    required this.onToggleFav,
    required this.onTap,
    required this.isDark,
  });

  Color get _catColor {
    switch (video.category) {
      case 'recuperation': return WorkoutColors.recuperation;
      case 'dance':
      case 'cardio':
      default: return WorkoutColors.dance;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _catColor;
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: video.thumbnailUrl.isNotEmpty
                    ? Image.asset(
                        video.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: color.withValues(alpha: 0.15)),
                      )
                    : Container(color: color.withValues(alpha: 0.15)),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        video.category.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : _kDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(LucideIcons.clock, size: 10, color: _kGrey),
                      const SizedBox(width: 4),
                      Text(video.duration,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _kGrey,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(width: 10),
                      Icon(LucideIcons.star, size: 10, color: _kGrey),
                      const SizedBox(width: 4),
                      Text('${video.points} pts',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _kGrey,
                              fontWeight: FontWeight.w500)),
                    ]),
                    if (video.phases.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      CycleBadgeRow(phases: video.phases),
                    ],
                  ],
                ),
              ),
            ),

            // Heart + arrow
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onToggleFav,
                    child: Icon(
                      LucideIcons.heart,
                      size: 18,
                      color: isFav
                          ? const Color(0xFFE53935)
                          : _kGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Icon(LucideIcons.chevronRight,
                      size: 16, color: _kGrey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.heart,
                  size: 32, color: _kGreen),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun favori pour l\'instant',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : _kDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuie sur ♡ sur un programme\npour le retrouver ici.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: _kGrey,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
}
