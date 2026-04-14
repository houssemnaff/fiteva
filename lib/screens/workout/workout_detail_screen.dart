import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import '../../theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutModel workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    workout.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  const Center(
                    child: Icon(LucideIcons.playCircle, size: 64, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.title, style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(LucideIcons.clock, workout.duration),
                      const SizedBox(width: 16),
                      _buildInfoChip(LucideIcons.barChart, workout.level),
                      const SizedBox(width: 16),
                      _buildInfoChip(LucideIcons.tag, workout.category),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Exercises', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ...workout.exercises.map((exercise) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.dumbbell, color: AppTheme.primaryColor),
                    ),
                    title: Text(exercise, style: Theme.of(context).textTheme.titleMedium),
                    trailing: const Icon(LucideIcons.moreHorizontal, color: Colors.grey),
                  )).toList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Navigate to Active Workout
            },
            child: const Text('START WORKOUT'),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondaryColor),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppTheme.textSecondaryColor)),
      ],
    );
  }
}
