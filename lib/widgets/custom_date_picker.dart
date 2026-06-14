// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shows the custom bottom-sheet date picker.
/// Returns the selected [DateTime] or null if dismissed.
Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String title    = 'Choisir une date',
  String subtitle = '',
  IconData icon   = Icons.calendar_today_rounded,
  Color accentColor = const Color(0xFFD94F6B),
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CustomDatePicker(
      initialDate:  initialDate,
      firstDate:    firstDate,
      lastDate:     lastDate,
      title:        title,
      subtitle:     subtitle,
      icon:         icon,
      accentColor:  accentColor,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class _CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String   title;
  final String   subtitle;
  final IconData icon;
  final Color    accentColor;

  const _CustomDatePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  State<_CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<_CustomDatePicker> {
  late DateTime  _focused;
  late DateTime? _selected;

  static const _months = [
    'Janvier','Fevrier','Mars','Avril','Mai','Juin',
    'Juillet','Aout','Septembre','Octobre','Novembre','Decembre',
  ];
  static const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _focused  = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  void _prevMonth() {
    final prev = DateTime(_focused.year, _focused.month - 1);
    if (prev.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month))) return;
    setState(() => _focused = prev);
  }

  void _nextMonth() {
    final next = DateTime(_focused.year, _focused.month + 1);
    if (next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month))) return;
    setState(() => _focused = next);
  }

  bool _isSelectable(DateTime d) =>
      !d.isBefore(widget.firstDate) && !d.isAfter(widget.lastDate);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg       = isDark ? const Color(0xFF0E1117) : Colors.white;
    final surface  = isDark ? const Color(0xFF1A1F2A) : const Color(0xFFF5F6FA);
    final cardCol  = isDark ? const Color(0xFF222837)  : const Color(0xFFEAECF3);
    final textCol  = isDark ? Colors.white              : const Color(0xFF1A1A2E);
    final textMid  = isDark ? const Color(0xFF8B93A8)  : const Color(0xFF888FAA);
    final borderCol= isDark ? const Color(0xFF2A3045)  : const Color(0xFFE2E5F0);

    final accent     = widget.accentColor;
    final accentSoft = accent.withOpacity(0.15);

    final firstDay   = DateTime(_focused.year, _focused.month, 1);
    final startOff   = (firstDay.weekday - 1) % 7;
    final daysInMonth= DateUtils.getDaysInMonth(_focused.year, _focused.month);
    final rows       = ((startOff + daysInMonth) / 7).ceil();

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        // Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 24),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: borderCol,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Title row
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, size: 19, color: accent),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.title,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700,
                color: textCol)),
            if (widget.subtitle.isNotEmpty)
              Text(widget.subtitle,
                style: GoogleFonts.inter(fontSize: 12, color: textMid)),
          ]),
        ]),

        const SizedBox(height: 24),

        // Month nav
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol),
          ),
          child: Row(children: [
            GestureDetector(
              onTap: _prevMonth,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: cardCol, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.chevron_left_rounded, size: 20, color: textMid),
              ),
            ),
            Expanded(child: Text(
              '${_months[_focused.month - 1]} ${_focused.year}',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700,
                color: textCol),
            )),
            GestureDetector(
              onTap: _nextMonth,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: cardCol, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.chevron_right_rounded, size: 20, color: textMid),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // Day headers
        Row(
          children: _days.map((d) => Expanded(
            child: Center(child: Text(d,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                color: textMid))),
          )).toList(),
        ),

        const SizedBox(height: 10),

        // Grid
        Column(
          children: List.generate(rows, (row) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: List.generate(7, (col) {
                final dayNum = row * 7 + col - startOff + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 40));
                }
                final date       = DateTime(_focused.year, _focused.month, dayNum);
                final isToday    = DateUtils.isSameDay(date, DateTime.now());
                final isSelected = DateUtils.isSameDay(date, _selected);
                final canSelect  = _isSelectable(date);

                return Expanded(child: GestureDetector(
                  onTap: canSelect
                      ? () { HapticFeedback.selectionClick(); setState(() => _selected = date); }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accent
                          : isToday ? accentSoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected
                          ? Border.all(color: accent.withOpacity(0.5), width: 1)
                          : null,
                    ),
                    child: Center(child: Text('$dayNum',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : canSelect ? textCol : textMid.withOpacity(0.35),
                      ))),
                  ),
                ));
              }),
            ),
          )),
        ),

        const SizedBox(height: 20),

        // Selected date chip
        if (_selected != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Row(children: [
              Icon(widget.icon, size: 16, color: accent),
              const SizedBox(width: 8),
              Text(
                '${_selected!.day}/${_selected!.month}/${_selected!.year}',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                  color: accent),
              ),
            ]),
          ),

        const SizedBox(height: 20),

        // CTA
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _selected != null
                ? () => Navigator.pop(context, _selected)
                : null,
            child: Text('Confirmer',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}
