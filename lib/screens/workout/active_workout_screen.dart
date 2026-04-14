import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import '../../theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  final WorkoutModel workout;
  const ActiveWorkoutScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video Placeholder
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[900],
                    child: Image.network(
                      workout.imageUrl,
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.5),
                    ),
                  ),
                  const Icon(LucideIcons.playCircle, size: 80, color: Colors.white),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Info & Timer
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      workout.exercises.first,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '00:45',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 64,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildControlButton(LucideIcons.skipBack, Colors.grey),
                        const SizedBox(width: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                            ],
                          ),
                          child: const Icon(LucideIcons.pause, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 24),
                        _buildControlButton(LucideIcons.skipForward, AppTheme.textPrimaryColor),
                      ],
                    ),
                    
                    // Next exercises
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: workout.exercises.length - 1,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Text('${index + 2}'),
                            title: Text(workout.exercises[index + 1]),
                            trailing: const Text('45s'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Icon(icon, color: color),
    );
  }
}
