import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mock_data_provider.dart';
import '../../theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutsProvider);
    final categories = ['All', 'Strength', 'HIIT', 'Pilates', 'Dance', 'Running'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Categories
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(categories[index]),
                    selected: isSelected,
                    onSelected: (_) {},
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(
                            workout.imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(LucideIcons.clock, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      workout.duration,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(LucideIcons.barChart, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      workout.level,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          workout.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
