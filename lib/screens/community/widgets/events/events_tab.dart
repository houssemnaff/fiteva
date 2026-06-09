import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/community_providers.dart';
import 'participants_sheet.dart';

const _kGreen   = Color(0xFF1C4D30);
const _kMint    = Color(0xFF7ABB98);
const _kBg      = Color(0xFFFEFEFE);
const _kSurface = Colors.white;
const _kBorder  = Color(0xFFECECEC);
const _kText1   = Color(0xFF1A1A1A);
const _kText2   = Color(0xFF757575);

// ─── Events Tab ───────────────────────────────────────────────
class EventsTab extends ConsumerStatefulWidget {
  const EventsTab({super.key});
  @override
  ConsumerState<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends ConsumerState<EventsTab> {
  String _selectedType = 'Tous';

  static const _filters = ['Tous', 'Running', 'Yoga', 'Gym', 'Natation', 'Vélo'];
  static const Map<String, IconData> _icons = {
    'running':  LucideIcons.footprints,
    'yoga':     LucideIcons.sparkles,
    'gym':      LucideIcons.dumbbell,
    'natation': LucideIcons.waves,
    'vélo':     LucideIcons.bike,
  };

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(eventsNotifierProvider);
    final filtered = _selectedType == 'Tous'
        ? events
        : events.where((e) => e.type.toLowerCase() == _selectedType.toLowerCase()).toList();

    return ColoredBox(
      color: _kBg,
      child: CustomScrollView(
        slivers: [

          // ── Header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EVENTS', style: GoogleFonts.inter(
                    color: _kMint, fontSize: 9,
                    fontWeight: FontWeight.w700, letterSpacing: 3,
                  )),
                  const SizedBox(height: 3),
                  Text('Événements', style: GoogleFonts.outfit(
                    color: _kText1, fontSize: 26,
                    fontWeight: FontWeight.w800, letterSpacing: -0.5,
                  )),
                ],
              ),
            ),
          ),

          // ── Filter pills ──────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                itemCount: _filters.length,
                itemBuilder: (_, i) {
                  final label = _filters[i];
                  final sel = _selectedType == label;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedType = label);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 5),
                      decoration: BoxDecoration(
                        color: sel ? _kGreen : _kSurface,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: sel ? _kGreen : _kBorder),
                      ),
                      child: Text(label, style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : _kText2,
                      )),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Event List ────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, i) {
                final event = filtered[i];
                return EventCard(
                  event: event,
                  typeIcon: _icons[event.type.toLowerCase()] ??
                      LucideIcons.calendarDays,
                  onJoin: () {
                    HapticFeedback.mediumImpact();
                    ref.read(eventsNotifierProvider.notifier).toggleJoin(event.id);
                  },
                  onViewParticipants: () => showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ParticipantsSheet(event: event),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Event Card ───────────────────────────────────────────────
class EventCard extends StatelessWidget {
  final EventModel event;
  final IconData typeIcon;
  final VoidCallback onJoin;
  final VoidCallback onViewParticipants;

  const EventCard({
    super.key,
    required this.event,
    required this.typeIcon,
    required this.onJoin,
    required this.onViewParticipants,
  });

  @override
  Widget build(BuildContext context) {
    final spotsLeft = event.maxSpots - event.joinedCount;
    final isFull    = spotsLeft <= 0;
    final isJoined  = event.isJoined;

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Banner
          Stack(children: [
            SizedBox(
              height: 160, width: double.infinity,
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: _kGreen.withOpacity(0.1),
                  child: Center(child: Icon(LucideIcons.image,
                      color: _kGreen.withOpacity(0.3), size: 32)),
                ),
              ),
            ),
            // Scrim
            Positioned(
              bottom: 0, left: 0, right: 0, height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [_kGreen.withOpacity(0.75), Colors.transparent],
                  ),
                ),
              ),
            ),
            // Type badge
            Positioned(
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _kGreen,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(typeIcon, size: 10, color: _kMint),
                  const SizedBox(width: 5),
                  Text(event.type.toUpperCase(), style: GoogleFonts.inter(
                    fontSize: 9, color: Colors.white,
                    fontWeight: FontWeight.w800, letterSpacing: 1,
                  )),
                ]),
              ),
            ),
            // Spots badge
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isFull
                      ? Colors.red.withOpacity(0.85)
                      : Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  isFull ? 'Complet' : '$spotsLeft places',
                  style: GoogleFonts.inter(
                    fontSize: 9, color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ]),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(event.title, style: GoogleFonts.outfit(
                  color: _kText1, fontSize: 17,
                  fontWeight: FontWeight.w800, letterSpacing: -0.4,
                )),
                const SizedBox(height: 12),

                // Meta
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _MetaChip(icon: LucideIcons.calendarDays,
                        label: '${event.date} · ${event.time}'),
                    _MetaChip(icon: LucideIcons.mapPin, label: event.location),
                  ],
                ),
                const SizedBox(height: 14),

                Divider(height: 1, color: _kBorder),
                const SizedBox(height: 14),

                // Organizer + participants
                Row(children: [
                  _ProAvatar(url: event.organizerAvatar, radius: 14),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Organisé par', style: GoogleFonts.inter(
                          color: _kText2, fontSize: 10,
                        )),
                        Text(event.organizer, style: GoogleFonts.inter(
                          color: _kText1, fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onViewParticipants,
                    child: _ParticipantsStack(
                      avatars: event.participantAvatars,
                      count: event.joinedCount,
                    ),
                  ),
                ]),

                const SizedBox(height: 14),

                // CTA
                _JoinButton(isJoined: isJoined, isFull: isFull,
                    onTap: isFull ? null : onJoin),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _kGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: _kGreen),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(
          fontSize: 11, color: _kText1, fontWeight: FontWeight.w500,
        )),
      ]),
    );
  }
}

class _ParticipantsStack extends StatelessWidget {
  final List<String> avatars;
  final int count;
  const _ParticipantsStack({required this.avatars, required this.count});

  @override
  Widget build(BuildContext context) {
    const size = 26.0;
    const overlap = 18.0;
    final shown = avatars.take(3).toList();
    return Row(children: [
      SizedBox(
        width: shown.length * overlap + (size - overlap),
        height: size,
        child: Stack(
          children: List.generate(shown.length, (i) => Positioned(
            left: i * overlap,
            child: Container(
              width: size, height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _kSurface, width: 1.5),
              ),
              child: ClipOval(child: Image.network(shown[i], fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: _kMint.withOpacity(0.3)))),
            ),
          )),
        ),
      ),
      const SizedBox(width: 7),
      Text('+$count', style: GoogleFonts.inter(
        color: _kText2, fontSize: 11, fontWeight: FontWeight.w600,
      )),
    ]);
  }
}

class _JoinButton extends StatelessWidget {
  final bool isJoined, isFull;
  final VoidCallback? onTap;
  const _JoinButton({required this.isJoined, required this.isFull, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData icon;
    final String label;

    if (isJoined) {
      bg = _kMint.withOpacity(0.15); fg = _kGreen;
      icon = LucideIcons.checkCircle; label = 'Inscrit ✓';
    } else if (isFull) {
      bg = Colors.red.withOpacity(0.08); fg = Colors.red.shade600;
      icon = LucideIcons.xCircle; label = 'Complet';
    } else {
      bg = _kGreen; fg = Colors.white;
      icon = LucideIcons.userPlus; label = 'Rejoindre';
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: (isJoined || isFull)
              ? Border.all(color: fg.withOpacity(0.25))
              : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(
            color: fg, fontSize: 13,
            fontWeight: FontWeight.w800, letterSpacing: 0.2,
          )),
        ]),
      ),
    );
  }
}

class _ProAvatar extends StatelessWidget {
  final String url;
  final double radius;
  const _ProAvatar({required this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2, height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _kSurface, width: 1),
      ),
      child: ClipOval(
        child: Image.network(url, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: _kMint.withOpacity(0.3))),
      ),
    );
  }
}