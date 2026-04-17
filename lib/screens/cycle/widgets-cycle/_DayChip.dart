  import 'package:flutter/material.dart';

  // ──────────────────────────────────────────────
  //  Reuse your phase model (or import from cycle_wheel.dart)
  // ──────────────────────────────────────────────
  class CyclePhase {
    final String name;
    final String description;
    final Color color;
    final Color lightColor;
    final List<int> days;

    const CyclePhase({
      required this.name,
      required this.description,
      required this.color,
      required this.lightColor,
      required this.days,
    });
  }

  const List<CyclePhase> kPhases = [
    CyclePhase(
      name: 'Règles',
      description: 'Corps au repos',
      color: Color(0xFFD94F6B),
      lightColor: Color(0xFFFDE8EC),
      days: [1, 2, 3, 4, 5],
    ),
    CyclePhase(
      name: 'Folliculaire',
      description: 'Énergie en hausse',
      color: Color(0xFF5BAE8A),
      lightColor: Color(0xFFE0F5EC),
      days: [6, 7, 8, 9, 10, 11, 12, 13],
    ),
    CyclePhase(
      name: 'Ovulation',
      description: 'Pic de fertilité',
      color: Color(0xFFE8A030),
      lightColor: Color(0xFFFDF0DC),
      days: [14, 15, 16],
    ),
    CyclePhase(
      name: 'Lutéale',
      description: 'Corps se prépare',
      color: Color(0xFF6B8FD4),
      lightColor: Color(0xFFE4ECFB),
      days: [17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
    ),
  ];

  CyclePhase phaseForDay(int day) =>
      kPhases.firstWhere((p) => p.days.contains(day), orElse: () => kPhases.last);

  // ──────────────────────────────────────────────
  //  Day Chip
  // ──────────────────────────────────────────────
  class _DayChip extends StatelessWidget {
    final int day;
    final bool isSelected;
    final VoidCallback onTap;

    const _DayChip({
      required this.day,
      required this.isSelected,
      required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
      final phase = phaseForDay(day);

      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: 40,
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          transform: isSelected
              ? (Matrix4.identity()..translate(0.0, -4.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: isSelected ? phase.color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? phase.color : const Color(0xFFECE0E8),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: phase.color.withOpacity(0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Phase dot indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white.withOpacity(0.6)
                      : phase.color,
                ),
              ),
              const SizedBox(height: 5),
              // Day number
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF3D2033),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ──────────────────────────────────────────────
  //  Phase progress bar
  // ──────────────────────────────────────────────
  class _PhaseBar extends StatelessWidget {
    final int currentDay;

    const _PhaseBar({required this.currentDay});

    @override
    Widget build(BuildContext context) {
      final activePhase = phaseForDay(currentDay);

      return Row(
        children: kPhases.map((phase) {
          final isActive = phase == activePhase;
          return Expanded(
            flex: phase.days.length,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: phase.color.withOpacity(isActive ? 1.0 : 0.22),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: phase.color.withOpacity(isActive ? 1.0 : 0.35),
                    ),
                    child: Text(phase.name, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  // ──────────────────────────────────────────────
  //  Day info header
  // ──────────────────────────────────────────────
  class _DayInfoHeader extends StatelessWidget {
    final int currentDay;

    const _DayInfoHeader({required this.currentDay});

    @override
    Widget build(BuildContext context) {
      final phase = phaseForDay(currentDay);

      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    'Jour $currentDay',
                    key: ValueKey(currentDay),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3D2033),
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${phase.name} · ${phase.description}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: const Color(0xFF3D2033).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          // Phase badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: phase.lightColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              phase.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: phase.color,
              ),
            ),
          ),
        ],
      );
    }
  }

  // ──────────────────────────────────────────────
  //  Public DaySlider widget
  // ──────────────────────────────────────────────
  class DaySlider extends StatefulWidget {
    final int currentDay;
    final Function(int) onDaySelected;
    final int totalDays;
  final Color phaseColor; // 👈 AJOUT

    const DaySlider({
      super.key,
      required this.currentDay,
      required this.onDaySelected,
      this.totalDays = 30,
          required this.phaseColor, // 👈 AJOUT

    });

    @override
    State<DaySlider> createState() => _DaySliderState();
  }

  class _DaySliderState extends State<DaySlider> {
    late ScrollController _scrollController;

    @override
    void initState() {
      super.initState();
      _scrollController = ScrollController();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }

    @override
    void didUpdateWidget(DaySlider old) {
      super.didUpdateWidget(old);
      if (old.currentDay != widget.currentDay) {
        _scrollToSelected();
      }
    }

    void _scrollToSelected() {
      // Each chip is 40px wide + 6px margin = 46px
      const chipWidth = 46.0;
      final targetOffset = (widget.currentDay - 1) * chipWidth -
          (MediaQuery.of(context).size.width / 2) +
          chipWidth / 2;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }

    @override
    void dispose() {
      _scrollController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0D9E6), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info header ─────────────────────
            _DayInfoHeader(currentDay: widget.currentDay),
            const SizedBox(height: 16),

            // ── Phase progress bar ───────────────
            _PhaseBar(currentDay: widget.currentDay),
            const SizedBox(height: 14),

            // ── Scrollable chips ─────────────────
            SizedBox(
              height: 62,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                itemCount: widget.totalDays,
                itemBuilder: (context, i) {
                  final day = i + 1;
                  return _DayChip(
                    day: day,
                    isSelected: day == widget.currentDay,
                    onTap: () => widget.onDaySelected(day),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }