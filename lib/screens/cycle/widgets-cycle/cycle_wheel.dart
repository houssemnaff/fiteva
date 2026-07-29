import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────

abstract class CycleColors {
  // Menstrual — soft muted coral (warm but still natural)
static const menstrual  = Color(0xFFE58F8A); // rose doux
static const follicular = Color(0xFF7ABB98); // vert frais
static const ovulation  = Color(0xFF1C4D30); // vert profond signature
static const luteal     = Color(0xFFA7B8AD); // gris-vert calme

  // Surface
  static const bg          = Color.fromARGB(255, 255, 255, 255);   // near-black
  static const surface     = Color(0xFF18181C);
  static const surfaceHigh = Color(0xFF22222A);
  static const textPrimary = Color(0xFFF2F0EC);
  static const textMuted   = Color(0xFF7A7872);
  static const textFaint   = Color(0xFF3A3A40);
}

abstract class CycleTypography {
  static const phaseTitle  = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    height: 1.1,
    color: CycleColors.textPrimary,
  );

  static const phaseDesc = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: CycleColors.textMuted,
  );

  static const dayLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.06,
    color: CycleColors.textMuted,
  );

  static const dayNumber = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: CycleColors.textFaint,
  );

  static const overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.12,
    color: CycleColors.textFaint,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class CyclePhase {
  final String name;
  final String description;
  final Color color;
  final List<int> days;

  const CyclePhase({
    required this.name,
    required this.description,
    required this.color,
    required this.days,
  });
}

// Référence 28 jours — gardée pour les usages sans accès au profil (fallback).
// Pour un cycle réel, préférer phasesForCycleDays() : la phase lutéale reste
// cliniquement ~14 jours quelle que soit la longueur du cycle, donc c'est la
// phase folliculaire qui doit absorber la variation (pas un simple partage
// proportionnel des 4 phases, qui donnerait des plages fausses).
const List<CyclePhase> kPhases = [
  CyclePhase(
    name: 'Règles',
    description: 'Corps au repos · Prends soin de toi',
    color: CycleColors.menstrual,
    days: [1, 2, 3, 4, 5],
  ),
  CyclePhase(
    name: 'Folliculaire',
    description: 'Énergie en hausse · Peau lumineuse',
    color: CycleColors.follicular,
    days: [6, 7, 8, 9, 10, 11, 12, 13],
  ),
  CyclePhase(
    name: 'Ovulation',
    description: 'Pic d\'énergie · Clarté mentale',
    color: CycleColors.ovulation,
    days: [14, 15, 16],
  ),
  CyclePhase(
    name: 'Lutéale',
    description: 'Corps se prépare · Écoute tes besoins',
    color: CycleColors.luteal,
    days: [17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
  ),
];

/// Plages de phases recalculées pour la durée de cycle réelle de
/// l'utilisatrice — avant, ces plages étaient figées sur un cycle de 28
/// jours et donnaient des phases systématiquement fausses pour tout cycle
/// plus court (ex. 21j) ou plus long (ex. 35j).
List<CyclePhase> phasesForCycleDays(int cycleDays, {Color? accent}) {
  final a = accent ?? CycleColors.follicular;
  final deep = Color.lerp(a, Colors.black, 0.35)!;
  final muted = Color.lerp(a, Colors.grey, 0.5)!;

  if (cycleDays == 28 && accent == null) return kPhases;
  final safeCycle = cycleDays.clamp(15, 45);

  const menstrualLen = 5;
  const lutealLen     = 14;
  final ovulationDay  = (safeCycle - lutealLen).clamp(menstrualLen + 2, safeCycle - 1);
  final ovulationStart = (ovulationDay - 1).clamp(menstrualLen + 1, safeCycle);
  final ovulationEnd   = (ovulationDay + 1).clamp(ovulationStart, safeCycle);
  final follicularEnd  = (ovulationStart - 1).clamp(menstrualLen, ovulationStart);
  final lutealStart    = (ovulationEnd + 1).clamp(ovulationEnd, safeCycle);

  final days28 = cycleDays == 28;
  return [
    CyclePhase(
      name: 'Règles',
      description: 'Corps au repos · Prends soin de toi',
      color: CycleColors.menstrual,
      days: days28 ? const [1, 2, 3, 4, 5] : List.generate(menstrualLen, (i) => i + 1),
    ),
    CyclePhase(
      name: 'Folliculaire',
      description: 'Énergie en hausse · Peau lumineuse',
      color: a,
      days: days28 ? const [6, 7, 8, 9, 10, 11, 12, 13] : [for (var d = menstrualLen + 1; d <= follicularEnd; d++) d],
    ),
    CyclePhase(
      name: 'Ovulation',
      description: 'Pic d\'énergie · Clarté mentale',
      color: deep,
      days: days28 ? const [14, 15, 16] : [for (var d = ovulationStart; d <= ovulationEnd; d++) d],
    ),
    CyclePhase(
      name: 'Lutéale',
      description: 'Corps se prépare · Écoute tes besoins',
      color: muted,
      days: days28 ? const [17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30] : [for (var d = lutealStart; d <= safeCycle; d++) d],
    ),
  ];
}

// Simulated energy curve (normalized 0–1.0).
// Represents the felt-energy quality of each day.
const List<double> kEnergyCurve = [
  0.40, 0.35, 0.38, 0.42, 0.50,   // Menstrual 1-5: low, recovering
  0.60, 0.68, 0.76, 0.82, 0.88,   // Follicular 6-13: rising
  0.91, 0.94, 0.98, 1.00, 0.98,   // Ovulation 14-16 (centered at 14)
  0.95, 0.85, 0.78, 0.72, 0.68,   // Luteal start: gentle descent
  0.65, 0.62, 0.58, 0.54, 0.50,   // Luteal mid
  0.46, 0.43, 0.40, 0.38, 0.36,   // Luteal end: withdrawal
];

CyclePhase phaseForDay(int day, {int cycleDays = 28}) {
  final phases = phasesForCycleDays(cycleDays);
  return phases.firstWhere((p) => p.days.contains(day), orElse: () => phases.last);
}

// ─────────────────────────────────────────────────────────────────────────────
//  ROOM WIDGET — Entry point
// ─────────────────────────────────────────────────────────────────────────────

class CycleRoomWidget extends StatefulWidget {
  /// The currently selected cycle day (1–30).
  final int currentDay;

  /// Called when the user taps a column to select a day.
  final ValueChanged<int>? onDaySelected;

  /// Total days in this cycle.
  final int totalDays;

  const CycleRoomWidget({
    super.key,
    this.currentDay = 14,
    this.onDaySelected,
    this.totalDays = 30,
  }) : assert(currentDay >= 1 && currentDay <= 30);

  @override
  State<CycleRoomWidget> createState() => _CycleRoomWidgetState();
}

class _CycleRoomWidgetState extends State<CycleRoomWidget>
    with TickerProviderStateMixin {
  // Currently selected day — internal state, can differ from widget.currentDay
  // only during transition.
  late int _selectedDay;

  // Header text fade controller
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // Column selection pulse
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  // Tilt on selection
  late AnimationController _tiltCtrl;
  late Animation<double> _tiltX;
  late Animation<double> _tiltY;

  // Drag scrub state
  double? _dragStartX;
  int? _dragStartDay;
  bool _isScrubbing = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.currentDay;

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _tiltCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tiltX = Tween<double>(begin: 0, end: 0).animate(_tiltCtrl);
    _tiltY = Tween<double>(begin: 0, end: 0).animate(_tiltCtrl);
  }

  @override
  void didUpdateWidget(CycleRoomWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDay != widget.currentDay) {
      _selectDay(widget.currentDay, fromParent: true);
    }
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _pulseCtrl.dispose();
    _tiltCtrl.dispose();
    super.dispose();
  }

  void _selectDay(int day, {bool fromParent = false}) {
    if (_selectedDay == day) return;

    HapticFeedback.selectionClick();

    setState(() => _selectedDay = day);

    _headerCtrl.forward(from: 0);

    if (!fromParent) {
      widget.onDaySelected?.call(day);
    }
  }

  void _onDragStart(DragStartDetails d) {
    _dragStartX = d.localPosition.dx;
    _dragStartDay = _selectedDay;
    _isScrubbing = true;
  }

  void _onDragUpdate(DragUpdateDetails d, double columnWidth) {
    if (_dragStartX == null || _dragStartDay == null) return;
    final delta = d.localPosition.dx - _dragStartX!;
    final dayDelta = (delta / columnWidth).round();
    final newDay = (_dragStartDay! + dayDelta).clamp(1, widget.totalDays);
    if (newDay != _selectedDay) {
      _selectDay(newDay);
    }
  }

  void _onDragEnd(DragEndDetails _) {
    _dragStartX = null;
    _dragStartDay = null;
    setState(() => _isScrubbing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CycleColors.bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(
            day: _selectedDay,
            fade: _headerFade,
            slide: _headerSlide,
          ),
          const SizedBox(height: 32),
          _ColumnsSection(
            selectedDay: _selectedDay,
            totalDays: widget.totalDays,
            pulse: _pulse,
            isScrubbing: _isScrubbing,
            onTap: _selectDay,
            onDragStart: _onDragStart,
            onDragUpdate: _onDragUpdate,
            onDragEnd: _onDragEnd,
          ),
         
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HEADER SECTION — phase name + description
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final int day;
  final Animation<double> fade;
  final Animation<Offset> slide;

  const _HeaderSection({
    required this.day,
    required this.fade,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    final phase = phaseForDay(day);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overline: CYCLE DAY · N
              Row(
                children: [
                  Text(
                    'CYCLE DAY  ·  $day',
                    style: CycleTypography.overline,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Phase name with phase color
              Text(
                phase.name,
                style: CycleTypography.phaseTitle.copyWith(
                  color: phase.color,
                ),
              ),
              const SizedBox(height: 6),
              // Description
              Text(
                phase.description,
                style: CycleTypography.phaseDesc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  COLUMNS SECTION — the "room"
// ─────────────────────────────────────────────────────────────────────────────

class _ColumnsSection extends StatelessWidget {
  final int selectedDay;
  final int totalDays;
  final Animation<double> pulse;
  final bool isScrubbing;
  final ValueChanged<int> onTap;
  final void Function(DragStartDetails) onDragStart;
  final void Function(DragUpdateDetails, double) onDragUpdate;
  final void Function(DragEndDetails) onDragEnd;

  const _ColumnsSection({
    required this.selectedDay,
    required this.totalDays,
    required this.pulse,
    required this.isScrubbing,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth - 48; // 24px padding each side
      final colWidth = availableWidth / totalDays;

      return GestureDetector(
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: (d) => onDragUpdate(d, colWidth),
        onHorizontalDragEnd: onDragEnd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(totalDays, (i) {
                final day = i + 1;
                return _Column(
                  day: day,
                  selectedDay: selectedDay,
                  colWidth: colWidth,
                  pulse: pulse,
                  onTap: () => onTap(day),
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SINGLE COLUMN
// ─────────────────────────────────────────────────────────────────────────────

class _Column extends StatefulWidget {
  final int day;
  final int selectedDay;
  final double colWidth;
  final Animation<double> pulse;
  final VoidCallback onTap;

  const _Column({
    required this.day,
    required this.selectedDay,
    required this.colWidth,
    required this.pulse,
    required this.onTap,
  });

  @override
  State<_Column> createState() => _ColumnState();
}

class _ColumnState extends State<_Column>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _hoverScale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _hoverScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final selected = day == widget.selectedDay;
    final isPast = day < widget.selectedDay;
    final phase = phaseForDay(day);

    // Compute height
    final energyNorm = kEnergyCurve[day - 1]; // 0–1
    final maxH = 120.0;
    final minH = 8.0;

    double rawH;
    if (selected) {
      rawH = energyNorm * maxH;
    } else if (isPast) {
      rawH = max(minH, energyNorm * maxH * 0.58);
    } else {
      rawH = max(minH, energyNorm * maxH * 0.32);
    }

    // Opacity
    final double opacity;
    if (selected) {
      opacity = 1.0;
    } else if (isPast) {
      opacity = 0.38;
    } else {
      opacity = 0.16;
    }

    // Column width with small gap
    final gap = 2.0;
    final barW = (widget.colWidth - gap).clamp(6.0, 18.0);

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _hoverCtrl.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _hoverCtrl.reverse();
        },
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: widget.colWidth,
          height: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Day number label — only visible on selected + neighbors
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: selected ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '$day',
                    style: CycleTypography.dayNumber.copyWith(
                      color: phase.color.withOpacity(0.7),
                      fontSize: 9,
                    ),
                  ),
                ),
              ),

              // The bar itself
              AnimatedBuilder(
                animation: Listenable.merge([widget.pulse, _hoverCtrl]),
                builder: (context, _) {
                  final pulseH = selected
                      ? rawH * widget.pulse.value
                      : rawH;
                  final hScale = _hoverScale.value;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 380),
                    curve: const _SpringCurve(),
                    width: barW,
                    height: pulseH * hScale,
                    decoration: BoxDecoration(
                      color: phase.color.withOpacity(opacity),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                        bottomLeft: Radius.circular(1),
                        bottomRight: Radius.circular(1),
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

// ─────────────────────────────────────────────────────────────────────────────
//  PHASE LEGEND — bottom row
// ─────────────────────────────────────────────────────────────────────────────



// ─────────────────────────────────────────────────────────────────────────────
//  CUSTOM SPRING CURVE
//  Approximates a spring physics bounce for the column height animation.
// ─────────────────────────────────────────────────────────────────────────────

class _SpringCurve extends Curve {
  const _SpringCurve();

  @override
  double transformInternal(double t) {
    // Damped spring: slightly overshoots then settles
    const mass = 1.0;
    const stiffness = 200.0;
    const damping = 18.0;

    final omega0 = sqrt(stiffness / mass);
    final zeta = damping / (2 * sqrt(stiffness * mass));

    if (zeta < 1.0) {
      // Underdamped
      final omegaD = omega0 * sqrt(1 - zeta * zeta);
      final decay = exp(-zeta * omega0 * t * 4);
      return 1.0 - decay * (cos(omegaD * t * 4) + (zeta * omega0 / omegaD) * sin(omegaD * t * 4));
    }

    return t; // fallback
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DEMO APP — for standalone testing
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  runApp(const _DemoApp());
}

class _DemoApp extends StatelessWidget {
  const _DemoApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: CycleColors.bg,
      ),
      home: const _DemoScreen(),
    );
  }
}

class _DemoScreen extends StatefulWidget {
  const _DemoScreen();

  @override
  State<_DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<_DemoScreen> {
  int _day = 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CycleColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            CycleRoomWidget(
              currentDay: _day,
              onDaySelected: (d) => setState(() => _day = d),
            ),
          ],
        ),
      ),
    );
  }
}