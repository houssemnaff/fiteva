import 'package:fiteva/widgets/chatbot_sheet.dart';
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

  /// 🔥 Position of draggable button
  double _x = 300;
  double _y = 500;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CycleScreen(),
    const WorkoutScreen(),
    const NutritionScreen(),
    const CommunityScreen(),
  ];

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatbotSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    const buttonSize = 56.0;
    const bottomNavHeight = 70.0;

    return Scaffold(
      body: Stack(
        children: [
          /// 📱 Current screen
          _screens[_currentIndex],

          /// 🤖 Draggable Chatbot Button
          Positioned(
            left: _x,
            top: _y,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _x = (_x + details.delta.dx).clamp(
                    0,
                    screenSize.width - buttonSize,
                  );

                  _y = (_y + details.delta.dy).clamp(
                    padding.top, // 🚫 avoid status bar
                    screenSize.height -
                        buttonSize -
                        bottomNavHeight, // 🚫 avoid navbar
                  );
                });
              },

              /// 🔥 Snap to edges after drag
              onPanEnd: (_) {
                setState(() {
                  if (_x < screenSize.width / 2) {
                    _x = 0;
                  } else {
                    _x = screenSize.width - buttonSize;
                  }
                });
              },

              child: FloatingActionButton(
                onPressed: _openChatbot,
                heroTag: 'ai_chatbot',
                backgroundColor: Colors.transparent,
                elevation: 4,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF5CD57A), Color(0xFF1C4D30)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),

      /// 📌 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.loader),
            label: 'Cycle',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.dumbbell),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.apple),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.users),
            label: 'Community',
          ),
        ],
      ),
    );
  }
}
