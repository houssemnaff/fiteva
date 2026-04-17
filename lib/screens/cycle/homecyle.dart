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




class CycleApp extends StatelessWidget {
  const CycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycle Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      scaffoldBackgroundColor: Colors.white,
        fontFamily: 'SF Pro Display', // swap to your font
      ),
      home: const CycleScreen(),
    );
  }
}

class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  int _currentDay = 14;
  double _energy = 0.5;
int _selectedMood = 0;
  int get _symptomScore => _selectedSymptoms.length;
  bool _showWheel = true;
final List<String> _symptoms = [
  "Fatigue",
  "Cramps",
  "Headache",
  "Mood swings",
  "Bloating",
  "Acne",
  "Stress",
];
Color _getDynamicColor() {
  if (_symptomScore <= 1) {
    return const Color(0xFF3D2033); // normal
  } else if (_symptomScore <= 3) {
    return const Color(0xFF6B4C5A); // stress léger
  } else {
    return const Color(0xFFB00020); // fatigue / alert
  }
}

String getInsight() {
  if (_selectedSymptoms.contains(0)) {
    return "Ton corps demande du repos léger et des mouvements doux.";
  }

  if (_selectedSymptoms.contains(2)) {
    return "Ton niveau de stress est élevé. Priorise respiration + récupération.";
  }

  if (_energy < 0.3) {
    return "Énergie basse détectée. Journée slow mode recommandée.";
  }

  if (_selectedMood >= 3) {
    return "Bonne énergie mentale. C’est le moment idéal pour performer.";
  }

  return "Équilibre global stable. Continue ton rythme actuel.";
}



String _getMoodText() {
  if (_symptomScore == 0) return "Feeling great today ✨";
  if (_symptomScore <= 2) return "Light symptoms detected 🌿";
  if (_symptomScore <= 4) return "Take care of your body 💛";
  return "Rest recommended 🧘‍♀️";
}
String _getMoodInsight() {
  if (_selectedMood == 0 && _symptomScore == 0) {
    return "Perfect balance ✨";
  }

  if (_selectedMood == 1 && _symptomScore <= 1) {
    return "Calm & stable ☁️";
  }

  if (_selectedMood >= 3 && _symptomScore >= 3) {
    return "High emotional load 🌪️";
  }

  if (_energy < 0.4) {
    return "Low energy detected 🌙";
  }

  return "Normal cycle state 🌿";
}
final Set<int> _selectedSymptoms = {};
 @override
Widget build(BuildContext context) {
  final theme = getTheme(_currentDay);

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
                    const SizedBox(height: 10),

                    const SizedBox(height: 16),

                    // 🌙 WHEEL / CALENDAR
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: AnimatedScale(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOutCubic,
  scale: 1.0,
                        child: _showWheel
                            ? _WheelPage(
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

                    // 🔋 ENERGY
               AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  curve: Curves.easeInOutCubic,
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withOpacity(0.12),
      ),
    ),
    child: EnergySection(
      energy: (_energy - (_symptomScore * 0.05)).clamp(0.0, 1.0),
      phaseColor: theme.primary,
      title: "Energy",
      onChanged: (val) {
        setState(() {
          _energy = val;
        });
      },
    ),
  ),
),

                    Text(
                      _getMoodText(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                   AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  curve: Curves.easeInOutCubic,
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withOpacity(0.12),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: InsightSection(
      insight: getInsight(),
      phaseColor: theme.primary,
    ),
  ),
),

                    const SizedBox(height: 20),

                   AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  curve: Curves.easeInOutCubic,
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withOpacity(0.12),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: MoodSection(
      selectedMood: _selectedMood,
      phaseColor: theme.primary,
      onSelect: (index) {
        setState(() {
          _selectedMood = index;
        });
      },
    ),
  ),
),

                    RecommendationsSection(
                      sportColor: _symptomScore > 3
                          ?theme.primary.withOpacity(0.8)
                          : const Color(0xFF6C63FF),
                      nutritionColor: _symptomScore > 2
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFFFFB703),
                      restColor: _symptomScore >= 3
                          ? const Color(0xFF4CC9F0)
                          : const Color(0xFF38B000),
                    ),

                    SymptomsSection(
                      symptoms: _symptoms,
                      selectedSymptoms: _selectedSymptoms,
                      phaseColor: theme.primary,
                      title: const Text("Symptoms"),
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

                    const SizedBox(height: 30),
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
class _WheelPage extends StatelessWidget {
  final int currentDay;
  final Function(int) onDaySelected;

  const _WheelPage({
    super.key,
    required this.currentDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final phaseColor = phaseForDay(currentDay).color;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(height: constraints.maxHeight * 0.02),

              DaySlider(
                currentDay: currentDay,
                onDaySelected: onDaySelected,
                phaseColor: phaseColor,
              ),

              SizedBox(height: constraints.maxHeight * 0.02),

              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: wheel.CycleWheel(
                      key: ValueKey(currentDay),
                      currentDay: currentDay,
                      onDaySelected: onDaySelected,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


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
        gradient: [
          Color(0xFFFFD6E0),
          Color(0xFFFF9BB3),
          Color(0xFFD94F6B),
        ],
        primary: Color(0xFFD94F6B),
        glow: Color(0x66FF4D6D),
      );

    case 'Folliculaire':
      return const CycleTheme(
        gradient: [
          Color(0xFFE8FDF3),
          Color(0xFF7BE0B5),
          Color(0xFF2FBF91),
        ],
        primary: Color(0xFF2FBF91),
        glow: Color(0x662FBF91),
      );

    case 'Ovulation':
      return const CycleTheme(
        gradient: [
          Color(0xFFFFF3D6),
          Color(0xFFFFC14D),
          Color(0xFFE8A030),
        ],
        primary: Color(0xFFE8A030),
        glow: Color(0x66FFB347),
      );

    default:
      return const CycleTheme(
        gradient: [
          Color(0xFFE3ECFF),
          Color(0xFF8FAFFF),
          Color(0xFF4A6CF7),
        ],
        primary: Color(0xFF4A6CF7),
        glow: Color(0x664A6CF7),
      );
  }
}


// ──────────────────────────────────────────────
//  Calendar page wrapper
// ──────────────────────────────────────────────
class _CalendarPage extends StatelessWidget {
  final int currentDay;
  final Function(int) onDaySelected;

  const _CalendarPage({super.key, required this.currentDay, required this.onDaySelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month nav
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
      child: Container(
  decoration: BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topCenter,
      radius: 1.2,
      colors: [
        Colors.white.withOpacity(0.18),
        Colors.transparent,
      ],
    ),
  ),


        child: Icon(icon, size: 18, color: const Color(0xFFB07A9A)),
      ),
    );
  }
}