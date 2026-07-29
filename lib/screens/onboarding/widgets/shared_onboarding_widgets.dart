import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ── Clean white palette ──────────────────────────────────────────────────────
const kBgDark      = Color(0xFFF8F8F8);
const kBgMid       = Color(0xFFF2F2F2);
const kBgMint      = Color(0xFFF8F8F8);
const kBgLight     = Color(0xFFF2F2F2);
const kGreenDark   = Color(0xFF2D8B55);
const kGreenMid    = Color(0xFF3DA06A);
const kGreenBright = Color(0xFF2D8B55);
const kCardUnsel   = Color(0xFFF2F2F2);
const kCardSel     = Color(0xFF2D8B55);
const kTextDark    = Color(0xFF1A1A1A);
const kTextMuted   = Color(0xFF8E8E93);
const kWhite       = Colors.white;
const kGlassBorder = Color(0xFFE5E5E5);
const kGlassFill   = Color(0xFFF5F5F5);

// ── Clean scaffold with gradient ────────────────────────────────────────────
Widget mintScaffold({required Widget child}) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F5EC),
            Color(0xFFF0FAF3),
            Color(0xFFFCFDFC),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: child,
    ),
  );
}

// ── Animated segmented progress bar ─────────────────────────────────────────
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                (onBack ?? () => Navigator.maybePop(context))();
              },
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.7),
                  border: Border.all(color: const Color(0xFFCCDDD3), width: 1),
                ),
                child: const Icon(LucideIcons.arrowLeft, size: 18,
                    color: Color(0xFF1A3C2A)),
              ),
            ),
            const Spacer(),
            if (title != null) ...[
              Text(
                title!,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A3C2A)),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kGreenBright.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$step / $total',
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: kGreenBright),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step header — Apple-style large title ────────────────────────────────────
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
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A3C2A),
            height: 1.1,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF5A7A66),
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Step icon (kept for backward compat, refined) ───────────────────────────
class StepIcon extends StatelessWidget {
  final IconData icon;
  const StepIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: kGreenBright.withValues(alpha: 0.12),
          boxShadow: [
            BoxShadow(
              color: kGreenBright.withValues(alpha: 0.15),
              blurRadius: 16, spreadRadius: 1),
          ],
        ),
        child: Icon(icon, color: kGreenBright, size: 22),
      ),
    );
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
            color: sel
                ? const Color(0xFFE8F5EC)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: sel
                  ? kGreenBright.withValues(alpha: 0.5)
                  : const Color(0xFFCCDDD3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: sel
                    ? const Color(0xFF2D8B55).withValues(alpha: 0.1)
                    : const Color(0xFF000000).withValues(alpha: 0.03),
                blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Row(children: [
            if (widget.icon != null) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: sel
                      ? kGreenBright.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(widget.icon,
                  color: sel ? kGreenBright : const Color(0xFF5A7A66), size: 20),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.label, style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: sel
                      ? kGreenBright
                      : const Color(0xFF1A3C2A))),
                if (widget.sublabel != null) ...[
                  const SizedBox(height: 3),
                  Text(widget.sublabel!, style: GoogleFonts.inter(
                    fontSize: 13,
                    color: sel ? kGreenMid : const Color(0xFF5A7A66),
                    fontWeight: FontWeight.w400)),
                ],
              ],
            )),
            _CheckIndicator(selected: sel),
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
            color: sel
                ? const Color(0xFFE8F5EC)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel
                  ? kGreenBright.withValues(alpha: 0.5)
                  : const Color(0xFFCCDDD3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: sel
                    ? const Color(0xFF2D8B55).withValues(alpha: 0.1)
                    : const Color(0xFF000000).withValues(alpha: 0.03),
                blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: sel
                      ? kGreenBright.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon,
                  color: sel ? kGreenBright : const Color(0xFF5A7A66), size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: sel
                      ? const Color(0xFF1A3C2A)
                      : const Color(0xFF1A3C2A),
                  height: 1.3),
              ),
              const SizedBox(height: 8),
              _CheckIndicator(selected: sel, size: 18),
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
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
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
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: 58,
              decoration: BoxDecoration(
                gradient: enabled
                    ? const LinearGradient(
                        colors: [Color(0xFF2D8B55), Color(0xFF3DA06A)])
                    : null,
                color: enabled ? null : Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: enabled
                    ? null
                    : Border.all(color: const Color(0xFFCCDDD3)),
                boxShadow: enabled
                    ? [BoxShadow(
                        color: const Color(0xFF2D8B55).withValues(alpha: 0.3),
                        blurRadius: 16, offset: const Offset(0, 6))]
                    : null,
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: enabled
                        ? Colors.white
                        : const Color(0xFF5A7A66)),
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
