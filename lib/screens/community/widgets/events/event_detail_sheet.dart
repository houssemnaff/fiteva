// ignore_for_file: deprecated_member_use
import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/community_providers.dart';

void showEventDetail(BuildContext context, EventModel event) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => EventDetailSheet(event: event),
  );
}

class EventDetailSheet extends ConsumerWidget {
  final EventModel event;
  const EventDetailSheet({super.key, required this.event});

  static const Map<String, IconData> _icons = {
    'running':  LucideIcons.footprints,
    'yoga':     LucideIcons.sparkles,
    'gym':      LucideIcons.dumbbell,
    'natation': LucideIcons.waves,
    'vélo':     LucideIcons.bike,
    'muscu':    LucideIcons.dumbbell,
    'autre':    LucideIcons.calendarDays,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs        = Theme.of(context).colorScheme;
    final events    = ref.watch(eventsNotifierProvider);
    final ev        = events.firstWhere((e) => e.id == event.id,
        orElse: () => event);
    final spotsLeft = ev.maxSpots - ev.joinedCount;
    final isFull    = spotsLeft <= 0;
    final isJoined  = ev.isJoined;
    final typeIcon  = _icons[ev.type.toLowerCase()] ?? LucideIcons.calendarDays;
    final screenH   = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.92),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Handle ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 0),
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

                  // ── Hero image ──────────────────────────────────
                  Stack(children: [
                    SizedBox(
                      height: 240, width: double.infinity,
                      child: Image.network(
                        ev.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 240,
                          color: cs.primary.withValues(alpha: 0.12),
                          child: Icon(LucideIcons.image,
                              size: 40,
                              color: cs.primary.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                    // Bottom scrim
                    Positioned(
                      bottom: 0, left: 0, right: 0, height: 100,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              cs.surface,
                              cs.surface.withValues(alpha: 0),
                            ],
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
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.x,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    // Type badge
                    Positioned(
                      top: 14, left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(typeIcon, size: 11, color: cs.onPrimary),
                          const SizedBox(width: 6),
                          Text(ev.type.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9, color: cs.onPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5)),
                        ]),
                      ),
                    ),
                  ]),

                  // ── Content ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Title
                        Text(ev.title, style: GoogleFonts.outfit(
                          fontSize: 24, fontWeight: FontWeight.w800,
                          color: cs.onSurface, letterSpacing: -0.5,
                          height: 1.2)),
                        const SizedBox(height: 16),

                        // ── Info cards row ───────────────────────
                        Row(children: [
                          Expanded(child: _InfoCard(
                            icon: LucideIcons.calendarDays,
                            label: 'Date',
                            value: ev.date,
                            sub: ev.time,
                            cs: cs,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _InfoCard(
                            icon: LucideIcons.mapPin,
                            label: 'Lieu',
                            value: ev.location,
                            sub: 'Voir sur carte',
                            cs: cs,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _InfoCard(
                            icon: LucideIcons.users,
                            label: 'Places',
                            value: isFull
                                ? 'Complet'
                                : '$spotsLeft/${ev.maxSpots}',
                            sub: isFull ? 'Aucune place' : 'disponibles',
                            cs: cs,
                            accent: isFull,
                          )),
                        ]),
                        const SizedBox(height: 20),

                        // ── Organizer ────────────────────────────
                        Text('ORGANISATEUR', style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          color: cs.onSurface.withValues(alpha: 0.45),
                          letterSpacing: 2)),
                        const SizedBox(height: 10),
                        Row(children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage:
                                NetworkImage(ev.organizerAvatar),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ev.organizer, style: GoogleFonts.outfit(
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: cs.onSurface, letterSpacing: -0.2)),
                              Text('Organisateur', style: GoogleFonts.inter(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.5))),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: cs.primary.withValues(alpha: 0.2)),
                            ),
                            child: Text('Message', style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: cs.primary)),
                          ),
                        ]),

                        const SizedBox(height: 20),

                        // ── Participants ─────────────────────────
                        if (ev.participantAvatars.isNotEmpty ||
                            ev.joinedCount > 0) ...[
                          Text('PARTICIPANTS', style: GoogleFonts.inter(
                            fontSize: 9, fontWeight: FontWeight.w700,
                            color: cs.onSurface.withValues(alpha: 0.45),
                            letterSpacing: 2)),
                          const SizedBox(height: 10),
                          _ParticipantStrip(
                              avatars: ev.participantAvatars,
                              count: ev.joinedCount,
                              cs: cs),
                          const SizedBox(height: 20),
                        ],

                        // ── About / details ──────────────────────
                        Text('À PROPOS', style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          color: cs.onSurface.withValues(alpha: 0.45),
                          letterSpacing: 2)),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cs.outline),
                          ),
                          child: Text(
                            'Rejoins-nous pour une session ${ev.type} '
                            'inoubliable ! Niveau requis : tous niveaux '
                            'bienvenus. Apporte ta tenue et ta motivation.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: cs.onSurface.withValues(alpha: 0.7),
                              height: 1.6)),
                        ),

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
                  top: BorderSide(color: cs.outline.withValues(alpha: 0.6))),
            ),
            child: Row(children: [
              // Spots indicator
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  isFull ? 'Complet' : '$spotsLeft places restantes',
                  style: GoogleFonts.outfit(
                    fontSize: 15, fontWeight: FontWeight.w800,
                    color: isFull ? cs.error : cs.onSurface,
                    letterSpacing: -0.3)),
                Text(ev.date, style: GoogleFonts.inter(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.5))),
              ]),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: isFull
                      ? null
                      : () {
                          HapticFeedback.mediumImpact();
                          ref
                              .read(eventsNotifierProvider.notifier)
                              .toggleJoin(ev.id);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isJoined
                          ? cs.primary.withValues(alpha: 0.1)
                          : isFull
                              ? cs.error.withValues(alpha: 0.1)
                              : cs.primary,
                      borderRadius: BorderRadius.circular(16),
                      border: isJoined
                          ? Border.all(
                              color: cs.primary.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        isJoined
                            ? 'Inscrit — Annuler'
                            : isFull
                                ? 'Événement complet'
                                : 'Rejoindre l\'événement',
                        style: GoogleFonts.outfit(
                          fontSize: 15, fontWeight: FontWeight.w800,
                          color: isJoined
                              ? cs.primary
                              : isFull
                                  ? cs.error
                                  : cs.onPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label, value, sub;
  final ColorScheme cs;
  final bool accent;
  const _InfoCard({
    required this.icon, required this.label,
    required this.value, required this.sub,
    required this.cs, this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent
            ? cs.error.withValues(alpha: 0.07)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent
              ? cs.error.withValues(alpha: 0.25)
              : cs.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 14,
            color: accent ? cs.error : cs.primary),
        const SizedBox(height: 6),
        Text(label.toUpperCase(), style: GoogleFonts.inter(
          fontSize: 8, fontWeight: FontWeight.w700,
          color: cs.onSurface.withValues(alpha: 0.45),
          letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.outfit(
          fontSize: 13, fontWeight: FontWeight.w800,
          color: accent ? cs.error : cs.onSurface,
          letterSpacing: -0.2),
          overflow: TextOverflow.ellipsis),
        Text(sub, style: GoogleFonts.inter(
          fontSize: 9,
          color: cs.onSurface.withValues(alpha: 0.45)),
          overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

// ─── Participant strip ────────────────────────────────────────
class _ParticipantStrip extends StatelessWidget {
  final List<String> avatars;
  final int count;
  final ColorScheme cs;
  const _ParticipantStrip({
    required this.avatars, required this.count, required this.cs});

  @override
  Widget build(BuildContext context) {
    const size   = 36.0;
    const offset = 26.0;
    final shown  = avatars.take(6).toList();
    return Row(children: [
      SizedBox(
        width: shown.isEmpty
            ? 0
            : shown.length * offset + (size - offset),
        height: size,
        child: Stack(
          children: List.generate(shown.length, (i) => Positioned(
            left: i * offset,
            child: Container(
              width: size, height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 2),
              ),
              child: ClipOval(child: Image.network(
                shown[i], fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: cs.secondary.withValues(alpha: 0.3)),
              )),
            ),
          )),
        ),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$count participant${count > 1 ? 's' : ''}',
            style: GoogleFonts.outfit(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: cs.onSurface, letterSpacing: -0.2)),
        Text('ont rejoint cet événement', style: GoogleFonts.inter(
          fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
      ]),
    ]);
  }
}
