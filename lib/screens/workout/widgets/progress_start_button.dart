import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bouton "Commencer" des cartes de programme/vidéo — au lieu d'un badge de
/// pourcentage séparé, la progression se lit directement dans le bouton :
/// la portion gauche se remplit de [color] (la couleur de la section, la
/// même que le bouton "Voir tout" du header) proportionnellement à
/// [progress] (0.0 → vide, 1.0 → plein). Une fois complété, le bouton est
/// entièrement rempli de cette même couleur, avec un petit effet de rebond
/// pour marquer l'accomplissement.
class ProgressStartButton extends StatefulWidget {
  final double progress; // 0.0–1.0
  final bool completed;
  final Color color;
  final String label;
  final String completedLabel;

  const ProgressStartButton({
    super.key,
    required this.progress,
    required this.completed,
    required this.color,
    required this.label,
    required this.completedLabel,
  });

  @override
  State<ProgressStartButton> createState() => _ProgressStartButtonState();
}

class _ProgressStartButtonState extends State<ProgressStartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _popCtrl;
  late final Animation<double> _pop;

  @override
  void initState() {
    super.initState();
    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _pop = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.14), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.14, end: 0.96), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _popCtrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant ProgressStartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebond uniquement au moment où le programme vient d'être terminé —
    // pas à chaque rebuild, sinon l'effet se déclencherait en boucle.
    if (widget.completed && !oldWidget.completed) {
      _popCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _popCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = widget.color;
    final fraction = widget.completed ? 1.0 : widget.progress.clamp(0.0, 1.0);

    return ScaleTransition(
      scale: _pop,
      child: Container(
        height: 40,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.white.withValues(alpha: 0.14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Portion remplie — largeur ET couleur s'animent en douceur à
            // chaque changement de progression ou passage à l'état terminé.
            if (fraction > 0)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => FractionallySizedBox(
                  widthFactor: value,
                  alignment: Alignment.centerLeft,
                  child: child,
                ),
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(begin: fillColor, end: fillColor),
                  duration: const Duration(milliseconds: 350),
                  builder: (context, animatedColor, _) {
                    final c = animatedColor ?? fillColor;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: c,
                        boxShadow: [
                          BoxShadow(
                            color: c.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            // Icône + libellé — toujours centrés sur toute la largeur du bouton.
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      widget.completed ? LucideIcons.check : LucideIcons.play,
                      key: ValueKey(widget.completed),
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.completed ? widget.completedLabel : widget.label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
