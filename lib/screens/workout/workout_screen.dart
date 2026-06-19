import 'dart:ui';
import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/screens/workout/widgets/DanceSection.dart';
import 'package:fiteva/screens/workout/widgets/GrossesseSection.dart';
import 'package:fiteva/screens/workout/widgets/MaisonSection.dart';
import 'package:fiteva/screens/workout/widgets/RecuperationSection.dart';
import 'package:fiteva/screens/workout/widgets/SalleSection.dart';
import 'package:fiteva/screens/workout/widgets/ZonesSection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/workout_model.dart';
import '../../providers/mock_data_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/workout_progress_provider.dart';
import 'favorites_screen.dart';
import 'theme/color.dart';
import 'theme/cycle_theme.dart';
import 'programme_detail_screen.dart';
import 'active_workout_screen.dart';
import 'weekly_plan_screen.dart';

// ═══════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  int _selectedChip = 0;
  CyclePhase? _selectedPhase;
  final _scrollController = ScrollController();

  final _keySalle     = GlobalKey();
  final _keyMaison    = GlobalKey();
  final _keyDance     = GlobalKey();
  final _keyRecup     = GlobalKey();
  final _keyZones     = GlobalKey();
  final _keyGrossesse = GlobalKey();

  static const _chipIcons = [
    LucideIcons.layoutGrid,
    LucideIcons.dumbbell,
    LucideIcons.house,
    LucideIcons.music,
    LucideIcons.wind,
    LucideIcons.heart,
  ];

  static const _chipColors = [
    WorkoutColors.zone,
    WorkoutColors.salle,
    WorkoutColors.maison,
    WorkoutColors.dance,
    WorkoutColors.recuperation,
    WorkoutColors.grossesse,
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void _onChipTap(int index) {
    setState(() => _selectedChip = index);
    final keys = [null, _keySalle, _keyMaison, _keyDance, _keyRecup, _keyGrossesse];
    if (index == 0) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    } else if (index < keys.length && keys[index] != null) {
      Future.delayed(const Duration(milliseconds: 100),
          () => _scrollToKey(keys[index]!));
    }
  }

  void _showProgramsSheet({
    required String title,
    required Color color,
    required IconData icon,
    required List<HomeProgramModel> programs,
    required String category,
  }) {
    final favorites = ref.read(favoritesProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProgramsFilterSheet(
        title: title,
        color: color,
        icon: icon,
        programs: programs,
        favorites: favorites,
        onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
        onSelectProgram: (p) {
          Navigator.pop(ctx);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => WorkoutDetailScreen(program: p)));
        },
      ),
    );
  }

  void _showWorkoutsSheet({
    required String title,
    required Color color,
    required IconData icon,
    required List<WorkoutModel> workouts,
  }) {
    final favorites = ref.read(favoritesProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WorkoutsFilterSheet(
        title: title,
        color: color,
        icon: icon,
        workouts: workouts,
        favorites: favorites,
        onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
        onSelectWorkout: (w) {
          Navigator.pop(ctx);
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(workout: w)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final dark      = Theme.of(context).brightness == Brightness.dark;
    final l10n      = ref.watch(l10nProvider);
    final workouts  = ref.watch(workoutsProvider);
    final cycle     = ref.watch(cycleProvider);
    final bodyZones = ref.watch(bodyZonesProvider);
    final sallePrograms       = ref.watch(salleProgramsProvider);
    final homePrograms        = ref.watch(homeProgramsProvider);
    final dancePrograms       = ref.watch(danceProgramsProvider);
    final recuperationPrograms = ref.watch(recuperationProgramsProvider);
    final grossessePrograms   = ref.watch(grossesseProgramsProvider);
    final favorites = ref.watch(favoritesProvider);

    final screenH  = MediaQuery.of(context).size.height;
    final bottomGap = screenH < 700 ? 80.0 : 110.0;

    bool matchesPhase(String phases) {
      if (_selectedPhase == null) return true;
      return parseCyclePhases(phases).contains(_selectedPhase);
    }

    List<HomeProgramModel> fp(List<HomeProgramModel> list) =>
        list.where((p) => matchesPhase(p.phases)).toList();

    final filteredSalle       = fp(sallePrograms);
    final filteredMaison      = fp(homePrograms);
    final filteredDance       = fp(dancePrograms);
    final filteredRecuperation = fp(recuperationPrograms);
    final filteredGrossesse   = fp(grossessePrograms);

    final chips = [
      l10n.workoutChipAll,
      l10n.workoutChipSalle,
      l10n.workoutChipMaison,
      l10n.workoutChipDance,
      l10n.workoutChipRecup,
      l10n.workoutChipGrossesse,
    ];

    final bg = dark ? const Color(0xFF0D0D0D) : const Color.fromARGB(255, 255, 255, 255);

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ────────────────────────────────────────────────────
            _WorkoutHeader(
              favorites: favorites,
              onFavTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen())),
              onCalTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WeeklyPlanScreen())),
            ),

            // ── Phase Hero Card ───────────────────────────────────────────
            _PhaseBanner(cycle: cycle, dark: dark, cs: cs),

            const SizedBox(height: 22),

            // ── Category chips ────────────────────────────────────────────
            _CategoryChips(
              chips: chips,
              icons: _chipIcons,
              colors: _chipColors,
              selected: _selectedChip,
              onTap: _onChipTap,
            ),

            const SizedBox(height: 18),

            // ── Phase filter ──────────────────────────────────────────────
            _PhaseFilterRow(
              selected: _selectedPhase,
              onSelect: (p) =>
                  setState(() => _selectedPhase = _selectedPhase == p ? null : p),
              l10n: l10n,
            ),

            const SizedBox(height: 8),

            // ── Sections ──────────────────────────────────────────────────
            if (filteredSalle.isNotEmpty) ...[
              KeyedSubtree(
                key: _keySalle,
                child: SalleSection(
                  sallePrograms: filteredSalle,
                  favorites: favorites,
                  onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
                  onSeeAll: () => _showProgramsSheet(
                    title: l10n.workoutSalleTitle,
                    color: WorkoutColors.salle,
                    icon: LucideIcons.dumbbell,
                    programs: filteredSalle,
                    category: 'SALLE',
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            if (filteredMaison.isNotEmpty) ...[
              KeyedSubtree(
                key: _keyMaison,
                child: MaisonSection(
                  homePrograms: filteredMaison,
                  favorites: favorites,
                  onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
                  onSeeAll: () => _showProgramsSheet(
                    title: l10n.workoutMaisonTitle,
                    color: WorkoutColors.maison,
                    icon: LucideIcons.house,
                    programs: filteredMaison,
                    category: 'MAISON',
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            if (filteredDance.isNotEmpty) ...[
              KeyedSubtree(
                key: _keyDance,
                child: DanceSection(
                  dancePrograms: filteredDance,
                  favorites: favorites,
                  onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
                  onSeeAll: () => _showProgramsSheet(
                    title: l10n.workoutDanceTitle,
                    color: WorkoutColors.dance,
                    icon: LucideIcons.music,
                    programs: filteredDance,
                    category: 'DANCE',
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            if (filteredRecuperation.isNotEmpty) ...[
              KeyedSubtree(
                key: _keyRecup,
                child: RecuperationSection(
                  recuperationPrograms: filteredRecuperation,
                  favorites: favorites,
                  onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
                  onSeeAll: () => _showProgramsSheet(
                    title: l10n.workoutRecupTitle,
                    color: WorkoutColors.recuperation,
                    icon: LucideIcons.wind,
                    programs: filteredRecuperation,
                    category: 'RECUPERATION',
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            if (filteredGrossesse.isNotEmpty) ...[
              KeyedSubtree(
                key: _keyGrossesse,
                child: GrossesseSection(
                  grossessePrograms: filteredGrossesse,
                  favorites: favorites,
                  onToggleFav: (id) => ref.read(favoritesProvider.notifier).toggleFavorite(id),
                  onSeeAll: () => _showProgramsSheet(
                    title: l10n.workoutGrossesseTitle,
                    color: WorkoutColors.grossesse,
                    icon: LucideIcons.heart,
                    programs: filteredGrossesse,
                    category: 'GROSSESSE',
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],

            KeyedSubtree(
              key: _keyZones,
              child: ZonesSection(bodyZones: bodyZones),
            ),

            SizedBox(height: bottomGap),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HEADER
// ══════════════════════════════════════════════════════════════════════════════
class _WorkoutHeader extends StatelessWidget {
  final Set<String> favorites;
  final VoidCallback onFavTap;
  final VoidCallback onCalTap;
  const _WorkoutHeader(
      {required this.favorites, required this.onFavTap, required this.onCalTap});

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFF1C4D30);

    return Container(
      color: dark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F5F3),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      child: Row(
        children: [
          // Left — title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                        color: accent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 7),
                  Text('MES ENTRAÎNEMENTS',
                      style: GoogleFonts.inter(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5)),
                ]),
                const SizedBox(height: 6),
                Text('Workout',
                    style: GoogleFonts.outfit(
                        color: cs.onSurface,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                        height: 1.0)),
              ],
            ),
          ),

          // Right — action buttons
          _HeaderBtn(
            icon: LucideIcons.heart,
            color: WorkoutColors.grossesse,
            badge: favorites.isNotEmpty ? '${favorites.length}' : null,
            onTap: onFavTap,
            dark: dark,
          ),
          const SizedBox(width: 10),
          _HeaderBtn(
            icon: LucideIcons.calendarDays,
            color: accent,
            onTap: onCalTap,
            dark: dark,
          ),
        ],
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? badge;
  final VoidCallback onTap;
  final bool dark;
  const _HeaderBtn(
      {required this.icon,
      required this.color,
      required this.onTap,
      required this.dark,
      this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xFF1A1A1A)
                  : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                  color: color.withValues(alpha: 0.20)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? 0.25 : 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          if (badge != null)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle),
                child: Text(badge!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800)),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PHASE BANNER
// ══════════════════════════════════════════════════════════════════════════════
class _PhaseBanner extends StatelessWidget {
  final CycleStatus cycle;
  final bool dark;
  final ColorScheme cs;
  const _PhaseBanner(
      {required this.cycle, required this.dark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withValues(alpha: 0.95),
              cs.secondary.withValues(alpha: 0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: cs.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phase pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.30)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('PHASE ${cycle.name.toUpperCase()}',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4)),
                  ]),
                ),
                const SizedBox(height: 10),
                Text(cycle.advice,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.55)),
                const SizedBox(height: 12),
                // CTA link
                Row(children: [
                  Text('Voir mes séances recommandées',
                      style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Icon(LucideIcons.arrowRight,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.80)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Icon bubble
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Center(
                    child: Text('🌿', style: TextStyle(fontSize: 28))),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CATEGORY CHIPS
// ══════════════════════════════════════════════════════════════════════════════
class _CategoryChips extends StatelessWidget {
  final List<String> chips;
  final List<IconData> icons;
  final List<Color> colors;
  final int selected;
  final void Function(int) onTap;

  const _CategoryChips({
    required this.chips,
    required this.icons,
    required this.colors,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chips.length,
        itemBuilder: (_, i) {
          final sel   = selected == i;
          final color = colors[i];
          final cardBg = dark ? const Color(0xFF1A1A1A) : Colors.white;

          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: sel ? color : cardBg,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: sel ? color : color.withValues(alpha: 0.20),
                  width: 1.5,
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]
                    : [
                        BoxShadow(
                            color: Colors.black
                                .withValues(alpha: dark ? 0.25 : 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icons[i],
                    size: 14,
                    color: sel ? Colors.white : color),
                const SizedBox(width: 8),
                Text(chips[i],
                    style: GoogleFonts.inter(
                        color: sel ? Colors.white : color,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PHASE FILTER ROW
// ══════════════════════════════════════════════════════════════════════════════
class _PhaseFilterRow extends StatelessWidget {
  final CyclePhase? selected;
  final void Function(CyclePhase) onSelect;
  final AppL10n l10n;
  const _PhaseFilterRow(
      {required this.selected, required this.onSelect, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Label row
        Row(children: [
          Text('Filtrer par phase',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withValues(alpha: 0.45),
                  letterSpacing: 0.3)),
          if (selected != null) ...[
            const Spacer(),
            GestureDetector(
              onTap: () => onSelect(selected!),
              child: Row(children: [
                Icon(LucideIcons.x, size: 11, color: selected!.color),
                const SizedBox(width: 4),
                Text(l10n.workoutShowAll,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected!.color)),
              ]),
            ),
          ],
        ]),
        const SizedBox(height: 10),
        // Phase chips
        Row(
          children: CyclePhase.values.map((phase) {
            final isSel = selected == phase;
            final isLast = phase == CyclePhase.values.last;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(phase),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: isLast ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSel
                        ? phase.color
                        : dark
                            ? const Color(0xFF1A1A1A)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSel
                          ? phase.color
                          : phase.color.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                                color: phase.color.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]
                        : [
                            BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: dark ? 0.25 : 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2))
                          ],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSel ? Colors.white : phase.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(phase.label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : phase.color,
                            letterSpacing: 0.1)),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEETS (unchanged logic, same design)
// ══════════════════════════════════════════════════════════════════════════════
class _ProgramsFilterSheet extends ConsumerStatefulWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<HomeProgramModel> programs;
  final Set<String> favorites;
  final void Function(String) onToggleFav;
  final void Function(HomeProgramModel) onSelectProgram;

  const _ProgramsFilterSheet({
    required this.title,
    required this.color,
    required this.icon,
    required this.programs,
    required this.favorites,
    required this.onToggleFav,
    required this.onSelectProgram,
  });

  @override
  ConsumerState<_ProgramsFilterSheet> createState() =>
      _ProgramsFilterSheetState();
}

class _ProgramsFilterSheetState
    extends ConsumerState<_ProgramsFilterSheet> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<HomeProgramModel> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return widget.programs;
    return widget.programs.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, ctrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          _SheetHandle(
              title: widget.title,
              color: widget.color,
              icon: widget.icon,
              onClose: () => Navigator.pop(context)),
          _SearchBar(
              ctrl: _searchCtrl,
              color: widget.color,
              hint: l10n.workoutSearchHint,
              onChanged: () => setState(() {})),
          Expanded(
            child: _filtered.isEmpty
                ? _EmptySearch(label: l10n.workoutNoProgramFound)
                : ListView.builder(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final p = _filtered[i];
                      return _ProgramTile(
                        imageUrl: p.imageUrl,
                        title: p.name,
                        subtitle: '${p.duration} · ${p.sessions}',
                        phases: p.phases,
                        color: widget.color,
                        isFav: widget.favorites.contains(p.name),
                        onToggleFav: () => widget.onToggleFav(p.name),
                        onTap: () => widget.onSelectProgram(p),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

class _WorkoutsFilterSheet extends ConsumerStatefulWidget {
  final String title;
  final Color color;
  final IconData icon;
  final List<WorkoutModel> workouts;
  final Set<String> favorites;
  final void Function(String) onToggleFav;
  final void Function(WorkoutModel) onSelectWorkout;

  const _WorkoutsFilterSheet({
    required this.title,
    required this.color,
    required this.icon,
    required this.workouts,
    required this.favorites,
    required this.onToggleFav,
    required this.onSelectWorkout,
  });

  @override
  ConsumerState<_WorkoutsFilterSheet> createState() =>
      _WorkoutsFilterSheetState();
}

class _WorkoutsFilterSheetState
    extends ConsumerState<_WorkoutsFilterSheet> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<WorkoutModel> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return widget.workouts;
    return widget.workouts.where((w) => w.title.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, ctrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          _SheetHandle(
              title: widget.title,
              color: widget.color,
              icon: widget.icon,
              onClose: () => Navigator.pop(context)),
          _SearchBar(
              ctrl: _searchCtrl,
              color: widget.color,
              hint: l10n.workoutSearchHint,
              onChanged: () => setState(() {})),
          Expanded(
            child: _filtered.isEmpty
                ? _EmptySearch(label: l10n.workoutNoWorkoutFound)
                : ListView.builder(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final w = _filtered[i];
                      return _ProgramTile(
                        imageUrl: w.imageUrl,
                        title: w.title,
                        subtitle: '${w.duration} · ${w.level}',
                        phases: w.phases,
                        color: widget.color,
                        isFav: widget.favorites.contains(w.id),
                        onToggleFav: () => widget.onToggleFav(w.id),
                        onTap: () => widget.onSelectWorkout(w),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

// ── Shared sheet sub-widgets ──────────────────────────────────────────────────
class _SheetHandle extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onClose;
  const _SheetHandle(
      {required this.title,
      required this.color,
      required this.icon,
      required this.onClose});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2))),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 16, 14),
        child: Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: cs.onSurface,
                      letterSpacing: -0.3))),
          GestureDetector(
              onTap: onClose,
              child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.08),
                      shape: BoxShape.circle),
                  child: Icon(LucideIcons.x,
                      size: 17,
                      color: cs.onSurface.withValues(alpha: 0.55)))),
        ]),
      ),
      Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.10)),
    ]);
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final Color color;
  final String hint;
  final VoidCallback onChanged;
  const _SearchBar(
      {required this.ctrl,
      required this.color,
      required this.hint,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: cs.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: TextField(
          controller: ctrl,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                color: cs.onSurface.withValues(alpha: 0.45), fontSize: 14),
            prefixIcon: Icon(LucideIcons.search, color: color, size: 18),
            suffixIcon: ctrl.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      ctrl.clear();
                      onChanged();
                    },
                    child: Icon(LucideIcons.x,
                        color: cs.onSurface.withValues(alpha: 0.45), size: 18))
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
          style: GoogleFonts.inter(color: cs.onSurface, fontSize: 14),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String label;
  const _EmptySearch({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.search, size: 48, color: cs.onSurface.withValues(alpha: 0.25)),
        const SizedBox(height: 12),
        Text(label,
            style: GoogleFonts.inter(
                color: cs.onSurface.withValues(alpha: 0.45), fontSize: 14)),
      ]),
    );
  }
}

class _ProgramTile extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String phases;
  final Color color;
  final bool isFav;
  final VoidCallback onToggleFav;
  final VoidCallback onTap;

  const _ProgramTile({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.phases,
    required this.color,
    required this.isFav,
    required this.onToggleFav,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
                color: cs.shadow.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(18)),
            child: Image.asset(imageUrl,
                width: 82,
                height: 82,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: 82,
                    height: 82,
                    color: color.withValues(alpha: 0.12))),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: cs.onSurface,
                          letterSpacing: -0.2)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.50))),
                  if (phases.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(phases,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: color)),
                    ),
                  ],
                ]),
          )),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(LucideIcons.chevronRight,
                size: 16, color: color.withValues(alpha: 0.70)),
          ),
        ]),
      ),
    );
  }
}
