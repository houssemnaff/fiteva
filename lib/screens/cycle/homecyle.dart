

import 'package:flutter/material.dart';
import '../../theme/FitEvaColors.dart';

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
        gradient: [FitEvaColors.phaseMenstrual, FitEvaColors.phaseMenstrual, FitEvaColors.phaseMenstrual],
        primary: FitEvaColors.phaseMenstrual,
        glow: Color(0x66D94F6B),
      );
    case 'Folliculaire':
      return const CycleTheme(
        gradient: [FitEvaColors.phaseFolliculaire, FitEvaColors.phaseFolliculaire, FitEvaColors.phaseFolliculaire],
        primary: FitEvaColors.phaseFolliculaire,
        glow: Color(0x667ABB98),
      );
    case 'Ovulation':
      return const CycleTheme(
        gradient: [FitEvaColors.phaseOvulatoire, FitEvaColors.phaseOvulatoire, FitEvaColors.phaseOvulatoire],
        primary: FitEvaColors.phaseOvulatoire,
        glow: Color(0x66F4A940),
      );
    default:
      return const CycleTheme(
        gradient: [FitEvaColors.phaseLuteal, FitEvaColors.phaseLuteal, FitEvaColors.phaseLuteal],
        primary: FitEvaColors.phaseLuteal,
        glow: Color(0x665A7FC2),
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: FitEvaColors.textMuted,
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