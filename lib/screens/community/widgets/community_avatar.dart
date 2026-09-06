import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cercle d'avatar partagé pour le feed, les commentaires, les événements
/// et les partenaires.
/// - URL fournie → image réseau.
/// - URL vide     → première lettre du nom.
class CommunityAvatar extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final double radius;

  const CommunityAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: cs.primary.withValues(alpha: 0.15),
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: cs.primary.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: GoogleFonts.outfit(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: cs.primary,
        ),
      ),
    );
  }
}
