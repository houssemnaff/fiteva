import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'home/home_screen.dart';
import 'cycle/cycle_screen.dart';
import 'workout/workout_screen.dart';
import 'nutrition/nutrition_screen.dart';
import 'community/community_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CycleScreen(),
    const WorkoutScreen(),
    const NutritionScreen(),
    const CommunityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.loader), label: 'Cycle'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.dumbbell), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.apple), label: 'Nutrition'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.users), label: 'Community'),
        ],
      ),
    );
  }
}
