import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/screens/workout/widgets/DanceSection.dart';
import 'package:fiteva/screens/workout/widgets/GrossesseSection.dart';
import 'package:fiteva/screens/workout/widgets/MaisonSection.dart';
import 'package:fiteva/screens/workout/widgets/RecuperationSection.dart';
import 'package:fiteva/screens/workout/widgets/SalleSection.dart';
import 'package:fiteva/screens/workout/widgets/ZonesSection.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/workout_model.dart';
import '../../providers/mock_data_provider.dart';
import 'theme/color.dart';
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

  final _scrollController = ScrollController();

  // GlobalKeys pour scroll par section
  final _keySalle     = GlobalKey();
  final _keyMaison    = GlobalKey();
  final _keyDance     = GlobalKey();
  final _keyRecup     = GlobalKey();
  final _keyZones     = GlobalKey();
  final _keyGrossesse = GlobalKey();

  final List<String>   _chipLabels = ['Tout','Salle','Maison','Danse','Récup.','Grossesse'];
  final List<Color>    _chipColors = [
    WorkoutColors.zone, WorkoutColors.salle, WorkoutColors.maison, WorkoutColors.dance, WorkoutColors.recuperation, WorkoutColors.grossesse,
  ];
  final List<IconData> _chipIcons  = [
    Icons.bolt_rounded, Icons.fitness_center_rounded, Icons.home_rounded,
    Icons.music_note_rounded, Icons.self_improvement_rounded, Icons.favorite_rounded,
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

    final screenH  = MediaQuery.of(context).size.height;
    final bottomGap = screenH < 700 ? 80.0 : 110.0;

    // Filtrage par catégorie
    List<WorkoutModel> byCat(String cat) =>
        workouts.where((w) => w.category.toUpperCase() == cat).toList();

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
                  onPressed: () {},
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
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _chipLabels.length,
                itemBuilder: (_, i) {
                  final sel = _selectedChip == i;
                  return GestureDetector(
                    onTap: () => _onChipTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? _chipColors[i] : colorScheme.surface,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: sel ? _chipColors[i] : colorScheme.outlineVariant),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                    color: _chipColors[i].withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2))
                              ]
                            : [],
                      ),
                      child: Row(children: [
                        Icon(_chipIcons[i],
                          color: sel
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withOpacity(0.72),
                            size: 16),
                        const SizedBox(width: 6),
                        Text(_chipLabels[i],
                            style: TextStyle(
                            color: sel
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withOpacity(0.82),
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ]),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // ── Section Salle ─────────────────────────
            KeyedSubtree(
              key: _keySalle,
              child: SalleSection(
                sallePrograms: sallePrograms,
                favorites: _favorites,
                onToggleFav: _toggleFav,
              ),
            ),

            const SizedBox(height: 8),

            // ── Section Maison ────────────────────────
            KeyedSubtree(
              key: _keyMaison,
              child: MaisonSection(
                homePrograms: homePrograms,
                favorites: _favorites,
                onToggleFav: _toggleFav,
              ),
            ),

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