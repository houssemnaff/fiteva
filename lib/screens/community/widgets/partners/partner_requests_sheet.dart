import 'package:fiteva/core/communiter_provider.dart';
import 'package:fiteva/screens/community/model/partner_model.dart';
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
                child: Text(l10n.communityRequestsReceived, style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
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
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.inbox, size: 32,
                            color: cs.onSurface.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(l10n.communityNoRequests,
                          style: GoogleFonts.inter(
                              color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
                    itemCount: incoming.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _RequestRow(request: incoming[i], colorScheme: cs),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RequestRow extends ConsumerWidget {
  final PartnerJoinRequest request;
  final ColorScheme colorScheme;
  const _RequestRow({required this.request, required this.colorScheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: cs.primary.withValues(alpha: 0.15),
          child: Text(request.requesterName.isNotEmpty
              ? request.requesterName[0].toUpperCase() : '?',
            style: GoogleFonts.outfit(
              color: cs.primary, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.requesterName, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface)),
              if (request.partnerGoal.isNotEmpty || request.partnerRegion.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'Pour : ${[request.partnerGoal, request.partnerRegion]
                      .where((s) => s.isNotEmpty).join(' · ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11, color: cs.onSurface.withValues(alpha: 0.55)),
                ),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(partnerRequestsProvider.notifier)
                .respond(requestId: request.id, accept: false);
          },
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: cs.error.withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Icon(LucideIcons.x, size: 15, color: cs.error),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            ref.read(partnerRequestsProvider.notifier)
                .respond(requestId: request.id, accept: true);
          },
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
            child: Icon(LucideIcons.check, size: 16, color: cs.onPrimary),
          ),
        ),
      ]),
    );
  }
}
