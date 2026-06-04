import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/screens/workout/favoritesheet.dart';
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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workouts     = ref.watch(workoutsProvider);
    final cycle        = ref.watch(cycleProvider);
    final bodyZones    = ref.watch(bodyZonesProvider);
    final sallePrograms = ref.watch(salleProgramsProvider);
    final homePrograms = ref.watch(homeProgramsProvider);
    final allPrograms = [...sallePrograms, ...homePrograms];

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
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Workouts',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.favorite_rounded,
                    color: WorkoutColors.grossesse,
                    size: 26,
                  ),
<<<<<<< Updated upstream
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FavoritesScreen(
                        initialFavorites: _favorites,
                        onToggleFav: _toggleFav,
                      ),
                    ),
=======
                  onPressed: () => openFavoritesSheet(
                    context,
                    workouts,
                    allPrograms,
                    _favorites,
>>>>>>> Stashed changes
                  ),
                ),
                if (_favorites.isNotEmpty)
                  Positioned(
                    top: 6, right: 6,
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
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Phase Banner ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                        colorScheme.primary.withOpacity(0.9),
                        colorScheme.secondary.withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
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
                            color: colorScheme.onPrimary.withOpacity(0.15),
                          shape: BoxShape.circle),
                      child: const Text('🌿',
                          style: TextStyle(fontSize: 22)),
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
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                    color: color.withValues(alpha: 0.38),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4))
                              ]
                            : [],
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
                  color: const Color(0xFF6B7280),
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