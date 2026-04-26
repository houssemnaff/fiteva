import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/workout_model.dart';
import '../../theme/app_theme.dart';
import 'active_workout_screen.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS  — matches workout_screen.dart
// ─────────────────────────────────────────────
class _T {
  static const bg       = Colors.white;
  static const surface  = Colors.white;
  static const surface2 = Colors.white;
  static const border   = Color(0x1A000000);
  static const text     = Color(0xFF000000);
  static const textSec  = Color(0xFF636366);
  static const muted    = Color(0xFFAEAEB2);
  static const accent   = Color(0xFF1C4D30);
  static const separator = Color(0x33C6C6C8);  // iOS separator

  // SF Pro text styles
  static const tsLargeTitle = TextStyle(
    color: text, fontSize: 34, fontWeight: FontWeight.w700,
    letterSpacing: 0.37, height: 1.21,
  );
  static const tsTitle1 = TextStyle(
    color: text, fontSize: 28, fontWeight: FontWeight.w700,
    letterSpacing: 0.36, height: 1.21,
  );
  static const tsTitle2 = TextStyle(
    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700,
    letterSpacing: 0.35, height: 1.27,
  );
  static const tsTitle3 = TextStyle(
    color: text, fontSize: 20, fontWeight: FontWeight.w600,
    letterSpacing: 0.38, height: 1.3,
  );
  static const tsHeadline = TextStyle(
    color: text, fontSize: 17, fontWeight: FontWeight.w600,
    letterSpacing: -0.41, height: 1.29,
  );
  static const tsBody = TextStyle(
    color: text, fontSize: 17, fontWeight: FontWeight.w400,
    letterSpacing: -0.41, height: 1.29,
  );
  static const tsCallout = TextStyle(
    color: textSec, fontSize: 16, fontWeight: FontWeight.w400,
    letterSpacing: -0.32, height: 1.55,
  );
  static const tsSubhead = TextStyle(
    color: textSec, fontSize: 15, fontWeight: FontWeight.w400,
    letterSpacing: -0.24, height: 1.33,
  );
  static const tsFootnote = TextStyle(
    color: muted, fontSize: 13, fontWeight: FontWeight.w400,
    letterSpacing: -0.08, height: 1.38,
  );
  static const tsCaption1 = TextStyle(
    color: muted, fontSize: 12, fontWeight: FontWeight.w400,
    letterSpacing: 0, height: 1.33,
  );
}

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutModel workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedWeek = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Category colour helper ────────────────
  Color _categoryColor(String cat) {
    switch (cat.toUpperCase()) {
      case 'MUSCULATION': return const Color(0xFF007AFF);
      case 'HIIT':        return const Color(0xFFFF3B30);
      case 'PILATES':     return const Color(0xFFAF52DE);
      case 'DANCE':       return const Color(0xFFFF2D55);
      case 'RUNNING':     return const Color(0xFF34C759);
      case 'YOGA':        return const Color(0xFFFF9500);
      default:            return _T.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout  = widget.workout;
    final catColor = _categoryColor(workout.category);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _T.bg,
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [

                // ── HERO APP BAR ─────────────────
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  backgroundColor: Colors.black,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  // Collapsed bar actions
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      _CircleButton(
                        icon: LucideIcons.moreHorizontal,
                        onTap: () {},
                      ),
                    ],
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Hero photo
                        Image.network(
                          workout.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey.shade900),
                        ),
                        // Gradient — heavier at bottom
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x33000000),
                                Color(0xDD000000),
                              ],
                              stops: [0.3, 1.0],
                            ),
                          ),
                        ),
                        // Bottom content on hero
                        Positioned(
                          left: 20, right: 20, bottom: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: catColor.withOpacity(0.6), width: 1),
                                ),
                                child: Text(
                                  workout.category.toUpperCase(),
                                  style: TextStyle(
                                    color: catColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Title
                              Text(workout.title, style: _T.tsTitle2),
                              const SizedBox(height: 12),
                              // Quick stats row
                              Row(
                                children: [
                                  _HeroStat(
                                      icon: LucideIcons.clock,
                                      label: workout.duration),
                                  const SizedBox(width: 16),
                                  _HeroStat(
                                      icon: LucideIcons.barChart2,
                                      label: workout.level),
                                  const SizedBox(width: 16),
                                  _HeroStat(
                                      icon: LucideIcons.flame,
                                      label: '${workout.calories} kcal'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── SEGMENTED CONTROL ────────────
                SliverToBoxAdapter(
                  child: Container(
                    color: _T.bg,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _SegmentedControl(
                      labels: const ['À propos', 'Les séances'],
                      controller: _tabController,
                    ),
                  ),
                ),

                // ── TAB CONTENT ──────────────────
                SliverToBoxAdapter(
                  child: _tabController.index == 0
                      ? _AboutTab(workout: workout)
                      : _SessionsTab(
                          workout: workout,
                          selectedWeek: _selectedWeek,
                          onWeekChanged: (w) =>
                              setState(() => _selectedWeek = w),
                        ),
                ),
              ],
            ),

            // ── STICKY BOTTOM CTA ─────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _BottomCTA(
                label: 'Rejoindre le programme',
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HERO STAT CHIP
// ─────────────────────────────────────────────
class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _HeroStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// CIRCLE BUTTON  (back / more)
// ─────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// iOS SEGMENTED CONTROL
// ─────────────────────────────────────────────
class _SegmentedControl extends StatelessWidget {
  final List<String>   labels;
  final TabController  controller;
  const _SegmentedControl({required this.labels, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _T.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = controller.index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: active ? _T.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: active ? _T.text : _T.textSec,
                    fontSize: 13,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 1 — À PROPOS
// ─────────────────────────────────────────────
class _AboutTab extends StatelessWidget {
  final WorkoutModel workout;
  const _AboutTab({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── STATS CARD (iOS grouped table style) ──
          _GroupedCard(
            children: [
              _StatRow(
                icon: LucideIcons.calendar,
                label: 'Durée du programme',
                value: '4 semaines',
                isFirst: true,
              ),
              _StatRow(
                icon: LucideIcons.barChart2,
                label: 'Niveau',
                value: workout.level,
              ),
              _StatRow(
                icon: LucideIcons.clock,
                label: 'Durée / séance',
                value: '20–40 min',
              ),
              _StatRow(
                icon: LucideIcons.flame,
                label: 'Calories',
                value: '${workout.calories} kcal',
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── DESCRIPTION ──
          Text('À propos', style: _T.tsTitle3),
          const SizedBox(height: 10),
          Text(
            'Ce programme complet de musculation et cardio vous aidera à sculpter votre corps et améliorer votre endurance globale. Mêlant des exercices variés pour éviter la monotonie, chaque séance est pensée pour des résultats optimaux.',
            style: _T.tsCallout,
          ),

          const SizedBox(height: 28),

          // ── COACH ──
          Text('Coach', style: _T.tsTitle3),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.border, width: 0.5),
            ),
            child: Row(
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    'https://i.pravatar.cc/150?img=12',
                    width: 48, height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48, height: 48, color: _T.surface2,
                      child: const Icon(Icons.person, color: _T.muted, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coach Sarah', style: _T.tsHeadline),
                      const SizedBox(height: 2),
                      Text('Expert Fitness & Nutrition',
                          style: _T.tsFootnote),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight,
                    color: _T.muted, size: 16),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── OBJECTIVES ──
          Text('Objectifs', style: _T.tsTitle3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Tonification',
              'Cardio',
              'Minceur',
              'Fessiers',
              'Ventre plat',
            ].map((label) => _GoalTag(label: label)).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// GROUPED TABLE CARD  (iOS UITableView style)
// ─────────────────────────────────────────────
class _GroupedCard extends StatelessWidget {
  final List<Widget> children;
  const _GroupedCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _T.border, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final bool     isFirst;
  final bool     isLast;
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast  = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: _T.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _T.accent, size: 15),
              ),
              const SizedBox(width: 12),
              // Label
              Expanded(
                child: Text(label, style: _T.tsSubhead),
              ),
              // Value — right aligned, iOS style
              Text(
                value,
                style: const TextStyle(
                  color: _T.textSec,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.24,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.only(left: 58),
            child: Divider(height: 0.5, color: _T.separator),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// GOAL TAG
// ─────────────────────────────────────────────
class _GoalTag extends StatelessWidget {
  final String label;
  const _GoalTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.border, width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _T.text,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.08,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 2 — LES SÉANCES
// ─────────────────────────────────────────────
class _SessionsTab extends StatelessWidget {
  final WorkoutModel workout;
  final int          selectedWeek;
  final ValueChanged<int> onWeekChanged;
  const _SessionsTab({
    required this.workout,
    required this.selectedWeek,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── WEEK SELECTOR ─────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) {
                final active = selectedWeek == i;
                return GestureDetector(
                  onTap: () => onWeekChanged(i),
                  child: Column(
                    children: [
                      Text(
                        'Sem ${i + 1}',
                        style: TextStyle(
                          color: active ? _T.text : _T.muted,
                          fontSize: 15,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                          letterSpacing: -0.24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: active ? 20 : 0,
                        height: 2,
                        decoration: BoxDecoration(
                          color: _T.accent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: _T.separator),
          const SizedBox(height: 16),

          // ── SESSION LIST ──────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _GroupedCard(
              children: List.generate(workout.exercises.length, (i) {
                final isDone = i == 0;
                final isLast = i == workout.exercises.length - 1;
                return _SessionRow(
                  index: i,
                  title: workout.exercises[i],
                  duration: i % 2 == 0 ? '25 min' : '40 min',
                  imageUrl: workout.imageUrl,
                  isDone: isDone,
                  isLast: isLast,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ActiveWorkoutScreen(workout: workout),
                    ),
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

// ─────────────────────────────────────────────
// SESSION ROW  (iOS table cell style)
// ─────────────────────────────────────────────
class _SessionRow extends StatelessWidget {
  final int    index;
  final String title;
  final String duration;
  final String imageUrl;
  final bool   isDone;
  final bool   isLast;
  final VoidCallback onTap;

  const _SessionRow({
    required this.index,
    required this.title,
    required this.duration,
    required this.imageUrl,
    required this.isDone,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            child: Row(
              children: [

                // Completion indicator
                _CompletionDot(isDone: isDone),
                const SizedBox(width: 12),

                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 58, height: 58,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: _T.surface2),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Text info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Séance ${index + 1}',
                        style: _T.tsCaption1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: _T.tsHeadline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(LucideIcons.clock,
                            size: 11, color: _T.muted),
                        const SizedBox(width: 4),
                        Text(duration, style: _T.tsCaption1),
                        const SizedBox(width: 10),
                        Icon(LucideIcons.package,
                            size: 11, color: _T.muted),
                        const SizedBox(width: 4),
                        Text('Tapis · Haltères',
                            style: _T.tsCaption1),
                      ]),
                    ],
                  ),
                ),

                // Chevron — iOS disclosure indicator
                Icon(LucideIcons.chevronRight,
                    color: _T.muted, size: 16),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.only(left: 86),
            child: Divider(height: 0.5, color: _T.separator),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// COMPLETION DOT
// ─────────────────────────────────────────────
class _CompletionDot extends StatelessWidget {
  final bool isDone;
  const _CompletionDot({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        color: isDone ? _T.accent : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDone ? _T.accent : _T.muted,
          width: 1.5,
        ),
      ),
      child: isDone
          ? const Icon(Icons.check_rounded,
              color: Colors.white, size: 13)
          : null,
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM CTA
// ─────────────────────────────────────────────
class _BottomCTA extends StatelessWidget {
  final String       label;
  final VoidCallback onTap;
  const _BottomCTA({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 34),
      decoration: BoxDecoration(
        color: _T.bg,
        border: const Border(
          top: BorderSide(color: _T.separator, width: 0.5),
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: _T.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.41,
            ),
          ),
        ),
      ),
    );
  }
}