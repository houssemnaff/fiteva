// ============================================================
//  symptom_suggestion_engine.dart
//  Smart suggestion logic + AI insight preview generation
//  Pure Dart — no external dependencies
// ============================================================

import 'symptom_models.dart';

// ─── Related Symptom Map ─────────────────────────────────────
// symptomId → list of related symptom ids to suggest
const Map<String, List<String>> _relatedSymptoms = {
  'headache': ['fatigue', 'brain_fog', 'nausea', 'low_energy'],
  'fatigue': ['low_energy', 'insomnia', 'brain_fog', 'oversleeping'],
  'cramps': ['back_pain', 'pelvic_pain', 'bloating', 'nausea'],
  'bloating': ['cramps', 'constipation', 'appetite_changes', 'nausea'],
  'mood_swings': ['irritability', 'anxiety', 'sadness', 'brain_fog'],
  'anxiety': ['insomnia', 'mood_swings', 'irritability', 'low_libido'],
  'insomnia': ['fatigue', 'anxiety', 'brain_fog', 'low_energy'],
  'breast_tenderness': ['bloating', 'mood_swings', 'fatigue'],
  'acne': ['bloating', 'mood_swings', 'breast_tenderness'],
  'nausea': ['cramps', 'appetite_changes', 'diarrhea', 'headache'],
  'back_pain': ['cramps', 'pelvic_pain', 'joint_pain', 'fatigue'],
  'low_energy': ['fatigue', 'oversleeping', 'brain_fog', 'sadness'],
  'brain_fog': ['fatigue', 'low_energy', 'anxiety', 'insomnia'],
  'irritability': ['mood_swings', 'anxiety', 'brain_fog', 'sadness'],
  'sadness': ['anxiety', 'low_libido', 'fatigue', 'insomnia'],
  'pelvic_pain': ['cramps', 'back_pain', 'bloating'],
  'constipation': ['bloating', 'cramps', 'appetite_changes'],
  'diarrhea': ['nausea', 'cramps', 'appetite_changes'],
  'cravings': ['appetite_changes', 'mood_swings', 'bloating'],
  'hot_flashes': ['insomnia', 'anxiety', 'mood_swings'],
  'low_libido': ['fatigue', 'sadness', 'anxiety'],
  'spotting': ['cramps', 'bloating'],
  'discharge': [],
  'joint_pain': ['back_pain', 'fatigue', 'low_energy'],
  'oversleeping': ['fatigue', 'sadness', 'low_energy'],
  'appetite_changes': ['cravings', 'nausea', 'mood_swings'],
};

// ─── Phase Pattern Signatures ────────────────────────────────
// Pattern: symptom ids that together suggest a cycle phase pattern

class _PhaseSignature {
  final String phaseLabel;
  final String insight;
  final List<String> triggers; // must have N of these selected

  const _PhaseSignature({
    required this.phaseLabel,
    required this.insight,
    required this.triggers,
  });
}

const List<_PhaseSignature> _phaseSignatures = [
  _PhaseSignature(
    phaseLabel: 'Luteal phase',
    insight:
        'Bloating, breast tenderness and mood shifts together suggest you may be in a luteal phase pattern. Progesterone peaks during this time — this is completely normal.',
    triggers: ['bloating', 'breast_tenderness', 'mood_swings'],
  ),
  _PhaseSignature(
    phaseLabel: 'Pre-menstrual',
    insight:
        'Cramps, lower back pain, and irritability often signal the body preparing for menstruation. Warmth, rest, and gentle movement may help.',
    triggers: ['cramps', 'back_pain', 'irritability'],
  ),
  _PhaseSignature(
    phaseLabel: 'Menstrual',
    insight:
        'Fatigue and cramping together are classic signs of the menstrual phase. Your body is doing significant work — rest is productive, not passive.',
    triggers: ['cramps', 'fatigue'],
  ),
  _PhaseSignature(
    phaseLabel: 'Low energy window',
    insight:
        'Brain fog, low energy, and sleep changes suggest your body may be in a low-hormone window. Light nutrition and short rest breaks may restore clarity faster than caffeine.',
    triggers: ['brain_fog', 'low_energy', 'insomnia'],
  ),
  _PhaseSignature(
    phaseLabel: 'Stress response',
    insight:
        'Anxiety, insomnia, and mood swings together may indicate an elevated cortisol pattern. Stress directly impacts hormone balance — consider tracking your sleep quality too.',
    triggers: ['anxiety', 'insomnia', 'mood_swings'],
  ),
  _PhaseSignature(
    phaseLabel: 'Ovulatory transition',
    insight:
        'Discharge changes alongside breast tenderness and low pelvic awareness can indicate the ovulatory window. This phase is often associated with a natural energy lift.',
    triggers: ['discharge', 'breast_tenderness', 'low_libido'],
  ),
];

// ─── Trend Analysis ──────────────────────────────────────────

enum SymptomTrend { increasing, stable, decreasing, newToday }

class SymptomSummaryData {
  final int count;
  final String? mostCommon; // name of most frequently intense symptom
  final SymptomTrend trend;
  final String? insightPhase;
  final String? insightText;

  const SymptomSummaryData({
    required this.count,
    this.mostCommon,
    required this.trend,
    this.insightPhase,
    this.insightText,
  });
}

// ─── Suggestion Engine ───────────────────────────────────────

class SymptomSuggestionEngine {
  /// Returns up to [limit] suggested SymptomDefs not already selected,
  /// ordered by how many selected symptoms trigger them.
  static List<SymptomDef> suggestions({
    required List<LoggedSymptom> selected,
    int limit = 4,
  }) {
    if (selected.isEmpty) return [];

    final selectedIds = selected.map((s) => s.def.id).toSet();
    final scores = <String, int>{};

    for (final logged in selected) {
      final related = _relatedSymptoms[logged.def.id] ?? [];
      for (final relId in related) {
        if (!selectedIds.contains(relId)) {
          scores[relId] = (scores[relId] ?? 0) + 1;
        }
      }
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted
        .take(limit)
        .map((e) => SymptomCatalog.findById(e.key))
        .whereType<SymptomDef>()
        .toList();
  }

  /// Returns the best matching phase insight for the current selection,
  /// or null if no pattern matches.
  static ({String phase, String insight})? insight({
    required List<LoggedSymptom> selected,
  }) {
    if (selected.isEmpty) return null;

    final selectedIds = selected.map((s) => s.def.id).toSet();

    _PhaseSignature? best;
    int bestScore = 0;

    for (final sig in _phaseSignatures) {
      final score =
          sig.triggers.where((t) => selectedIds.contains(t)).length;
      if (score >= 2 && score > bestScore) {
        best = sig;
        bestScore = score;
      }
    }

    if (best == null) return null;
    return (phase: best.phaseLabel, insight: best.insight);
  }

  /// Computes a summary card data object from the current selection.
  static SymptomSummaryData summary({
    required List<LoggedSymptom> selected,
    // previousCount: pass yesterday's count to determine trend
    int previousCount = 0,
  }) {
    if (selected.isEmpty) {
      return const SymptomSummaryData(
        count: 0,
        trend: SymptomTrend.stable,
      );
    }

    // Most common = highest intensity symptom; ties broken by category order
    LoggedSymptom? mostCommonLogged;
    for (final s in selected) {
      if (mostCommonLogged == null ||
          s.intensity.index > mostCommonLogged.intensity.index) {
        mostCommonLogged = s;
      }
    }

    SymptomTrend trend;
    if (previousCount == 0) {
      trend = SymptomTrend.newToday;
    } else if (selected.length > previousCount + 1) {
      trend = SymptomTrend.increasing;
    } else if (selected.length < previousCount - 1) {
      trend = SymptomTrend.decreasing;
    } else {
      trend = SymptomTrend.stable;
    }

    final ins = insight(selected: selected);

    return SymptomSummaryData(
      count: selected.length,
      mostCommon: mostCommonLogged?.def.name,
      trend: trend,
      insightPhase: ins?.phase,
      insightText: ins?.insight,
    );
  }
}