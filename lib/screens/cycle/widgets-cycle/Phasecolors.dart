import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  SYSTÈME DE COULEURS PAR PHASE — utilisable partout dans l'app
//  (Nutrition, Workout, Cycle, Sleep, etc.)
//
//  Usage :
//    final color = PhaseColors.forDay(currentDay).primary;
//    final badge = PhaseBadgeIndicator(day: currentDay);
// ══════════════════════════════════════════════════════════════════════════════

enum CyclePhase { menstrual, follicular, ovulation, luteal }

// ─── Palette complète pour chaque phase ───────────────────────────────────
class PhaseColorSet {
  final CyclePhase phase;
  final String name;           // nom affiché
  final Color primary;         // couleur principale (dot, badge, highlight)
  final Color light;           // fond clair (background de carte)
  final Color border;          // bordure / séparateur
  final Color text;            // texte sur fond clair
  final String emoji;          // emoji représentatif

  const PhaseColorSet({
    required this.phase,
    required this.name,
    required this.primary,
    required this.light,
    required this.border,
    required this.text,
    required this.emoji,
  });
}

// ─── Les 4 phases ─────────────────────────────────────────────────────────
class PhaseColors {
  PhaseColors._();

  static const menstrual = PhaseColorSet(
    phase: CyclePhase.menstrual,
    name: 'Règles',
    primary: Color(0xFFD94F6B),   // rouge rosé
    light:   Color(0xFFFDF0F2),
    border:  Color(0xFFF5C0CB),
    text:    Color(0xFF8B2A3A),
    emoji:   '🌸',
  );

  static const follicular = PhaseColorSet(
    phase: CyclePhase.follicular,
    name: 'Folliculaire',
    primary: Color(0xFF5BAE8A),   // vert menthe
    light:   Color(0xFFEEF8F3),
    border:  Color(0xFFB2DECA),
    text:    Color(0xFF2A6E52),
    emoji:   '🌿',
  );

  static const ovulation = PhaseColorSet(
    phase: CyclePhase.ovulation,
    name: 'Ovulation',
    primary: Color(0xFFF4A940),   // orange chaud
    light:   Color(0xFFFFF6E9),
    border:  Color(0xFFFFD89B),
    text:    Color(0xFF8A5800),
    emoji:   '☀️',
  );

  static const luteal = PhaseColorSet(
    phase: CyclePhase.luteal,
    name: 'Lutéale',
    primary: Color(0xFF6B8FD4),   // bleu lavande
    light:   Color(0xFFF0F3FC),
    border:  Color(0xFFBDCBF0),
    text:    Color(0xFF2E4A8A),
    emoji:   '🌙',
  );

  // ── Durées standard (jours) ──────────────────────────────────────────────
  static const List<int> phaseDurations = [5, 8, 3, 14]; // total = 30

  static const List<PhaseColorSet> all = [
    menstrual,
    follicular,
    ovulation,
    luteal,
  ];

  // ── Retourne la PhaseColorSet selon le jour du cycle (1–30) ─────────────
  static PhaseColorSet forDay(int day) {
    int accumulated = 0;
    for (int i = 0; i < phaseDurations.length; i++) {
      accumulated += phaseDurations[i];
      if (day <= accumulated) return all[i];
    }
    return luteal;
  }

  // ── Retourne directement par enum ────────────────────────────────────────
  static PhaseColorSet forPhase(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:   return menstrual;
      case CyclePhase.follicular:  return follicular;
      case CyclePhase.ovulation:   return ovulation;
      case CyclePhase.luteal:      return luteal;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  WIDGETS RÉUTILISABLES
// ══════════════════════════════════════════════════════════════════════════════

// ─── Petit dot coloré (devant un plat, un exercice, etc.) ─────────────────
class PhaseDot extends StatelessWidget {
  final int cycleDay;
  final double size;

  const PhaseDot({super.key, required this.cycleDay, this.size = 8});

  @override
  Widget build(BuildContext context) {
    final colors = PhaseColors.forDay(cycleDay);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: colors.primary.withOpacity(0.45), blurRadius: 4),
        ],
      ),
    );
  }
}

// ─── Badge pill complet (nom + dot) ───────────────────────────────────────
class PhaseTag extends StatelessWidget {
  final int cycleDay;
  final bool showEmoji;

  const PhaseTag({super.key, required this.cycleDay, this.showEmoji = false});

  @override
  Widget build(BuildContext context) {
    final c = PhaseColors.forDay(cycleDay);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.light,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              color: c.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: c.primary.withOpacity(0.5), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (showEmoji) ...[
            Text(c.emoji, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
          ],
          Text(
            c.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Barre colorée latérale (pour les cartes de plats / recettes) ─────────
class PhaseStrip extends StatelessWidget {
  final int cycleDay;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const PhaseStrip({
    super.key,
    required this.cycleDay,
    this.width = 4,
    this.height = double.infinity,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final c = PhaseColors.forDay(cycleDay);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Exemple : carte de plat avec indicateur de phase ─────────────────────
//
//  Usage dans Nutrition :
//    MealPhaseCard(
//      mealName: 'Soupe de lentilles',
//      cycleDay: currentDay,  // récupéré depuis le provider
//    )
//
class MealPhaseCard extends StatelessWidget {
  final String mealName;
  final String? subtitle;
  final int cycleDay;
  final Widget? trailing;

  const MealPhaseCard({
    super.key,
    required this.mealName,
    this.subtitle,
    required this.cycleDay,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = PhaseColors.forDay(cycleDay);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Barre colorée phase à gauche ──────────────
          Container(
            width: 5,
            height: 64,
            decoration: BoxDecoration(
              color: c.primary,
              borderRadius: const BorderRadius.only(
                topLeft:    Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // ── Contenu ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mealName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Tag phase à droite ────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PhaseTag(cycleDay: cycleDay, showEmoji: true),
          ),
        ],
      ),
    );
  }
}