import 'package:flutter/material.dart';

/// Couleurs des sections Workout, exposées comme ThemeExtension pour suivre
/// la palette choisie par l'utilisateur (colorPaletteProvider).
///
/// La palette par défaut « Forêt » utilise [forest] : exactement les mêmes
/// valeurs qu'avant la migration. Les autres palettes passent par
/// [WorkoutColors.fromPalette] qui décline primary/accent en 6 tons avec les
/// mêmes relations (salle = primary, récupération = accent, etc.).
class WorkoutColors extends ThemeExtension<WorkoutColors> {
  // 🏋️ Gym / Salle — force, discipline, performance
  final Color salle;

  // 🏠 Home workout — calme, accessible, soft energy
  final Color maison;

  // 💃 Dance — énergie fluide
  final Color dance;

  // 🧘 Recovery — reset, respiration, relaxation
  final Color recuperation;

  // 🤰 Pregnancy — sécurité, douceur
  final Color grossesse;

  // 🎯 Zone training — focus, mental sharpness
  final Color zone;

  const WorkoutColors({
    required this.salle,
    required this.maison,
    required this.dance,
    required this.recuperation,
    required this.grossesse,
    required this.zone,
  });

  /// Valeurs historiques (palette Forêt) — inchangées.
  static const forest = WorkoutColors(
    salle: Color(0xFF1C4D30), // deep forest
    maison: Color(0xFF4F7D66), // muted sage green
    dance: Color(0xFF2E6F5E), // teal-green dynamic
    recuperation: Color(0xFF7ABB98), // soft fresh green
    grossesse: Color(0xFFA7B8AD), // sage neutral calm
    zone: Color(0xFF2F3E46), // deep charcoal green-blue
  );

  factory WorkoutColors.fromPalette(Color primary, Color accent) {
    return WorkoutColors(
      salle: primary,
      maison: Color.lerp(primary, accent, 0.50)!,
      dance: Color.lerp(primary, accent, 0.30)!,
      recuperation: accent,
      grossesse: Color.lerp(accent, Colors.white, 0.35)!,
      zone: Color.lerp(primary, const Color(0xFF263238), 0.55)!,
    );
  }

  static WorkoutColors of(BuildContext context) =>
      Theme.of(context).extension<WorkoutColors>() ?? forest;

  @override
  WorkoutColors copyWith({
    Color? salle,
    Color? maison,
    Color? dance,
    Color? recuperation,
    Color? grossesse,
    Color? zone,
  }) {
    return WorkoutColors(
      salle: salle ?? this.salle,
      maison: maison ?? this.maison,
      dance: dance ?? this.dance,
      recuperation: recuperation ?? this.recuperation,
      grossesse: grossesse ?? this.grossesse,
      zone: zone ?? this.zone,
    );
  }

  @override
  WorkoutColors lerp(ThemeExtension<WorkoutColors>? other, double t) {
    if (other is! WorkoutColors) return this;
    return WorkoutColors(
      salle: Color.lerp(salle, other.salle, t)!,
      maison: Color.lerp(maison, other.maison, t)!,
      dance: Color.lerp(dance, other.dance, t)!,
      recuperation: Color.lerp(recuperation, other.recuperation, t)!,
      grossesse: Color.lerp(grossesse, other.grossesse, t)!,
      zone: Color.lerp(zone, other.zone, t)!,
    );
  }
}
