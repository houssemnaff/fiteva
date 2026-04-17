import 'package:flutter/material.dart';
import 'cycle_wheel.dart'; // for phaseForDay / colorForDay

class CycleCalendar extends StatelessWidget {
  final int currentDay;
  final int todayDay; // actual today highlight (dot)
  final Function(int) onDaySelected;

  const CycleCalendar({
    super.key,
    required this.currentDay,
    this.todayDay = 16,
    required this.onDaySelected,
  });
Color colorForDay(int day) {
  return phaseForDay(day).color;
}
  // April 2026 starts on Wednesday → Mon=0, Wed=2
  static const int _startOffset = 2;
  static const int _daysInMonth = 30;

  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Weekday headers ─────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: _weekdays
                .map(
                  (d) => Expanded(
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
                  ),
                )
                .toList(),
          ),
        ),

        const SizedBox(height: 8),

        // ── Grid ────────────────────────────────
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
            // Empty offset cells
            if (index < _startOffset) return const SizedBox();

            final day = index - _startOffset + 1;
            return _DayCell(
              day: day,
              isSelected: day == currentDay,
              isToday: day == todayDay,
              phaseColor: colorForDay(day),
              onTap: () => onDaySelected(day),
            );
          },
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
//  Single day cell
// ──────────────────────────────────────────────
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
              : Border.all(color: phaseColor.withOpacity(0.25), width: 0.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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