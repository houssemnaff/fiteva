import 'package:flutter/material.dart';

class CycleHeader extends StatelessWidget {
  final int currentDay;
  final bool showWheel;
  final VoidCallback onShowWheel;
  final VoidCallback onShowCalendar;
  final VoidCallback onClose;

  const CycleHeader({
    super.key,
    required this.currentDay,
    required this.showWheel,
    required this.onShowWheel,
    required this.onShowCalendar,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Top bar ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              // Close button
             

              const Spacer(),

              // Title
             

              const Spacer(),

              // Toggle group
              _ToggleGroup(
                showWheel: showWheel,
                onShowWheel: onShowWheel,
                onShowCalendar: onShowCalendar,
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),
      ],
    );
  }
}

// ──────────────────────────────────────────────
//  Toggle group
// ──────────────────────────────────────────────
class _ToggleGroup extends StatelessWidget {
  final bool showWheel;
  final VoidCallback onShowWheel;
  final VoidCallback onShowCalendar;

  const _ToggleGroup({
    required this.showWheel,
    required this.onShowWheel,
    required this.onShowCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _ToggleBtn(
            active: showWheel,
            icon: Icons.radio_button_checked_rounded,
            onTap: onShowWheel,
          ),
          const SizedBox(width: 2),
          _ToggleBtn(
            active: !showWheel,
            icon: Icons.calendar_month_rounded,
            onTap: onShowCalendar,
          ),
        ],
      ),
    );
  }
}
class _ToggleBtn extends StatelessWidget {
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.active,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? Colors.white : Colors.transparent,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFC1547A).withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 15,
          color: active
              ? const Color(0xFFC1547A)
              : const Color(0xFFB07A9A),
        ),
      ),
    );
  }
} 
// ──────────────────────────────────────────────
//  Phase legend pill
// ──────────────────────────────────────────────


// ──────────────────────────────────────────────
//  Round icon button
// ──────────────────────────────────────────────
class _RoundBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _RoundBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF3E8EF),
        ),
        child: child,
      ),
    );
  }
}