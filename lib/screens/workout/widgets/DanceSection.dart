import 'package:fiteva/models/video_model.dart';
import 'package:fiteva/screens/workout/exercise_player_screen.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/theme/cycle_theme.dart';
import 'package:fiteva/screens/workout/widgets/section_empty_state.dart';
import 'package:fiteva/providers/workout_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/app_localizations.dart';

class DanceSection extends StatelessWidget {
  final List<VideoModel> danceVideos;
  final Set<String> favorites;
  final void Function(String) onToggleFav;
  final VoidCallback? onSeeAll;

  const DanceSection({
    super.key,
    required this.danceVideos,
    required this.favorites,
    required this.onToggleFav,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _DanceHeader(onSeeAll: onSeeAll ?? () {}),
        const SizedBox(height: 16),
        SizedBox(
          height: 295,
          child: danceVideos.isEmpty
              ? Center(
                  child: SectionEmptyState(
                    icon: LucideIcons.music,
                    color: WorkoutColors.dance,
                    message: 'Aucune vidéo disponible pour le moment',
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: danceVideos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) {
                    final video = danceVideos[i];
                    return _DanceVideoCard(
                      video: video,
                      isFav: favorites.contains('video:${video.id}'),
                      onToggleFav: () => onToggleFav('video:${video.id}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _DanceHeader extends ConsumerWidget {
  final VoidCallback onSeeAll;
  const _DanceHeader({required this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    const color = WorkoutColors.dance;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Accent bar
          Container(
            width: 3,
            height: 42,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 12),

          // Icon box
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Center(
                child: Icon(LucideIcons.music, size: 20, color: Colors.white))),
          const SizedBox(width: 12),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Danse & Cardio',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rythme · Énergie · Amusement',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Voir tout pill
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: color.withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Text(
                l10n.sectionVoirTout,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Video card ────────────────────────────────────────────────────────────────
class _DanceVideoCard extends ConsumerWidget {
  final VideoModel video;
  final bool isFav;
  final VoidCallback onToggleFav;

  const _DanceVideoCard({
    required this.video,
    required this.isFav,
    required this.onToggleFav,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    const color = WorkoutColors.dance;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExercisePlayerScreen(
            ref: ref,
            workoutTitle: l10n.workoutDanceTitle,
            exerciseName: video.title,
            videoId: video.id,
            videoUrl: video.url.isNotEmpty ? video.url : null,
            exerciseIndex: 0,
            totalExercises: 1,
            totalWorkoutPoints: video.points,
            onCompleted: () {},
            workoutId: null,
            allVideoIds: null,
            video: video,
          ),
        ),
      ),
      child: Container(
        width: 235,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 8))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background thumbnail
              video.thumbnailUrl.isNotEmpty
                  ? Image.asset(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: color.withValues(alpha: 0.15)),
                    )
                  : Container(
                      color: color.withValues(alpha: 0.15),
                      child: Icon(LucideIcons.music,
                          size: 40, color: color.withValues(alpha: 0.5)),
                    ),

              // Gradient overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.10),
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // Top: watched badge + heart
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  children: [
                    Expanded(child: _WatchedBadge(videoId: video.id)),
                    GestureDetector(
                      onTap: onToggleFav,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isFav
                              ? Colors.white.withValues(alpha: 0.95)
                              : Colors.black.withValues(alpha: 0.30),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30)),
                        ),
                        child: Icon(
                          LucideIcons.heart,
                          size: 15,
                          color: isFav
                              ? const Color(0xFFE53935)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom: name + duration + button
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${video.duration} · ${video.points} pts',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (video.phases.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      CycleBadgeRow(phases: video.phases),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                              color: color.withValues(alpha: 0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.play,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 8),
                          Text(
                            l10n.progcardCommencer,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge "vu" (si vidéo déjà complétée à 80 %) ─────────────────────────────────
class _WatchedBadge extends ConsumerWidget {
  final String videoId;
  const _WatchedBadge({required this.videoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = ref.watch(completedVideosProvider).asData?.value.contains(videoId) ?? false;
    if (!done) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.green.withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.checkCircle, color: Colors.white, size: 10),
          const SizedBox(width: 4),
          Text(
            'Vu',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
