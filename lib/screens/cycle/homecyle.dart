import 'package:fiteva/screens/cycle/pregnancy/PregnancyHubScreen.dart';
import 'package:fiteva/screens/cycle/pregnancy/living_thread_screen.dart';

import 'package:fiteva/screens/cycle/pregnancy/pregnancy_week.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/calendar_screen.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/cycle_header.dart';
// 👈 add this
import 'package:fiteva/screens/cycle/widgets-cycle/cycle_wheel.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/symptom/symptoms_section.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

import 'widgets-cycle/cycle_wheel.dart' as wheel;
import 'widgets-cycle/energy_section.dart';
import 'widgets-cycle/insight_section.dart';
import 'widgets-cycle/mood_section.dart';
import 'widgets-cycle/recommendations_section.dart';

import 'widgets-cycle/cycle_info_card.dart';

// ──────────────────────────────────────────────
//  App entry
// ──────────────────────────────────────────────
class CycleApp extends StatelessWidget {
  const CycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycle Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: FitEvaColors.bgApp,
        fontFamily: 'SF Pro Display',
      ),
      home: const CycleScreen(),
    );
  }
}

// ──────────────────────────────────────────────
//  Theme helpers
// ──────────────────────────────────────────────
class CycleTheme {
  final List<Color> gradient;
  final Color primary;
  final Color glow;

  const CycleTheme({
    required this.gradient,
    required this.primary,
    required this.glow,
  });
}
CycleTheme getTheme(int day) {
  final phase = wheel.phaseForDay(day);

  switch (phase.name) {

    case 'Règles':
      return const CycleTheme(
        gradient: [
          Color(0xFFE58F8A),
          Color(0xFFDE7A7A),
          Color(0xFFF2B6B2),
        ],
        primary: Color(0xFFE58F8A),
        glow: Color(0x66E58F8A),
      );

    case 'Folliculaire':
      return const CycleTheme(
        gradient: [
          Color(0xFF7ABB98),
          Color(0xFF5FAE87),
          Color(0xFFBFE6D2),
        ],
        primary: Color(0xFF7ABB98), 
        glow: Color(0x667ABB98),
      );

    case 'Ovulation':
      return const CycleTheme(
        gradient: [
          Color(0xFF1C4D30),
          Color(0xFF2E6B45),
          Color(0xFF4A8F66),
        ],
        primary: Color(0xFF1C4D30),
        glow: Color(0x661C4D30),
      );

    default: // Luteal
      return const CycleTheme(
        gradient: [
          Color(0xFFA7B8AD),
          Color(0xFF8FA79A),
          Color(0xFFD6E2DB),
        ],
        primary: Color(0xFFA7B8AD),
        glow: Color(0x66A7B8AD),
      );
  }
}

// ──────────────────────────────────────────────
//  Main screen
// ──────────────────────────────────────────────
class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  int _currentDay = 14;
  double _energy = 0.5;
  int _selectedMood = 0;
  bool _showWheel = true;
  final Set<int> _selectedSymptoms = {};


  final List<String> _symptoms = [
    'Fatigue',
    'Cramps',
    'Headache',
    'Mood swings',
    'Bloating',
    'Acne',
    'Stress',
  ];

  int get _symptomScore => _selectedSymptoms.length;

  String _getInsight() {
    if (_selectedSymptoms.contains(0))
      return 'Ton corps demande du repos léger et des mouvements doux.';
    if (_selectedSymptoms.contains(2))
      return 'Ton niveau de stress est élevé. Priorise respiration + récupération.';
    if (_energy < 0.3)
      return 'Énergie basse détectée. Journée slow mode recommandée.';
    if (_selectedMood >= 3)
      return 'Bonne énergie mentale. C\'est le moment idéal pour performer.';
    return 'Équilibre global stable. Continue ton rythme actuel.';
  }

  String _getMoodText() {
    if (_symptomScore == 0) return 'Feeling great today';
    if (_symptomScore <= 2) return 'Light symptoms detected';
    if (_symptomScore <= 4) return 'Take care of your body';
    return 'Rest recommended';
  }

  IconData _getMoodIcon() {
    if (_symptomScore == 0) return Icons.star_rounded;
    if (_symptomScore <= 2) return Icons.nature_rounded;
    if (_symptomScore <= 4) return Icons.favorite_rounded;
    return Icons.self_improvement_rounded;
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: FitEvaColors.surface,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

@override
Widget build(BuildContext context) {
  final theme = getTheme(_currentDay);
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    backgroundColor: FitEvaColors.bgApp,
    body: SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────
            CycleHeader(
              currentDay: _currentDay,
              showWheel: _showWheel,
              onShowWheel: () => setState(() => _showWheel = true),
              onShowCalendar: () => setState(() => _showWheel = false),
              onClose: () => Navigator.maybePop(context),
              onSwitchToPregnancy: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PregnancyHubScreen(currentWeek:14)),
              ),  
            ),



            const SizedBox(height: 16),

            CycleRoomWidget(
  currentDay: _currentDay,
  onDaySelected: (d) => setState(() => _currentDay = d),
),

            const SizedBox(height: 16),

            // ── ÉNERGIE ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EnergySection(
                      energy: (_energy - (_symptomScore * 0.05)).clamp(0.0, 1.0),
                      phaseColor: theme.primary,
                      title: 'Energy',
                      onChanged: (val) => setState(() => _energy = val),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(_getMoodIcon(), size: 16, color: theme.primary),
                        const SizedBox(width: 6),
                        Text(
                          _getMoodText(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: FitEvaColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

          

            const SizedBox(height: 10),

            // ── RECOMMANDATIONS ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.all(14),
                decoration: _cardDecoration(),
                child: RecommendationsSection(
                  sportColor: _symptomScore > 3
                      ? theme.primary.withOpacity(0.8)
                      : const Color(0xFF6C63FF),
                  nutritionColor: _symptomScore > 2
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFFFFB703),
                  restColor: _symptomScore >= 3
                      ? const Color(0xFF4CC9F0)
                      : const Color(0xFF38B000),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── SYMPTÔMES ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.all(14),
                decoration: _cardDecoration(),
                child: SymptomsSection(
                 previousDayCount:3,
                 
                  phaseColor: theme.primary,

                 
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}
}
// ──────────────────────────────────────────────
//  Calendar page wrapper
// ──────────────────────────────────────────────
class _CalendarPage extends StatelessWidget {
  final int currentDay;
  final Function(int) onDaySelected;

  const _CalendarPage({
    super.key,
    required this.currentDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                _NavBtn(icon: Icons.chevron_left_rounded, onTap: () {}),
                const Spacer(),
                const Text(
                  'Avril 2026',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3D2033),
                  ),
                ),
                const Spacer(),
                _NavBtn(icon: Icons.chevron_right_rounded, onTap: () {}),
              ],
            ),
          ),
          CycleCalendar(
            currentDay: currentDay,
            todayDay: 16,
            onDaySelected: onDaySelected,
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 18, color: const Color(0xFFB07A9A)),
    );
  }
}