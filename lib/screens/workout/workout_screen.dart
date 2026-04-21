import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/workout_model.dart';
import '../../providers/mock_data_provider.dart';
import '../../theme/app_theme.dart';
import 'workout_detail_screen.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  int _selectedCategory = 0;
  bool _showAllWorkouts = false;

  final List<Map<String, dynamic>> categories = [
    {'label': 'Tout', 'emoji': '⚡'},
    {'label': 'Muscu', 'emoji': '💪'},
    {'label': 'Pilates', 'emoji': '🧘'},
    {'label': 'HIIT', 'emoji': '🔥'},
    {'label': 'Danse', 'emoji': '💃'},
    {'label': 'Running', 'emoji': '🏃'},
  ];

  Color _categoryColor(String label) {
    switch (label.toUpperCase()) {
      case 'MUSCULATION': return const Color(0xFFEF5350);
      case 'PILATES': return const Color(0xFF9575CD);
      case 'HIIT': return const Color(0xFFFFB300);
      case 'DANCE': return const Color(0xFFFF6F91);
      case 'YOGA': return const Color(0xFF4DB6AC);
      case 'RUNNING': return const Color(0xFF42A5F5);
      default: return const Color(0xFF90A4AE);
    }
  }

  Color _getCategoryChipColor(int index) {
    if (index == 0) return const Color(0xFF2D4A2D);
    String label = categories[index]['label'];
    return _categoryColor(_mapLabelToCategory(label));
  }

  String _mapLabelToCategory(String label) {
    switch (label) {
      case 'Muscu': return 'MUSCULATION';
      case 'Pilates': return 'PILATES';
      case 'HIIT': return 'HIIT';
      case 'Danse': return 'DANCE';
      case 'Running': return 'RUNNING';
      default: return '';
    }
  }

  List<WorkoutModel> _getFilteredWorkouts(List<WorkoutModel> workouts) {
    if (_selectedCategory == 0) return workouts;
    String categoryFilter = _mapLabelToCategory(categories[_selectedCategory]['label']);
    return workouts.where((w) => w.category.toUpperCase() == categoryFilter).toList();
  }

  List<String> _recommendedCategoriesForPhase(String phaseName) {
    final phase = phaseName.toLowerCase();
    if (phase.contains('follic')) return ['MUSCULATION', 'PILATES', 'DANCE'];
    if (phase.contains('ovul')) return ['HIIT', 'RUNNING', 'DANCE'];
    if (phase.contains('lute') || phase.contains('luteal')) return ['PILATES', 'RUNNING'];
    if (phase.contains('menstr') || phase.contains('period')) return ['PILATES'];
    return ['PILATES', 'RUNNING'];
  }

  List<WorkoutModel> _getPhaseRecommendedWorkouts(List<WorkoutModel> workouts, String phaseName) {
    final recommendedCategories = _recommendedCategoriesForPhase(phaseName);
    return workouts
        .where((workout) => recommendedCategories.contains(workout.category.toUpperCase()))
        .toList();
  }

  // Gets 1 workout from each available category based on the current filter
  List<WorkoutModel> _getOnePerCategory(List<WorkoutModel> workouts) {
    final Map<String, WorkoutModel> unique = {};
    for (var w in workouts) {
      if (!unique.containsKey(w.category.toUpperCase())) {
        unique[w.category.toUpperCase()] = w;
      }
    }
    return unique.values.toList();
  }

  Widget _buildGroupedCards(List<WorkoutModel> workouts, BuildContext context) {
    final List<List<WorkoutModel>> groups = [];
    for (int i = 0; i < workouts.length; i += 3) {
      groups.add(workouts.sublist(i, (i + 3).clamp(0, workouts.length)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: groups.map((group) => _buildGroup(group, context)).toList(),
    );
  }

  Widget _buildGroup(List<WorkoutModel> group, BuildContext context) {
    final large = group[0];
    final smalls = group.length > 1 ? group.sublist(1) : <WorkoutModel>[];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 11, child: _buildWorkoutCard(large, isLarge: true)),
            const SizedBox(width: 6),
            Expanded(
              flex: 10,
              child: Column(
                children: [
                  if (smalls.isNotEmpty) Expanded(child: _buildWorkoutCard(smalls[0], isLarge: false)),
                  if (smalls.length > 1) ...[
                    const SizedBox(height: 6),
                    Expanded(child: _buildWorkoutCard(smalls[1], isLarge: false)),
                  ],
                  if (smalls.length == 1) ...[
                    const SizedBox(height: 6),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutModel workout, {required bool isLarge, double? width, double? height}) {
    final color = _categoryColor(workout.category);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: width,
          height: height ?? (isLarge ? 220 : 107),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                workout.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade800),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.72)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    workout.category.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      workout.title,
                      style: TextStyle(color: Colors.white, fontSize: isLarge ? 16 : 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout.duration} · ${workout.level}',
                      style: TextStyle(color: Colors.white70, fontSize: isLarge ? 12 : 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridZoneCard(String label, IconData iconData, List<Map<String, dynamic>> providerZones, BuildContext context) {
    
    // Attempt to match the provider item based on the label, default to first item if not found
    final zoneContent = providerZones.firstWhere(
        (z) => z['title'].toString().toLowerCase().contains(label.toLowerCase().split(' ').first), 
        orElse: () => providerZones[0]);

    return GestureDetector(
      onTap: () {
        final workout = WorkoutModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: zoneContent['title'],
          category: 'Zone',
          duration: '15 min',
          level: 'Tous niveaux',
          calories: '150',
          imageUrl: zoneContent['imageUrl'],
          exercises: List<String>.from(zoneContent['exercises']),
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout)),
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(zoneContent['imageUrl']),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(workoutsProvider);
    final cycle = ref.watch(cycleProvider);
    final filteredWorkouts = _getFilteredWorkouts(workouts);
    final phaseRecommendedWorkouts = _getPhaseRecommendedWorkouts(workouts, cycle.name);
    final bodyZones = ref.watch(bodyZonesProvider);
    
    // Core UI Lists
    final swipeWorkouts = _getOnePerCategory(filteredWorkouts);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4A2D),
        elevation: 0,
        title: const Text('Workouts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
          Padding(
  padding: const EdgeInsets.all(16),
  child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFB2DFB2), width: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'PHASE ${cycle.name.toUpperCase()}',
              style: const TextStyle(
                color: Color(0xFF5A8A5A),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          cycle.advice,
          style: const TextStyle(
            color: Color(0xFF1A3A1A),
            fontWeight: FontWeight.w500,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
      /*  Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 14, color: Color(0xFF3A7A3A)),
              const SizedBox(width: 6),
              Text(
                'Jours ${cycle.startDay} – ${cycle.endDay}',
                style: const TextStyle(
                  color: Color(0xFF3A7A3A),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),*/
      ],
    ),
  ),
),

            // Chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategory = index;
                        _showAllWorkouts = false; // Reset to modern view on filter
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? _getCategoryChipColor(index) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isSelected ? _getCategoryChipColor(index) : Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Text(cat['emoji']),
                            const SizedBox(width: 8),
                            Text(cat['label'], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Recommended Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedCategory == 0
                          ? 'Programmes recommandés'
                          : '${categories[_selectedCategory]['label']} workouts',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1A2E1A),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showAllWorkouts = !_showAllWorkouts),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF1A2E1A).withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        _showAllWorkouts ? 'Voir moins' : 'Voir tout',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A2E1A), fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content logic
            if (_showAllWorkouts)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildGroupedCards(filteredWorkouts, context),
              )
            else ...[
              // Modern Horizontal Swipe
              SizedBox(
                height: 260,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: swipeWorkouts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildWorkoutCard(swipeWorkouts[index], isLarge: true, width: 220),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Body Zones Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Vidéos par zone du corps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A2E1A))),
                    Text('Tout voir ›', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryColor)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildGridZoneCard('Abdos', Icons.health_and_safety, bodyZones, context)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildGridZoneCard('Haut du corps', Icons.fitness_center, bodyZones, context)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildGridZoneCard('Bas du corps', Icons.directions_walk, bodyZones, context)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildGridZoneCard('Full body', Icons.accessibility_new, bodyZones, context)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ]
          ],
        ),
      ),
    );
  }
}
