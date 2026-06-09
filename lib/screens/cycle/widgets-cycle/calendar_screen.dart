// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Couleurs ──────────────────────────────────────────────────────────────────
const _kGreen   = Color(0xFF1C4D30);
const _kRed     = Color(0xFFD94F6B);
const _kSurface = Color(0xFFFAFAF8);
const _kText    = Color(0xFF111110);
const _kMuted   = Color(0xFFAAAAAA);
const _kDivider = Color(0xFFEEEEEC);

const _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
const _monthNames = [
  'Janvier','Février','Mars','Avril','Mai','Juin',
  'Juillet','Août','Septembre','Octobre','Novembre','Décembre',
];

// ─────────────────────────────────────────────────────────────────────────────
//  PUBLIC WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class CycleCalendar extends StatefulWidget {
  final int      displayYear;
  final int      displayMonth;
  final DateTime today;
  final int      todayCycleDay;
  final int      selectedCycleDay;
  final Function(int) onDaySelected;

  const CycleCalendar({
    super.key,
    required this.displayYear,
    required this.displayMonth,
    required this.today,
    required this.todayCycleDay,
    required this.selectedCycleDay,
    required this.onDaySelected,
  });

  @override
  State<CycleCalendar> createState() => _CycleCalendarState();
}

class _CycleCalendarState extends State<CycleCalendar> {
  static const _cycleLen  = 28;
  static const _periodLen = 5;

  bool _editMode = false;
  late Set<DateTime> _loggedPeriod;

  @override
  void initState() {
    super.initState();
    _loggedPeriod = {};
    final base = widget.today.subtract(
        Duration(days: widget.todayCycleDay - 1));
    for (int i = 0; i < _periodLen; i++) {
      final d = base.add(Duration(days: i));
      _loggedPeriod.add(DateTime(d.year, d.month, d.day));
    }
  }

  DateTime get _cycleStart => widget.today
      .subtract(Duration(days: widget.todayCycleDay - 1));

  int _cycleDay(DateTime d) {
    final s    = DateTime(_cycleStart.year, _cycleStart.month, _cycleStart.day);
    final diff = DateTime(d.year, d.month, d.day).difference(s).inDays;
    return ((diff % _cycleLen) + _cycleLen) % _cycleLen + 1;
  }

  bool _isPredictedPeriod(DateTime d) {
    final plain = DateTime(d.year, d.month, d.day);
    final now   = DateTime(widget.today.year, widget.today.month, widget.today.day);
    if (!plain.isAfter(now)) return false;
    final cd = _cycleDay(plain);
    return cd >= 1 && cd <= _periodLen;
  }

  bool _isToday(DateTime d) =>
      d.year == widget.today.year &&
      d.month == widget.today.month &&
      d.day   == widget.today.day;

  List<DateTime> get _months {
    final out = <DateTime>[];
    for (int i = -6; i <= 12; i++) {
      int m = widget.today.month + i;
      int y = widget.today.year;
      while (m <  1) { m += 12; y--; }
      while (m > 12) { m -= 12; y++; }
      out.add(DateTime(y, m));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final months = _months;
    final todayIdx = months.indexWhere(
        (m) => m.year == widget.today.year && m.month == widget.today.month);
    final ctrl = ScrollController(
        initialScrollOffset: math.max(0, todayIdx * 340.0));

    return Scaffold(
      backgroundColor: _kSurface,
      body: Stack(children: [

        // ── Month list ──────────────────────────────────────────────
        CustomScrollView(
          controller: ctrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(top)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _MonthBlock(
                  month: months[i],
                  today: widget.today,
                  loggedPeriod: _loggedPeriod,
                  isPredictedPeriod: _isPredictedPeriod,
                  isToday: _isToday,
                  editMode: _editMode,
                  onToggleDay: (d) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      final p = DateTime(d.year, d.month, d.day);
                      if (_loggedPeriod.contains(p)) _loggedPeriod.remove(p);
                      else _loggedPeriod.add(p);
                    });
                    widget.onDaySelected(_cycleDay(d));
                  },
                ),
                childCount: months.length,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: bottom + 90)),
          ],
        ),

        // ── Bouton flottant ─────────────────────────────────────────
        Positioned(
          left: 20, right: 20,
          bottom: bottom + 16,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _editMode = !_editMode);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _editMode ? _kRed : _kGreen,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(
                  color: (_editMode ? _kRed : _kGreen).withOpacity(0.30),
                  blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Center(
                child: Text(
                  _editMode
                      ? '✓  Terminer l\'édition'
                      : '✏  Modifier les dates des règles',
                  style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 15,
                    fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader(double top) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, top + 14, 20, 14),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 38, height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFF4F4F2),
              shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded, size: 18, color: _kText),
          ),
        ),
        const Spacer(),
        Text('Calendrier du cycle', style: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w800, color: _kText)),
        const Spacer(),
        // Légende
        Row(children: [
          _dot(_kRed, filled: true),
          const SizedBox(width: 6),
          Text('Règles', style: GoogleFonts.inter(
              fontSize: 11, color: _kMuted)),
          const SizedBox(width: 12),
          _dot(_kGreen, filled: true),
          const SizedBox(width: 6),
          Text('Auj.', style: GoogleFonts.inter(
              fontSize: 11, color: _kMuted)),
        ]),
      ]),
    );
  }

  Widget _dot(Color c, {required bool filled}) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(
      color: filled ? c : Colors.transparent,
      shape: BoxShape.circle,
      border: filled ? null : Border.all(color: c, width: 1.5)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  MONTH BLOCK
// ─────────────────────────────────────────────────────────────────────────────
class _MonthBlock extends StatelessWidget {
  final DateTime month;
  final DateTime today;
  final Set<DateTime> loggedPeriod;
  final bool Function(DateTime) isPredictedPeriod;
  final bool Function(DateTime) isToday;
  final bool editMode;
  final ValueChanged<DateTime> onToggleDay;

  const _MonthBlock({
    required this.month,
    required this.today,
    required this.loggedPeriod,
    required this.isPredictedPeriod,
    required this.isToday,
    required this.editMode,
    required this.onToggleDay,
  });

  int get _startOffset => DateTime(month.year, month.month, 1).weekday - 1;
  int get _daysInMonth => DateTime(month.year, month.month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final isCurrent =
        month.year == today.year && month.month == today.month;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month title ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _monthNames[month.month - 1],
                  style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: isCurrent ? _kGreen : _kText),
                ),
                if (month.year != today.year) ...[
                  const SizedBox(width: 8),
                  Text('${month.year}', style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w500,
                    color: _kMuted)),
                ],
                if (isCurrent) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3EC),
                      borderRadius: BorderRadius.circular(20)),
                    child: Text('Ce mois-ci', style: GoogleFonts.inter(
                      fontSize: 10, color: _kGreen,
                      fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ),

          // ── Jours de la semaine ───────────────────────────────────
          Row(children: _weekDays.map((d) => Expanded(
            child: Center(child: Text(d, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: _kMuted))),
          )).toList()),

          const SizedBox(height: 6),

          // ── Grille de jours ───────────────────────────────────────
          _buildGrid(),

          const SizedBox(height: 16),
          Divider(color: _kDivider, height: 1),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final total = _startOffset + _daysInMonth;
    final rows  = (total / 7).ceil();

    return Column(
      children: List.generate(rows, (row) => Row(
        children: List.generate(7, (col) {
          final idx = row * 7 + col;
          if (idx < _startOffset || idx >= _startOffset + _daysInMonth) {
            return const Expanded(child: SizedBox(height: 46));
          }
          final day   = idx - _startOffset + 1;
          final date  = DateTime(month.year, month.month, day);
          final plain = DateTime(date.year, date.month, date.day);

          return Expanded(
            child: GestureDetector(
              onTap: () => onToggleDay(date),
              child: SizedBox(
                height: 46,
                child: Center(child: _DayCircle(
                  day: day,
                  isPeriod:    loggedPeriod.contains(plain),
                  isPredicted: isPredictedPeriod(date),
                  isToday:     isToday(date),
                  editMode:    editMode,
                )),
              ),
            ),
          );
        }),
      )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DAY CIRCLE
// ─────────────────────────────────────────────────────────────────────────────
class _DayCircle extends StatelessWidget {
  final int day;
  final bool isPeriod, isPredicted, isToday, editMode;

  const _DayCircle({
    required this.day,
    required this.isPeriod,
    required this.isPredicted,
    required this.isToday,
    required this.editMode,
  });

  @override
  Widget build(BuildContext context) {
    final label = '$day';

    if (isPeriod) {
      return Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(color: _kRed, shape: BoxShape.circle),
        child: Center(child: Text(label, style: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
      );
    }

    if (isPredicted) {
      return CustomPaint(
        painter: _DashPainter(_kRed),
        child: SizedBox(width: 36, height: 36,
          child: Center(child: Text(label, style: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: _kRed)))),
      );
    }

    if (isToday) {
      return Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(color: _kGreen, shape: BoxShape.circle),
        child: Center(child: Text(label, style: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white))),
      );
    }

    if (editMode) {
      return Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _kRed.withOpacity(0.06), shape: BoxShape.circle),
        child: Center(child: Text(label, style: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: _kText))),
      );
    }

    return SizedBox(width: 36, height: 36,
      child: Center(child: Text(label, style: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: _kText))),
    );
  }
}

// ── Dashed circle painter ─────────────────────────────────────────────────────
class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ..style = PaintingStyle.stroke ..strokeWidth = 1.8;
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2.0;
    const n = 10;
    for (int i = 0; i < n; i++) {
      final start = (2 * math.pi * i) / n;
      canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          start, math.pi / n - 0.20, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
