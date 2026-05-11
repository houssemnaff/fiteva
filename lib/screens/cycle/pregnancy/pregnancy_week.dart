import 'package:flutter/material.dart';

class PregnancyWeek {
  final int week;
  final String babySize;       // ex: "Mangue"
  final String babySizeEmoji;  // ex: "🥭"
  final double babyCm;         // taille en cm
  final String babyDevelopment;
  final List<String> symptoms;
  final List<PregnancyTip> tips;
  final Color phaseColor;
  final String trimestre;

  const PregnancyWeek({
    required this.week,
    required this.babySize,
    required this.babySizeEmoji,
    required this.babyCm,
    required this.babyDevelopment,
    required this.symptoms,
    required this.tips,
    required this.phaseColor,
    required this.trimestre,
  });
}

class PregnancyTip {
  final String category; // 'Sport', 'Nutrition', 'Repos'
  final String text;
  final IconData icon;
  final Color color;

  const PregnancyTip({
    required this.category,
    required this.text,
    required this.icon,
    required this.color,
  });
}