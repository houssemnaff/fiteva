import 'package:fiteva/widgets/cycle_tracker_circle.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CycleScreen extends StatelessWidget {
  const CycleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Cycle Tracker'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔥 CYCLE CIRCLE
            const CycleTrackerCircle(value: 0.65),

            const SizedBox(height: 30),

            // 📊 INFO CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Current Phase',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),

                  const Text(
                    'Follicular Phase',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Day 8 of 28 cycle',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 💡 TIPS SECTION
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Today Insight',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'You are in a high-energy phase. It is the best time for strength training, cardio, and productivity.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🧠 RECOMMENDATIONS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recommended for you',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildCard('Workout', Icons.fitness_center),
                const SizedBox(width: 12),
                _buildCard('Nutrition', Icons.restaurant),
                const SizedBox(width: 12),
                _buildCard('Rest', Icons.bed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}