import 'package:flutter/material.dart';
import 'cycle_common_widgets.dart';
import 'cycle_wheel.dart'; 
import '../../../theme/FitEvaColors.dart';

class CycleInfoCard extends StatefulWidget {
  final int currentDay;
  final Function(int) onDaySelected;

  const CycleInfoCard({
    super.key,
    required this.currentDay,
    required this.onDaySelected,
  });

  @override
  State<CycleInfoCard> createState() => _CycleInfoCardState();
}

class _CycleInfoCardState extends State<CycleInfoCard> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDay(widget.currentDay);
    });
  }

  @override
  void didUpdateWidget(CycleInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDay != widget.currentDay) {
      _scrollToDay(widget.currentDay);
    }
  }

  void _scrollToDay(int day) {
    // Calcul: chaque jour = 48 (width) + 10 (margin)
    final offset = (day - 1) * 58.0;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Phases colors consistent with the design system
  static const _phaseColors = [
    FitEvaColors.phaseMenstrual,
    FitEvaColors.phaseFolliculaire,
    FitEvaColors.phaseOvulatoire,
    FitEvaColors.phaseLuteal,
  ];

  static const _phaseDays = [5, 8, 3, 14];

  String _getSubtitle(String phaseName) {
    switch (phaseName) {
      case 'Règles':
        return "Règles · Corps au repos";
      case 'Folliculaire':
        return "Énergie en hausse · Peau lumineuse";
      case 'Ovulation':
        return "Pic de fertilité · Humeur au top";
      case 'Lutéale':
        return "Corps se prépare · Écoute tes besoins";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = phaseForDay(widget.currentDay);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FitEvaColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP SECTION ────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jour ${widget.currentDay}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: FitEvaColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitle(phase.name),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: FitEvaColors.textMuted.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              PhaseBadge(
                name: phase.name,
                description: "",
                color: phase.color,
                isMinimal: true, // Only show the name in the badge for the card
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── MIDDLE SECTION ─────────────────────────
          PhaseProgressBar(
            currentDay: widget.currentDay,
            phaseColors: _phaseColors,
            phaseDays: _phaseDays,
          ),

          const SizedBox(height: 24),

          // ── BOTTOM SECTION (Horizontal Slider) ─────
          SizedBox(
            height: 64,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: 30,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final day = index + 1;
                final isSelected = day == widget.currentDay;
                final dayPhase = phaseForDay(day);
                
                return GestureDetector(
                  onTap: () => widget.onDaySelected(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 48,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? dayPhase.color : FitEvaColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                          ? dayPhase.color 
                          : Colors.black.withOpacity(0.06),
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: dayPhase.color.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$day",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : FitEvaColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Small indicator dot
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white.withOpacity(0.8) : dayPhase.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
