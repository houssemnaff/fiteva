import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Filter Pill ──────────────────────────────────────────────
class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;


  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 4 : 0,
        ),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────
class SectionHeaderComm extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  const SectionHeaderComm({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSecondaryContainer)),
        ],
      ),
    );
  }
}

// ─── Sheet drag handle ────────────────────────────────────────
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        width: 42,
        height: 5,
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

// ─── Sheet section label ──────────────────────────────────────
class SheetSection extends StatelessWidget {
  final String title;
  final Widget child;

  const SheetSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ─── Social contact list (WhatsApp / Instagram / Facebook) ────
// Widget partagé par les cartes/feuilles de détail des partenaires et des
// événements — un seul design pour tous les contextes.
class SocialContactList extends StatelessWidget {
  final String contactWhatsapp;
  final String contactInstagram;
  final String contactFacebook;
  final ColorScheme cs;
  final String linkErrorMessage;
  /// Texte affiché quand aucun contact n'est renseigné.
  /// Si null, le widget ne rend rien dans ce cas (SizedBox.shrink).
  final String? emptyLabel;
  /// Libellé de section optionnel (ex. "CONTACTER L'ORGANISATEUR", "CONTACT")
  /// affiché au-dessus de la liste. Si null, aucun titre n'est rendu.
  final String? title;

  const SocialContactList({
    super.key,
    required this.contactWhatsapp,
    required this.contactInstagram,
    required this.contactFacebook,
    required this.cs,
    required this.linkErrorMessage,
    this.emptyLabel,
    this.title,
  });

  static const _brandColors = {
    'whatsapp':  Color(0xFF25D366),
    'instagram': Color(0xFFD62A7A),
    'facebook':  Color(0xFF3B6FE0),
  };

  static Uri? _contactUri(String platform, String raw) {
    final v = raw.trim();
    if (v.isEmpty) return null;
    switch (platform) {
      case 'whatsapp':
        final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
        return digits.isEmpty ? null : Uri.parse('https://wa.me/$digits');
      case 'instagram':
        if (v.startsWith('http')) return Uri.tryParse(v);
        final handle = v.startsWith('@') ? v.substring(1) : v;
        return Uri.parse('https://instagram.com/$handle');
      case 'facebook':
        if (v.startsWith('http')) return Uri.tryParse(v);
        return Uri.parse('https://facebook.com/${Uri.encodeComponent(v)}');
      default:
        return null;
    }
  }

  Future<void> _open(BuildContext context, Uri? uri) async {
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(linkErrorMessage),
      ));
    }
  }

  Widget _buildTitle() => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 3, height: 12,
      decoration: BoxDecoration(
        color: cs.primary, borderRadius: BorderRadius.circular(2)),
    ),
    const SizedBox(width: 8),
    Text(title!, style: GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w700,
      color: cs.onSurface.withValues(alpha: 0.55), letterSpacing: 0.4)),
  ]);

  @override
  Widget build(BuildContext context) {
    final contacts = [
      ('whatsapp', contactWhatsapp, LucideIcons.messageCircle, 'WhatsApp'),
      ('instagram', contactInstagram, LucideIcons.atSign, 'Instagram'),
      ('facebook', contactFacebook, LucideIcons.globe, 'Facebook'),
    ].where((c) => c.$2.trim().isNotEmpty).toList();

    if (contacts.isEmpty) {
      if (emptyLabel == null) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) ...[_buildTitle(), const SizedBox(height: 12)],
        Row(children: [
          Icon(LucideIcons.userX, size: 15,
              color: cs.onSurface.withValues(alpha: 0.3)),
          const SizedBox(width: 8),
          Text(emptyLabel!, style: GoogleFonts.inter(
            fontSize: 13, color: cs.onSurface.withValues(alpha: 0.45))),
        ]),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title != null) ...[_buildTitle(), const SizedBox(height: 12)],
      Row(children: [
        for (int i = 0; i < contacts.length; i++)
          Padding(
            padding: EdgeInsets.only(right: i < contacts.length - 1 ? 10 : 0),
            child: _ContactIcon(
              icon: contacts[i].$3,
              label: contacts[i].$4,
              brandColor: _brandColors[contacts[i].$1]!,
              onTap: () => _open(context, _contactUri(contacts[i].$1, contacts[i].$2)),
            ),
          ),
      ]),
    ]);
  }
}

class _ContactIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color brandColor;
  final VoidCallback onTap;
  const _ContactIcon({
    required this.icon, required this.label,
    required this.brandColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 38, height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [
                  brandColor.withValues(alpha: 0.20),
                  brandColor.withValues(alpha: 0.09),
                ],
              ),
            ),
            child: Icon(icon, size: 16, color: brandColor),
          ),
        ),
      ),
    );
  }
}

// ─── Composer info tile ───────────────────────────────────────
class ComposerInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ComposerInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}