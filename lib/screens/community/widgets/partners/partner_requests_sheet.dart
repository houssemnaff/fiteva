import 'package:fiteva/core/communiter_provider.dart';
import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:fiteva/screens/community/widgets/community_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../l10n/app_localizations.dart';

void showPartnerRequestsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const PartnerRequestsSheet(),
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

/// Feuille listant les demandes de mise en relation reçues par l'utilisateur
/// pour ses propres posts partenaires, avec Accepter/Refuser.
class PartnerRequestsSheet extends ConsumerWidget {
  const PartnerRequestsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final bottom = MediaQuery.of(context).padding.bottom;
    final incoming = ref.watch(partnerRequestsProvider).incoming;

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
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: cs.outline.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(children: [
              Expanded(
                child: Row(children: [
                  Text(l10n.communityRequestsReceived, style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
                  if (incoming.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text('${incoming.length}', style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w800, color: cs.primary)),
                    ),
                  ],
                ]),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest, shape: BoxShape.circle),
                  child: Icon(LucideIcons.x, size: 14, color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ),
            ]),
          ),
          Divider(height: 1, color: cs.outline.withValues(alpha: 0.4)),

          Flexible(
            child: incoming.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.inbox, size: 26,
                              color: cs.primary.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.communityNoRequests,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13, height: 1.5)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
                    itemCount: incoming.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _RequestRow(
                      request: incoming[i], colorScheme: cs, isFrench: l10n.isFrench, l10n: l10n),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RequestRow extends ConsumerStatefulWidget {
  final PartnerJoinRequest request;
  final ColorScheme colorScheme;
  final bool isFrench;
  final AppL10n l10n;
  const _RequestRow({
    required this.request, required this.colorScheme,
    required this.isFrench, required this.l10n,
  });

  @override
  ConsumerState<_RequestRow> createState() => _RequestRowState();
}

class _RequestRowState extends ConsumerState<_RequestRow> {
  bool _responding = false;

  Future<void> _respond(bool accept) async {
    HapticFeedback.mediumImpact();
    setState(() => _responding = true);
    await ref.read(partnerRequestsProvider.notifier)
        .respond(requestId: widget.request.id, accept: accept);
    // Le widget est retiré de la liste dès que le state se met à jour —
    // pas besoin de remettre _responding à false.
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final request = widget.request;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _responding ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
        ),
        child: Row(children: [
          CommunityAvatar(
            avatarUrl: '', name: request.requesterName, radius: 20,
            mascotType: request.requesterMascotType,
            mascotMood: request.requesterMascotMood,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.requesterName, style: GoogleFonts.outfit(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: cs.onSurface)),
                const SizedBox(height: 2),
                if (request.partnerGoal.isNotEmpty || request.partnerRegion.isNotEmpty)
                  Text(
                    [
                      if (request.partnerGoal.isNotEmpty) widget.l10n.communityPartnerGoalOption(request.partnerGoal),
                      request.partnerRegion,
                    ].where((s) => s.isNotEmpty).join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55)),
                  ),
                const SizedBox(height: 2),
                Text(_timeAgo(request.createdAt, widget.isFrench), style: GoogleFonts.inter(
                  fontSize: 10, color: cs.onSurface.withValues(alpha: 0.4))),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IgnorePointer(
            ignoring: _responding,
            child: Row(children: [
              Tooltip(
                message: widget.l10n.communityPartnerDecline,
                child: GestureDetector(
                  onTap: () => _respond(false),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      color: cs.error.withValues(alpha: 0.10), shape: BoxShape.circle),
                    child: Icon(LucideIcons.x, size: 15, color: cs.error),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: widget.l10n.communityPartnerAccept,
                child: GestureDetector(
                  onTap: () => _respond(true),
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                    child: Icon(LucideIcons.check, size: 16, color: cs.onPrimary),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
