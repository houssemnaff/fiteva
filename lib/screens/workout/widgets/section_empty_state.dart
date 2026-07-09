import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// État vide partagé par toutes les sections horizontales (Salle, Maison,
/// Dance, Récupération, Grossesse) — affiché à la place du carrousel quand
/// la liste filtrée est vide, pour que le header de section reste visible.
class SectionEmptyState extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const SectionEmptyState({
    super.key,
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color.withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
