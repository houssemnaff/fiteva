import 'package:fiteva/screens/community/UserProfileScreen.dart';
import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:fiteva/screens/community/widgets/community_avatar.dart';
import 'package:fiteva/services/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/community_providers.dart';
import '../shared/community_shared_widgets.dart';
import 'create_event_sheet.dart';
import 'participants_sheet.dart';
import '../../../../l10n/app_localizations.dart';


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
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final events = ref.watch(eventsNotifierProvider);
    final filtered = _selectedType == 'Tous'
        ? events
        : events.where((e) => e.type.toLowerCase() == _selectedType.toLowerCase()).toList();

    return ColoredBox(
      color: cs.surface,
      child: RefreshIndicator(
        color: cs.onSurface,
        backgroundColor: cs.surface,
        onRefresh: () => ref.read(eventsNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [

          // ── Header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.communityEyebrow, style: GoogleFonts.inter(
                        color: cs.secondary, fontSize: 9,
                        fontWeight: FontWeight.w700, letterSpacing: 3,
                      )),
                      const SizedBox(height: 3),
                      Text(l10n.communityEventsLabel, style: GoogleFonts.outfit(
                        color: cs.onSurface, fontSize: 24,
                        fontWeight: FontWeight.w800, letterSpacing: -0.5,
                      )),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context, cs),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedType == 'Tous'
                            ? cs.onSurface.withValues(alpha: 0.05)
                            : cs.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.slidersHorizontal, size: 13,
                            color: _selectedType == 'Tous'
                                ? cs.onSurface.withValues(alpha: 0.45)
                                : cs.primary),
                          const SizedBox(width: 5),
                          Text(
                            _selectedType == 'Tous' ? 'Filtres' : _selectedType,
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: _selectedType == 'Tous'
                                  ? cs.onSurface.withValues(alpha: 0.5)
                                  : cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ── Event List ────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Container(
                height: 0.5,
                color: cs.onSurface.withValues(alpha: 0.06),
              ),
              itemBuilder: (_, i) {
                final event = filtered[i];
                return EventCard(
                  event: event,
                  typeIcon: _icons[event.type.toLowerCase()] ??
                      LucideIcons.calendarDays,
                  colorScheme: cs,
                  onJoin: () {
                    HapticFeedback.mediumImpact();
                    ref.read(eventsNotifierProvider.notifier).toggleJoin(event.id);
                  },
                  onViewParticipants: () => showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ParticipantsSheet(event: event, colorScheme: cs),
                  ),
                );
              },
            ),
          ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Filtrer par type', style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
              const SizedBox(height: 16),
              ...List.generate(_filters.length, (i) {
                final label = _filters[i];
                final active = _selectedType == label;
                final icon = _icons[label.toLowerCase()];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedType = label);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: active ? cs.primary.withValues(alpha: 0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: active ? cs.primary.withValues(alpha: 0.3) : cs.onSurface.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(children: [
                      if (icon != null) ...[
                        Icon(icon, size: 16, color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(width: 10),
                      ],
                      Text(label, style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                      )),
                      const Spacer(),
                      if (active)
                        Icon(LucideIcons.check, size: 16, color: cs.primary),
                    ]),
                  ),
                );
              }),
            ],
          ),
        ),
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
  final ColorScheme colorScheme;

  const EventCard({
    super.key,
    required this.event,
    required this.typeIcon,
    required this.onJoin,
    required this.onViewParticipants,
    required this.colorScheme,
  });

  void _openProfile(BuildContext context, String uid) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => UserProfileScreen(
        userId: uid,
        heroTag: 'event_avatar_$uid',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs        = colorScheme;
    final spotsLeft = event.maxSpots - event.joinedCount;
    final isFull    = spotsLeft <= 0;
    final isJoined  = event.isJoined;
    final isOwner   = event.organizerId.isNotEmpty &&
        event.organizerId == SupabaseConfig.userId;
    final organizerUid = event.organizerId.isNotEmpty
        ? event.organizerId
        : event.organizer;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header row ─────────────────────────────────────
          Row(children: [
            GestureDetector(
              onTap: () => _openProfile(context, organizerUid),
              child: Hero(
                tag: 'event_avatar_$organizerUid',
                child: CommunityAvatar(
                  avatarUrl: event.organizerAvatar,
                  name: event.organizer,
                  radius: 18,
                  mascotType: event.organizerMascotType,
                  mascotMood: event.organizerMascotMood,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _openProfile(context, organizerUid),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(child: Text(event.organizer,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: cs.onSurface, letterSpacing: -0.2,
                        )),
                      ),
                      if (event.organizerIsPro) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('PRO', style: GoogleFonts.inter(
                            fontSize: 9, fontWeight: FontWeight.w800,
                            color: const Color(0xFFF59E0B),
                          )),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(typeIcon, size: 9, color: cs.primary),
                          const SizedBox(width: 3),
                          Text(event.type, style: GoogleFonts.inter(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: cs.primary,
                          )),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 2),
                    Text('${event.date} · ${event.time}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: cs.onSurface.withValues(alpha: 0.4),
                      )),
                  ],
                ),
              ),
            ),
            if (isOwner)
              _EventOwnerMenu(event: event, cs: cs),
          ]),

          // ── Event title ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(event.title, style: GoogleFonts.outfit(
              fontSize: 15, color: cs.onSurface,
              height: 1.4, letterSpacing: -0.2,
              fontWeight: FontWeight.w700,
            )),
          ),

          // ── Location ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(children: [
              Icon(LucideIcons.mapPin, size: 12,
                  color: cs.onSurface.withValues(alpha: 0.35)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(event.location, style: GoogleFonts.inter(
                  fontSize: 12.5, color: cs.onSurface.withValues(alpha: 0.45),
                ), overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),

          // ── Description ─────────────────────────────────────
          if (event.description.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(event.description.trim(),
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13, height: 1.5,
                  color: cs.onSurface.withValues(alpha: 0.6))),
            ),

          // ── Cover image ────────────────────────────────────
          if (event.imageUrl.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: cs.primary.withValues(alpha: 0.06),
                        child: Icon(LucideIcons.image, size: 32,
                            color: cs.primary.withValues(alpha: 0.2)),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Action row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(children: [
              // Join button
              GestureDetector(
                onTap: isFull && !isJoined ? null : onJoin,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isJoined
                        ? cs.primary.withValues(alpha: 0.08)
                        : isFull
                            ? cs.error.withValues(alpha: 0.06)
                            : cs.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      isJoined ? LucideIcons.checkCircle
                          : isFull ? LucideIcons.xCircle
                          : LucideIcons.userPlus,
                      size: 14,
                      color: isJoined ? cs.primary
                          : isFull ? cs.error
                          : cs.onPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isJoined ? 'Inscrit' : isFull ? 'Complet' : 'Rejoindre',
                      style: GoogleFonts.inter(
                        fontSize: 12.5, fontWeight: FontWeight.w700,
                        color: isJoined ? cs.primary
                            : isFull ? cs.error
                            : cs.onPrimary,
                      ),
                    ),
                  ]),
                ),
              ),

              const SizedBox(width: 10),

              // Participants
              GestureDetector(
                onTap: onViewParticipants,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(LucideIcons.users, size: 15,
                      color: cs.onSurface.withValues(alpha: 0.35)),
                  const SizedBox(width: 5),
                  Text('${event.joinedCount}', style: GoogleFonts.inter(
                    fontSize: 12.5, fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.35),
                  )),
                ]),
              ),

              const Spacer(),

              // Spots left
              Text(
                isFull ? 'Complet' : '$spotsLeft places',
                style: GoogleFonts.inter(
                  fontSize: 11.5, fontWeight: FontWeight.w600,
                  color: isFull
                      ? cs.error.withValues(alpha: 0.6)
                      : cs.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ]),
          ),

          // ── Contact organisateur ────────────────────────────
          if (isJoined && !isOwner) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _EventCardContacts(event: event, cs: cs),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Menu propriétaire (modifier / supprimer) ─────────────────
class _EventOwnerMenu extends ConsumerWidget {
  final EventModel event;
  final ColorScheme cs;
  const _EventOwnerMenu({required this.event, required this.cs});

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Supprimer l\'événement ?',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Text('Cette action est irréversible.',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler',
                style: GoogleFonts.inter(color: cs.onSurface.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final ok = await ref.read(eventsNotifierProvider.notifier).deleteEvent(event.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: ok ? cs.primary : cs.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                content: Text(
                  ok ? 'Événement supprimé.' : 'Erreur lors de la suppression.',
                  style: GoogleFonts.inter(
                      color: ok ? cs.onPrimary : cs.onError,
                      fontWeight: FontWeight.w600)),
              ));
            },
            child: Text('Supprimer',
                style: GoogleFonts.inter(color: cs.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(CupertinoIcons.ellipsis,
          color: cs.onSurface.withValues(alpha: 0.4), size: 18),
      padding: const EdgeInsets.all(6),
      color: cs.surface,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(LucideIcons.pencil, size: 18, color: cs.primary),
            const SizedBox(width: 12),
            Text('Modifier', style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(LucideIcons.trash2, size: 18, color: cs.error),
            const SizedBox(width: 12),
            Text('Supprimer', style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600, color: cs.error)),
          ]),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') {
          showCreateEventSheet(context, event: event);
        } else {
          _confirmDelete(context, ref);
        }
      },
    );
  }
}

// ─── Contact organisateur (WhatsApp / Instagram / Facebook) ──
class _EventCardContacts extends ConsumerWidget {
  final EventModel event;
  final ColorScheme cs;
  const _EventCardContacts({required this.event, required this.cs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final hasContact = event.contactWhatsapp.trim().isNotEmpty ||
        event.contactInstagram.trim().isNotEmpty ||
        event.contactFacebook.trim().isNotEmpty;
    if (!hasContact) return const SizedBox.shrink();

    return SocialContactList(
      contactWhatsapp: event.contactWhatsapp,
      contactInstagram: event.contactInstagram,
      contactFacebook: event.contactFacebook,
      cs: cs,
      linkErrorMessage: l10n.communityPartnerLinkError,
      title: l10n.communityEventContactSection,
    );
  }
}
