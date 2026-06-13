import 'package:flutter/material.dart';

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
      case SymptomType.nausea:         return 'Nausées';
      case SymptomType.fatigue:        return 'Fatigue';
      case SymptomType.cramps:         return 'Crampes';
      case SymptomType.mood:           return 'Humeur';
      case SymptomType.sleep:          return 'Sommeil';
      case SymptomType.appetite:       return 'Appétit';
      case SymptomType.headache:       return 'Maux de tête';
      case SymptomType.backPain:       return 'Dos';
      case SymptomType.bloating:       return 'Ballonnements';
      case SymptomType.heartburn:      return 'Brûlures';
      case SymptomType.swelling:       return 'Gonflements';
      case SymptomType.breathlessness: return 'Essoufflement';
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

  IconData get icon {
    switch (this) {
      case SymptomType.nausea:         return Icons.sick_outlined;
      case SymptomType.fatigue:        return Icons.bedtime_outlined;
      case SymptomType.cramps:         return Icons.loop_rounded;
      case SymptomType.mood:           return Icons.mood_outlined;
      case SymptomType.sleep:          return Icons.nightlight_outlined;
      case SymptomType.appetite:       return Icons.restaurant_outlined;
      case SymptomType.headache:       return Icons.psychology_outlined;
      case SymptomType.backPain:       return Icons.accessibility_new_outlined;
      case SymptomType.bloating:       return Icons.bubble_chart_outlined;
      case SymptomType.heartburn:      return Icons.local_fire_department_outlined;
      case SymptomType.swelling:       return Icons.water_drop_outlined;
      case SymptomType.breathlessness: return Icons.air_outlined;
    }
  }

  Color get baseColor {
    switch (this) {
      case SymptomType.nausea:         return const Color(0xFF7ABB98);
      case SymptomType.fatigue:        return const Color(0xFF9B7DAF);
      case SymptomType.cramps:         return const Color(0xFFE58F8A);
      case SymptomType.mood:           return const Color(0xFF7A9BBF);
      case SymptomType.sleep:          return const Color(0xFF8A7DAF);
      case SymptomType.appetite:       return const Color(0xFF7ABB98);
      case SymptomType.headache:       return const Color(0xFFF4A940);
      case SymptomType.backPain:       return const Color(0xFF7DAF9B);
      case SymptomType.bloating:       return const Color(0xFFAFAF7D);
      case SymptomType.heartburn:      return const Color(0xFFE58F8A);
      case SymptomType.swelling:       return const Color(0xFF7D9BAF);
      case SymptomType.breathlessness: return const Color(0xFF9BAF7D);
    }
  }
}

class SymptomEntry {
  final String id;
  final SymptomType type;
  final int intensity; // 1–5
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
