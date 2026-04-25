import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:fiteva/screens/community/widgets/shared/community_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_theme.dart';
import '../../providers/community_providers.dart';
import 'create_event_sheet.dart';
import 'participants_sheet.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────
class _C {
  static const bg         = Colors.white;
  static const surface    = Colors.white;
  static const card       = Colors.white;
  static const cardHigh   = Colors.white;
  static const border     = Colors.white;
  static const borderHigh = Colors.white;
  static const accent     = Color(0xFF1C4D30); // electric lime
  static const accentDim  = Colors.white;
  static const textPrimary   = Color(0xFF242428);
  static const textSecondary = Color(0xFF8A8A96);
  static const textTertiary  = Color(0xFF4A4A54);
  static const success    = Color(0xFF3DCC7A);
  static const successDim = Color(0x1A3DCC7A);
  static const danger     = Color(0xFFFF4757);
  static const dangerDim  = Color(0x1AFF4757);
}

// ─────────────────────────────────────────────
//  EVENTS TAB
// ─────────────────────────────────────────────
class EventsTab extends ConsumerStatefulWidget {
  const EventsTab({super.key});

  @override
  ConsumerState<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends ConsumerState<EventsTab> {
  String _selectedType = 'Tous';

  static const _typeFilters = [
    'Tous', 'Running', 'Yoga', 'Gym', 'Natation', 'Vélo',
  ];

  static const Map<String, IconData> _typeIcons = {
    'running':  LucideIcons.footprints,
    'yoga':     LucideIcons.sparkles,
    'gym':      LucideIcons.dumbbell,
    'natation': LucideIcons.waves,
    'vélo':     LucideIcons.bike,
  };

  @override
  Widget build(BuildContext context) {
    final events  = ref.watch(eventsProvider);
    final filtered = _selectedType == 'Tous'
        ? events
        : events
            .where((e) => e.type.toLowerCase() == _selectedType.toLowerCase())
            .toList();

    return Container(
      color: _C.bg,
      child: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _Header(
                onCreateTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black87,
                  builder: (_) => const CreateEventSheet(),
                ),
              ),
            ),
          ),

          // ── Filter Pills ─────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 0, 0),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 20),
                  itemCount: _typeFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final label    = _typeFilters[i];
                    final selected = _selectedType == label;
                    return _FilterPill(
                      label: label,
                      selected: selected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedType = label);
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // ── Event List ───────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = filtered[index];
                return EventCard(
                  event: event,
                  typeIcon: _typeIcons[event.type.toLowerCase()] ??
                      LucideIcons.calendarDays,
                  onJoin: () {
                    HapticFeedback.mediumImpact();
                    ref.read(eventsProvider.notifier).update(
                          (list) => list
                              .map((e) {
                                if (e.id == event.id) e.isJoined = !e.isJoined;
                                return e;
                              })
                              .toList(),
                        );
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

// ─────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _Header({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'ÉVÉNEMENTS',
                style: TextStyle(
                  color: _C.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Fitness & Sport',
                style: TextStyle(
                  color: _C.accent,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onCreateTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _C.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(LucideIcons.plus, size: 14, color: _C.bg),
                SizedBox(width: 6),
                Text(
                  'Créer',
                  style: TextStyle(
                    color: _C.bg,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  FILTER PILL
// ─────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _C.accent : _C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.transparent : _C.border,
            width: 0.5,
          ),
        ),

        child: Text(
          label,
          style: TextStyle(
            color: selected ? _C.bg : _C.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EVENT CARD
// ─────────────────────────────────────────────
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
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Banner ────────────────────────────
          _CardBanner(
            event: event,
            typeIcon: typeIcon,
            spotsLeft: spotsLeft,
            isFull: isFull,
          ),

          // ── Body ──────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  event.title,
                  style: const TextStyle(
                    color: _C.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 12),

                // Meta chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: LucideIcons.calendarDays,
                      label: '${event.date} · ${event.time}',
                    ),
                    _MetaChip(
                      icon: LucideIcons.mapPin,
                      label: event.location,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(height: 0.5, color: _C.border),

                const SizedBox(height: 14),

                // Organizer + Participants row
                Row(
                  children: [
                    // Organizer avatar
                    _ProAvatar(
                      url: event.organizerAvatar,
                      radius: 14,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Organisé par',
                            style: TextStyle(
                              color: _C.textTertiary,
                              fontSize: 10,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            event.organizer,
                            style: const TextStyle(
                              color: _C.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stacked participant avatars
                    GestureDetector(
                      onTap: onViewParticipants,
                      behavior: HitTestBehavior.opaque,
                      child: _ParticipantsStack(
                        avatars: event.participantAvatars,
                        count: event.joinedCount,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // CTA Button
                _JoinButton(
                  isJoined: isJoined,
                  isFull: isFull,
                  onTap: isFull ? null : onJoin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CARD BANNER
// ─────────────────────────────────────────────
class _CardBanner extends StatelessWidget {
  final EventModel event;
  final IconData typeIcon;
  final int spotsLeft;
  final bool isFull;

  const _CardBanner({
    required this.event,
    required this.typeIcon,
    required this.spotsLeft,
    required this.isFull,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image
        SizedBox(
          height: 160,
          width: double.infinity,
          child: Image.network(
            event.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: _C.cardHigh,
              child: const Center(
                child: Icon(LucideIcons.image,
                    color: _C.textTertiary, size: 32),
              ),
            ),
          ),
        ),

        // Bottom scrim
        Positioned(
          bottom: 0, left: 0, right: 0, height: 90,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.72),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Type badge — top left
        Positioned(
          top: 12, left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(typeIcon, size: 11, color: _C.accentDim),
                const SizedBox(width: 5),
                Text(
                  event.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: _C.accentDim,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Spots badge — top right
        Positioned(
          top: 12, right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isFull
                  ? _C.danger.withOpacity(0.85)
                  : Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isFull
                    ? _C.danger.withOpacity(0.4)
                    : Colors.white.withOpacity(0.12),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFull ? LucideIcons.xCircle : LucideIcons.users,
                  size: 11,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  isFull ? 'Complet' : '$spotsLeft places',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  META CHIP
// ─────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _C.cardHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _C.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _C.textTertiary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _C.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PARTICIPANTS STACK
// ─────────────────────────────────────────────
class _ParticipantsStack extends StatelessWidget {
  final List<String> avatars;
  final int count;

  const _ParticipantsStack({required this.avatars, required this.count});

  @override
  Widget build(BuildContext context) {
    const size    = 26.0;
    const overlap = 18.0;
    final shown   = avatars.take(3).toList();

    return Row(
      children: [
        SizedBox(
          width: shown.length * overlap + (size - overlap),
          height: size,
          child: Stack(
            children: List.generate(shown.length, (i) {
              return Positioned(
                left: i * overlap,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _C.card, width: 1.5),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      shown[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _C.cardHigh,
                        child: const Icon(LucideIcons.user,
                            size: 12, color: _C.textTertiary),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          '+$count inscrits',
          style: const TextStyle(
            color: _C.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 3),
        const Icon(LucideIcons.chevronRight,
            size: 12, color: _C.textTertiary),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  JOIN BUTTON
// ─────────────────────────────────────────────
class _JoinButton extends StatelessWidget {
  final bool isJoined;
  final bool isFull;
  final VoidCallback? onTap;

  const _JoinButton({
    required this.isJoined,
    required this.isFull,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (isJoined) {
      bg    = _C.successDim;
      fg    = _C.success;
      icon  = LucideIcons.checkCircle;
      label = 'Inscrit';
    } else if (isFull) {
      bg    = _C.dangerDim;
      fg    = _C.danger;
      icon  = LucideIcons.xCircle;
      label = 'Complet';
    } else {
      bg    = _C.accent;
      fg    = _C.bg;
      icon  = LucideIcons.userPlus;
      label = 'Rejoindre';
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: isJoined || isFull
              ? Border.all(
                  color: fg.withOpacity(0.25),
                  width: 0.5,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PRO AVATAR  (network + fallback)
// ─────────────────────────────────────────────
class _ProAvatar extends StatelessWidget {
  final String url;
  final double radius;

  const _ProAvatar({required this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _C.border, width: 1),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: _C.cardHigh,
            child: Icon(LucideIcons.user,
                size: radius * 0.8, color: _C.textTertiary),
          ),
        ),
      ),
    );
  }
}