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



class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
              _CycleSection(cycle: cycle),
              _JoinedProgramsSection(
                programs: joinedPrograms,
                onResumeTap: () => _showProgramsSummary(context, joinedPrograms),
              ),

              // ── Daily Calories ────────────────────────────────────
              _CaloriesSection(
                nutrition: nutrition,
                onOpenNutrition: () => _openNutrition(context),
              ),

            
             

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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NutritionScreen()),
    );
  }

  void _openSocial(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CommunityScreen()),
    );
  }

  void _showProgramsSummary(BuildContext context, List<WorkoutModel> programs) {
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
        decoration: const BoxDecoration(
          color: Colors.white,
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
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Résumé de tes programmes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '${programs.length} programmes, $totalMinutes min, $totalCalories kcal estimées',
              style: TextStyle(color: Colors.black.withOpacity(0.55)),
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
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${program.category} • ${program.duration}',
                            style: TextStyle(color: Colors.black.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${program.calories} kcal',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.9),
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
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "TODAY'S WORKOUT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'FULL BODY\nSTRENGTH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '45 MIN • INTERMEDIATE • COACH NIKKI',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
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
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'START WORKOUT',
                  style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                    
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
    return Container(
      color: AppTheme.surfaceColor,
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
                  color: AppTheme.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '$doneCount/5 DONE',
                style: const TextStyle(
                  color: AppTheme.successMint,
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
                              ? AppTheme.successMint
                              : AppTheme.darkTitle,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        days[i],
                        style: TextStyle(
                          color: done
                              ? Colors.black.withOpacity(0.5)
                              : Colors.black.withOpacity(0.2),
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
              const Icon(LucideIcons.flame, color: AppTheme.successMint, size: 14),
              const SizedBox(width: 8),
              Text(
                '${user.streak} DAY STREAK',
                style: TextStyle(
                  color: AppTheme.successMint,
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
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.fromLTRB(24, 8, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MY PROGRAMS',
                  style: TextStyle(
                    color: AppTheme.black,
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

    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            child: Image.network(
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
                    color: AppTheme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    program.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
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
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: clampedProgress,
                    minHeight: 6,
                    backgroundColor: AppTheme.surfaceColor,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
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
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
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

class _CaloriesSection extends StatelessWidget {
  final NutritionSummary nutrition;
  final VoidCallback onOpenNutrition;

  const _CaloriesSection({
    required this.nutrition,
    required this.onOpenNutrition,
  });

  @override
  Widget build(BuildContext context) {
    final progress = nutrition.targetCalories == 0
        ? 0.0
        : nutrition.currentCalories / nutrition.targetCalories;

    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TODAY CALORIES',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
                Text(
                  '${nutrition.currentCalories}/${nutrition.targetCalories} kcal',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 78,
                  height: 78,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 10,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
                        valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                      ),
                      Center(
                        child: Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${nutrition.currentCalories} kcal consommées',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${nutrition.targetCalories - nutrition.currentCalories} kcal restantes',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.55),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _MiniStat(label: 'Prot', value: '${nutrition.protein}g'),
                          const SizedBox(width: 8),
                          _MiniStat(label: 'Gluc', value: '${nutrition.carbs}g'),
                          const SizedBox(width: 8),
                          _MiniStat(label: 'Lip', value: '${nutrition.fat}g'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onOpenNutrition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text('ALLER À NUTRITION'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.black.withOpacity(0.45)),
          ),
        ],
      ),
    );
  }
}

class _CycleSection extends StatelessWidget {
  final CyclePhase cycle;

  const _CycleSection({required this.cycle});

  @override
  Widget build(BuildContext context) {
    final accent = _cycleAccent(cycle.name);

    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent.withOpacity(0.16), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(LucideIcons.loader, color: accent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CYCLE DU JOUR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cycle.name} • Jour ${cycle.dayOfCycle}',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.65),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              cycle.advice,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _cycleAccent(String name) {
    switch (name.toLowerCase()) {
      case 'follicular':
      case 'folliculaire':
        return const Color(0xFF2FBF91);
      case 'ovulation':
        return const Color(0xFF5FD3C4);
      case 'règles':
      case 'regles':
        return const Color(0xFFD94F6B);
      default:
        return const Color(0xFF4A6CF7);
    }
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
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.fromLTRB(24, 28, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    color: AppTheme.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'SEE ALL',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
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
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            child: Image.network(
              workout.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppTheme.surfaceColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.category.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.successMint,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workout.title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
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
                    color: Colors.black.withOpacity(0.4),
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
    return Container(
      color: AppTheme.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                LucideIcons.info,
                color: AppTheme.primaryColor,
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
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Boost iron intake during your menstrual phase — leafy greens and red meat help recovery.',
                    style: TextStyle(
                      color: Colors.black,
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