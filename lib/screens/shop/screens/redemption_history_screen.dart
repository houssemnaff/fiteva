import 'package:fiteva/core/shop/shop_provider.dart';
import 'package:fiteva/services/shop_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/boutique_item.dart';
import 'boutique_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE — dérivée du ColorScheme du thème actif (donc de la palette Pro),
// même logique que community_screen.dart / boutique_screen.dart.
// Or = points, rouge = statuts d'erreur/refus : couleurs sémantiques fixes.
// ─────────────────────────────────────────────────────────────────────────────
class _P {
  final Color bg, surface, surfaceAlt, ink, inkMuted, inkSubtle, divider, chipBg;
  final Color accent, accentSoft;
  final bool  isDark;

  static const Color gold = Color(0xFFB8892F);

  factory _P.of(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    return _P._(
      bg:         cs.surface,
      surface:    cs.surface,
      surfaceAlt: cs.surfaceContainerHighest,
      ink:        cs.onSurface,
      inkMuted:   cs.onSurface.withValues(alpha: 0.55),
      inkSubtle:  cs.onSurface.withValues(alpha: 0.35),
      divider:    cs.outline,
      chipBg:     cs.surfaceContainerHighest,
      accent:     cs.primary,
      accentSoft: cs.secondaryContainer,
      isDark:     cs.brightness == Brightness.dark,
    );
  }

  const _P._({
    required this.bg, required this.surface, required this.surfaceAlt,
    required this.ink, required this.inkMuted, required this.inkSubtle,
    required this.divider, required this.chipBg,
    required this.accent, required this.accentSoft,
    required this.isDark,
  });
}

enum _Tab { redemptions, requests }

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN — échanges (étoiles) + candidatures "devenir partenaire"
// ─────────────────────────────────────────────────────────────────────────────
class RedemptionHistoryScreen extends ConsumerStatefulWidget {
  const RedemptionHistoryScreen({super.key});

  @override
  ConsumerState<RedemptionHistoryScreen> createState() => _RedemptionHistoryScreenState();
}

class _RedemptionHistoryScreenState extends ConsumerState<RedemptionHistoryScreen> {
  _Tab _tab = _Tab.redemptions;

  @override
  Widget build(BuildContext context) {
    final p = _P.of(context);

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(CupertinoIcons.back, size: 22, color: p.ink),
                  ),
                  const SizedBox(width: 14),
                  Text('Mon activité',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                          color: p.ink, letterSpacing: -0.4)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: p.chipBg, borderRadius: BorderRadius.circular(11)),
                child: Row(
                  children: [
                    _TabButton(p: p, label: 'Échanges', selected: _tab == _Tab.redemptions,
                        onTap: () => setState(() => _tab = _Tab.redemptions)),
                    _TabButton(p: p, label: 'Candidatures', selected: _tab == _Tab.requests,
                        onTap: () => setState(() => _tab = _Tab.requests)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _tab == _Tab.redemptions
                  ? _RedemptionsList(p: p)
                  : _RequestsList(p: p),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final _P p;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.p, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? p.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : p.inkMuted,
              )),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ÉCHANGES — ce que l'utilisatrice a obtenu avec ses étoiles
// ─────────────────────────────────────────────────────────────────────────────
class _RedemptionsList extends ConsumerWidget {
  final _P p;
  const _RedemptionsList({required this.p});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history   = ref.watch(shopRedemptionHistoryProvider);
    final itemsById = {
      for (final item in ref.watch(shopItemsProvider).asData?.value ?? <BoutiqueItem>[])
        item.id: item,
    };

    return history.when(
      loading: () => Center(child: CircularProgressIndicator(color: p.accent)),
      error: (_, __) => _EmptyState(p: p, icon: CupertinoIcons.clock,
          title: 'Aucun échange pour le moment',
          subtitle: 'Les articles échangés avec tes étoiles\napparaîtront ici.'),
      data: (entries) {
        if (entries.isEmpty) {
          return _EmptyState(p: p, icon: CupertinoIcons.clock,
              title: 'Aucun échange pour le moment',
              subtitle: 'Les articles échangés avec tes étoiles\napparaîtront ici.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          itemCount: entries.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: p.divider),
          itemBuilder: (ctx, i) {
            final entry = entries[i];
            final item  = itemsById[entry.shopItemId];
            return _HistoryRow(
              p: p,
              entry: entry,
              item: item,
              onTap: item == null ? null : () => Navigator.push(ctx,
                  CupertinoPageRoute(builder: (_) => BoutiqueDetailScreen(item: item))),
            );
          },
        );
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final _P p;
  final RedemptionEntry entry;
  final BoutiqueItem? item;
  final VoidCallback? onTap;
  const _HistoryRow({required this.p, required this.entry, required this.item, required this.onTap});

  String _fmtDate(DateTime d) {
    const months = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun', 'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56, height: 56,
                child: item != null && item!.imageUrl.isNotEmpty
                    ? Image.network(item!.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: p.surfaceAlt,
                            child: Icon(CupertinoIcons.bag, size: 20, color: p.inkSubtle)))
                    : Container(color: p.surfaceAlt,
                        child: Icon(CupertinoIcons.bag, size: 20, color: p.inkSubtle)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item?.title ?? 'Article indisponible',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: p.ink)),
                  const SizedBox(height: 3),
                  Text(_fmtDate(entry.redeemedAt),
                      style: TextStyle(fontSize: 11.5, color: p.inkMuted)),
                  if (entry.promoCode.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Code : ${entry.promoCode}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: p.accent)),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: p.isDark ? _P.gold.withValues(alpha: 0.16) : const Color(0xFFF6EFDF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(CupertinoIcons.star_fill, size: 10, color: _P.gold),
                const SizedBox(width: 5),
                Text('-${entry.pointsSpent}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _P.gold)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CANDIDATURES — mes demandes "devenir partenaire"
// ─────────────────────────────────────────────────────────────────────────────
class _RequestsList extends ConsumerWidget {
  final _P p;
  const _RequestsList({required this.p});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(myPartnerRequestsProvider);

    return requests.when(
      loading: () => Center(child: CircularProgressIndicator(color: p.accent)),
      error: (_, __) => _EmptyState(p: p, icon: Icons.handshake_rounded,
          title: 'Aucune candidature envoyée',
          subtitle: 'Tes demandes pour devenir marque\npartenaire apparaîtront ici.'),
      data: (entries) {
        if (entries.isEmpty) {
          return _EmptyState(p: p, icon: Icons.handshake_rounded,
              title: 'Aucune candidature envoyée',
              subtitle: 'Tes demandes pour devenir marque\npartenaire apparaîtront ici.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          itemCount: entries.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: p.divider),
          itemBuilder: (_, i) => _RequestRow(p: p, entry: entries[i]),
        );
      },
    );
  }
}

class _RequestRow extends StatelessWidget {
  final _P p;
  final PartnerRequestEntry entry;
  const _RequestRow({required this.p, required this.entry});

  String _fmtDate(DateTime d) {
    const months = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun', 'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  (Color, Color, String) _statusStyle() {
    switch (entry.status) {
      case 'approved':
        return (p.accentSoft, p.accent, 'Acceptée');
      case 'rejected':
        return (const Color(0xFFF3E4E4), const Color(0xFFC24A4A), 'Refusée');
      default:
        return (const Color(0xFFF6EFDF), _P.gold, 'En attente');
    }
  }

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _RequestDetailSheet(p: p, entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _statusStyle();
    return GestureDetector(
      onTap: () => _openDetail(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: p.chipBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.handshake_rounded, size: 19, color: p.inkMuted),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.brand.isEmpty ? 'Marque' : entry.brand,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: p.ink)),
                const SizedBox(height: 3),
                Text('${entry.category.isEmpty ? '—' : entry.category} · ${_fmtDate(entry.createdAt)}',
                    style: TextStyle(fontSize: 11.5, color: p.inkMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: fg)),
          ),
          const SizedBox(width: 8),
          Icon(CupertinoIcons.chevron_right, size: 14, color: p.inkSubtle),
        ],
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REQUEST DETAIL SHEET — infos complètes de la candidature
// ─────────────────────────────────────────────────────────────────────────────
class _RequestDetailSheet extends ConsumerStatefulWidget {
  final _P p;
  final PartnerRequestEntry entry;
  const _RequestDetailSheet({required this.p, required this.entry});

  @override
  ConsumerState<_RequestDetailSheet> createState() => _RequestDetailSheetState();
}

class _RequestDetailSheetState extends ConsumerState<_RequestDetailSheet> {
  bool _deleting = false;

  String _fmtDate(DateTime d) {
    const months = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun', 'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  (Color, Color, String) _statusStyle() {
    switch (widget.entry.status) {
      case 'approved':
        return (widget.p.accentSoft, widget.p.accent, 'Acceptée');
      case 'rejected':
        return (const Color(0xFFF3E4E4), const Color(0xFFC24A4A), 'Refusée');
      default:
        return (const Color(0xFFF6EFDF), _P.gold, 'En attente');
    }
  }

  Widget _row(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: widget.p.inkSubtle, letterSpacing: 1.1)),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: widget.p.ink)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la candidature ?'),
        content: const Text('Cette action est définitive — tu pourras en soumettre une nouvelle ensuite.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Supprimer', style: TextStyle(color: const Color(0xFFC24A4A))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    final ok = await ShopService.deletePartnerRequest(widget.entry.id);
    if (!mounted) return;
    setState(() => _deleting = false);

    if (ok) {
      ref.invalidate(myPartnerRequestsProvider);
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La suppression a échoué, réessaie.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final entry = widget.entry;
    final (bg, fg, label) = _statusStyle();
    final canDelete = entry.status == 'pending' && entry.id.isNotEmpty;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 36, height: 4,
                    decoration: BoxDecoration(color: p.divider, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(entry.brand.isEmpty ? 'Marque' : entry.brand,
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: p.ink, letterSpacing: -0.4)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                    child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Envoyée le ${_fmtDate(entry.createdAt)}',
                  style: TextStyle(fontSize: 12.5, color: p.inkMuted)),
              const SizedBox(height: 22),
              Divider(color: p.divider, height: 1),
              const SizedBox(height: 18),
              _row('Catégorie', entry.category),
              _row('Nom complet', entry.name),
              _row('Email', entry.email),
              _row('Téléphone', entry.phone),
              _row('Site web / réseau', entry.website),
              _row('Message', entry.message),
              if (canDelete) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _deleting ? null : _confirmDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC24A4A),
                      side: const BorderSide(color: Color(0xFFC24A4A)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _deleting
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC24A4A)))
                        : const Text('Supprimer la candidature', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE — partagé entre les deux onglets
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final _P p;
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({required this.p, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(color: p.chipBg, shape: BoxShape.circle),
            child: Icon(icon, size: 30, color: p.inkSubtle),
          ),
          const SizedBox(height: 20),
          Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: p.ink)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: p.inkMuted, height: 1.5)),
        ],
      ),
    );
  }
}
