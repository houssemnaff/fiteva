// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'dart:ui';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:fiteva/screens/cycle/cycle_colors.dart';
import 'package:fiteva/widgets/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

const _kPeriod     = Color(0xFFE88B8B);
const _kOvulation  = Color(0xFFE8AD6E);
const _weekDays    = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
const _monthNames  = [
  'Janvier','Février','Mars','Avril','Mai','Juin',
  'Juillet','Août','Septembre','Octobre','Novembre','Décembre',
];

Color _screenBg(bool isDark) =>
    isDark ? const Color(0xFF111114) : const Color.fromARGB(255, 255, 255, 255);

// ─────────────────────────────────────────────────────────────────────────────
//  PUBLIC WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class CycleCalendar extends ConsumerStatefulWidget {
  final int      displayYear;
  final int      displayMonth;
  final DateTime today;
  final int      todayCycleDay;
  final int      selectedCycleDay;
  final Function(DateTime)? onDaySelected;
  final DateTime? lastPeriodDate;
  final Function(DateTime)? onSavePeriod;

  const CycleCalendar({
    super.key,
    required this.displayYear,
    required this.displayMonth,
    required this.today,
    required this.todayCycleDay,
    required this.selectedCycleDay,
    this.onDaySelected,
    this.lastPeriodDate,
    this.onSavePeriod,
  });

  @override
  ConsumerState<CycleCalendar> createState() => _CycleCalendarState();
}

class _CycleCalendarState extends ConsumerState<CycleCalendar> {
  bool _editMode = false;
  late Set<DateTime> _loggedPeriod;
  late DateTime _editStart;
  int _editDuration = 5;

  @override
  void initState() {
    super.initState();
    _loggedPeriod = {};
    final base = widget.lastPeriodDate != null
        ? DateTime(widget.lastPeriodDate!.year,
                   widget.lastPeriodDate!.month,
                   widget.lastPeriodDate!.day)
        : widget.today.subtract(Duration(days: widget.todayCycleDay - 1));
    for (int i = 0; i < 5; i++) {
      final d = base.add(Duration(days: i));
      _loggedPeriod.add(DateTime(d.year, d.month, d.day));
    }
    _editStart = base;
  }

  static const _cycleLen = 28;

  DateTime get _cycleStart =>
      widget.today.subtract(Duration(days: widget.todayCycleDay - 1));

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
    return cd >= 1 && cd <= 5;
  }

  bool _isOvulation(DateTime d) {
    final plain = DateTime(d.year, d.month, d.day);
    final now   = DateTime(widget.today.year, widget.today.month, widget.today.day);
    if (plain.isBefore(now)) return false;
    if (_isPredictedPeriod(d)) return false;
    final cd = _cycleDay(plain);
    return cd >= 12 && cd <= 16;
  }

  bool _isFuture(DateTime d) {
    final plain = DateTime(d.year, d.month, d.day);
    final now   = DateTime(widget.today.year, widget.today.month, widget.today.day);
    return plain.isAfter(now);
  }

  bool _isToday(DateTime d) =>
      d.year == widget.today.year &&
      d.month == widget.today.month &&
      d.day == widget.today.day;

  Set<DateTime> get _editDays {
    final s = <DateTime>{};
    for (int i = 0; i < _editDuration; i++) {
      final d = _editStart.add(Duration(days: i));
      s.add(DateTime(d.year, d.month, d.day));
    }
    return s;
  }

  DateTime get _editEnd =>
      _editStart.add(Duration(days: _editDuration - 1));

  Set<DateTime> get _visiblePeriod => _editMode ? _editDays : _loggedPeriod;

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

  String _fmtDate(DateTime d) {
    const m = ['jan','fév','mar','avr','mai','juin',
                'juil','août','sep','oct','nov','déc'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  void _enterEdit() {
    final sorted = _loggedPeriod.toList()..sort((a, b) => a.compareTo(b));
    _editStart    = sorted.isNotEmpty ? sorted.first : widget.today;
    _editDuration = _loggedPeriod.length.clamp(1, 10);
    setState(() => _editMode = true);
  }

  void _cancelEdit() => setState(() => _editMode = false);

  void _saveEdit() {
    HapticFeedback.mediumImpact();
    setState(() { _loggedPeriod = _editDays; _editMode = false; });
    widget.onSavePeriod?.call(_editStart);
  }

  Future<void> _pickStartDate() async {
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: _editStart,
      firstDate: DateTime(2023),
      lastDate: widget.today,
      title: 'Debut des regles',
      subtitle: 'Choisir la date de debut',
      icon: Icons.water_drop_rounded,
      accentColor: _kPeriod,
    );
    if (picked != null) {
      setState(() => _editStart = DateTime(picked.year, picked.month, picked.day));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = ref.watch(l10nProvider);
    final cc     = CycleColors.of(context);
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final months = _months;
    final todayIdx = months.indexWhere(
        (m) => m.year == widget.today.year && m.month == widget.today.month);
    final ctrl = ScrollController(
        initialScrollOffset: math.max(0, todayIdx * 360.0));

    return Scaffold(
      backgroundColor: _screenBg(cc.isDark),
      body: Column(
        children: [
          _buildHeader(cc, top, l10n),
          Expanded(
            child: Stack(
              children: [
                CustomScrollView(
                  controller: ctrl,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _MonthBlock(
                          month:             months[i],
                          today:             widget.today,
                          loggedPeriod:      _visiblePeriod,
                          isPredictedPeriod: _editMode ? (_) => false : _isPredictedPeriod,
                          isOvulation:       _editMode ? (_) => false : _isOvulation,
                          isToday:           _isToday,
                          editMode:          _editMode,
                          cc:                cc,
                          l10n:              l10n,
                          onToggleDay: _editMode
                              ? (_) {}
                              : (d) {
                                  if (_isFuture(d)) return;
                                  HapticFeedback.selectionClick();
                                  widget.onDaySelected?.call(d);
                                },
                        ),
                        childCount: months.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: SizedBox(height: bottom + (_editMode ? 300 : 100))),
                  ],
                ),

                if (_editMode)
                  Positioned(
                    left: 0, right: 0, bottom: 0,
                    child: _EditPanel(
                      bottom:            bottom,
                      editStart:         _editStart,
                      editEnd:           _editEnd,
                      editDuration:      _editDuration,
                      fmtDate:           _fmtDate,
                      cc:                cc,
                      l10n:              l10n,
                      onPickStart:       _pickStartDate,
                      onDurationChanged: (v) => setState(() => _editDuration = v),
                      onCancel:          _cancelEdit,
                      onSave:            _saveEdit,
                    ),
                  ),

                if (!_editMode)
                  Positioned(
                    left: 20, right: 20, bottom: bottom + 20,
                    child: GestureDetector(
                      onTap: () { HapticFeedback.lightImpact(); _enterEdit(); },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            decoration: BoxDecoration(
                              color: _kPeriod.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [BoxShadow(
                                color: _kPeriod.withOpacity(0.35),
                                blurRadius: 20, offset: const Offset(0, 8),
                              )],
                            ),
                            child: Center(
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.edit_outlined,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(l10n.calModifier, style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(CycleColors cc, double top, AppL10n l10n) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: cc.isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.65),
            border: Border(bottom: BorderSide(
              color: cc.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
            )),
          ),
          padding: EdgeInsets.fromLTRB(16, top + 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: cc.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.chevron_left_rounded,
                        size: 24, color: cc.text),
                  ),
                ),
                const SizedBox(width: 12),
                Text(l10n.calTitle, style: GoogleFonts.outfit(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: cc.text)),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                _legendChip(cc, color: _kPeriod, label: l10n.calRegles, filled: true),
                const SizedBox(width: 8),
                _legendChip(cc, color: _kOvulation, label: l10n.calOvulation, filled: false),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendChip(CycleColors cc,
      {required Color color, required String label, required bool filled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(cc.isDark ? 0.15 : 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: filled ? color : Colors.transparent,
            shape: BoxShape.circle,
            border: filled ? null : Border.all(color: color, width: 1.5)),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EDIT PANEL
// ─────────────────────────────────────────────────────────────────────────────

class _EditPanel extends StatelessWidget {
  final double bottom;
  final DateTime editStart, editEnd;
  final int editDuration;
  final String Function(DateTime) fmtDate;
  final CycleColors cc;
  final AppL10n l10n;
  final VoidCallback onPickStart;
  final ValueChanged<int> onDurationChanged;
  final VoidCallback onCancel, onSave;

  const _EditPanel({
    required this.bottom, required this.editStart, required this.editEnd,
    required this.editDuration, required this.fmtDate, required this.cc,
    required this.l10n,
    required this.onPickStart, required this.onDurationChanged,
    required this.onCancel, required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: cc.isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(
              color: cc.isDark ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.90),
            )),
          ),
          padding: EdgeInsets.fromLTRB(20, 14, 20, bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: cc.isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 20),

              Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                      color: _kPeriod.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.water_drop_outlined, size: 17, color: _kPeriod),
                ),
                const SizedBox(width: 12),
                Text(l10n.calModifier, style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: cc.text)),
              ]),
              const SizedBox(height: 22),

              _FieldLabel(l10n.calDateDebut, cc),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onPickStart,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _kPeriod.withOpacity(cc.isDark ? 0.10 : 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kPeriod.withOpacity(0.20)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: _kPeriod.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.calendar_today_outlined,
                          size: 15, color: _kPeriod),
                    ),
                    const SizedBox(width: 12),
                    Text(fmtDate(editStart), style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600, color: cc.text)),
                    const Spacer(),
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                          color: cc.isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.edit_outlined, size: 13, color: cc.muted),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 18),

              _FieldLabel(l10n.calDuree, cc),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(8, (i) {
                    final d   = i + 2;
                    final sel = d == editDuration;
                    return GestureDetector(
                      onTap: () => onDurationChanged(d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: sel ? _kPeriod : (cc.isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
                          borderRadius: BorderRadius.circular(14),
                          border: sel ? null : Border.all(
                            color: cc.isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.08)),
                          boxShadow: sel
                              ? [BoxShadow(color: _kPeriod.withOpacity(0.28),
                                  blurRadius: 10, offset: const Offset(0, 3))]
                              : null,
                        ),
                        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('$d', style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : cc.text)),
                          Text('j', style: GoogleFonts.inter(
                            fontSize: 9, fontWeight: FontWeight.w500,
                            color: sel ? Colors.white.withOpacity(0.8) : cc.muted)),
                        ])),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 18),

              _FieldLabel(l10n.calDateFin, cc),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _kPeriod.withOpacity(cc.isDark ? 0.10 : 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kPeriod.withOpacity(0.20)),
                ),
                child: Row(children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                        color: _kPeriod.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.event_available_outlined,
                        size: 15, color: _kPeriod),
                  ),
                  const SizedBox(width: 12),
                  Text(fmtDate(editEnd), style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w600, color: _kPeriod)),
                ]),
              ),
              const SizedBox(height: 24),

              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: cc.isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: cc.isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.08)),
                      ),
                      child: Center(child: Text(l10n.calAnnuler, style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w600, color: cc.muted))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: _kPeriod,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [BoxShadow(
                          color: _kPeriod.withOpacity(0.35),
                          blurRadius: 14, offset: const Offset(0, 5),
                        )],
                      ),
                      child: Center(child: Text(l10n.calSauvegarder, style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: Colors.white))),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final CycleColors cc;
  const _FieldLabel(this.text, this.cc);

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
    style: GoogleFonts.inter(
      fontSize: 10, fontWeight: FontWeight.w700,
      color: cc.muted, letterSpacing: 2.0));
}

// ─────────────────────────────────────────────────────────────────────────────
//  MONTH BLOCK
// ─────────────────────────────────────────────────────────────────────────────

class _MonthBlock extends StatelessWidget {
  final DateTime month, today;
  final Set<DateTime> loggedPeriod;
  final bool Function(DateTime) isPredictedPeriod;
  final bool Function(DateTime) isOvulation;
  final bool Function(DateTime) isToday;
  final bool editMode;
  final CycleColors cc;
  final ValueChanged<DateTime> onToggleDay;
  final AppL10n l10n;

  const _MonthBlock({
    required this.month, required this.today,
    required this.loggedPeriod,
    required this.isPredictedPeriod, required this.isOvulation,
    required this.isToday, required this.editMode,
    required this.cc, required this.onToggleDay,
    required this.l10n,
  });

  int get _startOffset => DateTime(month.year, month.month, 1).weekday - 1;
  int get _daysInMonth => DateTime(month.year, month.month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final isCurrent = month.year == today.year && month.month == today.month;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(_monthNames[month.month - 1], style: GoogleFonts.outfit(
                fontSize: 24, fontWeight: FontWeight.w700,
                color: cc.text)),
              if (month.year != today.year) ...[
                const SizedBox(width: 8),
                Text('${month.year}', style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w500, color: cc.muted)),
              ],
              if (isCurrent) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cc.isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(l10n.cycleCeMois, style: GoogleFonts.inter(
                    fontSize: 11, color: cc.text, fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
          ),
          Row(children: _weekDays.map((d) => Expanded(
            child: Center(child: Text(d, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: cc.muted))),
          )).toList()),
          const SizedBox(height: 6),
          _buildGrid(),
          const SizedBox(height: 16),
          Container(height: 1, color: cc.isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
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
            return const Expanded(child: SizedBox(height: 48));
          }
          final day   = idx - _startOffset + 1;
          final date  = DateTime(month.year, month.month, day);
          final plain = DateTime(date.year, date.month, date.day);

          return Expanded(
            child: GestureDetector(
              onTap: () => onToggleDay(date),
              child: SizedBox(
                height: 48,
                child: Center(child: _DayCircle(
                  day:         day,
                  isPeriod:    loggedPeriod.contains(plain),
                  isPredicted: isPredictedPeriod(date),
                  isOvulation: isOvulation(date),
                  isToday:     isToday(date),
                  editMode:    editMode,
                  cc:          cc,
                  l10n:        l10n,
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
  final bool isPeriod, isPredicted, isOvulation, isToday, editMode;
  final CycleColors cc;
  final AppL10n l10n;

  const _DayCircle({
    required this.day, required this.isPeriod,
    required this.isPredicted, required this.isOvulation,
    required this.isToday, required this.editMode, required this.cc,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final label = '$day';

    if (isPeriod) {
      return Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: _kPeriod,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: _kPeriod.withOpacity(editMode ? 0.40 : 0.25),
            blurRadius: editMode ? 10 : 6, offset: const Offset(0, 2),
          )],
        ),
        child: Center(child: Text(label, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
      );
    }

    if (isPredicted) {
      return CustomPaint(
        painter: _DottedCirclePainter(color: _kPeriod, dotCount: 14, dotRadius: 1.6),
        child: SizedBox(width: 38, height: 38,
          child: Center(child: Text(label, style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600, color: _kPeriod)))),
      );
    }

    if (isOvulation) {
      return CustomPaint(
        painter: _DottedCirclePainter(color: _kOvulation, dotCount: 14, dotRadius: 1.6),
        child: SizedBox(width: 38, height: 38,
          child: Center(child: Text(label, style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600, color: _kOvulation)))),
      );
    }

    if (isToday) {
      return Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cc.isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06),
        ),
        child: Center(child: Text(label, style: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w800, color: cc.text))),
      );
    }

    return SizedBox(width: 38, height: 38,
      child: Center(child: Text(label, style: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: cc.text))),
    );
  }
}

// ── Dotted circle painter ────────────────────────────────────────────────────

class _DottedCirclePainter extends CustomPainter {
  final Color color;
  final int dotCount;
  final double dotRadius;
  const _DottedCirclePainter({required this.color, this.dotCount = 14, this.dotRadius = 1.4});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.width / 2) - 1.5;
    final paint = Paint()..color = color;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * math.pi - math.pi / 2;
      canvas.drawCircle(
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        dotRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DottedCirclePainter old) =>
      old.color != color || old.dotCount != dotCount;
}
