import 'package:fiteva/providers/mascot_provider.dart';
import 'package:fiteva/widgets/mascot_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cercle d'avatar partagé pour le feed, les événements et les partenaires.
/// - URL fournie  → image réseau avec fallback initiale.
/// - URL vide     → mascotte de l'utilisateur (style header).
class CommunityAvatar extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final cs     = Theme.of(context).colorScheme;
    final mascot = ref.watch(mascotProvider);
    final size   = radius * 2;

    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: cs.primary.withValues(alpha: 0.15),
        backgroundImage: NetworkImage(avatarUrl),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: MascotWidget(
          type: mascot.type,
          mood: mascot.mood,
          size: size,
        ),
      ),
    );
  }
}
