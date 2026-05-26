// ============================================================
//  symptom_category_group.dart
//  Collapsible category section with animated chip grid
// ============================================================

import 'package:flutter/material.dart';
import 'symptom_models.dart';
import 'symptom_chip.dart';

class SymptomCategoryGroup extends StatefulWidget {
  final SymptomCategory category;
  final List<SymptomDef> symptoms;
  final Map<String, LoggedSymptom> selected; // id → LoggedSymptom
  final Set<String> suggestedIds;
  final Color phaseColor;
  final bool startExpanded;
  final void Function(SymptomDef symptom, SymptomIntensity? intensity)
      onSymptomChanged;

  const SymptomCategoryGroup({
    super.key,
    required this.category,
    required this.symptoms,
    required this.selected,
    required this.suggestedIds,
    required this.phaseColor,
    required this.onSymptomChanged,
    this.startExpanded = true,
  });

  @override
  State<SymptomCategoryGroup> createState() => _SymptomCategoryGroupState();
}

class _SymptomCategoryGroupState extends State<SymptomCategoryGroup>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expanded = widget.startExpanded;
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: _expanded ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  int get _selectedCount =>
      widget.symptoms.where((s) => widget.selected.containsKey(s.id)).length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Category header ───────────────────────
        GestureDetector(
          onTap: _toggleExpanded,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                // Emoji + label
                Text(
                  widget.category.emoji,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.category.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.85),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                // Selected count badge
                if (_selectedCount > 0)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.phaseColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_selectedCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: widget.phaseColor,
                      ),
                    ),
                  ),
                const Spacer(),
                // Chevron
                AnimatedRotation(
                  turns: _expanded ? 0.0 : -0.25,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Colors.red.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── Collapsible chip grid ─────────────────
        SizeTransition(
          sizeFactor: _expandAnim,
          axisAlignment: -1,
          child: FadeTransition(
            opacity: _expandAnim,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.symptoms.map((symptom) {
                  final logged = widget.selected[symptom.id];
                  final isSuggested =
                      widget.suggestedIds.contains(symptom.id);

                  return SymptomChip(
                    symptom: symptom,
                    isSelected: logged != null,
                    intensity: logged?.intensity,
                    phaseColor: widget.phaseColor,
                    isSuggested: isSuggested,
                    onTap: (intensity) =>
                        widget.onSymptomChanged(symptom, intensity),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // Divider
        Divider(
          color: Colors.white.withOpacity(0.06),
          height: 1,
        ),
      ],
    );
  }
}