import 'package:flutter/material.dart';

/// Palette officielle FitEva — source unique de vérité pour toutes les couleurs.
/// Importer via : import 'package:fiteva/theme/fiteva_colors.dart';
class FitEvaColors {
  FitEvaColors._();

  /// #1C4D30 — Vert bouteille — CTA, en-têtes, éléments UI clés
  static const Color primary = Color(0xFF1C4D30);

  /// #7ABB98 — Vert menthe — accents, états actifs, icônes, barres de progression
  static const Color accent = Color(0xFF7ABB98);

  /// #EAF3EC — Vert clair — fond de cartes, sections, zones subtiles
  static const Color cardBg = Color(0xFFEAF3EC);

  /// #F4F4F2 — Blanc cassé — fond principal de l'application
  static const Color bgApp = Color(0xFFF4F4F2);

  /// #0D0D0D — Noir profond — texte principal et titres
  static const Color text = Color(0xFF0D0D0D);

  /// #FFFFFF — Blanc pur — fonds de cartes, modales, overlays
  static const Color surface = Color(0xFFFFFFFF);

  // ── Texte secondaire (dérivé de la palette) ────────────────────────────────
  /// Vert bouteille adouci — labels, sous-titres, textes muets
  static const Color textMuted = Color(0xFF5A6B62);

  // ── Couleurs sémantiques de phase ──────────────────────────────────────────
  /// Phase menstruelle — rouge rosé
  static const Color phaseMenstrual = Color(0xFFD94F6B);

  /// Phase folliculaire — vert menthe (= accent)
  static const Color phaseFolliculaire = Color(0xFF7ABB98);

  /// Phase ovulatoire — ambre chaud
  static const Color phaseOvulatoire = Color(0xFFF4A940);

  /// Phase lutéale — bleu doux
  static const Color phaseLuteal = Color(0xFF5A7FC2);
}