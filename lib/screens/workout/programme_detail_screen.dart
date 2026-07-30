import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/app_localizations.dart';
import '../../models/coach_model.dart';
import '../../models/home_program_model.dart';
import '../../models/program_week_model.dart';
import '../../models/workout_model.dart';
import '../../providers/workout_progress_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../services/workout_progress_service.dart';
import '../../services/program_service.dart';
import '../../widgets/paywall_sheet.dart';
import 'active_workout_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final HomeProgramModel program;
  const WorkoutDetailScreen({super.key, required this.program});

  @override
  ConsumerState<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen>
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

  /// Prochain workout à lancer — limité aux semaines débloquées.
  Future<WorkoutModel?> _getNextWorkout() async {
    final p = widget.program;
    final completed = await WorkoutProgressService.getCompletedWorkouts();
    final unlocked = await WorkoutProgressService.getUnlockedWeeksCount(p);
    final available = p.weeks.isEmpty
        ? p.workouts
        : [for (final wk in p.weeks.take(unlocked)) ...wk.workouts];
    for (final w in available) {
      if (!completed.contains(w.id)) return w;
    }
    return available.isNotEmpty ? available.first : null;
  }

  void _share(BuildContext context, HomeProgramModel p) {
    Clipboard.setData(ClipboardData(text: '${p.name} — ${p.duration}'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lien copié dans le presse-papiers !'), duration: Duration(seconds: 2)),
    );
  }

  void _toggleBookmark(BuildContext context, HomeProgramModel p) {
    final favorites = ref.read(favoritesProvider);
    final isFav = favorites.contains('prog:${p.id}');
    ref.read(favoritesProvider.notifier).toggleFavorite('prog:${p.id}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isFav ? 'Retiré des favoris' : 'Ajouté aux favoris'),
      duration: const Duration(seconds: 2),
    ));
  }

  /// True si ce programme est verrouillé (premium et l'utilisatrice n'est
  /// pas Pro) — la fiche reste consultable (teaser marketing) mais les
  /// séances ne peuvent pas être lancées.
  bool get _isLocked =>
      widget.program.isPremium && !ref.read(isProProvider);

  bool _blockIfLocked(BuildContext context) {
    if (!_isLocked) return false;
    showPaywallSheet(
      context,
      feature: widget.program.name,
      description: 'Ce programme complet est réservé aux membres Pro.',
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.program;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l10n = ref.watch(l10nProvider);
    final isFav = ref.watch(favoritesProvider).contains(p.id);

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0D0D0D) : const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _HeroSliver(
                program: p,
                isCompleted: _isProgramCompleted,
                anim: _enterAnim,
                l10n: l10n,
                onBack: () => Navigator.pop(context),
                onShare: () => _share(context, p),
                onBookmark: () => _toggleBookmark(context, p),
                isFav: isFav,
              ),
              _TabBarSliver(
                  current: _tab, l10n: l10n, onTab: (i) => setState(() => _tab = i)),
              if (_tab == 0)
                _AboutSliver(program: p, l10n: l10n)
              else
                _SessionsSliver(
                    program: p,
                    l10n: l10n,
                    locked: _isLocked,
                    onWorkoutTap: (w) async {
                      if (_blockIfLocked(context)) return;
                      await ref
                          .read(programJoinProvider.notifier)
                          .joinProgram(p.id);
                      if (!mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ActiveWorkoutScreen(workout: w)),
                      );
                      if (mounted) {
                        setState(() {});
                        _checkProgramCompletion();
                      }
                    }),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
          _BottomCta(
            workouts: p.workouts,
            l10n: l10n,
            locked: _isLocked,
            onTap: () async {
              if (_blockIfLocked(context)) return;
              final nav = Navigator.of(context);
              await ref.read(programJoinProvider.notifier).joinProgram(p.id);
              final next = await _getNextWorkout();
              if (!mounted || next == null) return;
              await nav.push(
                MaterialPageRoute(
                    builder: (_) => ActiveWorkoutScreen(workout: next)),
              );
              if (mounted) {
                setState(() {});
                _checkProgramCompletion();
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
  final AppL10n l10n;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onBookmark;
  final bool isFav;

  const _HeroSliver({
    required this.program,
    required this.isCompleted,
    required this.anim,
    required this.l10n,
    required this.onBack,
    required this.onShare,
    required this.onBookmark,
    required this.isFav,
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
            program: program, isCompleted: isCompleted, l10n: l10n, onBack: onBack,
            onShare: onShare, onBookmark: onBookmark, isFav: isFav),
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
  final AppL10n l10n;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onBookmark;
  final bool isFav;
  const _HeroBg(
      {required this.program,
      required this.isCompleted,
      required this.l10n,
      required this.onBack,
      required this.onShare,
      required this.onBookmark,
      required this.isFav});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Photo ──────────────────────────────────────────────────────────
        program.imageUrl.startsWith('http')
          ? Image.network(
              program.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF1A2E1A)),
            )
          : Image.asset(
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
              //  _CircleBtn(icon: LucideIcons.arrowLeft, onTap: onBack),
                const Spacer(),
                _CircleBtn(icon: LucideIcons.share2, onTap: onShare),
                const SizedBox(width: 10),
                _CircleBtn(
                  icon: isFav ? LucideIcons.bookmarkCheck : LucideIcons.bookmark,
                  onTap: onBookmark,
                ),
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
                _HeroBadge(label: l10n.progProgramme, accent: true),
                const SizedBox(width: 8),
                if (isCompleted) _HeroBadge(label: l10n.progCompleted),
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
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _StatPill(icon: LucideIcons.clock, label: program.duration),
                  _StatPill(
                      icon: LucideIcons.layers,
                      label: '${program.workouts.length} ${l10n.progSeances}'),
                  _StatPill(icon: LucideIcons.flame, label: 'Intermédiaire'),
                ],
              ),
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
  final AppL10n l10n;
  final void Function(int) onTab;
  const _TabBarSliver({required this.current, required this.l10n, required this.onTab});

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
                    label: l10n.progAbout,
                    icon: LucideIcons.info,
                    selected: current == 0,
                    onTap: () => onTab(0))),
            Expanded(
                child: _Tab(
                    label: l10n.progSessions,
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
    final accent = Theme.of(context).colorScheme.primary;
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
  final AppL10n l10n;
  const _AboutSliver({required this.program, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0D0D0D) : const Color.fromARGB(255, 255, 255, 255);

    return SliverToBoxAdapter(
      child: Container(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Quick stats pills ────────────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickStatPill(
                      icon: LucideIcons.calendarDays,
                      value: program.weeks.isNotEmpty
                          ? '${program.weeks.length}'
                          : '1',
                      label: l10n.progWeeks),
                  _QuickStatPill(
                      icon: LucideIcons.layers,
                      value: '${program.workouts.length}',
                      label: l10n.progSessions),
                  _QuickStatPill(
                      icon: LucideIcons.flame,
                      value: '~350',
                      label: l10n.progCalPerSession),
                  _QuickStatPill(
                      icon: LucideIcons.zap,
                      value: '${program.totalPoints}',
                      label: l10n.progPtsUnit),
                ],
              ),
              const SizedBox(height: 28),

              // ── Description ────────────────────────────────────────────
              _SectionTitle(label: l10n.progDescription),
              const SizedBox(height: 12),
              Text(
                program.description.isNotEmpty
                    ? program.description
                    : 'Description à venir pour ce programme.',
                style: GoogleFonts.inter(
                  color: cs.onSurface.withValues(alpha: 0.60),
                  fontSize: 14,
                  height: 1.70,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),

              // ── Coach ──────────────────────────────────────────────────
              _SectionTitle(label: l10n.progCoach),
              const SizedBox(height: 12),
              _CoachCard(dark: dark, cs: cs, l10n: l10n, coach: program.coach),
              const SizedBox(height: 28),

              // ── Objectifs ──────────────────────────────────────────────
              if (program.goals.isNotEmpty) ...[
                _SectionTitle(label: l10n.progObjectives),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final g in program.goals)
                    _GoalChip(label: g, icon: _goalIcon(g)),
                ]),
                const SizedBox(height: 28),
              ],

              // ── Programme phases ───────────────────────────────────────
              _SectionTitle(label: l10n.progPhases),
              const SizedBox(height: 14),
              _PhaseList(dark: dark, weeks: program.weeks),
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
    final accent = cs.primary;
    return Row(children: [
      Container(
          width: 3,
          height: 15,
          decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 9),
      Text(label,
          style: GoogleFonts.outfit(
              color: cs.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3)),
    ]);
  }
}

class _QuickStatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _QuickStatPill(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = cs.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.20 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: accent),
        const SizedBox(width: 8),
        Text(value,
            style: GoogleFonts.outfit(
                color: cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3)),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.inter(
                color: cs.onSurface.withValues(alpha: 0.45),
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final bool dark;
  final ColorScheme cs;
  final AppL10n l10n;

  /// Coach réel du programme (programs.coach_id → coaches) — null si non
  /// renseigné en base : la carte retombe sur le coach générique l10n.
  final CoachModel? coach;

  const _CoachCard(
      {required this.dark, required this.cs, required this.l10n, this.coach});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    const gold = Color(0xFFD4A853);

    final name = (coach?.name.isNotEmpty ?? false)
        ? coach!.name
        : l10n.progCoachName;
    final title = (coach?.title.isNotEmpty ?? false)
        ? coach!.title
        : l10n.progCoachTitle;
    final rating = coach != null
        ? '${coach!.rating} · ${coach!.reviewsCount} avis'
        : l10n.progCoachRating;
    final avatarUrl = coach?.avatarUrl ?? '';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (coach != null) {
          showCoachProfileSheet(context, coach: coach!, dark: dark);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark
              ? accent.withValues(alpha: 0.08)
              : accent.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.15 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.3), width: 2),
            ),
            child: ClipOval(
              child: avatarUrl.isNotEmpty
                  ? Image.network(avatarUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: accent,
                        child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'C',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
                      ))
                  : Container(
                      color: accent,
                      child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'C',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: GoogleFonts.outfit(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(title,
                style: GoogleFonts.inter(
                    color: cs.onSurface.withValues(alpha: 0.50),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Row(children: [
              Icon(LucideIcons.star,
                  size: 11, color: gold),
              const SizedBox(width: 4),
              Text(rating,
                  style: GoogleFonts.inter(
                      color: cs.onSurface.withValues(alpha: 0.50),
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: Icon(LucideIcons.chevronRight, size: 16, color: accent),
          ),
        ]),
      ),
    );
  }
}

/// Icône associée à un objectif (programs.goals) — mapping par libellé
/// connu, avec une icône neutre par défaut pour tout libellé inconnu
/// (permet d'ajouter de nouveaux objectifs en base sans casser l'UI).
IconData _goalIcon(String goal) {
  switch (goal) {
    case 'Tonification':      return LucideIcons.sparkles;
    case 'Cardio':            return LucideIcons.heart;
    case 'Minceur':           return LucideIcons.trendingDown;
    case 'Fessiers':          return LucideIcons.zap;
    case 'Force':             return LucideIcons.dumbbell;
    case 'Masse musculaire':  return LucideIcons.dumbbell;
    case 'Endurance':         return LucideIcons.activity;
    case 'Renforcement':      return LucideIcons.activity;
    case 'Souplesse':         return LucideIcons.moveVertical;
    case 'Posture':           return LucideIcons.moveVertical;
    case 'Récupération':      return LucideIcons.wind;
    case 'Relaxation':        return LucideIcons.moon;
    case 'Bien-être':         return LucideIcons.sparkles;
    case 'Respiration':       return LucideIcons.wind;
    default:                  return LucideIcons.target;
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _GoalChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
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
  final List<ProgramWeekModel> weeks;
  const _PhaseList({required this.dark, required this.weeks});

  // Fallback si le programme n'a pas encore de semaines en base.
  static const _fallbackPhases = [
    (week: 'Semaine 1', title: 'Mise en route', tag: 'Fondations'),
    (week: 'Semaine 2', title: 'Montée en charge', tag: 'Progression'),
    (week: 'Semaine 3', title: 'Intensification', tag: 'Challenge'),
    (week: 'Semaine 4', title: 'Pic de forme', tag: 'Peak'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = Theme.of(context).colorScheme.primary;
    const gold = Color(0xFFD4A853);

    final phases = weeks.isEmpty
        ? _fallbackPhases
        : [
            for (final w in weeks)
              (
                week: 'Semaine ${w.weekNumber}',
                title: w.title.isNotEmpty && w.title != 'Semaine ${w.weekNumber}'
                    ? w.title
                    : _fallbackPhases.length >= w.weekNumber
                        ? _fallbackPhases[w.weekNumber - 1].title
                        : 'Phase ${w.weekNumber}',
                tag: '${w.workouts.length} séance${w.workouts.length > 1 ? 's' : ''}',
              ),
          ];

    return Column(
      children: List.generate(phases.length, (i) {
        final phase = phases[i];
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
class _SessionsSliver extends StatefulWidget {
  final HomeProgramModel program;
  final AppL10n l10n;
  final void Function(WorkoutModel) onWorkoutTap;
  final bool locked;

  const _SessionsSliver(
      {required this.program, required this.l10n, required this.onWorkoutTap,
      this.locked = false});

  @override
  State<_SessionsSliver> createState() => _SessionsSliverState();
}

class _SessionsSliverState extends State<_SessionsSliver> {
  int _selectedWeek = 0;

  /// Charge en une passe : le premier workout non terminé (toutes semaines
  /// débloquées confondues) + le nombre de semaines débloquées.
  Future<({String? nextId, int unlockedWeeks})> _load() async {
    final done = await WorkoutProgressService.getCompletedWorkouts();
    final unlocked =
        await WorkoutProgressService.getUnlockedWeeksCount(widget.program);
    String? nextId;
    for (final w in widget.program.workouts) {
      if (!done.contains(w.id)) {
        nextId = w.id;
        break;
      }
    }
    return (nextId: nextId, unlockedWeeks: unlocked);
  }

  void _showLockedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
          '🔒 Semaine verrouillée — termine d\'abord la semaine précédente. '
          'Elle s\'ouvrira aussi après 7 jours.'),
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F7F5);

    final weeks = widget.program.weeks;
    final hasWeeks = weeks.isNotEmpty;
    final weekIdx = hasWeeks ? _selectedWeek.clamp(0, weeks.length - 1) : 0;
    // Seulement les workouts de la semaine sélectionnée (ou tout le
    // programme si aucune semaine n'existe encore en base).
    final workouts =
        hasWeeks ? weeks[weekIdx].workouts : widget.program.workouts;

    return SliverToBoxAdapter(
      child: Container(
        color: bg,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: FutureBuilder<({String? nextId, int unlockedWeeks})>(
          future: _load(),
          builder: (context, snap) {
            final nextId = snap.data?.nextId;
            final unlockedWeeks = snap.data?.unlockedWeeks ?? 1;
            // La semaine affichée est-elle verrouillée ? (navigation libre,
            // mais vidéos inaccessibles tant que la semaine n'est pas ouverte)
            final weekLocked = hasWeeks && weekIdx >= unlockedWeeks;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasWeeks && weeks.length > 1) ...[
                  _WeekNavBar(
                    weeks: weeks,
                    selected: weekIdx,
                    unlockedCount: unlockedWeeks,
                    onSelect: (i) => setState(() => _selectedWeek = i),
                  ),
                  const SizedBox(height: 18),
                ],
                if (weekLocked)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A853).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              const Color(0xFFD4A853).withValues(alpha: 0.35)),
                    ),
                    child: Row(children: [
                      const Icon(LucideIcons.lock,
                          size: 15, color: Color(0xFFB8833A)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Termine la semaine précédente pour débloquer '
                          'ces séances (7 jours par semaine).',
                          style: GoogleFonts.inter(
                              color: const Color(0xFFB8833A),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.4),
                        ),
                      ),
                    ]),
                  ),
                Opacity(
                  opacity: widget.locked ? 0.5 : 1,
                  child: Column(
                    children: List.generate(workouts.length, (i) {
                      final w = workouts[i];
                      return FutureBuilder<bool>(
                        future: WorkoutProgressService.isWorkoutCompleted(w.id),
                        builder: (context, s) {
                          final isDone = s.data == true;
                          final isCurrent =
                              !weekLocked && !isDone && w.id == nextId;
                          return _SessionCard(
                          index: i,
                          workout: w,
                          isDone: isDone,
                          isCurrent: isCurrent,
                          locked: weekLocked,
                          l10n: widget.l10n,
                          onTap: weekLocked
                              ? () => _showLockedMessage(context)
                              : () => widget.onWorkoutTap(w),
                        );
                      },
                    );
                  }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Navbar des semaines : « Semaine 1 · Semaine 2 · … » ──────────────────────
class _WeekNavBar extends StatelessWidget {
  final List<ProgramWeekModel> weeks;
  final int selected;

  /// Nombre de semaines débloquées (les index >= unlockedCount sont
  /// verrouillés : navigables mais affichés avec un cadenas).
  final int unlockedCount;
  final void Function(int) onSelect;

  const _WeekNavBar(
      {required this.weeks,
      required this.selected,
      required this.unlockedCount,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: weeks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final sel = i == selected;
          final locked = i >= unlockedCount;
          final week = weeks[i];
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: sel
                    ? accent
                    : (dark ? const Color(0xFF1A1A1A) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: sel
                        ? accent
                        : cs.outline.withValues(alpha: 0.15)),
                boxShadow: sel
                    ? [
                        BoxShadow(
                            color: accent.withValues(alpha: 0.30),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]
                    : [],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(locked ? LucideIcons.lock : LucideIcons.calendarDays,
                    size: 13,
                    color: sel
                        ? Colors.white
                        : cs.onSurface
                            .withValues(alpha: locked ? 0.30 : 0.45)),
                const SizedBox(width: 7),
                Text('Semaine ${week.weekNumber}',
                    style: GoogleFonts.inter(
                        color: sel
                            ? Colors.white
                            : cs.onSurface
                                .withValues(alpha: locked ? 0.35 : 0.60),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final int index;
  final WorkoutModel workout;
  final bool isDone;
  final bool isCurrent;

  /// Semaine verrouillée : la carte reste visible mais grisée, avec un
  /// cadenas — le tap n'ouvre pas la vidéo (message explicatif à la place).
  final bool locked;
  final AppL10n l10n;
  final VoidCallback onTap;

  const _SessionCard({
    required this.index,
    required this.workout,
    required this.isDone,
    required this.isCurrent,
    this.locked = false,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;
    const gold = Color(0xFFD4A853);
    final cardBg = dark ? const Color(0xFF1A1A1A) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: locked ? 0.55 : 1.0,
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
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                ),
                child: Row(children: [
                  const Icon(LucideIcons.play,
                      size: 11, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(l10n.progNextSession,
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
                // ── Thumbnail with number overlay ────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: workout.imageUrl.startsWith('http')
                          ? Image.network(workout.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: accent.withValues(alpha: 0.12)))
                          : Image.asset(workout.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: accent.withValues(alpha: 0.12))),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.50),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 6,
                      child: isDone
                          ? Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.check,
                                  color: Colors.white, size: 12),
                            )
                          : locked
                              ? Icon(LucideIcons.lock,
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.85))
                              : Text('${index + 1}',
                                  style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.50),
                                          blurRadius: 6,
                                        ),
                                      ])),
                    ),
                    if (isDone)
                      Positioned.fill(
                          child: Container(
                        color: accent.withValues(alpha: 0.45),
                      )),
                  ]),
                ),
                const SizedBox(width: 14),

                // ── Info ─────────────────────────────────────────────────
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('${l10n.progSession} ${index + 1}',
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
                        Flexible(
                          child: Text(workout.duration,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  color: cs.onSurface.withValues(alpha: 0.45),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 10),
                        Icon(LucideIcons.flame,
                            size: 10,
                            color: cs.onSurface.withValues(alpha: 0.40)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text('${workout.calories} cal',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  color: cs.onSurface.withValues(alpha: 0.45),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                        ),
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
                  Icon(locked ? LucideIcons.lock : LucideIcons.chevronRight,
                      size: 16,
                      color: cs.onSurface.withValues(alpha: 0.30)),
                ]),
              ]),
            ),
          ],
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
  final List workouts;
  final AppL10n l10n;
  final VoidCallback onTap;
  final bool locked;
  const _BottomCta({required this.workouts, required this.l10n, required this.onTap,
      this.locked = false});

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
    final accent = Theme.of(context).colorScheme.primary;
    const gold = Color(0xFFD4A853);
    final bg = dark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F7F5);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).padding.bottom + 24),
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
                      done
                          ? LucideIcons.checkCircle
                          : locked ? LucideIcons.lock : LucideIcons.play,
                      color: Colors.white,
                      size: 18),
                  const SizedBox(width: 10),
                  Text(
                    done
                        ? l10n.progDone
                        : locked ? 'Débloquer avec Pro' : l10n.progStart,
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

// ══════════════════════════════════════════════════════════════════════════════
// Coach Profile Bottom Sheet
// ══════════════════════════════════════════════════════════════════════════════

void showCoachProfileSheet(BuildContext context, {required CoachModel coach, required bool dark}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CoachProfileSheet(coach: coach, dark: dark),
  );
}

class _CoachProfileSheet extends StatefulWidget {
  final CoachModel coach;
  final bool dark;
  const _CoachProfileSheet({required this.coach, required this.dark});

  @override
  State<_CoachProfileSheet> createState() => _CoachProfileSheetState();
}

class _CoachProfileSheetState extends State<_CoachProfileSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  List<HomeProgramModel> _coachPrograms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic)));
    _loadCoachPrograms();
  }

  Future<void> _loadCoachPrograms() async {
    final all = await ProgramService.fetchAll();
    setState(() {
      _coachPrograms = all.where((p) => p.coach?.id == widget.coach.id).toList();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final dark = widget.dark;
    final coach = widget.coach;
    final bg = dark ? const Color(0xFF0D0D0D) : Colors.white;
    final cardBg = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final t1 = dark ? Colors.white : const Color(0xFF1A1A1A);
    final t2 = dark ? Colors.white.withValues(alpha: 0.55) : const Color(0xFF6B7280);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(children: [
        // Drag handle
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: t2.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              const SizedBox(height: 12),

              // ── Hero section ──
              FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Column(children: [
                    // Avatar with glow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.25),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Container(
                        width: 110, height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accent.withValues(alpha: 0.4), width: 3),
                        ),
                        child: ClipOval(
                          child: coach.avatarUrl.isNotEmpty
                              ? Image.network(coach.avatarUrl, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _avatarFallback(coach, accent))
                              : _avatarFallback(coach, accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Name
                    Text(coach.name,
                        style: GoogleFonts.outfit(
                            color: t1,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 6),

                    // Title
                    Text(coach.title,
                        style: GoogleFonts.inter(
                            color: t2,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CoachStatPill(icon: LucideIcons.star, value: '${coach.rating}', label: 'Note', accent: accent, dark: dark),
                        const SizedBox(width: 12),
                        _CoachStatPill(icon: LucideIcons.messageCircle, value: '${coach.reviewsCount}', label: 'Avis', accent: accent, dark: dark),
                        const SizedBox(width: 12),
                        _CoachStatPill(icon: LucideIcons.dumbbell, value: _loading ? '...' : '${_coachPrograms.length}', label: 'Programmes', accent: accent, dark: dark),
                      ],
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 28),

              // ── Bio section ──
              if (coach.bio.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: dark ? 0.2 : 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(LucideIcons.quote, size: 16, color: accent),
                          const SizedBox(width: 8),
                          Text('À propos',
                              style: GoogleFonts.outfit(
                                  color: t1,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ]),
                        const SizedBox(height: 12),
                        Text(coach.bio,
                            style: GoogleFonts.inter(
                                color: t2,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                height: 1.6)),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // ── Programs by this coach ──
              if (!_loading && _coachPrograms.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(children: [
                    Container(
                      width: 3, height: 20,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Ses programmes',
                        style: GoogleFonts.outfit(
                            color: t1,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3)),
                  ]),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _coachPrograms.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final prog = _coachPrograms[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => WorkoutDetailScreen(program: prog)));
                        },
                        child: Container(
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(fit: StackFit.expand, children: [
                              prog.imageUrl.startsWith('http')
                                  ? Image.network(prog.imageUrl, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: accent.withValues(alpha: 0.15)))
                                  : Image.asset(prog.imageUrl, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: accent.withValues(alpha: 0.15))),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.85),
                                    ],
                                    stops: const [0.4, 1.0],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 12, right: 12, bottom: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(prog.name,
                                        maxLines: 2,
                                        style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            height: 1.2)),
                                    const SizedBox(height: 4),
                                    Text(prog.duration,
                                        style: GoogleFonts.inter(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Instagram button ──
              if (coach.instagram.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: () {
                      final handle = coach.instagram.replaceAll('@', '');
                      launchUrl(Uri.parse('https://instagram.com/$handle'),
                          mode: LaunchMode.externalApplication);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFE1306C),
                            const Color(0xFFC13584),
                            const Color(0xFF833AB4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC13584).withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.camera, color: Colors.white, size: 18),
                          const SizedBox(width: 10),
                          Text('Suivre @${coach.instagram.replaceAll('@', '')}',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _avatarFallback(CoachModel coach, Color accent) => Container(
    color: accent,
    child: Center(child: Text(
      coach.name.isNotEmpty ? coach.name[0].toUpperCase() : 'C',
      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
    )),
  );
}

class _CoachStatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final bool dark;

  const _CoachStatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final t1 = dark ? Colors.white : const Color(0xFF1A1A1A);
    final t2 = dark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: [
        Icon(icon, size: 16, color: accent),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.outfit(
                color: t1,
                fontSize: 17,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: GoogleFonts.inter(
                color: t2,
                fontSize: 10.5,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
