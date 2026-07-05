import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/screens/workout/programme_detail_screen.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/theme/cycle_theme.dart';
import 'package:fiteva/providers/workout_progress_provider.dart';
import 'package:fiteva/services/workout_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/app_localizations.dart';

class SalleSection extends StatelessWidget {
  final List<HomeProgramModel> sallePrograms;
  final Set<String> favorites;
  final void Function(String) onToggleFav;
  final VoidCallback? onSeeAll;

  const SalleSection({
    super.key,
    required this.sallePrograms,
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
        _SalleHeader(onSeeAll: onSeeAll ?? () {}),
        const SizedBox(height: 16),
        SizedBox(
          height: 295,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: sallePrograms.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final program = sallePrograms[i];
              return _SalleProgramCard(
                program: program,
                isFav: favorites.contains('prog:${program.id}'),
                onToggleFav: () => onToggleFav('prog:${program.id}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutDetailScreen(
                      program: program,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SalleHeader extends ConsumerWidget {
  final VoidCallback onSeeAll;
  const _SalleHeader({required this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    const color = WorkoutColors.salle;

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
                child: Icon(LucideIcons.dumbbell, size: 20, color: Colors.white))),
          const SizedBox(width: 12),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Programmes Salle',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Machines · Barres · Haltères',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
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

// ── Program card ──────────────────────────────────────────────────────────────
class _SalleProgramCard extends ConsumerWidget {
  final HomeProgramModel program;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onTap;

  const _SalleProgramCard({
    required this.program,
    required this.isFav,
    required this.onToggleFav,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    const color = WorkoutColors.salle;

    return GestureDetector(
      onTap: onTap,
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
              // Background image
              Image.asset(
                program.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: color.withValues(alpha: 0.15)),
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

              // Top: PROGRAMME badge + completion status + heart
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  children: [
                    Expanded(
                      child: _ProgramStatusBadge(program: program),
                    ),
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

              // Bottom: name + pills + button
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      program.name,
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
                      '${program.duration} · ${program.sessions}',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CycleBadgeRow(phases: program.phases),
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

// ── Program status badge (completed, in-progress, or hidden) ────────────────────
class _ProgramStatusBadge extends ConsumerWidget {
  final HomeProgramModel program;

  const _ProgramStatusBadge({required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(programStatusProvider(program));

    return statusAsync.when(
      data: (status) {
        if (status.isCompleted) {
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
                const Icon(LucideIcons.checkCircle,
                    color: Colors.white, size: 10),
                const SizedBox(width: 4),
                Text(
                  'Complété',
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

        if (status.isStarted) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: WorkoutColors.salle.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: WorkoutColors.salle.withValues(alpha: 0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(status.completionPercentage * 100).toInt()}%',
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

        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

