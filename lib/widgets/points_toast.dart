import 'package:fiteva/models/points_model.dart';
import 'package:fiteva/providers/points_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Toast "+N Points" (icône étoile) affiché après une action récompensée.
class PointsToast {
  static void show(BuildContext context, int amount, {String? label}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _RewardToastWidget(
        title: '+$amount Points',
        emoji: '⭐',
        label: label,
        accent: const Color(0xFF4CAF50),
        background: const Color(0xFF1A2E20),
        onDone: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

/// Toast "+N 💎" affiché UNIQUEMENT lors d'un passage de niveau — les
/// diamants ne viennent jamais d'une action directe.
class DiamondToast {
  static void show(BuildContext context, int diamonds, {required int level}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    final title = PointsModel.levelTitles[level.clamp(0, PointsModel.maxLevel)];
    entry = OverlayEntry(
      builder: (_) => _RewardToastWidget(
        title: '+$diamonds 💎 Diamants',
        emoji: PointsModel.levelEmojis[level.clamp(0, PointsModel.maxLevel)],
        label: 'Niveau $level — $title !',
        accent: const Color(0xFF60A5FA),
        background: const Color(0xFF16233A),
        onDone: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

/// À appeler après un appel reward* : si le gain vient de faire passer un
/// niveau, affiche le toast diamants (et consomme l'événement pour ne
/// l'afficher qu'une fois).
void maybeShowLevelUpToast(BuildContext context, WidgetRef ref) {
  final diamonds = ref.read(pointsProvider.notifier).consumeLevelUpReward();
  if (diamonds == null || diamonds <= 0) return;
  DiamondToast.show(context, diamonds, level: ref.read(pointsProvider).level);
}

class _RewardToastWidget extends StatefulWidget {
  final String title;
  final String emoji;
  final String? label;
  final Color accent;
  final Color background;
  final VoidCallback onDone;

  const _RewardToastWidget({
    required this.title,
    required this.emoji,
    required this.label,
    required this.accent,
    required this.background,
    required this.onDone,
  });

  @override
  State<_RewardToastWidget> createState() => _RewardToastWidgetState();
}

class _RewardToastWidgetState extends State<_RewardToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>    _opacity;
  late final Animation<Offset>    _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // ~280ms fade-in | ~2100ms visible | ~420ms fade-out (out of 2800ms total)
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOut)), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 75),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Curves.easeIn)), weight: 15),
    ]).animate(_ctrl);

    _slide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0, 0.5), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 10,
      ),
      TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 75),
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0, -0.4))
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: safeBottom + 110,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) => FadeTransition(
            opacity: _opacity,
            child: SlideTransition(position: _slide, child: child),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: widget.background,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: widget.accent.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(widget.emoji, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: widget.accent,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (widget.label != null)
                        Text(
                          widget.label!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
