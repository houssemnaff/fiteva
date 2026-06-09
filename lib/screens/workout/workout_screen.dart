import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
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
import 'favorites_screen.dart';
import 'theme/color.dart';
import 'theme/cycle_theme.dart';
import 'workout_detail_screen.dart';
import 'corpszone_playerscreen.dart';




// ═══════════════════════════════════════════════════════════
// MAIN SCREEN — HomeWorkoutScreen
// ═══════════════════════════════════════════════════════════
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {

  final Set<String> _favorites = {};
  int _selectedChip = 0;
  CyclePhase? _selectedPhase;

  final _scrollController = ScrollController();

  // GlobalKeys pour scroll par section
  final _keySalle     = GlobalKey();
  final _keyMaison    = GlobalKey();
  final _keyDance     = GlobalKey();
  final _keyRecup     = GlobalKey();
  final _keyZones     = GlobalKey();
  final _keyGrossesse = GlobalKey();

  final List<String>   _chipLabels = ['Tout', 'Salle', 'Maison', 'Danse', 'Récup.', 'Grossesse'];
  final List<Color>    _chipColors = [
    WorkoutColors.zone, WorkoutColors.salle, WorkoutColors.maison,
    WorkoutColors.dance, WorkoutColors.recuperation, WorkoutColors.grossesse,
  ];
  final List<IconData> _chipIcons  = [
    LucideIcons.layoutGrid,
    LucideIcons.dumbbell,
    LucideIcons.house,
    LucideIcons.music,
    LucideIcons.wind,
    LucideIcons.heart,
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
    final keys = [
      null, _keySalle, _keyMaison, _keyDance, _keyRecup, _keyGrossesse,
    ];
    if (index < keys.length && keys[index] != null) {
      Future.delayed(const Duration(milliseconds: 100),
          () => _scrollToKey(keys[index]!));
    } else if (index == 0) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
  }

  void _toggleFav(String id) {
    setState(() {
      _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
    });
  }

  // ── "Voir tout" bottom sheet — programmes (HomeProgramModel) ─────────────────
  void _showProgramsSheet({
    required String title,
    required Color color,
    required IconData icon,
    required List<HomeProgramModel> programs,
    required String category,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx2, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx2).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _SheetHandle(title: title, color: color, icon: icon, onClose: () => Navigator.pop(ctx)),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: programs.length,
                  itemBuilder: (_, i) {
                    final p = programs[i];
                    return _ProgramTile(
                      imageUrl: p.imageUrl,
                      title: p.name,
                      subtitle: '${p.duration} · ${p.sessions}',
                      phases: p.phases,
                      color: color,
                      isFav: _favorites.contains(p.name),
                      onToggleFav: () => setState(() => _toggleFav(p.name)),
                      onTap: () {
                        Navigator.pop(ctx);
                        final workouts = p.workouts;
                        final calories = workouts.fold<int>(0, (s, w) => s + (int.tryParse(w.calories) ?? 0));
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(
                            workout: WorkoutModel(
                              id: 'prog_${p.name}',
                              title: p.name,
                              category: category,
                              duration: p.duration,
                              level: workouts.isNotEmpty ? workouts.first.level : 'Tous niveaux',
                              calories: calories.toString(),
                              imageUrl: p.imageUrl,
                              exercises: workouts.map((w) => '${w.title} · ${w.duration}').toList(),
                            ),
                          ),
                        ));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── "Voir tout" bottom sheet — workouts (WorkoutModel) ───────────────────────
  void _showWorkoutsSheet({
    required String title,
    required Color color,
    required IconData icon,
    required List<WorkoutModel> workouts,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx2, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx2).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _SheetHandle(title: title, color: color, icon: icon, onClose: () => Navigator.pop(ctx)),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: workouts.length,
                  itemBuilder: (_, i) {
                    final w = workouts[i];
                    return _ProgramTile(
                      imageUrl: w.imageUrl,
                      title: w.title,
                      subtitle: '${w.duration} · ${w.level}',
                      phases: w.phases,
                      color: color,
                      isFav: _favorites.contains(w.id),
                      onToggleFav: () => setState(() => _toggleFav(w.id)),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(workout: w),
                        ));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workouts     = ref.watch(workoutsProvider);
    final cycle        = ref.watch(cycleProvider);
    final bodyZones    = ref.watch(bodyZonesProvider);
    final sallePrograms = ref.watch(salleProgramsProvider);
    final homePrograms = ref.watch(homeProgramsProvider);

    final screenH  = MediaQuery.of(context).size.height;
    final bottomGap = screenH < 700 ? 80.0 : 110.0;

    // Filtrage par catégorie + phase
    bool matchesPhase(String phases) {
      if (_selectedPhase == null) return true;
      return parseCyclePhases(phases).contains(_selectedPhase);
    }

    List<WorkoutModel> byCat(String cat) => workouts
        .where((w) =>
            w.category.toUpperCase() == cat && matchesPhase(w.phases))
        .toList();

    final filteredSalle =
        sallePrograms.where((p) => matchesPhase(p.phases)).toList();
    final filteredMaison =
        homePrograms.where((p) => matchesPhase(p.phases)).toList();

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Common header ─────────────────────────
            SharedAppHeader(
              eyebrow:    'Workout',
              title:      'Mes entraînements',
              accentColor: WorkoutColors.salle,
              actions: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => FavoritesScreen(
                          initialFavorites: _favorites,
                          onToggleFav: _toggleFav,
                        ),
                      )),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: WorkoutColors.grossesse.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.favorite_rounded,
                            size: 18, color: WorkoutColors.grossesse),
                      ),
                    ),
                    if (_favorites.isNotEmpty)
                      Positioned(
                        top: -2, right: -2,
                        child: Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${_favorites.length}',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              )),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // ── Phase Banner ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.92),
                      colorScheme.secondary.withValues(alpha: 0.92),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                                width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: colorScheme.onPrimary,
                                shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('PHASE ${cycle.name.toUpperCase()}',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5)),
                          ]),
                          const SizedBox(height: 6),
                          Text(cycle.advice,
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🌿', style: TextStyle(fontSize: 22)),
                    ),
                  ],
                ),
              ),
            ),

            // ── Chips de navigation ───────────────────
            const SizedBox(height: 18),
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _chipLabels.length,
                itemBuilder: (_, i) {
                  final sel = _selectedChip == i;
                  final color = _chipColors[i];
                  return GestureDetector(
                    onTap: () => _onChipTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      decoration: BoxDecoration(
                        color: sel
                            ? color
                            : color.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: sel
                              ? color
                              : color.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                       
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _chipIcons[i],
                            size: 14,
                            color: sel ? Colors.white : color,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            _chipLabels[i],
                            style: GoogleFonts.inter(
                              color: sel ? Colors.white : color,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Filtre par phase de cycle ─────────────
            _PhaseFilterRow(
              selected: _selectedPhase,
              onSelect: (p) => setState(() =>
                  _selectedPhase = _selectedPhase == p ? null : p),
            ),

            const SizedBox(height: 8),

            // ── Section Salle ─────────────────────────
            if (filteredSalle.isNotEmpty)
              KeyedSubtree(
                key: _keySalle,
                child: SalleSection(
                  sallePrograms: filteredSalle,
                  favorites: _favorites,
                  onToggleFav: _toggleFav,
                  onSeeAll: () => _showProgramsSheet(
                    title: 'Programmes Salle',
                    color: WorkoutColors.salle,
                    icon: LucideIcons.dumbbell,
                    programs: filteredSalle,
                    category: 'SALLE',
                  ),
                ),
              ),

            if (filteredSalle.isNotEmpty) const SizedBox(height: 8),

            // ── Section Maison ────────────────────────
            if (filteredMaison.isNotEmpty)
              KeyedSubtree(
                key: _keyMaison,
                child: MaisonSection(
                  homePrograms: filteredMaison,
                  favorites: _favorites,
                  onToggleFav: _toggleFav,
                  onSeeAll: () => _showProgramsSheet(
                    title: 'Programmes Maison',
                    color: WorkoutColors.maison,
                    icon: LucideIcons.house,
                    programs: filteredMaison,
                    category: 'MAISON',
                  ),
                ),
              ),

            if (filteredMaison.isNotEmpty) const SizedBox(height: 8),

            const SizedBox(height: 8),

            // ── Section Danse ─────────────────────────
            KeyedSubtree(
              key: _keyDance,
              child: DanceSection(
                danceWorkouts: byCat('DANCE'),
                favorites: _favorites,
                onToggleFav: _toggleFav,
                onSeeAll: () => _showWorkoutsSheet(
                  title: 'Danse & Cardio',
                  color: WorkoutColors.dance,
                  icon: LucideIcons.music,
                  workouts: byCat('DANCE'),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Section Récupération ──────────────────
            KeyedSubtree(
              key: _keyRecup,
              child: RecuperationSection(
                recupWorkouts: byCat('RECUPERATION'),
                favorites: _favorites,
                onToggleFav: _toggleFav,
                onSeeAll: () => _showWorkoutsSheet(
                  title: 'Récupération',
                  color: WorkoutColors.recuperation,
                  icon: LucideIcons.wind,
                  workouts: byCat('RECUPERATION'),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Section Grossesse ─────────────────────
            KeyedSubtree(
              key: _keyGrossesse,
              child: GrossesseSection(
                grossesseWorkouts: byCat('GROSSESSE'),
                favorites: _favorites,
                onToggleFav: _toggleFav,
                onSeeAll: () => _showWorkoutsSheet(
                  title: 'Grossesse',
                  color: WorkoutColors.grossesse,
                  icon: LucideIcons.heart,
                  workouts: byCat('GROSSESSE'),
                ),
              ),
            ),


            const SizedBox(height: 8),

           // ── Section Zones du corps ────────────────
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

// ── Sheet header handle ───────────────────────────────────────────────────────
class _SheetHandle extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onClose;
  const _SheetHandle({required this.title, required this.color, required this.icon, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40, height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: cs.onSurface.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800, fontSize: 20,
                  color: cs.onSurface, letterSpacing: -0.3,
                )),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 18, color: cs.onSurface.withValues(alpha: 0.55)),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.10)),
      ],
    );
  }
}

// ── Program list tile (utilisé dans les bottom sheets) ───────────────────────
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
          boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.asset(imageUrl, width: 80, height: 80, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: color.withValues(alpha: 0.12))),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15,
                        color: cs.onSurface, letterSpacing: -0.2)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55))),
                    if (phases.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(phases, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(LucideIcons.chevronRight, size: 16, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Phase filter row ──────────────────────────────────────────────────────────
class _PhaseFilterRow extends StatelessWidget {
  final CyclePhase? selected;
  final void Function(CyclePhase) onSelect;
  const _PhaseFilterRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Container(
                width: 14,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFB39DDB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Phase du cycle',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                  letterSpacing: 0.2,
                ),
              ),
              if (selected != null) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () => onSelect(selected!),
                  child: Text(
                    'Tout afficher',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected!.color,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Phase chips
          Row(
            children: CyclePhase.values.map((phase) {
              final isSel = selected == phase;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(phase),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: phase != CyclePhase.values.last ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isSel
                          ? phase.color
                          : phase.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSel
                            ? phase.color
                            : phase.color.withValues(alpha: 0.30),
                        width: 1.5,
                      ),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: phase.color.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSel
                                ? Colors.white
                                : phase.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          phase.label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : phase.color,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}