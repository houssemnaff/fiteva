import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fiteva/theme/FitEvaColors.dart';

// ─── HeroCycleSection ──────────────────────────────────────────────────────
//
// Adapté pour la Fleur de 28 Pétales (PetalWheelPainter).
//
// Changements vs la version cercle :
// • Le Squircle blanc est remplacé par un fond circulaire très léger
//   (juste une lueur subtile) pour laisser les pétales "respirer" dans l'espace
// • L'aura de fond est légèrement plus grande pour donner de la profondeur à la fleur
// • La rotation est gardée mais 4× plus lente (120s) pour un effet quasi-imperceptible
// • Le CustomPaint est un peu plus grand (260px) pour loger les pétales confortablement

class HeroCycleSection extends StatelessWidget {
  final Animation<double> rotation;
  final Widget wheelCenter;
  final Widget legend;
  final CustomPainter wheelPainter;
  final Color mutedColor;
  final String userName;
  final String title;

  const HeroCycleSection({
    super.key,
    required this.rotation,
    required this.wheelCenter,
    required this.legend,
    required this.wheelPainter,
    required this.mutedColor,
    required this.userName,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ÉDITORIAL ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BIENVENUE, ${userName.toUpperCase()}',
                    style: TextStyle(
                      color: FitEvaColors.accent.withOpacity(0.7),
                      fontSize: 10,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: FitEvaColors.text,
                      fontSize: 28,
                     fontFamily: '.SF Pro Text',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildDateBadge(),
            ],
          ),

          const SizedBox(height: 44),

          // ── LA FLEUR DE 28 PÉTALES ───────────────────────────────────────
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. AURA EXTÉRIEURE : grande lueur douce en fond
                //    Plus large que l'ancienne version pour que les pétales
                //    semblent flotter dans une lumière naturelle
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        FitEvaColors.accent.withOpacity(0.10),
                        FitEvaColors.accent.withOpacity(0.0),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),

                // 2. FOND CIRCULAIRE TRÈS SUBTIL
                //    On remplace le Squircle opaque par un cercle blanc translucide.
                //    L'objectif est que les pétales semblent émerger d'un cœur lumineux
                //    sans être "enfermés" dans une forme géométrique dure.
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.85),
                    boxShadow: [
                      BoxShadow(
                        color: FitEvaColors.primary.withOpacity(0.06),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),

                // 3. LA FLEUR ANIMÉE
                //    AnimatedBuilder gère la rotation lente (120s/tour).
                //    Le PetalWheelPainter gère lui-même l'animation de bloom
                //    via le Listenable bloomProgress.
                //    Taille : 270px pour que les pétales aient de l'espace.
                AnimatedBuilder(
                  animation: rotation,
                  builder: (_, __) => Transform.rotate(
                    // Rotation très lente : quasi imperceptible, juste "vivante"
                    angle: rotation.value * 2 * pi,
                    child: CustomPaint(
                      size: const Size(270, 270),
                      painter: wheelPainter,
                    ),
                  ),
                ),

                // 4. CŒUR DE L'INTERFACE (WheelCenter)
                //    Le WheelCenter affiche "Jour 8 / Folliculaire" etc.
                //    Il est placé AU-DESSUS de la fleur, sur le cercle blanc central.
                Material(
                  color: Colors.transparent,
                  child: wheelCenter,
                ),
              ],
            ),
          ),

          const SizedBox(height: 44),

          // ── LÉGENDE DES PHASES ───────────────────────────────────────────
          legend,

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: FitEvaColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        "16 AVRIL",
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: FitEvaColors.primary,
        ),
      ),
    );
  }
}