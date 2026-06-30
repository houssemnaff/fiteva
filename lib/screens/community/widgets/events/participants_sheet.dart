import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:fiteva/services/comuniter_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../shared/community_shared_widgets.dart';

class ParticipantsSheet extends StatefulWidget {
  final EventModel event;
  final ColorScheme colorScheme;

  const ParticipantsSheet(
      {super.key, required this.event, required this.colorScheme});

  @override
  State<ParticipantsSheet> createState() => _ParticipantsSheetState();
}

class _ParticipantsSheetState extends State<ParticipantsSheet> {
  late final Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = CommunityService.getEventParticipants(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetHandle(),
          const SizedBox(height: 20),
          Row(children: [
            Icon(LucideIcons.users, size: 18, color: cs.primary),
            const SizedBox(width: 8),
            Text(
              'Participants (${widget.event.joinedCount}/${widget.event.maxSpots})',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          ]),
          const SizedBox(height: 20),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(color: cs.primary),
                  ),
                );
              }

              final participants = snap.data ?? [];

              if (participants.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(children: [
                      Icon(LucideIcons.userX,
                          size: 36,
                          color: cs.onSurface.withValues(alpha: 0.25)),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun participant pour l\'instant',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ]),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: participants.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: cs.outline.withValues(alpha: 0.4)),
                itemBuilder: (_, i) {
                  final p = participants[i];
                  final name = (p['username'] as String? ?? '').trim();
                  final displayName = name.isNotEmpty ? name : 'Utilisateur';
                  final initial = displayName[0].toUpperCase();
                  final avatarColor = _colorFor(displayName, cs);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: avatarColor.withValues(alpha: 0.15),
                        child: Text(
                          initial,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: avatarColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              '@${displayName.toLowerCase().replaceAll(' ', '')}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// Couleur avatar déterministe basée sur le nom.
  Color _colorFor(String name, ColorScheme cs) {
    const palette = [
      Color(0xFF6C63FF),
      Color(0xFF00B894),
      Color(0xFFE17055),
      Color(0xFF0984E3),
      Color(0xFFD63031),
      Color(0xFF6AB04C),
      Color(0xFFEB4D4B),
      Color(0xFF22A6B3),
    ];
    final index = name.codeUnits.fold(0, (a, b) => a + b) % palette.length;
    return palette[index];
  }
}
