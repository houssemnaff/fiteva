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

  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(workoutsProvider);
    final filteredWorkouts = _getFilteredWorkouts(workouts);
    final recommended = _selectedCategory == 0 ? workouts.take(2).toList() : filteredWorkouts.take(2).toList();

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
                        children: const [
                          Text(
                            'PHASE FOLLICULAIRE',
                            style: TextStyle(
                              color: Color(0xFF7A9A7A),
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Musculation, pilates, danse',
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
                      ? 'Recommandé pour ta phase '
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: recommended.map((workout) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: workout == recommended.first ? 8 : 0,
                        ),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WorkoutDetailScreen(workout: workout),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  workout.imageUrl,
                                  height: 130,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 130,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _categoryColor(workout.category.toUpperCase()).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          workout.category.toUpperCase(),
                                          style: TextStyle(
                                            color: _categoryColor(workout.category.toUpperCase()),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        workout.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          const Icon(LucideIcons.clock, size: 12, color: Colors.grey),
                                          Text(workout.duration, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          const Icon(LucideIcons.flame, size: 12, color: Colors.grey),
                                          Text('${workout.calories ?? 320} kcal', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        workout.level,
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 24),

            // All workouts section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tous les workouts (${_getFilteredWorkouts(workouts).length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1A2E1A),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (_getFilteredWorkouts(workouts).isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.search,
                        size: 56,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pas de workouts trouvés',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Essayez une autre catégorie',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _getFilteredWorkouts(workouts).length,
                itemBuilder: (context, index) {
                  final workout = _getFilteredWorkouts(workouts)[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkoutDetailScreen(workout: workout),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                          ),
                          child: Image.network(
                            workout.imageUrl,
                            width: 110,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 110, height: 90, color: Colors.grey[300],
                            ),
                          ),
                        ),
                        // Info
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _categoryColor(workout.category.toUpperCase()).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    workout.category.toUpperCase(),
                                    style: TextStyle(
                                      color: _categoryColor(workout.category.toUpperCase()),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  workout.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    const Icon(LucideIcons.clock, size: 12, color: Colors.grey),
                                    Text(workout.duration, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    const Icon(LucideIcons.flame, size: 12, color: Colors.grey),
                                    Text('${workout.calories ?? 320} kcal', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    Text(workout.level, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Arrow button
                        Container(
                          width: 44,
                          height: 90,
                          decoration: BoxDecoration(
                            color: _arrowBgColor(workout.category),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(18),
                              bottomRight: Radius.circular(18),
                            ),
                          ),
                          child: const Icon(Icons.chevron_right, color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}