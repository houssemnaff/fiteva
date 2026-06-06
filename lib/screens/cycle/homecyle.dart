// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fiteva/screens/cycle/pregnancy/PregnancyHubScreen.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/calendar_screen.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/cycle_wheel.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS (Flo-style light)
// ─────────────────────────────────────────────────────────────────────────────

abstract class FloColors {
  static const bg      = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8F6F3);
  static const text    = Color(0xFF2D1B20);
  static const muted   = Color(0xFF9E8A93);
}

abstract class FloTypo {
  static TextStyle heading(double size,
          {FontWeight w = FontWeight.w600, Color c = FloColors.text}) =>
      GoogleFonts.lora(fontSize: size, fontWeight: w, color: c);

  static TextStyle body(double size,
          {FontWeight w = FontWeight.w400, Color c = FloColors.text}) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: w, color: c);
}

// ─────────────────────────────────────────────────────────────────────────────
//  SYMPTOM MODEL
// ─────────────────────────────────────────────────────────────────────────────

enum FloSymptom { flow, mood, energy, cramps }

extension FloSymptomX on FloSymptom {
  String get label {
    switch (this) {
      case FloSymptom.flow:   return 'Flux';
      case FloSymptom.mood:   return 'Humeur';
      case FloSymptom.energy: return 'Énergie';
      case FloSymptom.cramps: return 'Crampes';
    }
  }

  IconData get icon {
    switch (this) {
      case FloSymptom.flow:   return Icons.water_drop_outlined;
      case FloSymptom.mood:   return Icons.sentiment_satisfied_outlined;
      case FloSymptom.energy: return Icons.bolt_outlined;
      case FloSymptom.cramps: return Icons.favorite_border_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PHASE THEME HELPER
// ─────────────────────────────────────────────────────────────────────────────

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
        gradient: [Color(0xFFE58F8A), Color(0xFFDE7A7A), Color(0xFFF2B6B2)],
        primary: Color(0xFFE58F8A),
        glow: Color(0x66E58F8A),
      );
    case 'Folliculaire':
      return const CycleTheme(
        gradient: [Color(0xFF7ABB98), Color(0xFF5FAE87), Color(0xFFBFE6D2)],
        primary: Color(0xFF7ABB98),
        glow: Color(0x667ABB98),
      );
    case 'Ovulation':
      return const CycleTheme(
        gradient: [Color(0xFF1C4D30), Color(0xFF2E6B45), Color(0xFF4A8F66)],
        primary: Color(0xFF1C4D30),
        glow: Color(0x661C4D30),
      );
    default: // Lutéale
      return const CycleTheme(
        gradient: [Color(0xFFA7B8AD), Color(0xFF8FA79A), Color(0xFFD6E2DB)],
        primary: Color(0xFFA7B8AD),
        glow: Color(0x66A7B8AD),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  APP ENTRY (standalone runner)
// ─────────────────────────────────────────────────────────────────────────────

class CycleApp extends StatelessWidget {
  const CycleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycle Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: FloColors.bg,
        useMaterial3: true,
      ),
      home: const CycleScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN CYCLE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  int _currentDay = 14;
  final Set<FloSymptom> _logged = {};
  bool _showCalendar = false;

  final DateTime _today = DateTime.now();
  late DateTime _viewDate;

  static const int _maxFutureMonths = 8;

  static const _monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  @override
  void initState() {
    super.initState();
    _viewDate = DateTime(DateTime.now().year, DateTime.now().month);
  }

  int get _viewMonthIndex => _viewDate.year * 12 + _viewDate.month;
  int get _todayMonthIndex => _today.year * 12 + _today.month;

  bool get _canGoBack => _viewMonthIndex > _todayMonthIndex;
  bool get _canGoForward =>
      _viewMonthIndex < _todayMonthIndex + _maxFutureMonths;

  void _prevMonth() {
    if (!_canGoBack) return;
    HapticFeedback.lightImpact();
    setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month - 1));
  }

  void _nextMonth() {
    if (!_canGoForward) return;
    HapticFeedback.lightImpact();
    setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month + 1));
  }

  String get _monthLabel =>
      '${_monthNames[_viewDate.month - 1]} ${_viewDate.year}';

  @override
  Widget build(BuildContext context) {
    final theme = getTheme(_currentDay);
    final phase = phaseForDay(_currentDay);

    return Scaffold(
      backgroundColor: FloColors.bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _showCalendar
              ? _buildCalendar()
              : _buildHome(theme, phase),
        ),
      ),
    );
  }

  // ── Home view ──────────────────────────────────────────────────────────────

  Widget _buildHome(CycleTheme theme, CyclePhase phase) {
    return SingleChildScrollView(
      key: const ValueKey('home'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(theme, phase),
          const SizedBox(height: 28),
          _CircularRing(
            day: _currentDay,
            total: 28,
            theme: theme,
            phase: phase,
          ),
          const SizedBox(height: 28),
          _buildChips(theme),
          const SizedBox(height: 24),
          _WeekStrip(
            currentDay: _currentDay,
            onDayTap: (d) {
              HapticFeedback.lightImpact();
              setState(() => _currentDay = d);
            },
          ),
          const SizedBox(height: 24),
          _PhaseCard(phase: phase, theme: theme),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CycleRoomWidget(
              currentDay: _currentDay,
              onDaySelected: (d) => setState(() => _currentDay = d),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Calendar view ──────────────────────────────────────────────────────────

  Widget _buildCalendar() {
    return SingleChildScrollView(
      key: const ValueKey('calendar'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _showCalendar = false);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: FloColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 15, color: Color(0xFFB07A9A)),
                  ),
                ),
                const SizedBox(width: 14),
                Text('Calendrier du cycle', style: FloTypo.heading(18)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Month nav
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                _NavBtn(
                  icon: Icons.chevron_left_rounded,
                  onTap: _prevMonth,
                  enabled: _canGoBack,
                ),
                const Spacer(),
                Text(
                  _monthLabel,
                  style: FloTypo.heading(15, w: FontWeight.w600),
                ),
                const Spacer(),
                _NavBtn(
                  icon: Icons.chevron_right_rounded,
                  onTap: _nextMonth,
                  enabled: _canGoForward,
                ),
              ],
            ),
          ),
          CycleCalendar(
            displayYear: _viewDate.year,
            displayMonth: _viewDate.month,
            today: _today,
            todayCycleDay: _currentDay,
            selectedCycleDay: _currentDay,
            onDaySelected: (d) {
              HapticFeedback.lightImpact();
              setState(() {
                _currentDay = d;
                _showCalendar = false;
              });
            },
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(CycleTheme theme, CyclePhase phase) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mon Cycle', style: FloTypo.heading(22, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                'Jour $_currentDay · ${phase.name}',
                style: FloTypo.body(13, c: FloColors.muted),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PregnancyHubScreen(
                      pregnancyStartDate: DateTime.now()
                          .subtract(const Duration(days: 14 * 7)),
                    ),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: FloColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.child_friendly_rounded,
                      size: 16, color: theme.primary),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showCalendar = true);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          size: 15, color: theme.primary),
                      const SizedBox(width: 5),
                      Text(
                        'Calendrier',
                        style: FloTypo.body(12,
                            w: FontWeight.w500, c: theme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Symptom chips row ──────────────────────────────────────────────────────

  Widget _buildChips(CycleTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: FloSymptom.values
            .map((s) => _SymptomChip(
                  symptom: s,
                  logged: _logged.contains(s),
                  color: theme.primary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (_logged.contains(s)) {
                        _logged.remove(s);
                      } else {
                        _logged.add(s);
                      }
                    });
                  },
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CIRCULAR RING
// ─────────────────────────────────────────────────────────────────────────────

class _CircularRing extends StatelessWidget {
  final int day;
  final int total;
  final CycleTheme theme;
  final CyclePhase phase;

  const _CircularRing({
    required this.day,
    required this.total,
    required this.theme,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 230,
      child: CustomPaint(
        painter: _RingPainter(
          day: day,
          total: total,
          colors: theme.gradient,
          primary: theme.primary,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Jour', style: FloTypo.body(13, c: FloColors.muted)),
              const SizedBox(height: 2),
              Text(
                '$day',
                style: FloTypo.heading(54,
                    w: FontWeight.w700, c: theme.primary),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  phase.name,
                  style: FloTypo.body(11, w: FontWeight.w600, c: theme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final int day;
  final int total;
  final List<Color> colors;
  final Color primary;

  const _RingPainter({
    required this.day,
    required this.total,
    required this.colors,
    required this.primary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width / 2) - 18;
    const stroke = 13.0;

    // Track arc
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = primary.withOpacity(0.1),
    );

    // Progress arc
    final progress = (day / total).clamp(0.0, 1.0);
    final sweep = progress * 2 * pi;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    final shader = SweepGradient(
      startAngle: -pi / 2,
      endAngle: -pi / 2 + 2 * pi,
      colors: [colors.first, colors.last, colors.first],
    ).createShader(rect);

    canvas.drawArc(
      rect,
      -pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );

    // Tip dot
    final angle = -pi / 2 + sweep;
    final dotX = cx + r * cos(angle);
    final dotY = cy + r * sin(angle);
    canvas.drawCircle(Offset(dotX, dotY), 8, Paint()..color = colors.first);
    canvas.drawCircle(Offset(dotX, dotY), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.day != day || old.total != total;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SYMPTOM CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _SymptomChip extends StatelessWidget {
  final FloSymptom symptom;
  final bool logged;
  final Color color;
  final VoidCallback onTap;

  const _SymptomChip({
    required this.symptom,
    required this.logged,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 74,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: logged ? color.withOpacity(0.13) : FloColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: logged ? color : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: logged
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              symptom.icon,
              size: 21,
              color: logged ? color : const Color(0xFFA89898),
            ),
            const SizedBox(height: 6),
            Text(
              symptom.label,
              style: FloTypo.body(
                10,
                w: FontWeight.w500,
                c: logged ? color : const Color(0xFFA89898),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  7-DAY WEEK STRIP
// ─────────────────────────────────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  final int currentDay;
  final void Function(int) onDayTap;

  const _WeekStrip({required this.currentDay, required this.onDayTap});

  static const _weekLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  Color _phaseColor(String name) {
    switch (name) {
      case 'Règles':      return const Color(0xFFE58F8A);
      case 'Folliculaire': return const Color(0xFF7ABB98);
      case 'Ovulation':   return const Color(0xFF1C4D30);
      default:            return const Color(0xFFA7B8AD);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offset = (currentDay - 1).clamp(0, 21);
    final days = List.generate(7, (i) => offset + i + 1);

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final d = days[i];
          if (d > 28) return const SizedBox(width: 48);

          final phase = phaseForDay(d);
          final color = _phaseColor(phase.name);
          final isSelected = d == currentDay;

          return GestureDetector(
            onTap: () => onDayTap(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              decoration: BoxDecoration(
                color: isSelected ? color : FloColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekLabels[i % 7],
                    style: FloTypo.body(
                      10,
                      w: FontWeight.w500,
                      c: isSelected
                          ? Colors.white70
                          : const Color(0xFFA89898),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$d',
                    style: FloTypo.body(
                      16,
                      w: FontWeight.w700,
                      c: isSelected ? Colors.white : const Color(0xFF4A3640),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.7)
                          : color.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PHASE INFO CARD
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseCard extends StatelessWidget {
  final CyclePhase phase;
  final CycleTheme theme;

  const _PhaseCard({required this.phase, required this.theme});

  static const _descriptions = {
    'Règles':
        'Ton corps se nettoie. Repos, chaleur et douceur sont essentiels.',
    'Folliculaire':
        'Énergie montante. C\'est le moment d\'explorer et commencer.',
    'Ovulation':
        'Pic d\'énergie et de confiance. Performe et connecte-toi.',
    'Lutéale':
        'Phase introspective. Écoute tes besoins et ralentis.',
  };

  @override
  Widget build(BuildContext context) {
    final desc =
        _descriptions[phase.name] ?? 'Suis ton cycle avec bienveillance.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.gradient[0].withOpacity(0.14),
              theme.gradient[2].withOpacity(0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.primary.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.spa_outlined, color: theme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phase ${phase.name}',
                    style: FloTypo.heading(15,
                        w: FontWeight.w600, c: theme.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: FloTypo.body(13, c: const Color(0xFF6B5760)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CALENDAR NAV BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _NavBtn({required this.icon, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: FloColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 17,
          color: enabled
              ? const Color(0xFFB07A9A)
              : const Color(0xFFD4C4CB),
        ),
      ),
    );
  }
}
