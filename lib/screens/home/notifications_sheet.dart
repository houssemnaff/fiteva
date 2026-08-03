import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../../models/notification_model.dart';
import '../../providers/notifications_provider.dart';

void showNotificationsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const NotificationsSheet(),
  );
}

String _timeAgo(DateTime date, bool fr) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1)  return fr ? 'À l\'instant' : 'Just now';
  if (diff.inMinutes < 60) return fr ? 'Il y a ${diff.inMinutes} min' : '${diff.inMinutes}m ago';
  if (diff.inHours < 24)   return fr ? 'Il y a ${diff.inHours} h'   : '${diff.inHours}h ago';
  if (diff.inDays < 7)     return fr ? 'Il y a ${diff.inDays} j'    : '${diff.inDays}d ago';
  return '${date.day}/${date.month}';
}

IconData _iconFor(String type) {
  switch (type) {
    case 'event_joined':
      return LucideIcons.calendarCheck;
    case 'partner_request_received':
      return LucideIcons.userPlus;
    case 'partner_request_accepted':
      return LucideIcons.checkCheck;
    default:
      return LucideIcons.bell;
  }
}

class NotificationsSheet extends ConsumerStatefulWidget {
  const NotificationsSheet({super.key});

  @override
  ConsumerState<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends ConsumerState<NotificationsSheet> {
  @override
  void initState() {
    super.initState();
    // Ouvrir la feuille vide le badge — comportement volontairement simple ;
    // un marquage lu par item individuel resterait une évolution facile.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final items = ref.watch(notificationsProvider);
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.isFrench ? 'Notifications' : 'Notifications',
                    style: GoogleFonts.outfit(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: 16, color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Flexible(
            child: items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(LucideIcons.bellOff, size: 32, color: cs.onSurface.withValues(alpha: 0.3)),
                        const SizedBox(height: 10),
                        Text(
                          l10n.isFrench ? 'Aucune notification pour le moment' : 'No notifications yet',
                          style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 20),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.horizontal,
                        background: _DeleteBackground(alignment: Alignment.centerLeft),
                        secondaryBackground: _DeleteBackground(alignment: Alignment.centerRight),
                        onDismissed: (_) => ref.read(notificationsProvider.notifier).delete(item.id),
                        child: _NotificationRow(item: item, isFrench: l10n.isFrench),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: alignment,
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(LucideIcons.trash2, color: Colors.white, size: 20),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item, required this.isFrench});

  final NotificationModel item;
  final bool isFrench;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isRead ? cs.onSurface.withValues(alpha: 0.04) : cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconFor(item.type), size: 17, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  item.body,
                  style: GoogleFonts.inter(fontSize: 12.5, color: cs.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeAgo(item.createdAt, isFrench),
                  style: GoogleFonts.inter(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
