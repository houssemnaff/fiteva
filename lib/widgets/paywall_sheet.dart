import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<void> showPaywallSheet(
  BuildContext context, {
  required String feature,
  required String description,
}) {
  final d = Theme.of(context).brightness == Brightness.dark;
  const main = Color(0xFF1C4D30);
  const sage = Color(0xFF7ABB98);
  final surf = d ? const Color(0xFF162119) : Colors.white;
  final ink  = d ? const Color(0xFFF0F0EE) : const Color(0xFF1A1A1A);
  final muted = d ? const Color(0xFF8A9B92) : const Color(0xFF6B7B73);
  final bdr  = d ? const Color(0xFF253D2E) : const Color(0xFFE8ECE9);

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4,
            decoration: BoxDecoration(
              color: bdr, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),

          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [main, sage]),
              borderRadius: BorderRadius.circular(16)),
            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 18),

          Text(feature,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700,
              color: ink, letterSpacing: -0.3)),
          const SizedBox(height: 4),
          Text('Réservé aux membres Pro',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
              color: sage)),
          const SizedBox(height: 10),

          Text(description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: muted, height: 1.5)),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: () { Navigator.of(ctx).pop(); context.push('/profile'); },
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: main,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                  color: main.withValues(alpha: 0.25),
                  blurRadius: 12, offset: const Offset(0, 4))]),
              child: Center(child: Text('Découvrir FITEVA Pro',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700,
                  color: Colors.white))),
            ),
          ),
          const SizedBox(height: 10),

          GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Plus tard',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
                  color: muted)),
            ),
          ),
        ],
      ),
    ),
  );
}
