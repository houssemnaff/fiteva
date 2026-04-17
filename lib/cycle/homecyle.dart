
import 'package:fiteva/cycle/widgets-cycle/_DayChip.dart';
import 'package:fiteva/cycle/widgets-cycle/calendar_screen.dart';
import 'package:fiteva/cycle/widgets-cycle/cycle_header.dart';
import 'package:fiteva/cycle/widgets-cycle/cycle_wheel.dart';
import 'package:fiteva/cycle/widgets-cycle/energy_section.dart';
import 'package:fiteva/cycle/widgets-cycle/insight_section.dart';
import 'package:fiteva/cycle/widgets-cycle/mood_section.dart';
import 'package:fiteva/cycle/widgets-cycle/recommendations_section.dart';
import 'package:fiteva/cycle/widgets-cycle/symptoms_section.dart';
import 'package:flutter/material.dart';




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
    return Scaffold(
 backgroundColor: Colors.white,
     body: SafeArea(
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

              // 🔋 ENERGY
             

              const SizedBox(height: 16),

              // 🌙 WHEEL / CALENDAR
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
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
              AnimatedContainer(
  duration: const Duration(milliseconds: 400),
  curve: Curves.easeInOut,
  child: 
              EnergySection(
  energy: (_energy - (_symptomScore * 0.05)).clamp(0.0, 1.0),
  phaseColor: _getDynamicColor(),
  title: "Energy",
  onChanged: (val) {
    setState(() {
      _energy = val;
    });
  },
)
              ),
Text(
  _getMoodText(),
  style: const TextStyle(
    fontSize: 12,
    color: Color(0xFF8E8E93),
    fontWeight: FontWeight.w500,
  ),
),
InsightSection(
  insight: getInsight(),
  phaseColor: const Color(0xFF3D2033),
),
              const SizedBox(height: 20),
MoodSection(
  selectedMood: _selectedMood,
  phaseColor: _getDynamicColor(),
  onSelect: (index) {
    setState(() {
      _selectedMood = index;
    });
    Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
  child: Text(
    _getMoodInsight(),
    style: const TextStyle(
      fontSize: 12,
      color: Color(0xFF8E8E93),
      fontWeight: FontWeight.w500,
    ),
  )
    );
  },
),
              // 💎 RECOMMENDATIONS
             RecommendationsSection(
  sportColor: _symptomScore > 3
      ? Colors.grey
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
  phaseColor: const Color(0xFF3D2033),
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
    );
  }
}

// ──────────────────────────────────────────────
//  Wheel page wrapper
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
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(height: constraints.maxHeight * 0.02),

              // ✅ utilise currentDay + callback du parent
              DaySlider(
                currentDay: currentDay,
                onDaySelected: onDaySelected,
              ),

              SizedBox(height: constraints.maxHeight * 0.02),

              // ── WHEEL ─────────────────────
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                 child: SizedBox(
  width: constraints.maxWidth,
  height: constraints.maxHeight,
  child: CycleWheel(
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFF3E8EF),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFFB07A9A)),
      ),
    );
  }
}