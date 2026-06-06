// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'cycle_wheel.dart';

class CycleCalendar extends StatelessWidget {
  /// Which month to display.
  final int displayYear;
  final int displayMonth; // 1-12

  /// The actual current date (used for "today" dot and phase prediction).
  final DateTime today;

  /// What cycle day today is (1-28). Used to predict phases in other months.
  final int todayCycleDay;

  /// Currently selected cycle day (1-28), for highlighting.
  final int selectedCycleDay;

  /// Called with the cycle day (1-28) when user taps a day.
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

  // ── Computed properties ─────────────────────────────────────────────────────

  /// Day-of-week offset for the 1st (0=Mon, 6=Sun).
  int get _startOffset =>
      DateTime(displayYear, displayMonth, 1).weekday - 1;

  int get _daysInMonth =>
      DateTime(displayYear, displayMonth + 1, 0).day;

  /// Cycle day (1-28) for a given calendar day in the displayed month.
  int _cycleDay(int day) {
    final date = DateTime(displayYear, displayMonth, day);
    final cycleStart = today.subtract(Duration(days: todayCycleDay - 1));
    final diff = date.difference(DateTime(
      cycleStart.year,
      cycleStart.month,
      cycleStart.day,
    )).inDays;
    // Handle negative (past months) and positive (future months)
    return ((diff % 28) + 28) % 28 + 1;
  }

  bool get _isCurrentMonth =>
      displayYear == today.year && displayMonth == today.month;

  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Weekday headers ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: _weekdays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB07A9A),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),

        const SizedBox(height: 8),

        // ── Day grid ──────────────────────────────────────────────────────────
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 4,
          ),
          itemCount: _startOffset + _daysInMonth,
          itemBuilder: (context, index) {
            if (index < _startOffset) return const SizedBox();

            final day = index - _startOffset + 1;
            final cd = _cycleDay(day);
            final isToday =
                _isCurrentMonth && day == today.day;

            return _DayCell(
              day: day,
              isSelected: _isCurrentMonth && cd == selectedCycleDay,
              isToday: isToday,
              phaseColor: phaseForDay(cd).color,
              onTap: () => onDaySelected(cd),
            );
          },
        ),

        // ── Phase legend ──────────────────────────────────────────────────────
        const SizedBox(height: 20),
        _PhaseLegend(),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Single day cell
// ─────────────────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isToday;
  final Color phaseColor;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.phaseColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? const Color(0xFFC1547A)
        : phaseColor.withOpacity(0.14);

    final textColor = isSelected
        ? Colors.white
        : Color.lerp(phaseColor, const Color(0xFF3D2033), 0.35)!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: isSelected
              ? null
              : Border.all(
                  color: isToday
                      ? const Color(0xFFC1547A)
                      : phaseColor.withOpacity(0.25),
                  width: isToday ? 1.5 : 0.5,
                ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight:
                    isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
            if (isToday && !isSelected)
              Positioned(
                bottom: 5,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFC1547A),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Phase legend
// ─────────────────────────────────────────────────────────────────────────────

class _PhaseLegend extends StatelessWidget {
  static const _items = [
    _LegendItem('Règles', Color(0xFFE58F8A)),
    _LegendItem('Folliculaire', Color(0xFF7ABB98)),
    _LegendItem('Ovulation', Color(0xFF1C4D30)),
    _LegendItem('Lutéale', Color(0xFFA7B8AD)),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: _items
          .map((item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9E8A93),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }
}

class _LegendItem {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);
}
