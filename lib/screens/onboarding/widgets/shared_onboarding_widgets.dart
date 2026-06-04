import 'dart:math';

import 'package:flutter/material.dart';

const kBgMint = Color(0xFFB8CFC4);
const kBgLight = Color(0xFFC8DAD0);
const kGreenDark = Color(0xFF2D4A2D);
const kGreenMid = Color(0xFF4A7A5A);
const kCardUnsel = Color(0xFFD4E4DB);
const kCardSel = Color(0xFF2D4A2D);
const kTextDark = Color(0xFF1A2E1A);
const kTextMuted = Color(0xFF5A7A65);
const kWhite = Colors.white;

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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack ?? () => Navigator.maybePop(context),
              child: const Icon(Icons.arrow_back, size: 20, color: kTextDark),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title?.toUpperCase() ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
                    color: kTextMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

class StepIcon extends StatelessWidget {
  final IconData icon;
  const StepIcon(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: kGreenDark, size: 28),
      ),
    );
  }
}

class StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const StepHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: kTextDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: kTextMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class PillCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: fullWidth ? double.infinity : null,
        padding: sublabel != null
            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 18)
            : const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? kCardSel : Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? kCardSel : Colors.white.withOpacity(0.8),
            width: 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: kGreenDark.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))]
              : [],
        ),
        child: sublabel != null
            ? Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: selected ? kWhite : kGreenMid, size: 22),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: selected ? kWhite : kTextDark)),
                        const SizedBox(height: 2),
                        Text(sublabel!, style: TextStyle(fontSize: 12.5, color: selected ? Colors.white70 : kTextMuted)),
                      ],
                    ),
                  ),
                  if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 20),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: selected ? kWhite : kGreenMid, size: 20),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: selected ? kWhite : kTextDark)),
                  ),
                  if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 18),
                ],
              ),
      ),
    );
  }
}

class CompactPill extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? kCardSel : Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: selected ? kCardSel : Colors.white.withOpacity(0.8), width: 1.5),
          boxShadow: selected ? [BoxShadow(color: kGreenDark.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 5))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? kWhite : kGreenMid, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: selected ? kWhite : kTextDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const CtaButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              color: enabled ? kGreenDark : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.8, color: enabled ? kWhite : kTextMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget mintScaffold({required Widget child}) {
  return Scaffold(
    backgroundColor: kBgMint,
    body: child,
  );
}

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
    final radius = size.width / 2;
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
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.72), s * pi / 180, (e - s) * pi / 180, false, paint);
    }
    canvas.drawRect(Rect.fromLTWH(size.width * 0.5, size.height * 0.38, size.width * 0.5, size.height * 0.24), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.62, size.height * 0.44, size.width * 0.38, size.height * 0.12), Paint()..color = const Color(0xFF4285F4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
