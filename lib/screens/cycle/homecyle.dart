

import 'package:flutter/material.dart';

import 'widgets-cycle/_DayChip.dart';
import 'widgets-cycle/calendar_screen.dart';
import 'widgets-cycle/cycle_header.dart';
import 'widgets-cycle/cycle_wheel.dart' as wheel;
import 'widgets-cycle/energy_section.dart';
import 'widgets-cycle/insight_section.dart';
import 'widgets-cycle/mood_section.dart';
import 'widgets-cycle/recommendations_section.dart';
import 'widgets-cycle/symptoms_section.dart';

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
        scaffoldBackgroundColor: Colors.white,
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
  final phase = phaseForDay(day);
  switch (phase.name) {
    case 'Règles':
      return const CycleTheme(
        gradient: [Color(0xFFFFD6E0), Color(0xFFFF9BB3), Color(0xFFD94F6B)],
        primary: Color(0xFFD94F6B),
        glow: Color(0x66FF4D6D),
      );
    case 'Folliculaire':
      return const CycleTheme(
        gradient: [Color(0xFFE8FDF3), Color(0xFF7BE0B5), Color(0xFF2FBF91)],
        primary: Color(0xFF2FBF91),
        glow: Color(0x662FBF91),
      );
    case 'Ovulation':
  return const CycleTheme(
    gradient: [
      Color(0xFFE8FFFB),
      Color(0xFFB8F2E6),
      Color(0xFF7DE2D1),
    ],
    primary: Color(0xFF5FD3C4),
    glow: Color(0x665FD3C4),
  );
    default:
      return const CycleTheme(
        gradient: [Color(0xFFE3ECFF), Color(0xFF8FAFFF), Color(0xFF4A6CF7)],
        primary: Color(0xFF4A6CF7),
        glow: Color(0x664A6CF7),
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
    'Fatigue', 'Cramps', 'Headache',
    'Mood swings', 'Bloating', 'Acne', 'Stress',
  ];

  int get _symptomScore => _selectedSymptoms.length;

  String _getInsight() {
    if (_selectedSymptoms.contains(0)) return 'Ton corps demande du repos léger et des mouvements doux.';
    if (_selectedSymptoms.contains(2)) return 'Ton niveau de stress est élevé. Priorise respiration + récupération.';
    if (_energy < 0.3) return 'Énergie basse détectée. Journée slow mode recommandée.';
    if (_selectedMood >= 3) return 'Bonne énergie mentale. C\'est le moment idéal pour performer.';
    return 'Équilibre global stable. Continue ton rythme actuel.';
  }

  String _getMoodText() {
    if (_symptomScore == 0) return 'Feeling great today ✨';
    if (_symptomScore <= 2) return 'Light symptoms detected 🌿';
    if (_symptomScore <= 4) return 'Take care of your body 💛';
    return 'Rest recommended 🧘‍♀️';
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final theme = getTheme(_currentDay);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.gradient[0].withOpacity(0.95),
              theme.gradient[1].withOpacity(0.65),
              theme.gradient[2].withOpacity(0.85),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              // ── ① HEADER (phase badge + toggle + progress bar) ──
              CycleHeader(
                currentDay: _currentDay,
                showWheel: _showWheel,
                onShowWheel: () => setState(() => _showWheel = true),
                onShowCalendar: () => setState(() => _showWheel = false),
                onClose: () => Navigator.maybePop(context),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
 Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DaySlider(
                          currentDay: _currentDay,
                          onDaySelected: (d) =>
                              setState(() => _currentDay = d),
                          phaseColor: theme.primary,
                        ),
                      ),

                      // ── ② ROUE CENTRÉE ────────────────────────
                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          width: screenWidth * 0.88,
                          height: screenWidth * 0.88,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: _showWheel
                                ? wheel.CycleWheel(
                                    key: const ValueKey('wheel'),
                                    currentDay: _currentDay,
                                    onDaySelected: (d) =>
                                        setState(() => _currentDay = d),
                                  )
                                : _CalendarPage(
                                    key: const ValueKey('cal'),
                                    currentDay: _currentDay,
                                    onDaySelected: (d) =>
                                        setState(() => _currentDay = d),
                                  ),
                          ),
                        ),
                      ),

                      // ── ③ DAY SLIDER ──────────────────────────
                     
                      const SizedBox(height: 16),

                      // ── ④ ÉNERGIE ─────────────────────────────
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
                                energy: (_energy - (_symptomScore * 0.05))
                                    .clamp(0.0, 1.0),
                                phaseColor: theme.primary,
                                title: 'Energy',
                                onChanged: (val) =>
                                    setState(() => _energy = val),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _getMoodText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── ⑤ HUMEUR + INSIGHT (2 colonnes) ───────
                      Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: SizedBox(
 height: MediaQuery.of(context).size.height * 0.25,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: MoodSection(
              selectedMood: _selectedMood,
              phaseColor: theme.primary,
              onSelect: (i) =>
                  setState(() => _selectedMood = i),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: _cardDecoration(),
            child: InsightSection(
              insight: _getInsight(),
              phaseColor: theme.primary,
            ),
          ),
        ),
      ],
    ),
  ),
),
                      const SizedBox(height: 10),

                      // ── ⑥ RECOMMANDATIONS ─────────────────────
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

                      // ── ⑦ SYMPTÔMES ───────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                          padding: const EdgeInsets.all(14),
                          decoration: _cardDecoration(),
                          child: SymptomsSection(
                            symptoms: _symptoms,
                            selectedSymptoms: _selectedSymptoms,
                            phaseColor: theme.primary,
                            title: const Text('Symptoms'),
                            onToggle: (index) {
                              setState(() {
                                if (_selectedSymptoms.contains(index)) {
                                  _selectedSymptoms.remove(index);
                                } else {
                                  _selectedSymptoms.add(index);
                                }
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
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