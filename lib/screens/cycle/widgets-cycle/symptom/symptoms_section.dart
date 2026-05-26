// ============================================================
//  symptoms_section.dart
//  Main orchestrator widget — drop-in replacement for your
//  existing SymptomsSection
//
//  Usage:
//    SymptomsSection(
//      phaseColor: myPhaseColor,
//      onSymptomsChanged: (logged) { /* save to your state */ },
//    )
// ============================================================

import 'package:flutter/material.dart';
import 'symptom_models.dart';
import 'symptom_suggestion_engine.dart';
import 'symptom_category_group.dart';
import 'symptom_insight_card.dart';

class SymptomsSection extends StatefulWidget {
  /// The phase accent color — drives the entire visual palette.
  final Color phaseColor;

  /// Called whenever the selection changes. Gives you the full
  /// list of currently logged symptoms.
  final ValueChanged<List<LoggedSymptom>>? onSymptomsChanged;

  /// Pass yesterday's symptom count to enable trend arrow.
  final int previousDayCount;

  /// Optional initial selection (e.g., loaded from local DB).
  final List<LoggedSymptom> initialSelection;

  const SymptomsSection({
    super.key,
    required this.phaseColor,
    this.onSymptomsChanged,
    this.previousDayCount = 0,
    this.initialSelection = const [],
  });

  @override
  State<SymptomsSection> createState() => _SymptomsSectionState();
}

class _SymptomsSectionState extends State<SymptomsSection> {
  // id → LoggedSymptom
  late Map<String, LoggedSymptom> _selected;

  // Suggested symptom ids to highlight
  Set<String> _suggestedIds = {};

  // Debounce insight/suggestion recompute
  SymptomSummaryData _summary = const SymptomSummaryData(
    count: 0,
    trend: SymptomTrend.stable,
  );
  ({String phase, String insight})? _insight;

  // Which categories start expanded
  final Map<SymptomCategory, bool> _categoryExpanded = {
    for (final c in SymptomCategory.values) c: true,
  };

  @override
  void initState() {
    super.initState();
    _selected = {
      for (final l in widget.initialSelection) l.def.id: l,
    };
    _recompute();
  }

  void _recompute() {
    final list = _selected.values.toList();

    final suggestions = SymptomSuggestionEngine.suggestions(selected: list);
    final insight = SymptomSuggestionEngine.insight(selected: list);
    final summary = SymptomSuggestionEngine.summary(
      selected: list,
      previousCount: widget.previousDayCount,
    );

    setState(() {
      _suggestedIds = suggestions.map((s) => s.id).toSet();
      _insight = insight;
      _summary = summary;
    });

    widget.onSymptomsChanged?.call(list);
  }

  void _handleSymptomChanged(SymptomDef symptom, SymptomIntensity? intensity) {
    setState(() {
      if (intensity == null) {
        _selected.remove(symptom.id);
      } else {
        _selected[symptom.id] = LoggedSymptom(
          def: symptom,
          intensity: intensity,
        );
      }
    });
    _recompute();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = SymptomCatalog.byCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Section title ────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Text(
                'How are you feeling?',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.9),
                ),
              ),
              const Spacer(),
              if (_selected.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() => _selected.clear());
                    _recompute();
                  },
                  child: Text(
                    'Clear all',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.35),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ─── Daily summary card ───────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SizeTransition(sizeFactor: anim, child: child),
          ),
          child: _summary.count > 0
              ? Padding(
                  key: const ValueKey('summary'),
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SymptomSummaryCard(
                    data: _summary,
                    phaseColor: widget.phaseColor,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no-summary')),
        ),

        // ─── AI Insight card ──────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SizeTransition(
              sizeFactor: anim,
              axisAlignment: -1,
              child: child,
            ),
          ),
          child: _insight != null
              ? Padding(
                  key: ValueKey(_insight!.phase),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SymptomInsightCard(
                    phase: _insight!.phase,
                    insight: _insight!.insight,
                    phaseColor: widget.phaseColor,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no-insight')),
        ),

        // ─── Suggestion strip ─────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: _suggestedIds.isNotEmpty
              ? Padding(
                  key: ValueKey(_suggestedIds.join()),
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _SuggestionStrip(
                    suggestedIds: _suggestedIds,
                    selected: _selected,
                    phaseColor: widget.phaseColor,
                    onTap: (def) =>
                        _handleSymptomChanged(def, SymptomIntensity.low),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no-suggestions')),
        ),

        // ─── Category groups ──────────────────────
        ...SymptomCategory.values.map((category) {
          final symptoms = catalog[category] ?? [];
          if (symptoms.isEmpty) return const SizedBox.shrink();

          return SymptomCategoryGroup(
            key: ValueKey(category),
            category: category,
            symptoms: symptoms,
            selected: _selected,
            suggestedIds: _suggestedIds,
            phaseColor: widget.phaseColor,
            startExpanded: _categoryExpanded[category] ?? true,
            onSymptomChanged: _handleSymptomChanged,
          );
        }),

        const SizedBox(height: 8),

        // ─── Hint text ────────────────────────────
        Center(
          child: Text(
            'Tap to log · Long-press to set intensity',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black.withOpacity(0.25),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Suggestion Strip ────────────────────────────────────────

class _SuggestionStrip extends StatelessWidget {
  final Set<String> suggestedIds;
  final Map<String, LoggedSymptom> selected;
  final Color phaseColor;
  final ValueChanged<SymptomDef> onTap;

  const _SuggestionStrip({
    required this.suggestedIds,
    required this.selected,
    required this.phaseColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defs = suggestedIds
        .where((id) => !selected.containsKey(id))
        .map((id) => SymptomCatalog.findById(id))
        .whereType<SymptomDef>()
        .take(4)
        .toList();

    if (defs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.tips_and_updates_rounded,
              size: 13,
              color: phaseColor.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              'Related symptoms',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.45),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: defs.map((def) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onTap(def),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: phaseColor.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: phaseColor.withOpacity(0.25),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(def.emoji,
                            style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          def.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: phaseColor.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.add_rounded,
                            size: 12, color: phaseColor.withOpacity(0.6)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}