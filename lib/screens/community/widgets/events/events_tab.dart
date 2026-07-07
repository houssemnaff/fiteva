import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:fiteva/screens/community/widgets/community_avatar.dart';
import 'package:fiteva/services/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/community_providers.dart';
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
      child: CustomScrollView(
        slivers: [

          // ── Header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.communityEyebrow, style: GoogleFonts.inter(
                    color: cs.secondary, fontSize: 9,
                    fontWeight: FontWeight.w700, letterSpacing: 3,
                  )),
                  const SizedBox(height: 3),
                  Text(l10n.communityEventsLabel, style: GoogleFonts.outfit(
                    color: cs.onSurface, fontSize: 26,
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
                        color: sel ? cs.primary : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                            color: sel ? cs.primary : cs.outline),
                      ),
                      child: Text(label, style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
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

  @override
  Widget build(BuildContext context) {
    final cs        = colorScheme;
    final spotsLeft = event.maxSpots - event.joinedCount;
    final isFull    = spotsLeft <= 0;
    final isJoined  = event.isJoined;
    final isOwner   = event.organizerId.isNotEmpty &&
        event.organizerId == SupabaseConfig.userId;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 14, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header row (mirrors feed post header) ─────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
            child: Row(children: [
              CommunityAvatar(
                avatarUrl: event.organizerAvatar,
                name: event.organizer,
                radius: 20,
                mascotType: event.organizerMascotType,
                mascotMood: event.organizerMascotMood,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.organizer, style: GoogleFonts.outfit(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: cs.onSurface, letterSpacing: -0.2,
                    )),
                    const SizedBox(height: 3),
                    Row(children: [
                      Flexible(
                        child: Text('${event.date} · ${event.time}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.6),
                          )),
                      ),
                      const SizedBox(width: 6),
                      Container(width: 3, height: 3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.outline.withValues(alpha: 0.3))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
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
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isOwner) ...[
                    _EventOwnerMenu(event: event, cs: cs),
                    const SizedBox(height: 6),
                  ],
                  // Spots pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFull
                          ? cs.error.withValues(alpha: 0.1)
                          : cs.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      isFull ? 'Complet' : '$spotsLeft places',
                      style: GoogleFonts.inter(
                        fontSize: 10, fontWeight: FontWeight.w700,
                        color: isFull
                            ? cs.error
                            : cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
          ),

          // ── Event title + location ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: GoogleFonts.inter(
                  fontSize: 14, color: cs.onSurface,
                  height: 1.5, letterSpacing: -0.1,
                  fontWeight: FontWeight.w700,
                )),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(LucideIcons.mapPin, size: 11,
                      color: cs.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(event.location, style: GoogleFonts.inter(
                      fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6),
                    ), overflow: TextOverflow.ellipsis),
                  ),
                ]),
                if (event.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(event.description.trim(),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5, height: 1.5,
                      color: cs.onSurface.withValues(alpha: 0.65))),
                ],
              ],
            ),
          ),

          // ── Action row (mirrors feed action row) ──────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 12, 12),
            child: Row(children: [
              // Join pill
              GestureDetector(
                onTap: isFull ? null : onJoin,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isJoined
                        ? cs.secondary.withValues(alpha: 0.1)
                        : isFull
                            ? cs.error.withValues(alpha: 0.08)
                            : cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: isJoined
                        ? Border.all(
                            color: cs.primary.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      isJoined
                          ? LucideIcons.checkCircle
                          : isFull
                              ? LucideIcons.xCircle
                              : LucideIcons.userPlus,
                      size: 15,
                      color: isJoined
                          ? cs.primary
                          : isFull
                              ? cs.error
                              : cs.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isJoined ? 'Inscrit' : isFull ? 'Complet' : 'Rejoindre',
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: isJoined
                            ? cs.primary
                            : isFull
                                ? cs.error
                                : cs.primary,
                      ),
                    ),
                  ]),
                ),
              ),

              const SizedBox(width: 8),

              // Participants pill
              GestureDetector(
                onTap: onViewParticipants,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: cs.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.users, size: 15,
                        color: cs.onSurface.withValues(alpha: 0.6)),
                    const SizedBox(width: 5),
                    Text('${event.joinedCount}', style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    )),
                  ]),
                ),
              ),
            ]),
          ),

          // ── Contact organisateur (visible après inscription,
          //    même pattern que la carte partenaire) ──────────
          if (isJoined) _EventCardContacts(event: event, cs: cs),
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
      icon: Container(
        width: 30, height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(CupertinoIcons.ellipsis,
            color: cs.onSurface.withValues(alpha: 0.6), size: 15),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30, maxWidth: 30, maxHeight: 30),
      color: cs.surface,
      elevation: 4,
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          height: 42,
          child: Row(children: [
            Icon(LucideIcons.pencil, size: 16, color: cs.primary),
            const SizedBox(width: 10),
            Text('Modifier', style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 42,
          child: Row(children: [
            Icon(LucideIcons.trash2, size: 16, color: cs.error),
            const SizedBox(width: 10),
            Text('Supprimer', style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: cs.error)),
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
Uri? _contactUri(String platform, String raw) {
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

class _EventCardContacts extends ConsumerWidget {
  final EventModel event;
  final ColorScheme cs;
  const _EventCardContacts({required this.event, required this.cs});

  static const _brandColors = {
    'whatsapp':  Color(0xFF25D366),
    'instagram': Color(0xFFD62A7A),
    'facebook':  Color(0xFF3B6FE0),
  };

  Future<void> _open(BuildContext context, Uri? uri, String errorMsg) async {
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(errorMsg),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final contacts = [
      ('whatsapp', event.contactWhatsapp, LucideIcons.messageCircle, 'WhatsApp'),
      ('instagram', event.contactInstagram, LucideIcons.atSign, 'Instagram'),
      ('facebook', event.contactFacebook, LucideIcons.globe, 'Facebook'),
    ].where((c) => c.$2.trim().isNotEmpty).toList();

    if (contacts.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Divider(height: 1, indent: 14, endIndent: 14,
          color: cs.outline.withValues(alpha: 0.5)),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
        child: Text(l10n.communityEventContactSection, style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w700,
          color: cs.onSurface.withValues(alpha: 0.45), letterSpacing: 2)),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Column(children: [
          for (final (platform, value, icon, label) in contacts)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _open(context, _contactUri(platform, value),
                    l10n.communityPartnerLinkError),
                child: Row(children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: _brandColors[platform]!.withValues(alpha: 0.12),
                      shape: BoxShape.circle),
                    child: Icon(icon, size: 15, color: _brandColors[platform]),
                  ),
                  const SizedBox(width: 12),
                  Text(label, style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: cs.onSurface)),
                  const Spacer(),
                  Icon(LucideIcons.arrowUpRight, size: 15,
                      color: cs.onSurface.withValues(alpha: 0.35)),
                ]),
              ),
            ),
        ]),
      ),
    ]);
  }
}

