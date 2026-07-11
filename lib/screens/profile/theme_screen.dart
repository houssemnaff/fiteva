// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/color_palettes.dart';
import '../../widgets/paywall_sheet.dart';

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final current = ref.watch(colorPaletteProvider);
    final isPro = ref.watch(isProProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.arrowLeft, size: 16, color: cs.onSurface),
          ),
        ),
        title: Text('Thèmes', style: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w800, color: cs.onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text('Personnalise les couleurs de ton app',
            style: GoogleFonts.inter(
              fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 20),
          ...kPalettes.map((p) => _PaletteCard(
            palette: p,
            isSelected: current.id == p.id,
            isPro: isPro,
            onTap: () {
              HapticFeedback.selectionClick();
              if (!p.isFree && !isPro) {
                showPaywallSheet(context,
                  feature: 'Thème ${p.name}',
                  description:
                    'Les thèmes de couleur exclusifs sont réservés aux '
                    'abonnées FITEVA Pro. Personnalise ton app !');
                return;
              }
              ref.read(colorPaletteProvider.notifier).setPalette(p);
            },
          )),
        ],
      ),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  final AppColorPalette palette;
  final bool isSelected;
  final bool isPro;
  final VoidCallback onTap;

  const _PaletteCard({
    required this.palette,
    required this.isSelected,
    required this.isPro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locked = !palette.isFree && !isPro;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? palette.primary.withValues(alpha: 0.08)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? palette.primary : cs.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          // Color preview circles
          SizedBox(
            width: 52, height: 52,
            child: Stack(children: [
              Positioned(
                left: 0, top: 0,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: palette.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: palette.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ]),
          ),

          const SizedBox(width: 14),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(palette.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(palette.name, style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
              ]),
              const SizedBox(height: 4),
              // Mini preview bar
              Row(children: [
                _MiniSwatch(palette.primary),
                _MiniSwatch(palette.accent),
                _MiniSwatch(Color.lerp(palette.primary, palette.accent, 0.5)!),
                _MiniSwatch(Color.lerp(palette.primary, Colors.white, 0.7)!),
              ]),
            ],
          )),

          if (isSelected)
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: palette.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.check, size: 16, color: Colors.white),
            )
          else if (locked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFD4A017).withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.lock, size: 10,
                  color: Color(0xFFD4A017)),
                const SizedBox(width: 4),
                Text('PRO', style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w800,
                  color: const Color(0xFFD4A017))),
              ]),
            )
          else
            Icon(LucideIcons.chevronRight, size: 16,
              color: cs.onSurface.withValues(alpha: 0.25)),
        ]),
      ),
    );
  }
}

class _MiniSwatch extends StatelessWidget {
  final Color color;
  const _MiniSwatch(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18, height: 8,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
