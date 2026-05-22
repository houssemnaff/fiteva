import 'package:fiteva/screens/home/cerclecaloriespourhome.dart';
import 'package:fiteva/theme/app_theme.dart';
import 'package:fiteva/widgets/home_header.dart';
import 'package:fiteva/widgets/messtepcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../models/post_model.dart';
import '../../models/nutrition_model.dart';
import '../../models/workout_model.dart';
import '../../providers/mock_data_provider.dart';
import '../community/community_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../nutrition/widgets/home/home_widgets.dart';



class HomeScreen extends ConsumerWidget {
  final VoidCallback? onOpenNutritionTab;

  const HomeScreen({super.key, this.onOpenNutritionTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final joinedPrograms = ref.watch(joinedProgramsProvider);
    final nutrition = ref.watch(nutritionProvider);
    final posts = ref.watch(postsProvider);
    final cycle = ref.watch(cycleProvider);
    final latestPost = posts.isNotEmpty ? posts.first : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Section ──────────────────────────────────────
              _HeroWorkoutCard(user: user),

              // ── Weekly Progress Bar ───────────────────────────────
              _WeeklyProgressSection(user: user),

              // ── Steps Card ─────────────────────────────────────
             
               MesPasCard(),
              

              // ── Joined Programs ───────────────────────────────────
               // ── Cycle of the day ──────────────────────────────────
             // _CycleSection(cycle: cycle),
              _JoinedProgramsSection(
                programs: joinedPrograms,
                onResumeTap: () => _showProgramsSummary(context, joinedPrograms),
              ),

              // ── Daily Calories ────────────────────────────────────
            /*  Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: DailyTrackingCardhome(
                  anim: AlwaysStoppedAnimation(1.0),
                 
                
                  caloriesConsumed: nutrition.currentCalories,
                  caloriesGoal: nutrition.targetCalories,
                ),
              ),*/

            
             

              // ── Recommended Workouts ──────────────────────────────
              _RecommendedSection(workouts: ref.watch(workoutsProvider)),

              // ── Cycle Tip ─────────────────────────────────────────
             // const _CycleTipCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _openNutrition(BuildContext context) {
    if (onOpenNutritionTab != null) {
      onOpenNutritionTab!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NutritionHomeScreen()),
    );
  }

  void _openSocial(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CommunityScreen()),
    );
  }

  void _showProgramsSummary(BuildContext context, List<WorkoutModel> programs) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = colorScheme.surface;
    final textPrimary = colorScheme.onSurface;
    final textSecondary = theme.textTheme.bodyMedium?.color ?? colorScheme.onSurface.withOpacity(0.72);

    final totalMinutes = programs.fold<int>(
      0,
      (sum, program) => sum + _parseMinutes(program.duration),
    );
    final totalCalories = programs.fold<int>(
      0,
      (sum, program) => sum + (int.tryParse(program.calories) ?? 0),
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Résumé de tes programmes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              '${programs.length} programmes, $totalMinutes min, $totalCalories kcal estimées',
              style: TextStyle(color: textSecondary),
            ),
            const SizedBox(height: 16),
            ...programs.map(
              (program) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.dumbbell, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.title,
                            style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
                          ),
                          Text(
                            '${program.category} • ${program.duration}',
                            style: TextStyle(color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${program.calories} kcal',
                      style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _parseMinutes(String value) {
    final match = RegExp(r'\d+').firstMatch(value);
    return match == null ? 0 : int.parse(match.group(0)!);
  }
}

// ─────────────────────────────────────────────────────────────
// HERO CARD
// ─────────────────────────────────────────────────────────────
class _HeroWorkoutCard extends StatelessWidget {
  final dynamic user;
  const _HeroWorkoutCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Stack(
  children: [
    // ── IMAGE BACKGROUND ──
    SizedBox(
      height: 520,
      width: double.infinity,
      child: Image.asset(
        'assets/images/workout.jpeg',
        fit: BoxFit.cover,
      ),
    ),

    // ── DARK GRADIENT OVERLAY (Nike style) ──
    Container(
      height: 520,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.scrim.withOpacity(0.06),
            colorScheme.scrim.withOpacity(0.24),
            colorScheme.scrim.withOpacity(0.4),
          ],
        ),
      ),
    ),

    // ── TOP BAR ──
    Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: const HomeHeader(),
      ),
    ),

    // ── BOTTOM CONTENT ──
    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "TODAY'S WORKOUT",
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'FULL BODY\nSTRENGTH',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '45 MIN • INTERMEDIATE • COACH NIKKI',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.72),
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 18),

            // button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'START WORKOUT',
                  style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimary,
                  ),
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


// ─────────────────────────────────────────────────────────────
// WEEKLY PROGRESS
// ─────────────────────────────────────────────────────────────
class _WeeklyProgressSection extends StatelessWidget {
  final dynamic user;
  const _WeeklyProgressSection({required this.user});

  static const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const doneCount = 4;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                  const Text(
                'THIS WEEK',
                style: TextStyle(
                  // color resolved below for runtime
                  color: null,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '$doneCount/5 DONE',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(days.length, (i) {
              final done = i < doneCount;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200 + i * 60),
                        height: 4,
                        decoration: BoxDecoration(
                            color: done
                              ? colorScheme.secondary
                              : colorScheme.onSurface.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        days[i],
                        style: TextStyle(
                          color: done
                              ? colorScheme.onSurface.withOpacity(0.6)
                              : colorScheme.onSurface.withOpacity(0.28),
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(LucideIcons.flame, color: colorScheme.secondary, size: 14),
              const SizedBox(width: 8),
              Text(
                '${user.streak} DAY STREAK',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JoinedProgramsSection extends StatelessWidget {
  final List<WorkoutModel> programs;
  final VoidCallback onResumeTap;

  const _JoinedProgramsSection({
    required this.programs,
    required this.onResumeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(24, 8, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'MY PROGRAMS',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
               
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 242,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 24),
              itemCount: programs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _JoinedProgramTile(
                program: programs[index],
                progress: 0.35 + (index * 0.18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinedProgramTile extends StatelessWidget {
  final WorkoutModel program;
  final double progress;

  const _JoinedProgramTile({required this.program, required this.progress});

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.1, 0.95);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 84,
            width: double.infinity,
              child: Image.asset(
              program.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    program.category.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  program.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${program.duration} • ${program.level}',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                    value: clampedProgress,
                    minHeight: 6,
                    backgroundColor: colorScheme.surface,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                      style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(34),
                      padding: EdgeInsets.zero,
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'RESUME',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────
// RECOMMENDED WORKOUTS
// ─────────────────────────────────────────────────────────────
class _RecommendedSection extends StatelessWidget {
  final List<WorkoutModel> workouts;
  const _RecommendedSection({required this.workouts});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(24, 28, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'SEE ALL',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 24),
              itemCount: workouts.length > 5 ? 5 : workouts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _WorkoutTile(workout: workouts[index]),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  final WorkoutModel workout;
  const _WorkoutTile({required this.workout});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            child: Image.asset(
              workout.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
                errorBuilder: (_, __, ___) =>
                  Container(color: colorScheme.surface),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.category.toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workout.title.toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  workout.duration.toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CYCLE TIP
// ─────────────────────────────────────────────────────────────
class _CycleTipCard extends StatelessWidget {
  const _CycleTipCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                LucideIcons.info,
                color: colorScheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CYCLE TIP',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Boost iron intake during your menstrual phase — leafy greens and red meat help recovery.',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}