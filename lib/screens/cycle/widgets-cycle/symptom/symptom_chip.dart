// ============================================================
//  symptom_chip.dart
//  Animated chip with soft glow, scale micro-interaction,
//  and inline intensity selector
// ============================================================

import 'package:flutter/material.dart';
import 'symptom_models.dart';

// ─── SymptomChip ─────────────────────────────────────────────

class SymptomChip extends StatefulWidget {
  final SymptomDef symptom;
  final bool isSelected;
  final SymptomIntensity? intensity;
  final Color phaseColor;
  final bool isSuggested; // soft highlight when suggested
  final ValueChanged<SymptomIntensity?> onTap;
  // onTap receives null = deselect, intensity = select/update

  const SymptomChip({
    super.key,
    required this.symptom,
    required this.isSelected,
    required this.intensity,
    required this.phaseColor,
    required this.onTap,
    this.isSuggested = false,
  });

  @override
  State<SymptomChip> createState() => _SymptomChipState();
}

class _SymptomChipState extends State<SymptomChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    await _controller.reverse();

    if (!mounted) return;

    if (widget.isSelected) {
      // Deselect
      widget.onTap(null);
    } else {
      // Select at low intensity by default; user can change via long press
      widget.onTap(SymptomIntensity.low);
    }
  }

  void _handleLongPress() {
    if (!widget.isSelected) return;
    _showIntensitySheet();
  }

  void _showIntensitySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SymptomIntensitySelector(
        symptom: widget.symptom,
        current: widget.intensity ?? SymptomIntensity.low,
        phaseColor: widget.phaseColor,
        onSelect: (intensity) {
          Navigator.pop(context);
          widget.onTap(intensity);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.phaseColor;
    final isSelected = widget.isSelected;
    final intensity = widget.intensity;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (_, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withOpacity(0.12)
                : widget.isSuggested
                    ? color.withOpacity(0.04)
                    : const Color(0xFF1C1C2E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? color.withOpacity(0.7)
                  : widget.isSuggested
                      ? color.withOpacity(0.3)
                      : Colors.white.withOpacity(0.08),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.symptom.emoji,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              Text(
                widget.symptom.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? color
                      : widget.isSuggested
                          ? color.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                ),
              ),
              if (isSelected && intensity != null) ...[
                const SizedBox(width: 6),
                _IntensityDot(intensity: intensity, color: color),
              ],
              if (widget.isSuggested && !isSelected) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.add_rounded,
                  size: 12,
                  color: color.withOpacity(0.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Intensity dot indicator ─────────────────────────────────

class _IntensityDot extends StatelessWidget {
  final SymptomIntensity intensity;
  final Color color;

  const _IntensityDot({required this.intensity, required this.color});

  @override
  Widget build(BuildContext context) {
    final count = intensity.index + 1; // 1, 2, or 3
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < count
                ? color
                : color.withOpacity(0.2),
          ),
        );
      }),
    );
  }
}

// ─── SymptomIntensitySelector (bottom sheet) ─────────────────

class SymptomIntensitySelector extends StatelessWidget {
  final SymptomDef symptom;
  final SymptomIntensity current;
  final Color phaseColor;
  final ValueChanged<SymptomIntensity> onSelect;

  const SymptomIntensitySelector({
    super.key,
    required this.symptom,
    required this.current,
    required this.phaseColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 88, 88, 244),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: phaseColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(symptom.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'How intense?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            symptom.name,
            style: TextStyle(
              fontSize: 13,
              color: phaseColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: SymptomIntensity.values.map((level) {
              final isActive = level == current;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isActive
                          ? phaseColor.withOpacity(0.2)
                          : Colors.white.withOpacity(0.04),
                      border: Border.all(
                        color: isActive
                            ? phaseColor.withOpacity(0.7)
                            : Colors.white.withOpacity(0.08),
                        width: isActive ? 1.5 : 1.0,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: phaseColor.withOpacity(0.2),
                                blurRadius: 10,
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(level.index + 1, (_) {
                            return Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? phaseColor
                                    : Colors.white.withOpacity(0.3),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          level.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? phaseColor
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Tap to select · Long-press a chip to change',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}