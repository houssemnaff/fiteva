import 'dart:async';
import 'dart:math';
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/providers/xp_provider.dart';
import 'package:fiteva/providers/weekly_plan_provider.dart';
import 'package:fiteva/core/nutrition/nutrition_provider.dart' hide userProfileProvider;
import 'package:fiteva/screens/cycle/homecyle.dart';
import 'package:fiteva/screens/cycle/pregnancy/PregnancyHubScreen.dart';
import 'package:fiteva/screens/cycle/pregnancy/postpartum/postpartum_hub_screen.dart';

import 'package:fiteva/screens/home/referral_card.dart';
import 'package:fiteva/screens/workout/programme_detail_screen.dart';
import 'package:fiteva/screens/workout/workout_screen.dart';
import 'package:fiteva/screens/nutrition/nutrition_screen.dart';
import 'package:fiteva/widgets/home_header.dart';
import 'package:fiteva/widgets/messtepcard.dart';
import 'package:fiteva/providers/program_recommendations_provider.dart';
import 'package:fiteva/providers/workout_progress_provider.dart';
import 'package:fiteva/services/workout_progress_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';
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
          // ── 1. Hero — featured pick ────────────────────
          SliverToBoxAdapter(child: _HeroSection(user: user)),


        

          // ── 3. Today at a glance — cycle / calories / workout ─
          const SliverToBoxAdapter(child: _StatBar()),

          // ── 4. Steps ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: MesPasCard(),
            ),
          ),

          // ── 5. This week's plan ─────────────────────────
          SliverToBoxAdapter(child: _WeeklyPlanSection()),

          // ── 6. Continue where you left off ─────────────
          SliverToBoxAdapter(child: _ContinueWorkoutsSection(programs: allPrograms)),

          // ── 7. Invite a friend ──────────────────────────
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
// r
// ═══════════════════════════════════════════════════════════

class _WeeklyPlanSection extends ConsumerStatefulWidget {
  const _WeeklyPlanSection();

  @override
  ConsumerState<_WeeklyPlanSection> createState() => _WeeklyPlanSectionState();
}

const int _kWeeklyGoal = 5;

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

  void _showPicker(int dayIndex) {
    final programs = ref.read(allProgramsProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProgramPickerSheet(
        programs: programs,
        onPick: (p) {
          ref.read(weeklyPlanProvider.notifier).assignProgram(dayIndex, p);
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
          // Section header — title left, clean progress module right
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _WeekProgressRing(
                  done: done, goal: _kWeeklyGoal, total: plans.length,
                  goalLabel: ref.watch(l10nProvider).homeWeekGoalLabel,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Day pills — clean segmented control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: List.generate(plans.length, (i) {
                  final plan = plans[i];
                  final isSel = _selectedDay == i;
                  final isPast = plan.isPast;
                  final dotColor = plan.isMissed
                      ? const Color(0xFFE0703C)
                      : isPast
                          ? cs.onSurface.withValues(alpha: 0.15)
                          : _statusColor(plan, cs);
                  final hasProgram = plan.program != null;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDay = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? cs.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Text(
                              plan.dayShort,
                              style: GoogleFonts.inter(
                                color: isSel ? cs.primary : cs.onSurfaceVariant,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${plan.date.day}',
                              style: GoogleFonts.outfit(
                                color: isSel ? cs.onSurface : cs.onSurfaceVariant,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 5, height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasProgram ? dotColor : Colors.transparent,
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
          ),

          const SizedBox(height: 16),


          if (sel != null)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.08, 0), end: Offset.zero,
        ).animate(animation);
        return ClipRect(
          child: SlideTransition(
            position: slide,
            child: FadeTransition(opacity: animation, child: child),
          ),
        );
      },
      child: _DayDetailCard(
        key: ValueKey(_selectedDay),
        plan: sel,
        dayIndex: _selectedDay,
        onAddWorkout: () => _showPicker(_selectedDay),
        onRemove: () {
          ref.read(weeklyPlanProvider.notifier)
              .remove(_selectedDay);
        },
        onViewDetail: () {
          final p = sel.program;
          if (p == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(program: p),
            ),
          );
        },
        onAcceptSuggestion: (program) {
          ref.read(weeklyPlanProvider.notifier)
              .assignProgram(_selectedDay, program);
        },
      ),
    ),
  ),
        ],
      ),
    );
  }
}

// ── Week progress ring — replaces the old two-pill header cluster with a
// single clean module: a slim ring showing days-completed progress, plus
// a small weekly-goal readout underneath.
class _WeekProgressRing extends StatelessWidget {
  final int done;
  final int goal;
  final int total;
  final String goalLabel;
  const _WeekProgressRing({
    required this.done, required this.goal, required this.total, required this.goalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      SizedBox(
        width: 46, height: 46,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          ),
          Text('$done/$total', style: GoogleFonts.outfit(
            fontSize: 12, fontWeight: FontWeight.w800, color: cs.onSurface)),
        ]),
      ),
      const SizedBox(height: 6),
      Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🏆', style: TextStyle(fontSize: 10)),
        const SizedBox(width: 3),
        Text('$goalLabel $goal', style: GoogleFonts.inter(
          fontSize: 10.5, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
      ]),
    ]);
  }
}

// ── Day detail card ────────────────────────────────────────

class _DayDetailCard extends ConsumerWidget {
  final DayPlan plan;
  final int dayIndex;
  final VoidCallback onAddWorkout;
  final VoidCallback onRemove;
  final VoidCallback? onViewDetail;
  final ValueChanged<HomeProgramModel>? onAcceptSuggestion;

  const _DayDetailCard({
    super.key,
    required this.plan,
    required this.dayIndex,
    required this.onAddWorkout,
    required this.onRemove,
    this.onViewDetail,
    this.onAcceptSuggestion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final p = plan.program;
    final isDone = plan.status == DayStatus.done;
    final isPast = plan.isPast;
    final cs = Theme.of(context).colorScheme;

    if (p == null) {
      // Past day with no program — show locked state
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
      // Future/today empty — friendlier, less "boring" placeholder, with a
      // phase-aware suggestion (cycle/pregnancy/postpartum) instead of just
      // a generic "choose workout" prompt.
      final profile = ref.watch(userProfileProvider);
      final phase   = _phaseLabel(profile, l10n, plan.date);
      HomeProgramModel? suggestion;
      if (phase != null) {
        final allPrograms = ref.watch(allProgramsProvider);
        if (phase.tag == 'grossesse' || phase.tag == 'recuperation') {
          final matches = allPrograms.where((pr) => pr.category == phase.tag).toList();
          if (matches.isNotEmpty) suggestion = matches[plan.date.day % matches.length];
        } else {
          final matches = allPrograms.where((pr) => pr.compatibleCycles.contains(phase.tag)).toList();
          if (matches.isNotEmpty) suggestion = matches[plan.date.day % matches.length];
        }
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
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
            child: Icon(LucideIcons.sparkles, color: cs.primary, size: 19),
          ),
          const SizedBox(height: 10),
          Text(l10n.homeEmptyDayTitle,
            style: GoogleFonts.outfit(
              color: cs.onSurface,
              fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(l10n.homeEmptyDaySubtitle(plan.dayFull),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: cs.onSurfaceVariant,
              fontSize: 12.5, fontWeight: FontWeight.w500)),

          if (phase != null && suggestion != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(children: [
                  Container(width: 3, color: const Color(0xFFB2447A)),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(suggestion.imageUrl, width: 40, height: 40, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 40, height: 40, color: cs.surface,
                            child: Icon(LucideIcons.dumbbell, size: 16, color: cs.primary.withValues(alpha: 0.4)))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${phase.emoji} ${phase.label}', style: GoogleFonts.inter(
                          fontSize: 10.5, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                        const SizedBox(height: 2),
                        Text(suggestion.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w800, color: cs.onSurface)),
                      ])),
                      GestureDetector(
                        onTap: onAcceptSuggestion != null ? () => onAcceptSuggestion!(suggestion!) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: cs.primary, borderRadius: BorderRadius.circular(50)),
                          child: Text(l10n.homeAddSuggestion, style: GoogleFonts.inter(
                            fontSize: 11.5, fontWeight: FontWeight.w800, color: cs.secondary)),
                        ),
                      ),
                    ]),
                  )),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onAddWorkout,
              child: Text(l10n.homeChooseAnother, style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600, color: cs.primary,
                decoration: TextDecoration.underline)),
            ),
          ] else ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onAddWorkout,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(l10n.homeChooseWorkout,
                  style: GoogleFonts.inter(
                    color: cs.secondary,
                    fontSize: 12.5, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ]),
      );
    }

    // Workout present
    final progress = ref.watch(programCompletionPercentageProvider(p)).asData?.value ?? 0.0;
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
                  p.imageUrl,
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
                  )
                else if (plan.isMissed)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0703C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.close_rounded, size: 11, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(l10n.homeMissedBadge, style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                      ]),
                    ),
                  )
                else
                  Positioned(top: 10, right: 10, child: SizedBox(
                    width: 34, height: 34,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox.expand(child: CircularProgressIndicator(
                        value: progress, strokeWidth: 3, strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor: const AlwaysStoppedAnimation(Colors.white))),
                      Text('${(progress * 100).round()}%', style: GoogleFonts.outfit(
                        fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white)),
                    ]),
                  )),
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
                          p.name.toUpperCase(),
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
                          p.duration,
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
                    icon: LucideIcons.star,
                    label: '${p.totalPoints} pts',
                    color: const Color(0xFFFF7043)),
                const SizedBox(width: 8),
                _StatBadge(
                    icon: LucideIcons.barChart2,
                    label: p.level ?? '—',
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                _StatBadge(
                    icon: LucideIcons.tag,
                    label: p.category,
                    color: Theme.of(context).colorScheme.secondary),
              ]),

              const SizedBox(height: 14),

              // Action buttons — "fait" n'est plus déclarable manuellement :
              // seul le suivi vidéo réel (_syncDoneFromProgress) marque un
              // jour comme terminé, pour que le statut reflète le vrai
              // progrès plutôt qu'un simple bouton.
              Row(children: [
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(50)),
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
        width: 40,
        height: 40,
        decoration:
            BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PROGRAM PICKER BOTTOM SHEET
// ═══════════════════════════════════════════════════════════

class _ProgramPickerSheet extends ConsumerStatefulWidget {
  final List<HomeProgramModel> programs;
  final void Function(HomeProgramModel) onPick;
  const _ProgramPickerSheet({required this.programs, required this.onPick});

  @override
  ConsumerState<_ProgramPickerSheet> createState() => _ProgramPickerSheetState();
}

class _ProgramPickerSheetState extends ConsumerState<_ProgramPickerSheet> {
  String _cat = 'Tout';

  List<String> get _cats {
    final cats = widget.programs.map((p) => p.category).toSet().toList();
    return ['Tout', ...cats];
  }

  List<HomeProgramModel> get _filtered => _cat == 'Tout'
      ? widget.programs
      : widget.programs.where((p) => p.category == _cat).toList();

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
              final p = _filtered[i];
              return GestureDetector(
                onTap: () => widget.onPick(p),
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
                        p.imageUrl,
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
                          Text(p.name,
                              style: GoogleFonts.outfit(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              )),
                          const SizedBox(height: 3),
                          Text(p.duration,
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
                      child: Text('${p.totalPoints} pts',
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


// ═══════════════════════════════════════════════════════════
// CYCLE STATUS BANNER — one-line "where you are" summary
// ═══════════════════════════════════════════════════════════

// Durée moyenne des règles (jours) — non stockée sur le profil, on utilise
// une valeur standard faute de donnée plus précise côté utilisatrice.
const int _kPeriodLengthDays = 5;

/// Jour du cycle (1-indexed) et jour d'ovulation estimé pour [forDate]
/// (aujourd'hui par défaut), ou null si pas applicable (grossesse/post-partum,
/// ou pas de date de dernières règles).
({int day, int ovulationDay, int cycleDays})? _cycleDayInfo(UserProfile profile, [DateTime? forDate]) {
  if (profile.healthStatus == 'pregnant' || profile.healthStatus == 'postpartum') {
    return null;
  }
  final lastPeriod = profile.lastPeriod;
  if (lastPeriod == null) return null;

  final target    = forDate ?? DateTime.now();
  final targetNorm = DateTime(target.year, target.month, target.day);
  final lastNorm  = DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day);
  final cycleDays = profile.cycleDays;
  final elapsed   = targetNorm.difference(lastNorm).inDays % cycleDays;
  final day       = (elapsed + 1).clamp(1, cycleDays);
  final ovulationDay = (cycleDays - 14).clamp(1, cycleDays);
  return (day: day, ovulationDay: ovulationDay, cycleDays: cycleDays);
}

/// Retourne le statut du jour ("🩸 Day X of your period", "🌸 Ovulation
/// today", etc.) ou null si l'utilisatrice n'est pas en mode "cycle"
/// classique (grossesse/post-partum n'ont pas ces états) ou si on n'a pas
/// encore de date de dernières règles enregistrée.
String? _cycleStatusText(UserProfile profile) {
  final info = _cycleDayInfo(profile);
  if (info == null) return null;

  final now       = DateTime.now();
  final todayNorm = DateTime(now.year, now.month, now.day);

  // Retard — priorité sur tout le reste.
  final pending = profile.pendingPeriodDate;
  if (pending != null && pending.isBefore(todayNorm)) {
    final lateDays = todayNorm.difference(pending).inDays;
    return '⏳ Period late by $lateDays day${lateDays > 1 ? 's' : ''}';
  }

  final day = info.day;
  final ovulationDay = info.ovulationDay;

  if (day <= _kPeriodLengthDays) {
    return '🩸 Day $day of your period';
  }
  if (day == ovulationDay) {
    return '🌸 Ovulation today';
  }
  if (day < ovulationDay) {
    return '🌿 Day $day • Follicular phase';
  }

  final next = profile.nextPeriodDate;
  final daysUntil = next?.difference(todayNorm).inDays;
  if (daysUntil != null && daysUntil > 0) {
    return '🌙 Period in $daysUntil day${daysUntil > 1 ? 's' : ''}';
  }
  return null;
}

class _CycleStatusBanner extends ConsumerWidget {
  const _CycleStatusBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final status  = _cycleStatusText(profile);
    if (status == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const CycleScreen())),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFCEAF3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFB2447A).withValues(alpha: 0.25)),
          ),
          child: Row(children: [
            Expanded(child: Text(status, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: const Color(0xFF7A2F52)))),
            Icon(LucideIcons.chevronRight, size: 16, color: cs.onSurfaceVariant),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PHASE-BASED WORKOUT SUGGESTION — for the weekly plan section
// ═══════════════════════════════════════════════════════════

// Résout le libellé de phase (emoji + nom + tag "compatibleCycles" français
// pour matcher les programmes) selon l'état réel de l'utilisatrice —
// grossesse, post-partum, ou phase du cycle classique.
({String emoji, String label, String tag})? _phaseLabel(UserProfile profile, AppL10n l10n, [DateTime? forDate]) {
  if (profile.healthStatus == 'pregnant') {
    return (emoji: '🤰', label: l10n.phasePregnancy, tag: 'grossesse');
  }
  if (profile.healthStatus == 'postpartum') {
    return (emoji: '🌱', label: l10n.phasePostpartum, tag: 'recuperation');
  }
  final info = _cycleDayInfo(profile, forDate);
  if (info == null) return null;
  final day = info.day;
  final ovulationDay = info.ovulationDay;
  // Les tags restent en français (littéraux stockés dans compatibleCycles),
  // seul le label affiché est traduit.
  if (day <= _kPeriodLengthDays) return (emoji: '🧘', label: l10n.phaseMenstrual, tag: 'Règles');
  if (day == ovulationDay)       return (emoji: '🔥', label: l10n.phaseOvulation, tag: 'Ovulation');
  if (day < ovulationDay)        return (emoji: '💪', label: l10n.phaseFollicular, tag: 'Folliculaire');
  return (emoji: '🌙', label: l10n.phaseLuteal, tag: 'Lutéale');
}

// ═══════════════════════════════════════════════════════════
// STAT BAR — cycle day / calories left / workout status today
// ═══════════════════════════════════════════════════════════

class _StatBar extends ConsumerWidget {
  const   _StatBar();

  static const _ppWeeksLabel = {
    '0-2': '0-2 sem.', '2-6': '2-6 sem.', '6-12': '6-12 sem.',
    '3-6m': '3-6 mois', '6m+': '6 mois +',
  };

  Widget _cycleScreen(BuildContext context, UserProfile profile) {
    if (profile.healthStatus == 'pregnant') return const PregnancyHubScreen();
    if (profile.healthStatus == 'postpartum') {
      // Utilise la vraie date de naissance sauvegardée — avant, une fausse
      // date était reconstituée à partir du bucket ppDuration ('2-6' → "il y
      // a 4 semaines") à chaque ouverture, ce qui figeait le décompte au
      // lieu de le faire avancer avec le temps réel.
      return PostpartumHubScreen(
        birthDate: profile.ppBirthDate ?? _fallbackBirthDate(profile.ppDuration),
      );
    }
    return const CycleScreen();
  }

  static DateTime _fallbackBirthDate(String? ppDuration) {
    const weeksAgoByDuration = {
      '0-2': 1, '2-6': 4, '6-12': 9, '3-6m': 18, '6m+': 30,
    };
    final weeksAgo = weeksAgoByDuration[ppDuration] ?? 4;
    return DateTime.now().subtract(Duration(days: weeksAgo * 7));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile  = ref.watch(userProfileProvider);
    final totals   = ref.watch(todayTotalsProvider);
    final weekPlan = ref.watch(weeklyPlanProvider);

    DayPlan? todayPlan;
    for (final d in weekPlan) {
      if (d.isToday) { todayPlan = d; break; }
    }

    // ── Cycle / pregnancy / postpartum value ──────────────────────────────
    String cycleValue;
    String cycleLabel;
    IconData cycleIcon = Icons.favorite_rounded;
    if (profile.healthStatus == 'pregnant') {
      final week = profile.currentPregnancyWeek ?? profile.pregnancyWeekSA;
      cycleValue = week != null ? 'S$week' : '—';
      cycleLabel = 'Grossesse';
      cycleIcon  = Icons.child_friendly_rounded;
    } else if (profile.healthStatus == 'postpartum') {
      cycleValue = _ppWeeksLabel[profile.ppDuration] ?? '—';
      cycleLabel = 'Post-partum';
    } else {
      final lastPeriod = profile.lastPeriod;
      if (lastPeriod != null) {
        final today     = DateTime.now();
        final todayNorm = DateTime(today.year, today.month, today.day);
        final lastNorm  = DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day);
        final cycleDays = profile.cycleDays;
        final elapsed   = todayNorm.difference(lastNorm).inDays % cycleDays;
        final day       = (elapsed + 1).clamp(1, cycleDays);
        cycleValue = 'J$day';
        cycleLabel = 'Cycle';
      } else {
        cycleValue = '—';
        cycleLabel = 'Cycle';
      }
    }

    // ── Nutrition value (calories restantes aujourd'hui) ──────────────────
    final target    = profile.targets.tdeeKcal;
    final remaining = (target - totals.calories).clamp(0, target > 0 ? target : 99999);

    // ── Workout value ──────────────────────────────────────────────────────
    String workoutValue;
    String workoutLabel;
    IconData workoutIcon;
    if (todayPlan == null || todayPlan.status == DayStatus.empty) {
      workoutValue = '—'; workoutLabel = 'Séance'; workoutIcon = LucideIcons.dumbbell;
    } else {
      switch (todayPlan.status) {
        case DayStatus.done:
          workoutValue = 'Fait'; workoutLabel = 'Séance'; workoutIcon = LucideIcons.check;
          break;
        case DayStatus.planned:
          workoutValue = 'Prévue'; workoutLabel = 'Séance'; workoutIcon = LucideIcons.dumbbell;
          break;
        case DayStatus.rest:
          workoutValue = 'Repos'; workoutLabel = 'Séance'; workoutIcon = LucideIcons.moon;
          break;
        case DayStatus.empty:
          workoutValue = '—'; workoutLabel = 'Séance'; workoutIcon = LucideIcons.dumbbell;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Expanded(child: _StatChip(
          icon: cycleIcon, value: cycleValue, label: cycleLabel,
          color: const Color(0xFFB2447A), bg: const Color(0xFFFCEAF3),
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => _cycleScreen(context, profile))))),
        const SizedBox(width: 10),
        Expanded(child: _StatChip(
          icon: LucideIcons.apple, value: '$remaining', label: 'kcal restants',
          color: Theme.of(context).colorScheme.primary, bg: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NutritionHomeScreen())))),
        const SizedBox(width: 10),
        Expanded(child: _StatChip(
          icon: workoutIcon, value: workoutValue, label: workoutLabel,
          color: const Color(0xFF1A3A6B), bg: const Color(0xFFE8EEF9),
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const WorkoutScreen())))),
      ]),
    );
  }
}

// Chaque stat est sa propre carte (icône dans un badge coloré, valeur,
// label) au lieu d'un seul bandeau avec des séparateurs verticaux.
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _StatChip({
    required this.icon, required this.value, required this.label,
    required this.color, required this.bg, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 15, color: color)),
          const SizedBox(height: 8),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: cs.onSurface)),
          const SizedBox(height: 1),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 9.5, color: cs.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CONTINUE WORKOUTS — recap of programs started but not finished
// ═══════════════════════════════════════════════════════════

class _ContinuableProgram {
  final HomeProgramModel program;
  final int doneVideos;
  final int totalVideos;
  final double percentage;
  _ContinuableProgram(this.program, this.doneVideos, this.totalVideos, this.percentage);
}

// Un programme apparaît dans "Reprendre" dès que l'utilisatrice l'a REJOINT
// (user_joined_programs — via le bouton "Commencer" du détail programme),
// qu'elle ait déjà regardé une vidéo ou non. Avant, la section se basait
// uniquement sur videoProgress (au moins une vidéo à progrès > 0) : un
// programme rejoint mais pas encore commencé (0 vidéo vue) n'apparaissait
// jamais, alors qu'il devrait être immédiatement proposé pour reprendre.
// Seuls les programmes déjà 100% terminés sont exclus (rien à "reprendre").
Future<List<_ContinuableProgram>> _fetchContinuablePrograms(
    List<HomeProgramModel> programs) async {
  final joinedPrograms    = await WorkoutProgressService.getJoinedPrograms();
  final completedPrograms = await WorkoutProgressService.getCompletedPrograms();
  final videoProgress     = await WorkoutProgressService.getAllVideoProgress();

  final result = <_ContinuableProgram>[];
  for (final p in programs) {
    if (!joinedPrograms.contains(p.id)) continue;
    if (completedPrograms.contains(p.id)) continue;

    var done = 0;
    var total = 0;
    var sumProgress = 0.0;
    for (final w in p.workouts) {
      for (final v in w.videos) {
        total++;
        final prog = videoProgress[v.id] ?? 0.0;
        sumProgress += prog;
        if (prog >= 0.8) done++;
      }
    }
    result.add(_ContinuableProgram(
      p, done, total, total > 0 ? sumProgress / total : 0));
  }
  return result;
}

class _ContinueWorkoutsSection extends StatelessWidget {
  final List<HomeProgramModel> programs;
  const _ContinueWorkoutsSection({required this.programs});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<List<_ContinuableProgram>>(
      future: _fetchContinuablePrograms(programs),
      builder: (context, snap) {
        final started = snap.data;
        if (started == null || started.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(children: [
                Expanded(child: Text('Reprendre où tu t\'es arrêtée', style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w800, color: cs.onSurface))),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _ContinueAllSheet(programs: started),
                  ),
                  child: Text('Voir tout', style: GoogleFonts.inter(
                    fontSize: 12.5, fontWeight: FontWeight.w600, color: cs.primary)),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(right: 20),
                itemCount: started.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) => SizedBox(
                  width: 165, child: _ContinueWorkoutCard(item: started[i])),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _ContinueWorkoutCard extends StatelessWidget {
  final _ContinuableProgram item;
  const _ContinueWorkoutCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final program = item.program;
    final cs = Theme.of(context).colorScheme;
    final pct = (item.percentage * 100).round();

    // Carte "photo pleine" avec dégradé + anneau de progression superposé,
    // au lieu d'une image en haut suivie d'un bloc texte séparé.
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => WorkoutDetailScreen(program: program))),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(
            program.imageUrl, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: cs.surfaceContainerHighest,
              child: Icon(LucideIcons.dumbbell, size: 32, color: cs.primary.withValues(alpha: 0.4))),
          ),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [Color(0x00000000), Color(0x33000000), Color(0xE6000000)]))),

          // Anneau de progression + pourcentage, en haut à droite
          Positioned(top: 10, right: 10, child: SizedBox(
            width: 38, height: 38,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox.expand(child: CircularProgressIndicator(
                value: item.percentage, strokeWidth: 3, strokeCap: StrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(Colors.white))),
              Text('$pct%', style: GoogleFonts.outfit(
                fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
            ]),
          )),

          // Pastille "Reprendre" en haut à gauche
          Positioned(top: 10, left: 10, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(50)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.play, size: 9, color: Colors.white),
              const SizedBox(width: 3),
              Text('Reprendre', style: GoogleFonts.inter(
                fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white)),
            ]),
          )),

          Positioned(left: 12, right: 12, bottom: 12, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
            children: [
              Text(program.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w800,
                  color: Colors.white, height: 1.15)),
              const SizedBox(height: 4),
              Text('${item.doneVideos}/${item.totalVideos} vidéos vues',
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.75))),
            ],
          )),
        ]),
      ),
    );
  }
}

// ── "Voir tout" bottom sheet — grille des programmes à reprendre ───────────
class _ContinueAllSheet extends StatelessWidget {
  final List<_ContinuableProgram> programs;
  const _ContinueAllSheet({required this.programs});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: Text('Reprendre où tu t\'es arrêtée', style: GoogleFonts.outfit(
                fontSize: 17, fontWeight: FontWeight.w800, color: cs.onSurface))),
              Text('${programs.length}', style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
            ]),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
                childAspectRatio: 165 / 190),
              itemCount: programs.length,
              itemBuilder: (context, i) => _ContinueWorkoutCard(item: programs[i]),
            ),
          ),
        ]),
      ),
    );
  }
}
