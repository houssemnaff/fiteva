import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ── Premium dark palette ─────────────────────────────────────────────────────
const kBgDark      = Color(0xFF080E0B);
const kBgMid       = Color(0xFF0F1A14);
const kBgMint      = Color(0xFF080E0B);
const kBgLight     = Color(0xFF0F1A14);
const kGreenDark   = Color(0xFF1C4D30);
const kGreenMid    = Color(0xFF7ABB98);
const kGreenBright = Color(0xFF5CD57A);
const kCardUnsel   = Color(0xFF1A2A20);
const kCardSel     = Color(0xFF1C4D30);
const kTextDark    = Color(0xFFF0F0EE);
const kTextMuted   = Color(0xFF6B8B78);
const kWhite       = Colors.white;
const kGlassBorder = Color(0xFF2A3D30);
const kGlassFill   = Color(0x18FFFFFF);

// ── Premium scaffold ────────────────────────────────────────────────────────
Widget mintScaffold({required Widget child}) {
  return Scaffold(
    backgroundColor: kBgDark,
    body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.35, 1.0],
              colors: [Color(0xFF0D1F14), Color(0xFF0A130E), Color(0xFF080E0B)],
            ),
          ),
        ),
        Positioned(
          top: -100, right: -80,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                kGreenDark.withValues(alpha: 0.18),
                kGreenDark.withValues(alpha: 0),
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: 80, left: -100,
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                kGreenMid.withValues(alpha: 0.06),
                kGreenMid.withValues(alpha: 0),
              ]),
            ),
          ),
        ),
        child,
      ],
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
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    (onBack ?? () => Navigator.maybePop(context))();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: kGlassFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kGlassBorder, width: 0.5),
                        ),
                        child: const Icon(LucideIcons.arrowLeft, size: 18, color: kTextDark),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$step of $total',
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: kTextMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Segmented progress bar
            Row(
              children: List.generate(total, (i) {
                final isCompleted = i < step;
                final isCurrent = i == step - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isCompleted
                            ? kGreenBright
                            : kWhite.withValues(alpha: 0.08),
                        boxShadow: isCurrent
                            ? [BoxShadow(
                                color: kGreenBright.withValues(alpha: 0.4),
                                blurRadius: 8)]
                            : [],
                      ),
                    ),
                  ),
                );
              }),
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
            color: kTextDark,
            height: 1.1,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: kTextMuted,
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1C4D30), Color(0xFF0F3320)],
          ),
          boxShadow: [
            BoxShadow(
              color: kGreenBright.withValues(alpha: 0.15),
              blurRadius: 20, spreadRadius: 1),
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
            color: sel ? kGreenDark.withValues(alpha: 0.35) : kGlassFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: sel ? kGreenBright.withValues(alpha: 0.5) : kGlassBorder,
              width: sel ? 1.2 : 0.5,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: kGreenBright.withValues(alpha: 0.08),
                    blurRadius: 24, offset: const Offset(0, 8))]
                : [],
          ),
          child: Row(children: [
            if (widget.icon != null) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: sel
                      ? kGreenBright.withValues(alpha: 0.12)
                      : kWhite.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(widget.icon,
                  color: sel ? kGreenBright : kTextMuted, size: 20),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.label, style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: sel ? kWhite : kTextDark)),
                if (widget.sublabel != null) ...[
                  const SizedBox(height: 3),
                  Text(widget.sublabel!, style: GoogleFonts.inter(
                    fontSize: 13, color: sel ? kGreenMid : kTextMuted,
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
            color: sel ? kGreenDark.withValues(alpha: 0.35) : kGlassFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: sel ? kGreenBright.withValues(alpha: 0.5) : kGlassBorder,
              width: sel ? 1.2 : 0.5,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: kGreenBright.withValues(alpha: 0.08),
                    blurRadius: 20, offset: const Offset(0, 6))]
                : [],
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
                      : kWhite.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon,
                  color: sel ? kGreenBright : kTextMuted, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: sel ? kWhite : kTextDark,
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
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF22694A), Color(0xFF1C4D30)])
                    : null,
                color: enabled ? null : kWhite.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: enabled
                    ? null
                    : Border.all(color: kGlassBorder, width: 0.5),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: kGreenDark.withValues(alpha: 0.5),
                          blurRadius: 24, offset: const Offset(0, 8)),
                        BoxShadow(
                          color: kGreenBright.withValues(alpha: 0.1),
                          blurRadius: 40, offset: const Offset(0, 4)),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  enabled ? widget.label : widget.label,
                  style: GoogleFonts.outfit(
                    fontSize: 17, fontWeight: FontWeight.w700,
                    color: enabled ? kWhite : kTextMuted,
                    letterSpacing: 0.2),
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
        color: selected ? kGreenBright : Colors.transparent,
        border: Border.all(
          color: selected ? kGreenBright : kWhite.withValues(alpha: 0.15),
          width: selected ? 0 : 1.5),
      ),
      child: selected
          ? Icon(LucideIcons.check, size: size * 0.55, color: kBgDark)
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
