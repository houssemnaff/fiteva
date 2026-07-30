import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ── WeGLOW-style palette with green ──────────────────────────────────────────
const kBgDark      = Color(0xFFEFF7F1);
const kBgMid       = Color(0xFFF2F9F4);
const kBgMint      = Color(0xFFEFF7F1);
const kBgLight     = Color(0xFFF5FAF7);
const kGreenDark   = Color(0xFF1B5E3B);
const kGreenMid    = Color(0xFF276E4A);
const kGreenBright = Color(0xFF1B5E3B);
const kCardUnsel   = Color(0xFFF5FAF7);
const kCardSel     = Color(0xFF1B5E3B);
const kTextDark    = Color(0xFF1A1A1A);
const kTextMuted   = Color(0xFF8E8E93);
const kWhite       = Colors.white;
const kGlassBorder = Color(0xFFDAE8DF);
const kGlassFill   = Color(0xFFF5FAF7);

// ── WeGLOW-style scaffold with warm mint gradient ──────────────────────────
Widget mintScaffold({required Widget child}) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE6F2EA),
            Color(0xFFEFF7F1),
            Color(0xFFF5FAF7),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: child,
    ),
  );
}

// ── Segmented progress bar — WeGLOW-style ──────────────────────────────────
class OnboardingTopBar extends StatelessWidget {
  final int step;
  final int total;
  final String? title;
  final VoidCallback? onBack;

  const OnboardingTopBar({
    super.key,
    required this.step,
    required this.total,
    this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              (onBack ?? () => Navigator.maybePop(context))();
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(LucideIcons.chevronLeft, size: 24,
                  color: Color(0xFF1A3C2A)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step header — WeGLOW bold left-aligned ──────────────────────────────────
class StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const StepHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: kGreenDark,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: kGreenMid,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Step icon — hidden in WeGLOW redesign ───────────────────────────────────
class StepIcon extends StatelessWidget {
  final IconData icon;
  const StepIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ── Selection card with scale + haptic ──────────────────────────────────────
class PillCard extends StatefulWidget {
  final String label;
  final String? sublabel;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;

  const PillCard({
    super.key,
    required this.label,
    this.sublabel,
    this.icon,
    required this.selected,
    required this.onTap,
    this.fullWidth = true,
  });

  @override
  State<PillCard> createState() => _PillCardState();
}

class _PillCardState extends State<PillCard> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleCtrl.forward();
  void _onTapUp(TapUpDetails _) {
    _scaleCtrl.reverse();
    HapticFeedback.lightImpact();
    widget.onTap();
  }
  void _onTapCancel() => _scaleCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: sel ? kGreenBright : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel ? kGreenBright : kGreenBright.withValues(alpha: 0.12),
              width: sel ? 2 : 1,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: kGreenBright.withValues(alpha: 0.2),
                    blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.03),
                    blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.label, style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : kGreenDark)),
                if (widget.sublabel != null) ...[
                  const SizedBox(height: 4),
                  Text(widget.sublabel!, style: GoogleFonts.inter(
                    fontSize: 13,
                    color: sel
                        ? Colors.white.withValues(alpha: 0.8)
                        : kTextMuted,
                    fontWeight: FontWeight.w400)),
                ],
              ],
            )),
            if (widget.icon != null)
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: sel
                      ? Colors.white.withValues(alpha: 0.2)
                      : kGreenBright.withValues(alpha: 0.08),
                ),
                child: Icon(widget.icon, size: 20,
                    color: sel ? Colors.white.withValues(alpha: 0.9) : kGreenMid),
              ),
          ]),
        ),
      ),
    );
  }
}

// ── Large visual card (for goals/equipment grids) ───────────────────────────
class CompactPill extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const CompactPill({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<CompactPill> createState() => _CompactPillState();
}

class _CompactPillState extends State<CompactPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleCtrl.forward();
  void _onTapUp(TapUpDetails _) {
    _scaleCtrl.reverse();
    HapticFeedback.selectionClick();
    widget.onTap();
  }
  void _onTapCancel() => _scaleCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
          decoration: BoxDecoration(
            color: sel ? kGreenBright : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel ? kGreenBright : kGreenBright.withValues(alpha: 0.12),
              width: sel ? 2 : 1,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: kGreenBright.withValues(alpha: 0.2),
                    blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.03),
                    blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: sel
                      ? Colors.white.withValues(alpha: 0.2)
                      : kGreenBright.withValues(alpha: 0.08),
                ),
                child: Icon(widget.icon, size: 22,
                    color: sel ? Colors.white.withValues(alpha: 0.9) : kGreenMid),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : kGreenDark,
                  height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── CTA button with press animation ─────────────────────────────────────────
class CtaButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const CtaButton({super.key, required this.label, this.onPressed});

  @override
  State<CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<CtaButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 12, 40, 24),
        child: GestureDetector(
          onTapDown: enabled ? (_) => _ctrl.forward() : null,
          onTapUp: enabled ? (_) {
            _ctrl.reverse();
            HapticFeedback.mediumImpact();
            widget.onPressed!();
          } : null,
          onTapCancel: () => _ctrl.reverse(),
          child: ScaleTransition(
            scale: _scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              height: 56,
              decoration: BoxDecoration(
                color: enabled
                    ? kGreenBright
                    : kGreenBright.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated check indicator ────────────────────────────────────────────────
class _CheckIndicator extends StatelessWidget {
  final bool selected;
  final double size;
  const _CheckIndicator({required this.selected, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? kGreenBright : Colors.white.withValues(alpha: 0.6),
        border: Border.all(
          color: selected ? kGreenBright : const Color(0xFFCCDDD3),
          width: selected ? 0 : 1.5),
      ),
      child: selected
          ? Icon(LucideIcons.check, size: size * 0.55, color: Colors.white)
          : null,
    );
  }
}

// ── Data models ─────────────────────────────────────────────────────────────
class GoalItem {
  final String label;
  final IconData icon;
  GoalItem(this.label, this.icon);
}

class LevelItem {
  final String label, sub;
  final IconData icon;
  LevelItem(this.label, this.sub, this.icon);
}

class GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final segments = [
      (0.0, 90.0, const Color(0xFF4285F4)),
      (90.0, 180.0, const Color(0xFF34A853)),
      (180.0, 270.0, const Color(0xFFFBBC05)),
      (270.0, 360.0, const Color(0xFFEA4335)),
    ];
    for (final (s, e, color) in segments) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = size.width * 0.22
        ..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCircle(center: center, radius: size.width * 0.36),
        s * pi / 180, (e - s) * pi / 180, false, paint);
    }
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.38,
        size.width * 0.5, size.height * 0.24),
      Paint()..color = Colors.white);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.44,
        size.width * 0.38, size.height * 0.12),
      Paint()..color = const Color(0xFF4285F4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
