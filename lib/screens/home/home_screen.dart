import 'dart:async';
import 'dart:math';
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/providers/xp_provider.dart';
import 'package:fiteva/providers/weekly_plan_provider.dart';

import 'package:fiteva/screens/home/library_widget.dart';
import 'package:fiteva/screens/home/referral_card.dart';
import 'package:fiteva/screens/home/programs_bottom_sheet.dart';
import 'package:fiteva/screens/home/favorites_bottom_sheet.dart';
import 'package:fiteva/screens/shop/screens/boutique_screen.dart';
import 'package:fiteva/screens/workout/programme_detail_screen.dart';
import 'package:fiteva/screens/workout/exercise_player_screen.dart';
import 'package:fiteva/widgets/home_header.dart';
import 'package:fiteva/widgets/messtepcard.dart';
import 'package:fiteva/providers/workout_progress_provider.dart';
import 'package:fiteva/providers/program_recommendations_provider.dart';
import 'package:fiteva/services/workout_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/workout_model.dart';
import '../../models/home_program_model.dart';
import '../../providers/mock_data_provider.dart';
import '../../l10n/app_localizations.dart';




// ═══════════════════════════════════════════════════════════
// HOME SCREEN
// ═══════════════════════════════════════════════════════════

class HomeScreen extends ConsumerWidget {
  final VoidCallback? onOpenNutritionTab;
  const HomeScreen({super.key, this.onOpenNutritionTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final homePrograms = ref.watch(homeProgramsProvider);
    final sallePrograms = ref.watch(salleProgramsProvider);
    final dancePrograms = ref.watch(danceProgramsProvider);
    final recuperationPrograms = ref.watch(recuperationProgramsProvider);
    final grossessePrograms = ref.watch(grossesseProgramsProvider);

    // Combine all programs from all sources
    final allPrograms = [
      ...homePrograms,
      ...sallePrograms,
      ...dancePrograms,
      ...recuperationPrograms,
      ...grossessePrograms,
    ];

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero ──────────────────────────────────────
          SliverToBoxAdapter(child: _HeroSection(user: user)),

          // ── "GOOD TO SEE YOU" motivational strip ──────
         // SliverToBoxAdapter(child: _MotivationStrip()),

          // ── Weekly Plan ───────────────────────────────
          SliverToBoxAdapter(child: _WeeklyPlanSection()),

          // ── Steps ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: MesPasCard(),
            ),
          ),

          // ── In-Progress Programs ──────────────────────
          SliverToBoxAdapter(
            child: _ProgramsSection(programs: allPrograms, l10n: ref.watch(l10nProvider)),
          ),

          // ── Library ───────────────────────────────────
          SliverToBoxAdapter(
            child: LibrarySection(),
          ),

          // ── Referral / Invite ─────────────────────────
          const SliverToBoxAdapter(
            child: ReferralCard(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HERO — full-bleed, editorial, We Rise energy
// ═══════════════════════════════════════════════════════════

class _HeroSection extends ConsumerStatefulWidget {
  final dynamic user;
  const _HeroSection({required this.user});

  @override
  ConsumerState<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends ConsumerState<_HeroSection> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) {
        setState(() {
          _currentIndex++;
        });
      }
    });
    // Daily login XP (once per day, safe to call repeatedly)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(xpProvider.notifier).rewardDailyLogin();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = ref.watch(programRecommendationsProvider);
    final h = MediaQuery.of(context).size.height * 0.62;
    final cs = Theme.of(context).colorScheme;
    final loading = recommendations.isEmpty;

    debugPrint('Building HeroSection with ${recommendations.length} recommendations');

    if (_currentIndex == 0 && recommendations.isNotEmpty) {
      _currentIndex = Random().nextInt(recommendations.length);
    }

    final safeIndex = recommendations.isEmpty ? 0 : _currentIndex % recommendations.length;
    final program = recommendations.isEmpty ? null : recommendations[safeIndex];

    return SizedBox(
      height: h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (loading)
            Shimmer.fromColors(
              baseColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
              highlightColor: cs.surfaceContainerHighest.withValues(alpha: 0.85),
              child: Container(color: Colors.white),
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: SizedBox.expand(
                key: ValueKey(_currentIndex),
                child: Image.asset(
                  program!.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/workout.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35, 0.75, 1.0],
                colors: [
                  Color(0x00000000),
                  Color(0x33000000),
                  Color(0x990B1A12),
                  Color(0xE6000000),
                ],
              ),
            ),
          ),

          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.0, 0.4, 0.75, 1.0],
                colors: [
                  Color(0x00000000),
                  Color(0x33000000),
                  Color(0x990B1A12),
                  Color(0xE6000000),
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: const HomeHeader(),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [
                    Container(width: 28, height: 2, color: cs.secondary),
                    const SizedBox(width: 10),
                    if (loading)
                      Container(
                        width: 84,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      )
                    else
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          key: ValueKey('cat_$_currentIndex'),
                          ref.watch(l10nProvider).homeProgramme,
                          style: GoogleFonts.inter(
                            color: cs.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                  ]),

                  const SizedBox(height: 10),

                  if (loading)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 220,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    )
                  else
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        key: ValueKey('title_$_currentIndex'),
                        program!.name.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: (MediaQuery.of(context).size.width * 0.105).clamp(28.0, 42.0),
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          letterSpacing: -1,
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  if (loading)
                    Row(children: [
                      _HeroSkeletonPill(),
                      const SizedBox(width: 8),
                      _HeroSkeletonPill(),
                      const SizedBox(width: 8),
                      _HeroSkeletonPill(),
                    ])
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _MetaPill(label: program!.duration, icon: LucideIcons.timer),
                        _MetaPill(label: program.sessions, icon: LucideIcons.dumbbell),
                        _MetaPill(label: program.phases, icon: LucideIcons.activity),
                      ],
                    ),

                  const SizedBox(height: 20),

                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: loading || program == null || program.workouts.isEmpty
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WorkoutDetailScreen(program: program),
                                  ),
                                ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              ref.watch(l10nProvider).homeStartProgram,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(LucideIcons.bookmark,
                          color: Colors.white, size: 20),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSkeletonPill extends StatelessWidget {
  const _HeroSkeletonPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _MetaPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: Colors.white.withOpacity(0.85)),
      const SizedBox(width: 4),
      Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    ],
  ),
);
  }
}

// ═══════════════════════════════════════════════════════════
// MOTIVATION STRIP
// ═══════════════════════════════════════════════════════════

class _MotivationStrip extends ConsumerWidget {
  // Variable heights create an organic flame silhouette
  static const List<double> _barRatios = [0.45, 0.75, 0.55, 0.95, 0.65, 0.38, 0.22];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n   = ref.watch(l10nProvider);
    final xp     = ref.watch(xpProvider);
    final streak = xp.streak;
    final daysCompleted = streak % 7;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1A0E), Color(0xFF180900), Color(0xFF0B1A0E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF7A00).withValues(alpha: 0.20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7A00).withValues(alpha: 0.07),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Row(
        children: [
          // ── Left: streak count ──────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeSerieActive,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFF7A00).withValues(alpha: 0.60),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$streak',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                        letterSpacing: -3,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.homeJours,
                            style: GoogleFonts.inter(
                              color: Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5CD57A).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF5CD57A).withValues(alpha: 0.30),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              l10n.homeEnFeu,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF5CD57A),
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Right: flame equalizer bars ─────────────────
          SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final done = i < daysCompleted;
                final isToday = i == daysCompleted;
                final barH = (_barRatios[i] * 52).clamp(8.0, 52.0);

                final Color top = done
                    ? const Color(0xFFFFD000)
                    : isToday
                        ? const Color(0xFF5CD57A)
                        : Colors.white.withValues(alpha: 0.10);
                final Color bottom = done
                    ? const Color(0xFFFF4500)
                    : isToday
                        ? const Color(0xFF1A5C26)
                        : Colors.white.withValues(alpha: 0.04);

                return Container(
                  width: 7,
                  height: barH,
                  margin: const EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [bottom, top],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: (done || isToday)
                        ? [
                            BoxShadow(
                              color: top.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, -3),
                            )
                          ]
                        : [],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// WEEKLY PLAN SECTION
// ═══════════════════════════════════════════════════════════

class _WeeklyPlanSection extends ConsumerStatefulWidget {
  const _WeeklyPlanSection();

  @override
  ConsumerState<_WeeklyPlanSection> createState() => _WeeklyPlanSectionState();
}

class _WeeklyPlanSectionState extends ConsumerState<_WeeklyPlanSection> {
  int _selectedDay = -1;

  @override
  void initState() {
    super.initState();
    final plans = ref.read(weeklyPlanProvider);
    _selectedDay = plans.indexWhere((d) => d.isToday);
    if (_selectedDay == -1) _selectedDay = 0;
  }

  Color _statusColor(DayPlan plan, ColorScheme cs) {
    if (plan.isToday && plan.status == DayStatus.empty) return cs.secondary;
    switch (plan.status) {
      case DayStatus.done:    return const Color(0xFF52B788);
      case DayStatus.planned: return cs.primary;
      case DayStatus.rest:    return const Color(0xFF9CA3AF);
      case DayStatus.empty:   return const Color(0xFFE8EDE8);
    }
  }

  Color _statusTextColor(DayPlan plan) {
    if (plan.status == DayStatus.empty || plan.status == DayStatus.rest) {
      return const Color(0xFF8E8E93);
    }
    return Colors.white;
  }

  void _showPicker(int dayIndex) {
    final workouts = ref.read(workoutsProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WorkoutPickerSheet(
        workouts: workouts,
        onPick: (w) {
          ref.read(weeklyPlanProvider.notifier).assignWorkout(dayIndex, w);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(weeklyPlanProvider);
    final sel = _selectedDay >= 0 ? plans[_selectedDay] : null;
    final done = plans.where((d) => d.status == DayStatus.done).length;
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.watch(l10nProvider).homeWeekPlan,
                        style: GoogleFonts.inter(
                          color: cs.secondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ref.watch(l10nProvider).homePlanYourWeek,
                        style: GoogleFonts.outfit(
                          color: cs.onSurface,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    ref.watch(l10nProvider).homeDoneCount(done),
                    style: GoogleFonts.inter(
                      color: cs.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Day pills — horizontal scroll feel but all visible
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(plans.length, (i) {
                final plan = plans[i];
                final isSel = _selectedDay == i;
                final isPast = plan.isPast;
                final sc = isPast
                    ? cs.onSurface.withValues(alpha: 0.06)
                    : _statusColor(plan, cs);
                final hasWorkout = plan.workout != null;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSel ? cs.primary : sc,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: cs.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Text(
                            plan.dayShort,
                            style: GoogleFonts.inter(
                              color: isSel
                                  ? cs.secondary
                                  : _statusTextColor(plan),
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${plan.date.day}',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasWorkout
                                  ? (isSel
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.white.withOpacity(0.7))
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),


          if (sel != null)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: _DayDetailCard(
      plan: sel,
      dayIndex: _selectedDay,
      onAddWorkout: () => _showPicker(_selectedDay),
      onMarkDone: () {
        ref.read(weeklyPlanProvider.notifier)
            .markDone(_selectedDay);
      },
      onRemove: () {
        ref.read(weeklyPlanProvider.notifier)
            .remove(_selectedDay);
      },
      onViewDetail: () {
        final w = sel.workout;
        if (w == null || w.exercises.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExercisePlayerScreen(
              ref: ref,
              workoutTitle: w.title,
              exerciseName: w.exercises[0],
              videoId: w.videoIdAt(0) ?? '',
              videoUrl: w.videos.isNotEmpty ? w.videos[0].url : null,
              exerciseIndex: 0,
              totalExercises: w.exercises.length,
              totalWorkoutPoints: w.points,
              onCompleted: () {},
              workoutId: w.id,
              allVideoIds: w.videos.map((v) => v.id).toList(),
            ),
          ),
        );
      },
    ),
  ),
        ],
      ),
    );
  }
}

// ── Day detail card ────────────────────────────────────────

class _DayDetailCard extends ConsumerWidget {
  final DayPlan plan;
  final int dayIndex;
  final VoidCallback onAddWorkout;
  final VoidCallback onMarkDone;
  final VoidCallback onRemove;
  final VoidCallback? onViewDetail;

  const _DayDetailCard({
    super.key,
    required this.plan,
    required this.dayIndex,
    required this.onAddWorkout,
    required this.onMarkDone,
    required this.onRemove,
    this.onViewDetail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final w = plan.workout;
    final isDone = plan.status == DayStatus.done;
    final isPast = plan.isPast;
    final cs = Theme.of(context).colorScheme;

    if (w == null) {
      // Past day with no workout — show locked state
      if (isPast) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.onSurface.withValues(alpha: 0.08)),
          ),
          child: Column(children: [
            Icon(LucideIcons.lock, color: cs.onSurface.withValues(alpha: 0.2), size: 22),
            const SizedBox(height: 8),
            Text('Jour passé — ${plan.dayFull}',
              style: GoogleFonts.inter(
                color: cs.onSurface.withValues(alpha: 0.3),
                fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
        );
      }
      // Future/today empty — show add button
      return GestureDetector(
        onTap: onAddWorkout,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: cs.primary.withValues(alpha: 0.15),
                width: 1.5,
                style: BorderStyle.solid),
          ),
          child: Column(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.plus, color: cs.primary, size: 20),
            ),
            const SizedBox(height: 10),
            Text('Planifier ${plan.dayFull}',
              style: GoogleFonts.inter(
                color: cs.onSurfaceVariant,
                fontSize: 13, fontWeight: FontWeight.w500)),
          ]),
        ),
      );
    }

    // Workout present
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image strip
          GestureDetector(
            onTap: onViewDetail,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(children: [
                Image.asset(
                  w.imageUrl,
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(LucideIcons.dumbbell,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        size: 36),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isDone)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF52B788),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 26),
                        ),
                      ),
                    ),
                  ),
                // Title on image
                Positioned(
                  bottom: 12,
                  left: 14,
                  right: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          w.title.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          w.duration,
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),

          // Info + actions
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              // Stats row
              Row(children: [
                _StatBadge(
                    icon: LucideIcons.flame,
                    label: '${w.calories} kcal',
                    color: const Color(0xFFFF7043)),
                const SizedBox(width: 8),
                _StatBadge(
                    icon: LucideIcons.barChart2,
                    label: w.level,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                _StatBadge(
                    icon: LucideIcons.tag,
                    label: w.category,
                    color: Theme.of(context).colorScheme.secondary),
              ]),

              const SizedBox(height: 14),

              // Action buttons
              Row(children: [
                if (!isDone) ...[
                  Expanded(
                    child: _Btn(
                      label: l10n.homeDone,
                      icon: LucideIcons.checkCircle,
                      bg: const Color(0xFF52B788),
                      fg: Colors.white,
                      onTap: onMarkDone,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: _Btn(
                    label: isDone ? l10n.homeReview : l10n.homeStart,
                    icon: isDone ? LucideIcons.eye : LucideIcons.play,
                    bg: Theme.of(context).colorScheme.primary,
                    fg: Colors.white,
                    onTap: onViewDetail ?? () {},
                  ),
                ),
                const SizedBox(width: 8),
                _IconBtnSmall(
                  icon: LucideIcons.refreshCw,
                  color: Theme.of(context).colorScheme.primary,
                  bg: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  onTap: onAddWorkout,
                ),
                const SizedBox(width: 6),
                _IconBtnSmall(
                  icon: LucideIcons.trash2,
                  color: Colors.red.shade400,
                  bg: Colors.red.withValues(alpha: 0.06),
                  onTap: onRemove,
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatBadge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            )),
      ]),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg, fg;
  final VoidCallback onTap;
  const _Btn(
      {required this.label,
      required this.icon,
      required this.bg,
      required this.fg,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: fg, size: 13),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.inter(
                  color: fg,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
        ]),
      ),
    );
  }
}

class _IconBtnSmall extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final VoidCallback onTap;
  const _IconBtnSmall(
      {required this.icon,
      required this.color,
      required this.bg,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// COMPLETION INDICATOR — circular progress or checkmark
// ═══════════════════════════════════════════════════════════

class _CompletionIndicator extends StatelessWidget {
  final bool isCompleted;
  final double percentage;

  const _CompletionIndicator({
    required this.isCompleted,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.green.shade400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade400.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          LucideIcons.checkCircle,
          color: Colors.white,
          size: 20,
        ),
      );
    }

    if (percentage > 0) {
      return SizedBox(
        width: 38,
        height: 38,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                strokeWidth: 2.5,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(
                  Color(0xFFFFD89B),
                ),
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ═══════════════════════════════════════════════════════════
// PROGRAMS SECTION — horizontal cards, editorial
// ═══════════════════════════════════════════════════════════

class _ProgramsSection extends StatelessWidget {
  final List<HomeProgramModel> programs;
  final AppL10n l10n;
  const _ProgramsSection({required this.programs, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HomeProgramModel>>(
      future: WorkoutProgressService.getJoinedProgramsList(programs),
      builder: (context, snapshot) {
        final joinedPrograms = snapshot.data ?? [];

        if (joinedPrograms.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.homeInProgress,
                            style: GoogleFonts.inter(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                            )),
                        const SizedBox(height: 4),
                        Text(l10n.homeContinueSection,
                            style: GoogleFonts.outfit(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            )),
                      ],
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ProgramsBottomSheet(programs: joinedPrograms),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Text(l10n.homeVoirTout,
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          )),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 232,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: joinedPrograms.length,
                  itemBuilder: (_, i) => _ProgramCard(
                    program: joinedPrograms[i],
                    progress: 0.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgramCard extends ConsumerWidget {
  final HomeProgramModel program;
  final double progress;
  const _ProgramCard({required this.program, required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(programStatusProvider(program));
 final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return statusAsync.when(
      data: (status) {
        final isCompleted = status.isCompleted;
        final percentage = status.completionPercentage;

        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(children: [
                Image.asset(
                  program.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                // Points chip
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${program.totalPoints} PTS',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                // Completion indicator - top right
                Positioned(
                  top: 10,
                  right: 10,
                  child: _CompletionIndicator(
                    isCompleted: isCompleted,
                    percentage: percentage,
                  ),
                ),
              ]),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.name,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${program.duration}  •  ${program.sessions}',
                      style: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                  /*  Row(
                      children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (percentage).clamp(0.0, 1.0),
                            minHeight: 5,
                            backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation(
                              isCompleted ? Colors.green.shade400 : Color(0xFFFFD89B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${(percentage * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            color: isCompleted ? Colors.green.shade400 : Theme.of(context).colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          )),
                    ]),*/
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutDetailScreen(program: program),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Consumer(
                              builder: (ctx, r, _) {
                                final l = r.watch(l10nProvider);
                                return Text(
                                  isCompleted ? l.homeReview : l.homeResume,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 200,
        height: 232,
        child: Center(child: SizedBox.shrink()),
      ),
      error: (_, __) => const SizedBox(
        width: 200,
        height: 232,
        child: Center(child: SizedBox.shrink()),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// WORKOUT PICKER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════

class _WorkoutPickerSheet extends ConsumerStatefulWidget {
  final List<WorkoutModel> workouts;
  final void Function(WorkoutModel) onPick;
  const _WorkoutPickerSheet({required this.workouts, required this.onPick});

  @override
  ConsumerState<_WorkoutPickerSheet> createState() => _WorkoutPickerSheetState();
}

class _WorkoutPickerSheetState extends ConsumerState<_WorkoutPickerSheet> {
  String _cat = 'Tout';

  List<String> get _cats {
    final cats = widget.workouts.map((w) => w.category).toSet().toList();
    return ['Tout', ...cats];
  }

  List<WorkoutModel> get _filtered => _cat == 'Tout'
      ? widget.workouts
      : widget.workouts.where((w) => w.category == _cat).toList();

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            Text(l10n.homePickWorkout,
                style: GoogleFonts.outfit(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                )),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded,
                    size: 16, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 14),

        // Category chips
        SizedBox(
          height: 34,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _cats.length,
            itemBuilder: (_, i) {
              final cat = _cats[i];
              final sel = _cat == cat;
              return GestureDetector(
                onTap: () => setState(() => _cat = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: sel ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Text(cat,
                      style: GoogleFonts.inter(
                        color: sel ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      )),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final w = _filtered[i];
              return GestureDetector(
                onTap: () => widget.onPick(w),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        w.imageUrl,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 54,
                          height: 54,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(LucideIcons.dumbbell,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w.title,
                              style: GoogleFonts.outfit(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 3),
                          Text('${w.duration}  •  ${w.calories} kcal',
                              style: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              )),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(w.level,
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          )),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
