import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/home_program_model.dart';
import '../../models/workout_model.dart';
import '../../services/workout_progress_service.dart';
import 'active_workout_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final HomeProgramModel program;
  const WorkoutDetailScreen({super.key, required this.program});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen>
    with TickerProviderStateMixin {
  int _tab = 0;
  bool _isProgramCompleted = false;
  late final AnimationController _enterAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _enterAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _checkProgramCompletion();
  }

  @override
  void dispose() {
    _enterAnim.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _checkProgramCompletion() async {
    final done =
        await WorkoutProgressService.isProgramCompleted(widget.program.id);
    if (mounted) setState(() => _isProgramCompleted = done);
  }

  Future<int> _getFirstIncompleteWorkoutIndex() async {
    final completed = await WorkoutProgressService.getCompletedWorkouts();
    for (int i = 0; i < widget.program.workouts.length; i++) {
      if (!completed.contains(widget.program.workouts[i].id)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.program;
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F7F5),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _HeroSliver(
                program: p,
                isCompleted: _isProgramCompleted,
                anim: _enterAnim,
                onBack: () => Navigator.pop(context),
              ),
              _TabBarSliver(
                  current: _tab, onTab: (i) => setState(() => _tab = i)),
              if (_tab == 0)
                _AboutSliver(program: p)
              else
                _SessionsSliver(
                    program: p,
                    onWorkoutTap: (w) => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ActiveWorkoutScreen(workout: w)),
                        )),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
          _BottomCta(
            workouts: p.workouts,
            onTap: () async {
              final idx = await _getFirstIncompleteWorkoutIndex();
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          ActiveWorkoutScreen(workout: p.workouts[idx])),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HERO
// ══════════════════════════════════════════════════════════════════════════════
class _HeroSliver extends StatelessWidget {
  final HomeProgramModel program;
  final bool isCompleted;
  final AnimationController anim;
  final VoidCallback onBack;

  const _HeroSliver({
    required this.program,
    required this.isCompleted,
    required this.anim,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: _HeroBg(
            program: program, isCompleted: isCompleted, onBack: onBack),
      ),
      // collapsed top bar
      title: FadeTransition(
        opacity: const AlwaysStoppedAnimation(0),
        child: Text(program.name,
            style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800)),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: _CircleBtn(icon: LucideIcons.arrowLeft, onTap: onBack),
      ),
    );
  }
}

class _HeroBg extends StatelessWidget {
  final HomeProgramModel program;
  final bool isCompleted;
  final VoidCallback onBack;
  const _HeroBg(
      {required this.program,
      required this.isCompleted,
      required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Photo ──────────────────────────────────────────────────────────
        Image.asset(
          program.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: const Color(0xFF1A2E1A)),
        ),

        // ── Gradient overlay ───────────────────────────────────────────────
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.25),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.90),
              ],
              stops: const [0.0, 0.30, 0.65, 1.0],
            ),
          ),
        ),

        // ── Top buttons ────────────────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(children: [
                _CircleBtn(icon: LucideIcons.arrowLeft, onTap: onBack),
                const Spacer(),
                _CircleBtn(icon: LucideIcons.share2, onTap: () {}),
                const SizedBox(width: 10),
                _CircleBtn(icon: LucideIcons.bookmark, onTap: () {}),
              ]),
            ),
          ),
        ),

        // ── Bottom content ─────────────────────────────────────────────────
        Positioned(
          left: 22,
          right: 22,
          bottom: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // badges row
              Row(children: [
                _HeroBadge(label: 'PROGRAMME', accent: true),
                const SizedBox(width: 8),
                if (isCompleted) _HeroBadge(label: '✓ TERMINÉ'),
                const Spacer(),
                _HeroBadge(label: '${program.totalPoints} PTS', icon: LucideIcons.zap),
              ]),
              const SizedBox(height: 12),
              // title
              Text(
                program.name,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.0,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 16),
              // stat pills
              Row(children: [
                _StatPill(icon: LucideIcons.clock, label: program.duration),
                const SizedBox(width: 8),
                _StatPill(
                    icon: LucideIcons.layers,
                    label: '${program.workouts.length} séances'),
                const SizedBox(width: 8),
                _StatPill(icon: LucideIcons.flame, label: 'Intermédiaire'),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ),
        ),
      );
}

class _HeroBadge extends StatelessWidget {
  final String label;
  final bool accent;
  final IconData? icon;
  const _HeroBadge({required this.label, this.accent = false, this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: accent
              ? const Color(0xFFD4A853)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: accent
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0)),
        ]),
      );
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: Colors.white70),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF1A1A1A) : Colors.white;

    return SliverToBoxAdapter(
      child: Container(
        color: dark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F7F5),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.30 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(children: [
            Expanded(
                child: _Tab(
                    label: 'À propos',
                    icon: LucideIcons.info,
                    selected: current == 0,
                    onTap: () => onTab(0))),
            Expanded(
                child: _Tab(
                    label: 'Les séances',
                    icon: LucideIcons.layoutList,
                    selected: current == 1,
                    onTap: () => onTab(1))),
          ]),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _Tab(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const accent = Color(0xFF1C4D30);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon,
              size: 14,
              color: selected
                  ? Colors.white
                  : cs.onSurface.withValues(alpha: 0.40)),
          const SizedBox(width: 7),
          Text(label,
              style: GoogleFonts.inter(
                  color: selected
                      ? Colors.white
                      : cs.onSurface.withValues(alpha: 0.50),
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// À PROPOS
// ══════════════════════════════════════════════════════════════════════════════
class _AboutSliver extends StatelessWidget {
  final HomeProgramModel program;
  const _AboutSliver({required this.program});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F7F5);

    return SliverToBoxAdapter(
      child: Container(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Quick stats grid ───────────────────────────────────────
              Row(children: [
                Expanded(
                    child: _QuickStat(
                        icon: LucideIcons.calendarDays,
                        value: '4',
                        label: 'Semaines')),
                const SizedBox(width: 10),
                Expanded(
                    child: _QuickStat(
                        icon: LucideIcons.layers,
                        value: '${program.workouts.length}',
                        label: 'Séances')),
                const SizedBox(width: 10),
                Expanded(
                    child: _QuickStat(
                        icon: LucideIcons.flame,
                        value: '~350',
                        label: 'Cal/séance')),
                const SizedBox(width: 10),
                Expanded(
                    child: _QuickStat(
                        icon: LucideIcons.zap,
                        value: '${program.totalPoints}',
                        label: 'Points')),
              ]),
              const SizedBox(height: 28),

              // ── Description ────────────────────────────────────────────
              _SectionTitle(label: 'Description'),
              const SizedBox(height: 12),
              Text(
                'Ce programme complet de musculation et cardio te permettra de sculpter ton corps et d\'améliorer ton endurance. Chaque séance est pensée pour des résultats optimaux, en respectant ton cycle.',
                style: GoogleFonts.inter(
                  color: cs.onSurface.withValues(alpha: 0.60),
                  fontSize: 14,
                  height: 1.70,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),

              // ── Coach ──────────────────────────────────────────────────
              _SectionTitle(label: 'Ton coach'),
              const SizedBox(height: 12),
              _CoachCard(dark: dark, cs: cs),
              const SizedBox(height: 28),

              // ── Objectifs ──────────────────────────────────────────────
              _SectionTitle(label: 'Objectifs'),
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: const [
                _GoalChip(label: 'Tonification', icon: LucideIcons.sparkles),
                _GoalChip(label: 'Cardio', icon: LucideIcons.heart),
                _GoalChip(label: 'Minceur', icon: LucideIcons.trendingDown),
                _GoalChip(label: 'Fessiers', icon: LucideIcons.zap),
                _GoalChip(label: 'Ventre plat', icon: LucideIcons.target),
              ]),
              const SizedBox(height: 28),

              // ── Programme phases ───────────────────────────────────────
              _SectionTitle(label: 'Les phases'),
              const SizedBox(height: 14),
              _PhaseList(dark: dark),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
              color: const Color(0xFF1C4D30),
              borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 10),
      Text(label,
          style: GoogleFonts.outfit(
              color: cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4)),
    ]);
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _QuickStat(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF1C4D30);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.25 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: accent),
        ),
        const SizedBox(height: 8),
        Text(value,
            style: GoogleFonts.outfit(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: cs.onSurface.withValues(alpha: 0.45),
                fontSize: 10,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final bool dark;
  final ColorScheme cs;
  const _CoachCard({required this.dark, required this.cs});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF1C4D30);
    const gold = Color(0xFFD4A853);
    final cardBg = dark ? const Color(0xFF1A1A1A) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.25 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [gold, Color(0xFFB8833A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
          child: const CircleAvatar(
            radius: 26,
            backgroundColor: accent,
            child: Text('S',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Coach Sarah',
              style: GoogleFonts.outfit(
                  color: cs.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text('Expert Fitness & Nutrition',
              style: GoogleFonts.inter(
                  color: cs.onSurface.withValues(alpha: 0.50),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(LucideIcons.star,
                size: 11, color: gold),
            const SizedBox(width: 4),
            Text('4.9  ·  1 200 élèves',
                style: GoogleFonts.inter(
                    color: cs.onSurface.withValues(alpha: 0.50),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ]),
        ])),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: accent.withValues(alpha: 0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Text('Suivre',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
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
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF1C4D30);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: dark
            ? accent.withValues(alpha: 0.15)
            : accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: accent),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.inter(
                color: accent, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _PhaseList extends StatelessWidget {
  final bool dark;
  const _PhaseList({required this.dark});

  static const _phases = [
    (week: 'Semaine 1', title: 'Mise en route', tag: 'Fondations'),
    (week: 'Semaine 2', title: 'Montée en charge', tag: 'Progression'),
    (week: 'Semaine 3', title: 'Intensification', tag: 'Challenge'),
    (week: 'Semaine 4', title: 'Pic de forme', tag: 'Peak'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const accent = Color(0xFF1C4D30);
    const gold = Color(0xFFD4A853);

    return Column(
      children: List.generate(_phases.length, (i) {
        final phase = _phases[i];
        final active = i == 0;
        final cardBg = dark ? const Color(0xFF1A1A1A) : Colors.white;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: active ? accent : cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: active
                    ? accent
                    : cs.outline.withValues(alpha: 0.12)),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: accent.withValues(alpha: 0.30),
                        blurRadius: 14,
                        offset: const Offset(0, 5))
                  ]
                : [
                    BoxShadow(
                        color:
                            Colors.black.withValues(alpha: dark ? 0.20 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ],
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: 0.15)
                    : accent.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('${i + 1}',
                    style: GoogleFonts.outfit(
                        color: active ? Colors.white : accent,
                        fontSize: 17,
                        fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(phase.week,
                      style: GoogleFonts.inter(
                          color: active
                              ? Colors.white.withValues(alpha: 0.65)
                              : cs.onSurface.withValues(alpha: 0.45),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 3),
                  Text(phase.title,
                      style: GoogleFonts.outfit(
                          color: active ? Colors.white : cs.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2)),
                ])),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: 0.15)
                    : gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: active
                        ? Colors.white.withValues(alpha: 0.25)
                        : gold.withValues(alpha: 0.30)),
              ),
              child: Text(phase.tag,
                  style: GoogleFonts.inter(
                      color: active ? Colors.white : gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4)),
            ),
          ]),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LES SÉANCES
// ══════════════════════════════════════════════════════════════════════════════
class _SessionsSliver extends StatelessWidget {
  final HomeProgramModel program;
  final void Function(WorkoutModel) onWorkoutTap;

  const _SessionsSliver(
      {required this.program, required this.onWorkoutTap});

  Future<int> _getFirstIncomplete() async {
    final done = await WorkoutProgressService.getCompletedWorkouts();
    for (int i = 0; i < program.workouts.length; i++) {
      if (!done.contains(program.workouts[i].id)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F7F5);

    return SliverToBoxAdapter(
      child: Container(
        color: bg,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: FutureBuilder<int>(
          future: _getFirstIncomplete(),
          builder: (context, snap) {
            final nextIdx = snap.data ?? 0;
            return Column(
              children: List.generate(program.workouts.length, (i) {
                final w = program.workouts[i];
                return FutureBuilder<bool>(
                  future: WorkoutProgressService.isWorkoutCompleted(w.id),
                  builder: (context, s) {
                    final isDone = s.data == true;
                    final isCurrent = !isDone && i == nextIdx;
                    return _SessionCard(
                      index: i,
                      workout: w,
                      isDone: isDone,
                      isCurrent: isCurrent,
                      onTap: () => onWorkoutTap(w),
                    );
                  },
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final int index;
  final WorkoutModel workout;
  final bool isDone;
  final bool isCurrent;
  final VoidCallback onTap;

  const _SessionCard({
    required this.index,
    required this.workout,
    required this.isDone,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF1C4D30);
    const gold = Color(0xFFD4A853);
    final cardBg = dark ? const Color(0xFF1A1A1A) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDone
                ? accent.withValues(alpha: 0.35)
                : isCurrent
                    ? accent.withValues(alpha: 0.50)
                    : cs.outline.withValues(alpha: 0.10),
            width: isCurrent ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isCurrent
                  ? accent.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: dark ? 0.20 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          children: [
            // ── Current indicator strip ───────────────────────────────────
            if (isCurrent)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
                decoration: const BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
                ),
                child: Row(children: [
                  const Icon(LucideIcons.play,
                      size: 11, color: Colors.white),
                  const SizedBox(width: 6),
                  Text('Prochaine séance',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3)),
                ]),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                // ── Number badge ─────────────────────────────────────────
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDone
                        ? accent
                        : isCurrent
                            ? accent.withValues(alpha: 0.12)
                            : cs.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? accent
                          : isCurrent
                              ? accent.withValues(alpha: 0.40)
                              : cs.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(LucideIcons.check,
                            color: Colors.white, size: 16)
                        : Text('${index + 1}',
                            style: GoogleFonts.outfit(
                                color: isCurrent
                                    ? accent
                                    : cs.onSurface.withValues(alpha: 0.45),
                                fontSize: 15,
                                fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Thumbnail ────────────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(children: [
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: Image.asset(workout.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: accent.withValues(alpha: 0.12))),
                    ),
                    if (isDone)
                      Positioned.fill(
                          child: Container(
                        color: accent.withValues(alpha: 0.65),
                        child: const Icon(LucideIcons.check,
                            color: Colors.white, size: 22),
                      )),
                  ]),
                ),
                const SizedBox(width: 12),

                // ── Info ─────────────────────────────────────────────────
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Séance ${index + 1}',
                          style: GoogleFonts.inter(
                              color: gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8)),
                      const SizedBox(height: 3),
                      Text(workout.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                              color: isDone
                                  ? cs.onSurface.withValues(alpha: 0.45)
                                  : cs.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(LucideIcons.clock,
                            size: 10,
                            color: cs.onSurface.withValues(alpha: 0.40)),
                        const SizedBox(width: 4),
                        Text(workout.duration,
                            style: GoogleFonts.inter(
                                color: cs.onSurface.withValues(alpha: 0.45),
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 10),
                        Icon(LucideIcons.flame,
                            size: 10,
                            color: cs.onSurface.withValues(alpha: 0.40)),
                        const SizedBox(width: 4),
                        Text(workout.calories + ' cal',
                            style: GoogleFonts.inter(
                                color: cs.onSurface.withValues(alpha: 0.45),
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ]),
                    ])),

                // ── Points + chevron ─────────────────────────────────────
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: gold.withValues(alpha: 0.30)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.zap, size: 10, color: gold),
                      const SizedBox(width: 3),
                      Text('${workout.points} pts',
                          style: GoogleFonts.inter(
                              color: gold,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Icon(LucideIcons.chevronRight,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.30)),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOTTOM CTA
// ══════════════════════════════════════════════════════════════════════════════
class _BottomCta extends StatelessWidget {
  final List workouts;
  final VoidCallback onTap;
  const _BottomCta({required this.workouts, required this.onTap});

  Future<bool> _allDone() async {
    final done = await WorkoutProgressService.getCompletedWorkouts();
    for (final w in workouts) {
      if (!done.contains(w.id)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF1C4D30);
    const gold = Color(0xFFD4A853);
    final bg = dark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F7F5);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20, 14, 20, MediaQuery.of(context).padding.bottom + 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [bg, bg.withValues(alpha: 0)],
            stops: const [0.60, 1.0],
          ),
        ),
        child: FutureBuilder<bool>(
          future: _allDone(),
          builder: (context, snap) {
            final done = snap.data ?? false;
            return GestureDetector(
              onTap: done ? null : onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: done
                        ? [gold.withValues(alpha: 0.70), gold]
                        : [accent, const Color(0xFF2E7D52)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: (done ? gold : accent).withValues(alpha: 0.40),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Icon(
                      done ? LucideIcons.checkCircle : LucideIcons.play,
                      color: Colors.white,
                      size: 18),
                  const SizedBox(width: 10),
                  Text(
                    done
                        ? 'Programme terminé ✓'
                        : 'Commencer le programme',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
