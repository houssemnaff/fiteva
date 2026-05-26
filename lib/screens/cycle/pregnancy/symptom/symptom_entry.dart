// ─────────────────────────────────────────────
// symptom_entry.dart
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';

// ── Symptom types ────────────────────────────────────────────────────────────

enum SymptomType {
  nausea,
  fatigue,
  cramps,
  mood,
  sleep,
  appetite,
  headache,
  backPain,
  bloating,
  heartburn,
  swelling,
  breathlessness,
}

extension SymptomTypeExtension on SymptomType {
  String get label {
    switch (this) {
      case SymptomType.nausea:         return 'Nausea';
      case SymptomType.fatigue:        return 'Fatigue';
      case SymptomType.cramps:         return 'Cramps';
      case SymptomType.mood:           return 'Mood';
      case SymptomType.sleep:          return 'Sleep';
      case SymptomType.appetite:       return 'Appetite';
      case SymptomType.headache:       return 'Headache';
      case SymptomType.backPain:       return 'Back Pain';
      case SymptomType.bloating:       return 'Bloating';
      case SymptomType.heartburn:      return 'Heartburn';
      case SymptomType.swelling:       return 'Swelling';
      case SymptomType.breathlessness: return 'Breathlessness';
    }
  }

  String get emoji {
    switch (this) {
      case SymptomType.nausea:         return '🤢';
      case SymptomType.fatigue:        return '😴';
      case SymptomType.cramps:         return '🌀';
      case SymptomType.mood:           return '💭';
      case SymptomType.sleep:          return '🌙';
      case SymptomType.appetite:       return '🍃';
      case SymptomType.headache:       return '🧠';
      case SymptomType.backPain:       return '🌿';
      case SymptomType.bloating:       return '🫧';
      case SymptomType.heartburn:      return '🔥';
      case SymptomType.swelling:       return '💧';
      case SymptomType.breathlessness: return '🌬️';
    }
  }

  Color get baseColor {
    switch (this) {
      case SymptomType.nausea:         return const Color(0xFF7DAF8A);
      case SymptomType.fatigue:        return const Color(0xFF9B7DAF);
      case SymptomType.cramps:         return const Color(0xFFB97A8A);
      case SymptomType.mood:           return const Color(0xFF7A9BBF);
      case SymptomType.sleep:          return const Color(0xFF8A7DAF);
      case SymptomType.appetite:       return const Color(0xFF8AAF8A);
      case SymptomType.headache:       return const Color(0xFFAF9B7D);
      case SymptomType.backPain:       return const Color(0xFF7DAF9B);
      case SymptomType.bloating:       return const Color(0xFFAFAF7D);
      case SymptomType.heartburn:      return const Color(0xFFAF8A7D);
      case SymptomType.swelling:       return const Color(0xFF7D9BAF);
      case SymptomType.breathlessness: return const Color(0xFF9BAF7D);
    }
  }
}

// ── Data model ───────────────────────────────────────────────────────────────

class SymptomEntry {
  final String id;
  final SymptomType type;
  final int intensity; // 0–5
  final DateTime date;
  final String? note;

  const SymptomEntry({
    required this.id,
    required this.type,
    required this.intensity,
    required this.date,
    this.note,
  });

  SymptomEntry copyWith({
    String? id,
    SymptomType? type,
    int? intensity,
    DateTime? date,
    String? note,
  }) {
    return SymptomEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}