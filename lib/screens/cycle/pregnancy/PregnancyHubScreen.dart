import 'package:fiteva/screens/cycle/pregnancy/DailyInsightCard.dart';
import 'package:fiteva/screens/cycle/pregnancy/PregnancyInsightRepository.dart';
import 'package:fiteva/screens/cycle/pregnancy/baby-story/baby_story_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/checklist/pregnancy_checklist_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/living_thread_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/symptom/symptoms_home_screen.dart';
import 'package:fiteva/screens/cycle/pregnancy/theme.dart' as Theme;
import 'package:fiteva/screens/cycle/pregnancy/theme.dart';
import 'package:flutter/material.dart';

class PregnancyHubScreen extends StatelessWidget {
  final int currentWeek;

  const PregnancyHubScreen({
    super.key,
    required this.currentWeek,
  });

  @override
  Widget build(BuildContext context) {
    final color = ThreadTheme.threadColorForWeek(currentWeek);

    return Scaffold(
      backgroundColor: ThreadTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Week $currentWeek",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),

              // DAILY INSIGHT
              DailyInsightCard(
                insight: PregnancyInsightRepository.forWeek(currentWeek),
                accentColor: color,
              ),

              const SizedBox(height: 16),

              // NAV CARDS
              _NavCard(
                title: "Living Thread",
                icon: Icons.timeline,
                color: color,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LivingThreadScreen(),
                    ),
                  );
                },
              ),

              _NavCard(
  title: "Symptoms",
  icon: Icons.favorite,
  color: color,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SymptomsHomeScreen(
          currentWeek: currentWeek,
        ),
      ),
    );
  },
),

              _NavCard(
  title: "Checklist",
  icon: Icons.checklist_rounded,
  color: color,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PregnancyChecklistScreen(
          currentWeek: currentWeek,
        ),
      ),
    );
  },
),

              _NavCard(
  title: "Baby Story",
  icon: Icons.auto_stories_rounded,
  color: color,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BabyStoryScreen(
          currentWeek: currentWeek,
        ),
      ),
    );
  },
),
            ],
          ),
        ),
      ),
    );
  }
}


class _NavCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}