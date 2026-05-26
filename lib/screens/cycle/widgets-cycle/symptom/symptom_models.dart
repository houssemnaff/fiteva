// ============================================================
//  symptom_models.dart
//  Data models, enums, and symptom catalog
// ============================================================

enum SymptomCategory {
  physical,
  emotional,
  energy,
  pain,
  digestion;

  String get label {
    switch (this) {
      case SymptomCategory.physical:
        return 'Physical';
      case SymptomCategory.emotional:
        return 'Emotional';
      case SymptomCategory.energy:
        return 'Energy';
      case SymptomCategory.pain:
        return 'Pain';
      case SymptomCategory.digestion:
        return 'Digestion';
    }
  }

  String get emoji {
    switch (this) {
      case SymptomCategory.physical:
        return '🫀';
      case SymptomCategory.emotional:
        return '💭';
      case SymptomCategory.energy:
        return '⚡';
      case SymptomCategory.pain:
        return '🔥';
      case SymptomCategory.digestion:
        return '🌿';
    }
  }
}

enum SymptomIntensity {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case SymptomIntensity.low:
        return 'Mild';
      case SymptomIntensity.medium:
        return 'Moderate';
      case SymptomIntensity.high:
        return 'Intense';
    }
  }

  String get shortLabel {
    switch (this) {
      case SymptomIntensity.low:
        return 'Low';
      case SymptomIntensity.medium:
        return 'Med';
      case SymptomIntensity.high:
        return 'High';
    }
  }
}

// A symptom definition (catalog entry)
class SymptomDef {
  final String id;
  final String name;
  final String emoji;
  final SymptomCategory category;

  const SymptomDef({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
  });
}

// A logged symptom (selected by user, with intensity)
class LoggedSymptom {
  final SymptomDef def;
  final SymptomIntensity intensity;

  const LoggedSymptom({
    required this.def,
    required this.intensity,
  });

  LoggedSymptom copyWith({SymptomIntensity? intensity}) {
    return LoggedSymptom(
      def: def,
      intensity: intensity ?? this.intensity,
    );
  }
}

// ─── Symptom Catalog ─────────────────────────────────────────

class SymptomCatalog {
  static const List<SymptomDef> all = [
    // Physical
    SymptomDef(
        id: 'bloating',
        name: 'Bloating',
        emoji: '🫧',
        category: SymptomCategory.physical),
    SymptomDef(
        id: 'breast_tenderness',
        name: 'Breast Tenderness',
        emoji: '🌸',
        category: SymptomCategory.physical),
    SymptomDef(
        id: 'acne',
        name: 'Acne',
        emoji: '💢',
        category: SymptomCategory.physical),
    SymptomDef(
        id: 'spotting',
        name: 'Spotting',
        emoji: '🩸',
        category: SymptomCategory.physical),
    SymptomDef(
        id: 'discharge',
        name: 'Discharge',
        emoji: '💧',
        category: SymptomCategory.physical),
    SymptomDef(
        id: 'hot_flashes',
        name: 'Hot Flashes',
        emoji: '🌡️',
        category: SymptomCategory.physical),

    // Emotional
    SymptomDef(
        id: 'mood_swings',
        name: 'Mood Swings',
        emoji: '🌊',
        category: SymptomCategory.emotional),
    SymptomDef(
        id: 'anxiety',
        name: 'Anxiety',
        emoji: '🌀',
        category: SymptomCategory.emotional),
    SymptomDef(
        id: 'irritability',
        name: 'Irritability',
        emoji: '⚡',
        category: SymptomCategory.emotional),
    SymptomDef(
        id: 'sadness',
        name: 'Sadness',
        emoji: '🫧',
        category: SymptomCategory.emotional),
    SymptomDef(
        id: 'brain_fog',
        name: 'Brain Fog',
        emoji: '☁️',
        category: SymptomCategory.emotional),
    SymptomDef(
        id: 'low_libido',
        name: 'Low Libido',
        emoji: '🌙',
        category: SymptomCategory.emotional),

    // Energy
    SymptomDef(
        id: 'fatigue',
        name: 'Fatigue',
        emoji: '😴',
        category: SymptomCategory.energy),
    SymptomDef(
        id: 'low_energy',
        name: 'Low Energy',
        emoji: '🔋',
        category: SymptomCategory.energy),
    SymptomDef(
        id: 'insomnia',
        name: 'Insomnia',
        emoji: '🌑',
        category: SymptomCategory.energy),
    SymptomDef(
        id: 'oversleeping',
        name: 'Oversleeping',
        emoji: '💤',
        category: SymptomCategory.energy),

    // Pain
    SymptomDef(
        id: 'cramps',
        name: 'Cramps',
        emoji: '🔥',
        category: SymptomCategory.pain),
    SymptomDef(
        id: 'headache',
        name: 'Headache',
        emoji: '🧠',
        category: SymptomCategory.pain),
    SymptomDef(
        id: 'back_pain',
        name: 'Back Pain',
        emoji: '🦴',
        category: SymptomCategory.pain),
    SymptomDef(
        id: 'pelvic_pain',
        name: 'Pelvic Pain',
        emoji: '💠',
        category: SymptomCategory.pain),
    SymptomDef(
        id: 'joint_pain',
        name: 'Joint Pain',
        emoji: '🔩',
        category: SymptomCategory.pain),

    // Digestion
    SymptomDef(
        id: 'nausea',
        name: 'Nausea',
        emoji: '🌊',
        category: SymptomCategory.digestion),
    SymptomDef(
        id: 'constipation',
        name: 'Constipation',
        emoji: '🪨',
        category: SymptomCategory.digestion),
    SymptomDef(
        id: 'diarrhea',
        name: 'Diarrhea',
        emoji: '💦',
        category: SymptomCategory.digestion),
    SymptomDef(
        id: 'appetite_changes',
        name: 'Appetite Changes',
        emoji: '🍃',
        category: SymptomCategory.digestion),
    SymptomDef(
        id: 'cravings',
        name: 'Cravings',
        emoji: '🍫',
        category: SymptomCategory.digestion),
  ];

  static Map<SymptomCategory, List<SymptomDef>> get byCategory {
    final map = <SymptomCategory, List<SymptomDef>>{};
    for (final s in all) {
      map.putIfAbsent(s.category, () => []).add(s);
    }
    return map;
  }

  static SymptomDef? findById(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}