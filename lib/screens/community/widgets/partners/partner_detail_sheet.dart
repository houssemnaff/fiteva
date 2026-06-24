// ignore_for_file: deprecated_member_use
import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../l10n/app_localizations.dart';

void showPartnerDetail(BuildContext context, PartnerModel partner, Color color) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => PartnerDetailSheet(partner: partner, color: color),
  );
}

class PartnerDetailSheet extends ConsumerStatefulWidget {
  final PartnerModel partner;
  final Color color;
  const PartnerDetailSheet({super.key, required this.partner, required this.color});

  @override
  ConsumerState<PartnerDetailSheet> createState() => _PartnerDetailSheetState();
}

class _PartnerDetailSheetState extends ConsumerState<PartnerDetailSheet> {
  bool _messaged = false;

  String get _initials {
    final p = widget.partner.name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return widget.partner.name.substring(0,
        widget.partner.name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color get _levelColor {
    switch (widget.partner.level) {
      case 'Débutant':      return const Color(0xFF34D399);
      case 'Intermédiaire': return const Color(0xFFFBBF24);
      case 'Avancé':        return const Color(0xFFF87171);
      default:              return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final l10n      = ref.watch(l10nProvider);
    final p         = widget.partner;
    final c         = widget.color;
    final screenH   = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.90),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: cs.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Hero avatar section ────────────────────────
                  Stack(children: [
                    // Colored background
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: c,
                      child: Center(
                        child: Text(_initials, style: GoogleFonts.outfit(
                          fontSize: 72, fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: -2)),
                      ),
                    ),
                    // Gradient fade to surface
                    Positioned(
                      bottom: 0, left: 0, right: 0, height: 70,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [cs.surface, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    // Close button
                    Positioned(
                      top: 14, right: 14,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.x,
                              size: 15, color: Colors.white),
                        ),
                      ),
                    ),
                    // Level badge
                    Positioned(
                      top: 14, left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 7, height: 7,
                            decoration: BoxDecoration(
                              color: _levelColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text(p.level, style: GoogleFonts.inter(
                            fontSize: 10, color: Colors.white,
                            fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ]),

                  // ── Identity ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(p.name, style: GoogleFonts.outfit(
                          fontSize: 26, fontWeight: FontWeight.w800,
                          color: cs.onSurface, letterSpacing: -0.6,
                          height: 1.1)),
                        const SizedBox(height: 6),

                        // Location + frequency
                        Row(children: [
                          Icon(LucideIcons.mapPin, size: 13,
                              color: c),
                          const SizedBox(width: 5),
                          Text(p.region, style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: cs.onSurface.withValues(alpha: 0.6))),
                          const SizedBox(width: 14),
                          Icon(LucideIcons.calendarDays, size: 13,
                              color: c),
                          const SizedBox(width: 5),
                          Text(p.frequency, style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: cs.onSurface.withValues(alpha: 0.6))),
                        ]),

                        const SizedBox(height: 16),

                        // ── Goal ──────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: c.withValues(alpha: 0.25)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min,
                              children: [
                            Icon(LucideIcons.target, size: 14, color: c),
                            const SizedBox(width: 8),
                            Text(p.goal, style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: c)),
                          ]),
                        ),

                        const SizedBox(height: 20),

                        // ── À propos ──────────────────────────────
                        Text(l10n.communityAboutLabel, style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          color: cs.onSurface.withValues(alpha: 0.4),
                          letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text(
                          p.description.isNotEmpty
                              ? p.description
                              : 'Aucune description fournie.',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: cs.onSurface.withValues(alpha: 0.75),
                            height: 1.65)),

                        const SizedBox(height: 20),

                        // ── Tags ──────────────────────────────────
                        if (p.tags.isNotEmpty) ...[
                          Text(l10n.communityTagsLabel, style: GoogleFonts.inter(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: cs.onSurface.withValues(alpha: 0.4),
                            letterSpacing: 2)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: p.tags.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: cs.outline),
                              ),
                              child: Text('#$tag', style: GoogleFonts.inter(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: cs.onSurface.withValues(
                                    alpha: 0.6))),
                            )).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Stats row ─────────────────────────────
                        Row(children: [
                          Expanded(child: _StatBox(
                            label: 'Niveau', value: p.level, color: c, cs: cs)),
                          const SizedBox(width: 10),
                          Expanded(child: _StatBox(
                            label: 'Fréquence', value: p.frequency,
                            color: c, cs: cs)),
                          const SizedBox(width: 10),
                          Expanded(child: _StatBox(
                            label: 'Région', value: p.region,
                            color: c, cs: cs)),
                        ]),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom CTA ────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(
                  top: BorderSide(
                      color: cs.outline.withValues(alpha: 0.6))),
            ),
            child: GestureDetector(
              onTap: _messaged
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      setState(() => _messaged = true);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _messaged
                      ? c.withValues(alpha: 0.1)
                      : c,
                  borderRadius: BorderRadius.circular(16),
                  border: _messaged
                      ? Border.all(color: c.withValues(alpha: 0.3))
                      : null,
                ),
                child: Center(
                  child: _messaged
                      ? Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(LucideIcons.checkCircle,
                              size: 16, color: c),
                          const SizedBox(width: 8),
                          Text(l10n.communityMessageSent,
                              style: GoogleFonts.outfit(
                                fontSize: 15, fontWeight: FontWeight.w800,
                                color: c)),
                        ])
                      : Text(l10n.communitySendMessage,
                          style: GoogleFonts.outfit(
                            fontSize: 15, fontWeight: FontWeight.w800,
                            color: Colors.white, letterSpacing: 0.2)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  final ColorScheme cs;
  const _StatBox({
    required this.label, required this.value,
    required this.color, required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(
          fontSize: 8, fontWeight: FontWeight.w700,
          color: cs.onSurface.withValues(alpha: 0.4),
          letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text(value,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 13, fontWeight: FontWeight.w800,
            color: cs.onSurface, letterSpacing: -0.2)),
      ]),
    );
  }
}
