import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/workout_model.dart';
import 'active_workout_screen.dart';

// ── Brand tokens (jamais changés par le thème) ────────────────────────────────
const _kGreen     = Color(0xFF1C4D30);
const _kGreenMid  = Color(0xFF2E7D52);
const _kGold      = Color(0xFFB8966E);
const _kGoldLight = Color(0xFFF0DFC0);

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutModel workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  int _selectedWeek = 0;
  late final AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w  = widget.workout;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _HeroAppBar(workout: w),
              _TabBarSliver(current: _tab, onTab: (i) => setState(() => _tab = i)),
              _tab == 0
                  ? _AboutTab(workout: w)
                  : _SessionsTab(
                      workout: w,
                      selectedWeek: _selectedWeek,
                      onWeekTap: (i) => setState(() => _selectedWeek = i),
                    ),
            ],
          ),
          _BottomCta(
            anim: _fabAnim,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(workout: w)),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HERO APP BAR
// ══════════════════════════════════════════════════════════════════════════════
class _HeroAppBar extends StatelessWidget {
  final WorkoutModel workout;
  const _HeroAppBar({required this.workout});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      stretch: true,
      backgroundColor: _kGreen,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              workout.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: _kGreen.withValues(alpha: 0.4)),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.30),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.70),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.35, 0.72, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    _GlassButton(icon: LucideIcons.arrowLeft, onTap: () => Navigator.pop(context)),
                    const Spacer(),
                    _GlassButton(icon: LucideIcons.share2,   onTap: () {}),
                    const SizedBox(width: 10),
                    _GlassButton(icon: LucideIcons.bookmark, onTap: () {}),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 22, right: 22, bottom: 26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: _kGold, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      workout.category.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: Colors.white, fontSize: 9,
                        fontWeight: FontWeight.w800, letterSpacing: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(workout.title, style: GoogleFonts.outfit(
                    color: Colors.white, fontSize: 30,
                    fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.1,
                  )),
                  const SizedBox(height: 14),
                  Row(children: [
                    _HeroStatPill(icon: LucideIcons.clock,     label: workout.duration),
                    const SizedBox(width: 8),
                    _HeroStatPill(icon: LucideIcons.flame,     label: '${workout.calories} kcal'),
                    const SizedBox(width: 8),
                    _HeroStatPill(icon: LucideIcons.barChart2, label: workout.level),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ),
        ),
      );
}

class _HeroStatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroStatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: _kGoldLight),
            const SizedBox(width: 5),
            Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB BAR
// ══════════════════════════════════════════════════════════════════════════════
class _TabBarSliver extends StatelessWidget {
  final int current;
  final void Function(int) onTab;
  const _TabBarSliver({required this.current, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
          ),
          child: Row(children: [
            _TabPill(label: 'À propos',   selected: current == 0, onTap: () => onTab(0)),
            _TabPill(label: 'Les séances', selected: current == 1, onTap: () => onTab(1)),
          ]),
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? _kGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [BoxShadow(color: _kGreen.withValues(alpha: 0.30), blurRadius: 10, offset: const Offset(0, 3))]
                : [],
          ),
          child: Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: selected ? Colors.white : cs.onSurface.withValues(alpha: 0.50),
              fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.1,
            )),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// À PROPOS TAB
// ══════════════════════════════════════════════════════════════════════════════
class _AboutTab extends StatelessWidget {
  final WorkoutModel workout;
  const _AboutTab({required this.workout});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _StatTile(icon: LucideIcons.calendarDays, value: '4 sem.',      label: 'Durée'),
              const SizedBox(width: 10),
              _StatTile(icon: LucideIcons.zap,          value: workout.level, label: 'Niveau'),
              const SizedBox(width: 10),
              _StatTile(icon: LucideIcons.timer,        value: '30–45',       label: 'min / séance'),
            ]),
            const SizedBox(height: 28),
            const _SectionLabel(label: 'Description'),
            const SizedBox(height: 12),
            Text(
              'Ce programme complet de musculation et cardio vous aidera à sculpter votre corps et améliorer votre endurance globale. Chaque séance est pensée pour des résultats optimaux, en respectant votre cycle.',
              style: GoogleFonts.inter(
                color: cs.onSurface.withValues(alpha: 0.60),
                fontSize: 14, height: 1.65, fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),
            const _SectionLabel(label: 'Coach'),
            const SizedBox(height: 12),
            const _CoachCard(),
            const SizedBox(height: 28),
            const _SectionLabel(label: 'Objectifs'),
            const SizedBox(height: 14),
            const Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                _GoalChip(label: 'Tonification', icon: LucideIcons.sparkles),
                _GoalChip(label: 'Cardio',       icon: LucideIcons.heart),
                _GoalChip(label: 'Minceur',      icon: LucideIcons.trendingDown),
                _GoalChip(label: 'Fessiers',     icon: LucideIcons.zap),
                _GoalChip(label: 'Ventre plat',  icon: LucideIcons.target),
              ],
            ),
            const SizedBox(height: 28),
            const _SectionLabel(label: 'Programme'),
            const SizedBox(height: 14),
            const _PhaseStrip(),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Container(
        width: 16, height: 2,
        decoration: BoxDecoration(color: _kGold, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 8),
      Text(label, style: GoogleFonts.outfit(
        color: cs.onSurface, fontSize: 17,
        fontWeight: FontWeight.w800, letterSpacing: -0.3,
      )),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatTile({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
          boxShadow: [BoxShadow(color: _kGreen.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: _kGreen.withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: _kGreen),
          ),
          const SizedBox(height: 8),
          Text(value, textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: cs.onSurface.withValues(alpha: 0.50), fontSize: 10, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: _kGreen.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _kGold, width: 2)),
          child: const CircleAvatar(
            radius: 26, backgroundColor: _kGreen,
            child: Text('S', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Coach Sarah', style: GoogleFonts.outfit(
              color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text('Expert Fitness & Nutrition', style: GoogleFonts.inter(
              color: cs.onSurface.withValues(alpha: 0.50), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _kGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kGold.withValues(alpha: 0.35)),
          ),
          child: Text('Suivre', style: GoogleFonts.inter(color: _kGold, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _GoalChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _kGreen.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kGreen.withValues(alpha: 0.18)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: _kGreen),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(color: _kGreen, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      );
}

class _PhaseStrip extends StatelessWidget {
  const _PhaseStrip();
  static const _phases = ['Semaine 1', 'Semaine 2', 'Semaine 3', 'Semaine 4'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(_phases.length, (i) {
        final active = i == 0;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < _phases.length - 1 ? 6 : 0),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? _kGreen : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: active ? _kGreen : cs.outline.withValues(alpha: 0.15)),
              boxShadow: active
                  ? [BoxShadow(color: _kGreen.withValues(alpha: 0.28), blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Column(children: [
              Text('${i + 1}', style: GoogleFonts.outfit(
                color: active ? Colors.white : cs.onSurface.withValues(alpha: 0.50),
                fontSize: 16, fontWeight: FontWeight.w800,
              )),
              const SizedBox(height: 2),
              Text('sem.', style: GoogleFonts.inter(
                color: active ? Colors.white.withValues(alpha: 0.75) : cs.onSurface.withValues(alpha: 0.40),
                fontSize: 9, fontWeight: FontWeight.w500,
              )),
            ]),
          ),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LES SÉANCES TAB
// ══════════════════════════════════════════════════════════════════════════════
class _SessionsTab extends StatelessWidget {
  final WorkoutModel workout;
  final int selectedWeek;
  final void Function(int) onWeekTap;

  const _SessionsTab({
    required this.workout,
    required this.selectedWeek,
    required this.onWeekTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: List.generate(4, (i) {
                  final sel = selectedWeek == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onWeekTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: sel ? _kGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: sel
                              ? [BoxShadow(color: _kGreen.withValues(alpha: 0.28), blurRadius: 8, offset: const Offset(0, 3))]
                              : [],
                        ),
                        child: Text('Sem ${i + 1}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: sel ? Colors.white : cs.onSurface.withValues(alpha: 0.50),
                            fontWeight: FontWeight.w700, fontSize: 12,
                          )),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(workout.exercises.length, (i) {
              return _SessionCard(
                index: i,
                title: workout.exercises[i],
                imageUrl: workout.imageUrl,
                isDone: i == 0,
                isLocked: i > 2,
                onTap: i > 2
                    ? null
                    : () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => ActiveWorkoutScreen(workout: workout),
                        )),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final int index;
  final String title;
  final String imageUrl;
  final bool isDone;
  final bool isLocked;
  final VoidCallback? onTap;

  const _SessionCard({
    required this.index,
    required this.title,
    required this.imageUrl,
    required this.isDone,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.50 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDone ? _kGreen.withValues(alpha: 0.35) : cs.outline.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(color: cs.shadow.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isDone ? _kGreen : _kGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: isDone ? _kGreen : _kGreen.withValues(alpha: 0.25)),
                  boxShadow: isDone
                      ? [BoxShadow(color: _kGreen.withValues(alpha: 0.30), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Center(
                  child: isDone
                      ? const Icon(LucideIcons.check, color: Colors.white, size: 16)
                      : isLocked
                          ? Icon(LucideIcons.lock, color: cs.onSurface.withValues(alpha: 0.40), size: 14)
                          : Text('${index + 1}', style: GoogleFonts.outfit(
                              color: _kGreen, fontSize: 14, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 62, height: 62,
                  child: Image.asset(imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _kGreen.withValues(alpha: 0.10))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Séance ${index + 1}', style: GoogleFonts.inter(
                      color: _kGold, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                    const SizedBox(height: 3),
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: cs.onSurface, fontSize: 14,
                        fontWeight: FontWeight.w700, letterSpacing: -0.2,
                      )),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(LucideIcons.clock, size: 10, color: cs.onSurface.withValues(alpha: 0.45)),
                      const SizedBox(width: 4),
                      Text(index % 2 == 0 ? '25 min' : '40 min',
                        style: GoogleFonts.inter(color: cs.onSurface.withValues(alpha: 0.45), fontSize: 11, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 10),
                      Icon(LucideIcons.dumbbell, size: 10, color: cs.onSurface.withValues(alpha: 0.45)),
                      const SizedBox(width: 4),
                      Text('Haltères · Tapis',
                        style: GoogleFonts.inter(color: cs.onSurface.withValues(alpha: 0.45), fontSize: 11, fontWeight: FontWeight.w500)),
                    ]),
                  ],
                ),
              ),
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.transparent : _kGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.chevronRight, size: 16,
                  color: isLocked ? cs.onSurface.withValues(alpha: 0.30) : _kGreen),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOTTOM CTA
// ══════════════════════════════════════════════════════════════════════════════
class _BottomCta extends StatelessWidget {
  final AnimationController anim;
  final VoidCallback onTap;
  const _BottomCta({required this.anim, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [cs.surface, cs.surface.withValues(alpha: 0.0)],
              stops: const [0.55, 1.0],
            ),
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kGreen, _kGreenMid],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(color: _kGreen.withValues(alpha: 0.40), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.play, color: Colors.white, size: 16),
                  const SizedBox(width: 10),
                  Text('Commencer le programme', style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 15,
                    fontWeight: FontWeight.w700, letterSpacing: 0.2,
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
