import 'package:fiteva/providers/workout_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Badge « Vu » (vidéo déjà complétée à 80 %) — partagé entre les sections
/// vidéo (Danse, Récupération…). Passer [color] pour suivre la couleur de la
/// section (elle-même dérivée du template) ; vert par défaut.
class WatchedBadge extends ConsumerWidget {
  final String videoId;
  final Color? color;
  const WatchedBadge({super.key, required this.videoId, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done =
        ref.watch(completedVideosProvider).asData?.value.contains(videoId) ??
            false;
    if (!done) return const SizedBox.shrink();
    final c = color ?? Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: c.withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.checkCircle, color: Colors.white, size: 10),
          const SizedBox(width: 4),
          Text(
            'Vu',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
