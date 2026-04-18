import 'package:fiteva/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/mock_data_provider.dart';
import '../../models/workout_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final workouts = ref.watch(workoutsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Section ──────────────────────────────────────
              _HeroWorkoutCard(user: user),

              // ── Weekly Progress Bar ───────────────────────────────
              _WeeklyProgressSection(user: user),

              // ── Recommended Workouts ──────────────────────────────
              _RecommendedSection(workouts: workouts),

              // ── Cycle Tip ─────────────────────────────────────────
              const _CycleTipCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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
        'images/workout.jpg',
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GOOD MORNING',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            )
          ],
        ),
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
                color: const Color(0xFF1C4D30),
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
                fontWeight: FontWeight.w900,
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
                  backgroundColor: const Color(0xFF1C4D30),
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

  Widget _metaChip(String label) => Text(
        label,
        style: TextStyle(
          color: Colors.black.withOpacity(0.7),
          fontSize: 11,
          letterSpacing: 1,
        ),
      );
}

class _OrangeDot extends StatelessWidget {
  const _OrangeDot();
  @override
  Widget build(BuildContext context) => Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 158, 155, 155),
          shape: BoxShape.circle,
        ),
      );
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
      color: Colors.white,
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
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '$doneCount/5 DONE',
                style: const TextStyle(
                  color: Color(0xFF52B788),
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
                              ? const Color(0xFF52B788)
                              : const Color(0xFF333333),
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
              const Icon(LucideIcons.flame, color: Color(0xFF52B788), size: 14),
              const SizedBox(width: 8),
              Text(
                '${user.streak} DAY STREAK',
                style: TextStyle(
                  color: Color(0xFF52B788),
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

// ─────────────────────────────────────────────────────────────
// RECOMMENDED WORKOUTS
// ─────────────────────────────────────────────────────────────
class _RecommendedSection extends StatelessWidget {
  final List<WorkoutModel> workouts;
  const _RecommendedSection({required this.workouts});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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
                    color: Colors.black,
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
        color: Colors.white,
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
                  Container(color: Colors.white),
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
                    color: Color(0xFF52B788),
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
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1C4D30).withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                LucideIcons.info,
                color: Color(0xFF1C4D30),
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