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
  // ── Builds groups of 3: 1 large left + 2 small right
Widget _buildGroupedCards(List<WorkoutModel> workouts, BuildContext context) {
  final List<List<WorkoutModel>> groups = [];
  for (int i = 0; i < workouts.length; i += 3) {
    groups.add(workouts.sublist(i, (i + 3).clamp(0, workouts.length)));
  }

  return Column(
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
          // Large card
          Expanded(
            flex: 11,
            child: _buildWorkoutCard(large, isLarge: true, context: context),
          ),
          const SizedBox(width: 6),
          // Two small cards
          Expanded(
            flex: 10,
            child: Column(
              children: [
                if (smalls.isNotEmpty)
                  Expanded(
                    child: _buildWorkoutCard(smalls[0], isLarge: false, context: context),
                  ),
                if (smalls.length > 1) ...[
                  const SizedBox(height: 6),
                  Expanded(
                    child: _buildWorkoutCard(smalls[1], isLarge: false, context: context),
                  ),
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

Widget _buildWorkoutCard(
  WorkoutModel workout, {
  required bool isLarge,
  required BuildContext context,
}) {
  final color = _categoryColor(workout.category.toUpperCase());

  return GestureDetector(
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutDetailScreen(workout: workout),
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: isLarge ? 220 : 107,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              workout.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey.shade800),
            ),

            // Dark gradient
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.72),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

            // Category badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  workout.category.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),

            // Title + meta
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    workout.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isLarge ? 15 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${workout.duration} · ${workout.calories} kcal · ${workout.level}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: isLarge ? 11 : 9.5,
                    ),
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
    case 'MUSCULATION': return const Color(0xFFEF5350); // rouge énergique
    case 'PILATES': return const Color(0xFF9575CD); // violet soft
    case 'HIIT': return const Color(0xFFFFB300); // jaune/orange dynamique
    case 'DANCE': return const Color(0xFFFF6F91); // rose moderne
    case 'YOGA': return const Color(0xFF4DB6AC); // teal relax
    case 'RUNNING': return const Color(0xFF42A5F5); // bleu frais
    default: return const Color(0xFF90A4AE); // gris fallback
  }
}

Color _arrowBgColor(String category) {
  switch (category.toUpperCase()) {
    case 'MUSCULATION': return const Color(0xFFE57373);
    case 'PILATES': return const Color(0xFFB39DDB);
    case 'HIIT': return const Color(0xFFFFCA28);
    case 'DANCE': return const Color(0xFFFF8DA1);
    case 'YOGA': return const Color(0xFF80CBC4);
    case 'RUNNING': return const Color(0xFF64B5F6);
    default: return const Color(0xFFB0BEC5);
  }
}

  Color _getCategoryChipColor(int index) {
    if (index == 0) {
      return const Color(0xFF2D4A2D); // Tout - green
    }
    String label = categories[index]['label'];
    String categoryName = _mapLabelToCategory(label);
    return _categoryColor(categoryName);
  }

  String _getCategoryLabel(int index) {
    if (index == 0) return 'Tout'; // All
    return categories[index]['label'];
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
    if (_selectedCategory == 0) {
      return workouts; // 'Tout' shows all
    }
    
    String selectedLabel = categories[_selectedCategory]['label'];
    String categoryFilter = _mapLabelToCategory(selectedLabel);
    
    return workouts
        .where((workout) => workout.category.toUpperCase() == categoryFilter)
        .toList();
  }

  List<String> _recommendedCategoriesForPhase(String phaseName) {
    final phase = phaseName.toLowerCase();

    if (phase.contains('follic')) {
      return ['MUSCULATION', 'PILATES', 'DANCE'];
    }
    if (phase.contains('ovul')) {
      return ['HIIT', 'RUNNING', 'DANCE'];
    }
    if (phase.contains('lute') || phase.contains('luteal')) {
      return ['PILATES', 'RUNNING'];
    }
    if (phase.contains('menstr') || phase.contains('period')) {
      return ['PILATES'];
    }

    return ['PILATES', 'RUNNING'];
  }

  List<WorkoutModel> _getPhaseRecommendedWorkouts(
    List<WorkoutModel> workouts,
    String phaseName,
  ) {
    final recommendedCategories = _recommendedCategoriesForPhase(phaseName);
    return workouts
        .where(
          (workout) =>
              recommendedCategories.contains(workout.category.toUpperCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(workoutsProvider);
    final cycle = ref.watch(cycleProvider);
    final filteredWorkouts = _getFilteredWorkouts(workouts);
    final phaseRecommendedWorkouts = _getPhaseRecommendedWorkouts(
      workouts,
      cycle.name,
    );
    final recommended = _selectedCategory == 0
        ? workouts.take(2).toList()
        : filteredWorkouts.take(2).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar:  AppBar(
        backgroundColor: const Color(0xFF2D4A2D),
        elevation: 0,
        title: const Text(
          'Workouts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.info, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PHASE ${cycle.name.toUpperCase()}',
                            style: TextStyle(
                              color: Color(0xFF7A9A7A),
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            cycle.advice,
                            style: TextStyle(
                              color: Color(0xFF1A2E1A),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Recommandé pour toi aujourd'hui",
                            style: TextStyle(
                              color: Color(0xFF7A9A7A),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text('🌱', style: TextStyle(fontSize: 40)),
                  ],
                ),
              ),
            ),

            // Recommended for current phase
            if (phaseRecommendedWorkouts.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: const [
                    Text(
                      'Recommandé pour ta phase',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1A2E1A),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text('🌿', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildGroupedCards(
                  phaseRecommendedWorkouts.take(3).toList(),
                  context,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Category chips
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = _selectedCategory == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? _getCategoryChipColor(index) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? _getCategoryChipColor(index) : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(cat['emoji'], style: const TextStyle(fontSize: 15)),
                            const SizedBox(width: 6),
                            Text(
                              cat['label'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Recommended section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    _selectedCategory == 0 
                      ? 'tous les workouts '
                      : '${categories[_selectedCategory]['label']} workouts ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1A2E1A),
                    ),
                  ),
                  Text(_selectedCategory == 0 ? '✨' : '💪', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),

            // Recommended 2-column grid
            if (recommended.isNotEmpty)
            // ── Séances du jour header


// ── Dynamic grouped cards (1 large + 2 small)
if (filteredWorkouts.isNotEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: _buildGroupedCards(filteredWorkouts, context),
  ),


          ],
        ),
      ),
    );
  }
}