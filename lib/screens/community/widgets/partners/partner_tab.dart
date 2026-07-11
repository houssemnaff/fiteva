import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:fiteva/screens/community/UserProfileScreen.dart';
import 'package:fiteva/screens/community/widgets/community_avatar.dart';
import 'package:fiteva/screens/community/widgets/partners/create_partner_sheet.dart';
import 'package:fiteva/screens/community/widgets/partners/partner_requests_sheet.dart';
import 'package:fiteva/services/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/community_providers.dart';
import '../shared/community_shared_widgets.dart';
import '../../../../l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  PARTNERS TAB — liste éditoriale, sobre et premium
// ═══════════════════════════════════════════════════════════════════════════
class PartnerTab extends ConsumerStatefulWidget {
  const PartnerTab({super.key});
  @override
  ConsumerState<PartnerTab> createState() => _PartnerTabState();
}

class _PartnerTabState extends ConsumerState<PartnerTab> {
  String _goal   = 'Tous';
  String _level  = 'Tous';
  String _region = 'Tous';
  String _query  = '';
  bool _searchOpen = false;
  final _searchCtrl = TextEditingController();

  static const _goals   = ['Tous', 'Perdre du poids', 'Tonifier', 'Masse', 'Bien-être'];
  static const _levels  = ['Tous', 'Débutant', 'Intermédiaire', 'Avancé'];
  static const _regions = ['Tous', 'Sousse', 'Monastir', 'Tunis', 'Sfax'];

  bool get _hasActiveFilters => _goal != 'Tous' || _level != 'Tous' || _region != 'Tous';
  int get _activeFilterCount =>
      [_goal, _level, _region].where((v) => v != 'Tous').length;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(partnerRequestsProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    HapticFeedback.selectionClick();
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        goal: _goal, level: _level, region: _region,
        goals: _goals, levels: _levels, regions: _regions,
        colorScheme: cs,
        onApply: (g, l, r) => setState(() { _goal = g; _level = l; _region = r; }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final partners = ref.watch(partnersProvider);
    final loading  = ref.watch(partnersLoadingProvider);
    final incomingCount = ref.watch(partnerRequestsProvider).incoming.length;

    final q = _query.trim().toLowerCase();
    final filtered = partners.where((p) {
      final goalOk   = _goal   == 'Tous' || p.goal   == _goal;
      final levelOk  = _level  == 'Tous' || p.level  == _level;
      final regionOk = _region == 'Tous' || p.region == _region;
      if (!(goalOk && levelOk && regionOk)) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          p.goal.toLowerCase().contains(q) ||
          p.region.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();

    return ColoredBox(
      color: cs.surface,
      child: RefreshIndicator(
        color: cs.onSurface,
        backgroundColor: cs.surface,
        onRefresh: () => ref.read(partnersNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [

            // ── Header ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.communityPartnerLabel, style: GoogleFonts.inter(
                      color: cs.onSurface.withValues(alpha: 0.4), fontSize: 10,
                      fontWeight: FontWeight.w600, letterSpacing: 3)),
                    const SizedBox(height: 6),
                    Text(l10n.communityPartnerTitle, style: GoogleFonts.outfit(
                      fontSize: 30, fontWeight: FontWeight.w700,
                      color: cs.onSurface, letterSpacing: -0.8, height: 1.0)),
                  ],
                ),
              ),
            ),

            // ── Utility bar: search / filters / inbox ───────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: _searchOpen
                    ? _SearchField(
                        controller: _searchCtrl,
                        colorScheme: cs,
                        onChanged: (v) => setState(() => _query = v),
                        onClose: () => setState(() {
                          _searchOpen = false; _query = ''; _searchCtrl.clear();
                        }),
                      )
                    : Row(children: [
                        Expanded(
                          child: Text(
                            loading
                                ? l10n.communityPartnerSearching
                                : l10n.communityPartnerProfilesCount(filtered.length),
                            style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.45)),
                          ),
                        ),
                        _UtilityTextBtn(
                          label: l10n.communityPartnerSearch, icon: LucideIcons.search,
                          onTap: () => setState(() => _searchOpen = true),
                        ),
                        Container(width: 1, height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: cs.outline.withValues(alpha: 0.6)),
                        _UtilityTextBtn(
                          label: l10n.communityPartnerFiltersCount(_activeFilterCount),
                          icon: LucideIcons.slidersHorizontal,
                          highlighted: _hasActiveFilters,
                          onTap: _openFilterSheet,
                        ),
                        Container(width: 1, height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: cs.outline.withValues(alpha: 0.6)),
                        GestureDetector(
                          onTap: () => showPartnerRequestsSheet(context),
                          child: Stack(clipBehavior: Clip.none, children: [
                            Icon(LucideIcons.inbox, size: 17,
                                color: cs.onSurface.withValues(alpha: 0.6)),
                            if (incomingCount > 0)
                              Positioned(
                                top: -5, right: -6,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    color: cs.error, shape: BoxShape.circle,
                                    border: Border.all(color: cs.surface, width: 1.5)),
                                ),
                              ),
                          ]),
                        ),
                      ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 22)),

            // ── Content ──────────────────────────────────────
            if (loading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverList.separated(
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (_, __) => const _PartnerCardSkeleton(),
                ),
              )
            else if (partners.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  colorScheme: cs,
                  icon: LucideIcons.userSearch,
                  title: l10n.communityPartnerEmptyTitle,
                  subtitle: l10n.communityPartnerEmptySubtitle,
                  ctaLabel: l10n.communityPublishProfile,
                  onCta: () => showCreatePartnerSheet(context),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  colorScheme: cs,
                  icon: LucideIcons.searchX,
                  title: l10n.communityPartnerNoResultsTitle,
                  subtitle: l10n.communityPartnerNoResultsSubtitle,
                  ctaLabel: l10n.communityPartnerReset,
                  onCta: () {
                    _searchCtrl.clear();
                    setState(() { _query = ''; _goal = 'Tous'; _level = 'Tous'; _region = 'Tous'; });
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (_, i) => _AnimatedEntry(
                    index: i,
                    child: _PartnerCard(partner: filtered[i], colorScheme: cs),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Utility bar text button ─────────────────────────────────────
class _UtilityTextBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;
  const _UtilityTextBtn({
    required this.label, required this.icon, required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = highlighted ? cs.onSurface : cs.onSurface.withValues(alpha: 0.6);
    return GestureDetector(
      onTap: onTap,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(
          fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

// ─── Search field ─────────────────────────────────────────────
class _SearchField extends ConsumerWidget {
  final TextEditingController controller;
  final ColorScheme colorScheme;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;
  const _SearchField({
    required this.controller, required this.colorScheme,
    required this.onChanged, required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = colorScheme;
    final l10n = ref.watch(l10nProvider);
    return Row(children: [
      Icon(LucideIcons.search, size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
      const SizedBox(width: 10),
      Expanded(
        child: TextField(
          controller: controller,
          autofocus: true,
          onChanged: onChanged,
          style: GoogleFonts.inter(fontSize: 15, color: cs.onSurface),
          decoration: InputDecoration(
            isDense: true,
            hintText: l10n.communityPartnerSearchHint,
            hintStyle: GoogleFonts.inter(fontSize: 15, color: cs.onSurface.withValues(alpha: 0.3)),
            border: UnderlineInputBorder(borderSide: BorderSide(color: cs.outline)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.outline)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: cs.onSurface)),
            contentPadding: const EdgeInsets.only(bottom: 8),
          ),
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: onClose,
        child: Text(l10n.communityCancel, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.5))),
      ),
    ]);
  }
}

// ─── Staggered fade-in ────────────────────────────────────────
class _AnimatedEntry extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (index.clamp(0, 6) * 50)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 16), child: child),
      ),
      child: child,
    );
  }
}

// ─── Level → subtle accent dot color ─────────────────────────────
Color _levelDot(String level, ColorScheme cs) {
  switch (level) {
    case 'Débutant':      return cs.primary;
    case 'Intermédiaire': return const Color(0xFFC08A2E);
    case 'Avancé':        return const Color(0xFFB4483E);
    default:              return cs.onSurface.withValues(alpha: 0.3);
  }
}

// ─── Empty state ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final ColorScheme colorScheme;
  final IconData icon;
  final String title, subtitle, ctaLabel;
  final VoidCallback onCta;

  const _EmptyState({
    required this.colorScheme, required this.icon,
    required this.title, required this.subtitle,
    required this.ctaLabel, required this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 34, color: cs.onSurface.withValues(alpha: 0.25)),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.outfit(
            fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.inter(
            fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5), height: 1.55)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onCta,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              decoration: BoxDecoration(
                color: cs.onSurface,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(ctaLabel, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: cs.surface)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────
class _PartnerCardSkeleton extends StatelessWidget {
  const _PartnerCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = cs.onSurface.withValues(alpha: 0.06);
    return Row(children: [
      CircleAvatar(radius: 30, backgroundColor: base),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 14, width: 120, color: base),
          const SizedBox(height: 8),
          Container(height: 11, width: 180, color: base),
          const SizedBox(height: 10),
          Container(height: 11, width: double.infinity, color: base),
        ]),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  PARTNER CARD — liste éditoriale
// ═══════════════════════════════════════════════════════════════════════════
class _PartnerCard extends ConsumerWidget {
  final PartnerModel partner;
  final ColorScheme colorScheme;
  const _PartnerCard({required this.partner, required this.colorScheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = colorScheme;
    final l10n = ref.watch(l10nProvider);
    final p = partner;
    final isOwnPost = p.userId.isNotEmpty && p.userId == SupabaseConfig.userId;
    final status = ref.watch(partnerRequestsProvider).myStatusByPartnerId[p.id] ?? 'none';
    final dot = _levelDot(p.level, cs);

    return GestureDetector(
      onTap: () => showPartnerDetailSheet(context, p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () {
                final uid = p.userId.isNotEmpty ? p.userId : p.id;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => UserProfileScreen(
                    userId: uid, heroTag: 'partner_avatar_$uid')));
              },
              child: Hero(
                tag: 'partner_avatar_${p.userId.isNotEmpty ? p.userId : p.id}',
                child: CommunityAvatar(
                  avatarUrl: p.avatar, name: p.name, radius: 30,
                  mascotType: p.mascotType, mascotMood: p.mascotMood,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(child: Text(p.name, style: GoogleFonts.outfit(
                      fontSize: 16.5, fontWeight: FontWeight.w700,
                      color: cs.onSurface, letterSpacing: -0.3),
                      overflow: TextOverflow.ellipsis)),
                    if (p.isPro) ...[
                      const SizedBox(width: 5),
                      const Icon(LucideIcons.crown, size: 13, color: Color(0xFFF59E0B)),
                    ],
                    if (isOwnPost) ...[
                      const SizedBox(width: 8),
                      Text(l10n.communityPartnerYouSuffix, style: GoogleFonts.inter(
                        fontSize: 12.5, fontWeight: FontWeight.w500,
                        color: cs.onSurface.withValues(alpha: 0.35))),
                    ],
                    if (!isOwnPost && status != 'none') ...[
                      const Spacer(),
                      _StatusBadge(status: status, colorScheme: cs, l10n: l10n),
                    ],
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(width: 6, height: 6,
                      decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text('${l10n.communityPartnerLevelOption(p.level)} · ${p.region} · ${l10n.communityPartnerFreqOption(p.frequency)}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12.5, color: cs.onSurface.withValues(alpha: 0.5))),
                    ),
                  ]),
                  if (p.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(p.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.5, color: cs.onSurface.withValues(alpha: 0.72),
                        height: 1.45)),
                  ],
                ],
              ),
            ),
          ]),
          const SizedBox(height: 14),
          if (!isOwnPost) ...[
            if (status == 'accepted')
              SocialContactList(
                contactWhatsapp: p.contactWhatsapp,
                contactInstagram: p.contactInstagram,
                contactFacebook: p.contactFacebook,
                cs: cs,
                linkErrorMessage: l10n.communityPartnerLinkError,
                emptyLabel: l10n.communityPartnerNoContact,
                title: l10n.communityEventContactSection,
              )
            else if (status == 'pending')
              const SizedBox.shrink()
            else
              _CardCta(status: status, partner: p, colorScheme: cs),
          ] else
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outline),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(LucideIcons.eye, size: 13, color: cs.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 6),
                  Text(l10n.communityPartnerPublicListing, style: GoogleFonts.inter(
                    fontSize: 11.5, fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.5))),
                ]),
              ),
              const Spacer(),
              _PartnerOwnerMenu(partner: p, cs: cs),
            ]),
          const SizedBox(height: 20),
          Divider(height: 1, color: cs.outline.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}

// ─── Petit badge de statut affiché à côté du nom ────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  final ColorScheme colorScheme;
  final AppL10n l10n;
  const _StatusBadge({required this.status, required this.colorScheme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final accepted = status == 'accepted';
    final color = accepted ? cs.primary : const Color(0xFFD69A2C);
    final icon = accepted ? LucideIcons.checkCircle2 : LucideIcons.clock;
    final label = accepted
        ? (l10n.isFrench ? 'Accepté' : 'Accepted')
        : l10n.communityJoinPending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

// ─── Bouton "Rejoindre" — affiché uniquement quand aucune demande n'est en cours ──
class _CardCta extends ConsumerWidget {
  final String status;
  final PartnerModel partner;
  final ColorScheme colorScheme;
  const _CardCta({required this.status, required this.partner, required this.colorScheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final cs = colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(partnerRequestsProvider.notifier)
            .join(partnerId: partner.id, ownerId: partner.userId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: cs.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(LucideIcons.userPlus, size: 14, color: cs.onSurface.withValues(alpha: 0.75)),
          const SizedBox(width: 7),
          Text(l10n.communityJoinBtn, style: GoogleFonts.inter(
            fontSize: 12.5, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.85))),
        ]),
      ),
    );
  }
}

// ─── Filter bottom sheet ────────────────────────────────────────
class _FilterSheet extends ConsumerStatefulWidget {
  final String goal, level, region;
  final List<String> goals, levels, regions;
  final ColorScheme colorScheme;
  final void Function(String goal, String level, String region) onApply;

  const _FilterSheet({
    required this.goal, required this.level, required this.region,
    required this.goals, required this.levels, required this.regions,
    required this.colorScheme, required this.onApply,
  });

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late String _goal = widget.goal;
  late String _level = widget.level;
  late String _region = widget.region;

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final l10n = ref.watch(l10nProvider);
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
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            width: 36, height: 4,
            decoration: BoxDecoration(color: cs.outline.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(3)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: Row(children: [
              Expanded(child: Text(l10n.communityPartnerFilterTitle, style: GoogleFonts.outfit(
                fontSize: 19, fontWeight: FontWeight.w700, color: cs.onSurface))),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(l10n.communityClose, style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.5))),
              ),
            ]),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterRow(label: l10n.communityPartnerGoalLabel, items: widget.goals, selected: _goal,
                    colorScheme: cs, optionLabel: l10n.communityPartnerGoalOption,
                    onSelect: (v) => setState(() => _goal = v)),
                  const SizedBox(height: 24),
                  _FilterRow(label: l10n.communityLevelLabel, items: widget.levels, selected: _level,
                    colorScheme: cs, optionLabel: l10n.communityPartnerLevelOption,
                    onSelect: (v) => setState(() => _level = v)),
                  const SizedBox(height: 24),
                  _FilterRow(label: l10n.communityPartnerRegionLabel, items: widget.regions, selected: _region,
                    colorScheme: cs, optionLabel: (v) => v == 'Tous' ? l10n.communityPartnerRegionAll : v,
                    onSelect: (v) => setState(() => _region = v)),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 10, 24, 20 + bottom),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() { _goal = 'Tous'; _level = 'Tous'; _region = 'Tous'; }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50), border: Border.all(color: cs.outline)),
                    child: Center(child: Text(l10n.communityPartnerReset, style: GoogleFonts.inter(
                      fontSize: 13.5, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.7)))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onApply(_goal, _level, _region);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(color: cs.onSurface, borderRadius: BorderRadius.circular(50)),
                    child: Center(child: Text(l10n.communityPartnerApply, style: GoogleFonts.inter(
                      fontSize: 13.5, fontWeight: FontWeight.w700, color: cs.surface))),
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

class _FilterRow extends StatelessWidget {
  final String label;
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;
  final String Function(String) optionLabel;
  final ColorScheme colorScheme;

  const _FilterRow({
    required this.label, required this.items,
    required this.selected, required this.onSelect,
    required this.optionLabel, required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: GoogleFonts.inter(
          fontSize: 10.5, fontWeight: FontWeight.w700,
          color: cs.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: items.map((item) {
            final sel = selected == item;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelect(item);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? cs.onSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: sel ? cs.onSurface : cs.outline),
                ),
                child: Text(optionLabel(item), style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? cs.surface : cs.onSurface.withValues(alpha: 0.65),
                )),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  DETAIL SHEET — bottom sheet plein de couleurs
// ═══════════════════════════════════════════════════════════════════════════
void showPartnerDetailSheet(BuildContext context, PartnerModel partner) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (_) => PartnerDetailSheet(partner: partner),
  );
}

class PartnerDetailSheet extends ConsumerWidget {
  final PartnerModel partner;
  const PartnerDetailSheet({super.key, required this.partner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final p = partner;
    final isOwnPost = p.userId.isNotEmpty && p.userId == SupabaseConfig.userId;
    final status = ref.watch(partnerRequestsProvider).myStatusByPartnerId[p.id] ?? 'none';
    final dot = _levelDot(p.level, cs);

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
          // ── Handle ──────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: cs.outline.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(3)),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero header — dégradé teinté selon le niveau ────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.4),
                        radius: 1.1,
                        colors: [
                          dot.withValues(alpha: cs.brightness == Brightness.dark ? 0.22 : 0.14),
                          cs.surface,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(children: [
                        GestureDetector(
                          onTap: () {
                            final uid = p.userId.isNotEmpty ? p.userId : p.id;
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => UserProfileScreen(userId: uid, heroTag: 'partner_avatar_$uid')));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(
                                color: dot.withValues(alpha: 0.35), blurRadius: 26, spreadRadius: 2)],
                              border: Border.all(color: dot.withValues(alpha: 0.5), width: 2),
                            ),
                            child: Hero(
                              tag: 'partner_avatar_${p.userId.isNotEmpty ? p.userId : p.id}',
                              child: CommunityAvatar(
                                avatarUrl: p.avatar, name: p.name, radius: 44,
                                mascotType: p.mascotType, mascotMood: p.mascotMood,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(p.name, style: GoogleFonts.outfit(
                            fontSize: 24, fontWeight: FontWeight.w700,
                            color: cs.onSurface, letterSpacing: -0.5)),
                          if (p.isPro) ...[
                            const SizedBox(width: 7),
                            const Icon(LucideIcons.crown, size: 19, color: Color(0xFFF59E0B)),
                          ],
                        ]),
                        const SizedBox(height: 10),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: dot.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(l10n.communityPartnerLevelOption(p.level), style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w700, color: dot)),
                          ),
                          const SizedBox(width: 8),
                          Icon(LucideIcons.mapPin, size: 13, color: cs.onSurface.withValues(alpha: 0.4)),
                          const SizedBox(width: 3),
                          Text(p.region, style: GoogleFonts.inter(
                            fontSize: 13, color: cs.onSurface.withValues(alpha: 0.55))),
                        ]),
                      ]),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Stats row ────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(children: [
                            Expanded(child: _StatColumn(
                              icon: LucideIcons.target, iconColor: cs.primary,
                              label: l10n.communityPartnerGoalLabel,
                              value: l10n.communityPartnerGoalOption(p.goal), cs: cs)),
                            Container(width: 1, height: 32, color: cs.outline.withValues(alpha: 0.5)),
                            Expanded(child: _StatColumn(
                              icon: LucideIcons.calendarDays, iconColor: const Color(0xFF5B8DEF),
                              label: l10n.communityPartnerFrequencyLabel,
                              value: l10n.communityPartnerFreqOption(p.frequency), cs: cs)),
                            Container(width: 1, height: 32, color: cs.outline.withValues(alpha: 0.5)),
                            Expanded(child: _StatColumn(
                              icon: LucideIcons.barChart2, iconColor: dot,
                              label: l10n.communityLevelLabel,
                              value: l10n.communityPartnerLevelOption(p.level), cs: cs)),
                          ]),
                        ),

                        if (p.description.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          Row(children: [
                            Icon(LucideIcons.userCircle2, size: 13, color: cs.primary),
                            const SizedBox(width: 6),
                            Text(l10n.communityAboutLabel, style: GoogleFonts.inter(
                              fontSize: 10.5, fontWeight: FontWeight.w700,
                              color: cs.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
                          ]),
                          const SizedBox(height: 10),
                          Text(p.description, style: GoogleFonts.inter(
                            fontSize: 15, color: cs.onSurface.withValues(alpha: 0.8), height: 1.65)),
                        ],

                        if (p.tags.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          Row(children: [
                            Icon(LucideIcons.sparkles, size: 13, color: const Color(0xFFD69A2C)),
                            const SizedBox(width: 6),
                            Text(l10n.communityPartnerInterestsSection, style: GoogleFonts.inter(
                              fontSize: 10.5, fontWeight: FontWeight.w700,
                              color: cs.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
                          ]),
                          const SizedBox(height: 10),
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            for (int i = 0; i < p.tags.length; i++)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                                decoration: BoxDecoration(
                                  color: _tagColors[i % _tagColors.length].withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(p.tags[i], style: GoogleFonts.inter(
                                  fontSize: 12.5, fontWeight: FontWeight.w600,
                                  color: _tagColors[i % _tagColors.length])),
                              ),
                          ]),
                        ],

                        if (status == 'accepted') ...[
                          const SizedBox(height: 28),
                          Row(children: [
                            Icon(LucideIcons.messageCircle, size: 13, color: cs.primary),
                            const SizedBox(width: 6),
                            Text(l10n.communityEventContactSection, style: GoogleFonts.inter(
                              fontSize: 10.5, fontWeight: FontWeight.w700,
                              color: cs.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
                          ]),
                          const SizedBox(height: 14),
                          SocialContactList(
                            contactWhatsapp: p.contactWhatsapp,
                            contactInstagram: p.contactInstagram,
                            contactFacebook: p.contactFacebook,
                            cs: cs,
                            linkErrorMessage: l10n.communityPartnerLinkError,
                            emptyLabel: l10n.communityPartnerNoContact,
                          ),
                        ],

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Sticky CTA bar ────────────────────────────────
          if (!isOwnPost)
            Container(
              padding: EdgeInsets.fromLTRB(28, 16, 28, 16 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.5))),
              ),
              child: _DetailCta(status: status, partner: p, colorScheme: cs),
            )
          else
            SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
      ]),
    );
  }
}

const _tagColors = [
  Color(0xFF5B8DEF), // bleu
  Color(0xFFD65C8A), // rose
  Color(0xFFD69A2C), // ambre
  Color(0xFF3FA796), // sarcelle
  Color(0xFF8B6FD6), // violet
];

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final ColorScheme cs;
  const _StatColumn({
    required this.icon, required this.iconColor,
    required this.label, required this.value, required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, size: 16, color: iconColor),
      const SizedBox(height: 8),
      Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface)),
      const SizedBox(height: 3),
      Text(label, style: GoogleFonts.inter(
        fontSize: 10, color: cs.onSurface.withValues(alpha: 0.45))),
    ]);
  }
}

class _DetailCta extends ConsumerWidget {
  final String status;
  final PartnerModel partner;
  final ColorScheme colorScheme;
  const _DetailCta({required this.status, required this.partner, required this.colorScheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final cs = colorScheme;

    if (status == 'accepted') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.checkCircle2, size: 17, color: cs.primary),
          const SizedBox(width: 8),
          Text(l10n.communityJoinAccepted, style: GoogleFonts.inter(
            fontSize: 13.5, fontWeight: FontWeight.w700, color: cs.primary)),
        ]),
      );
    }
    if (status == 'pending') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cs.secondary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: cs.secondary.withValues(alpha: 0.25)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.clock, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Text(l10n.communityJoinPending, style: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w700, color: cs.primary)),
        ]),
      );
    }
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        ref.read(partnerRequestsProvider.notifier).join(partnerId: partner.id, ownerId: partner.userId);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [BoxShadow(
            color: cs.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.userPlus, size: 16, color: cs.onPrimary),
          const SizedBox(width: 8),
          Text(l10n.communityJoinBtn, style: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w700, color: cs.onPrimary)),
        ]),
      ),
    );
  }
}

// ─── Menu propriétaire (modifier / supprimer) ─────────────────
class _PartnerOwnerMenu extends ConsumerWidget {
  final PartnerModel partner;
  final ColorScheme cs;
  const _PartnerOwnerMenu({required this.partner, required this.cs});

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Supprimer cette annonce ?',
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
              final ok = await ref.read(partnersNotifierProvider.notifier).deletePartner(partner.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: ok ? cs.primary : cs.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                content: Text(
                  ok ? 'Annonce supprimée.' : 'Erreur lors de la suppression.',
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
          color: cs.onSurface.withValues(alpha: 0.5), size: 18),
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
          showCreatePartnerSheet(context, partner: partner);
        } else {
          _confirmDelete(context, ref);
        }
      },
    );
  }
}

// ─── Public re-exports (kept for backward compatibility) ──────
class GoalBadge extends StatelessWidget {
  final String label;
  const GoalBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: cs.secondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.target, size: 10, color: cs.primary),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: cs.primary)),
      ]),
    );
  }
}

class LevelBadge extends StatelessWidget {
  final String level;
  const LevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dot = _levelDot(level, cs);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), border: Border.all(color: cs.outline)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(level, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.7))),
      ]),
    );
  }
}
