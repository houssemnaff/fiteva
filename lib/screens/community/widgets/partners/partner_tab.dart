import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../providers/community_providers.dart';


const _avatarColors = [
  Color(0xFF7C3AED), Color(0xFF059669), Color(0xFFD97706),
  Color(0xFF2563EB), Color(0xFFDB2777),
];

// ─── Partners Tab ─────────────────────────────────────────────
class PartnerTab extends ConsumerStatefulWidget {
  const PartnerTab({super.key});
  @override
  ConsumerState<PartnerTab> createState() => _PartnerTabState();
}

class _PartnerTabState extends ConsumerState<PartnerTab> {
  String _goal   = 'Tous';
  String _level  = 'Tous';
  String _region = 'Tous';
  bool _filtersOpen = false;

  static const _goals   = ['Tous', 'Perdre du poids', 'Tonifier', 'Masse', 'Bien-être'];
  static const _levels  = ['Tous', 'Débutant', 'Intermédiaire', 'Avancé'];
  static const _regions = ['Tous', 'Sousse', 'Monastir', 'Tunis', 'Sfax'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final partners = ref.watch(partnersProvider);
    final filtered = partners.where((p) {
      final goalOk   = _goal   == 'Tous' || p.goal   == _goal;
      final levelOk  = _level  == 'Tous' || p.level  == _level;
      final regionOk = _region == 'Tous' || p.region == _region;
      return goalOk && levelOk && regionOk;
    }).toList();

    return ColoredBox(
      color: cs.surface,
      child: CustomScrollView(
        slivers: [

          // ── Header ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PARTNERS', style: GoogleFonts.inter(
                          color: cs.secondary, fontSize: 9,
                          fontWeight: FontWeight.w700, letterSpacing: 3,
                        )),
                        const SizedBox(height: 3),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(
                              fontSize: 26, fontWeight: FontWeight.w800,
                              color: cs.onSurface, letterSpacing: -0.5, height: 1.1,
                            ),
                            children: [
                              const TextSpan(text: "Partenaires\n"),
                              TextSpan(text: "d'entraînement",
                                  style: TextStyle(color: cs.primary)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filtered.length} partenaire${filtered.length > 1 ? 's' : ''} trouvé${filtered.length > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter toggle
                  GestureDetector(
                    onTap: () => setState(() => _filtersOpen = !_filtersOpen),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _filtersOpen ? cs.primary.withValues(alpha: 0.08) : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: _filtersOpen ? cs.primary : cs.outline,
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(LucideIcons.sliders,
                            size: 13,
                            color: _filtersOpen ? cs.primary : cs.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 6),
                        Text('Filtres', style: GoogleFonts.inter(
                          color: _filtersOpen ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                          fontSize: 12, fontWeight: FontWeight.w700,
                        )),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Filter Panel (collapsible) ─────────────────────
          SliverToBoxAdapter(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: _filtersOpen
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _FilterPanel(
                        selectedGoal:   _goal,
                        selectedLevel:  _level,
                        selectedRegion: _region,
                        goals:   _goals,
                        levels:  _levels,
                        regions: _regions,
                        onGoalSelect:   (v) => setState(() => _goal   = v),
                        onLevelSelect:  (v) => setState(() => _level  = v),
                        onRegionSelect: (v) => setState(() => _region = v),
                        colorScheme: cs,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // ── Cards ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) =>
                  PartnerCard(partner: filtered[i], index: i, colorScheme: cs),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Panel ─────────────────────────────────────────────
class _FilterPanel extends StatelessWidget {
  final String selectedGoal, selectedLevel, selectedRegion;
  final List<String> goals, levels, regions;
  final ValueChanged<String> onGoalSelect, onLevelSelect, onRegionSelect;
  final ColorScheme colorScheme;

  const _FilterPanel({
    required this.selectedGoal,
    required this.selectedLevel,
    required this.selectedRegion,
    required this.goals,
    required this.levels,
    required this.regions,
    required this.onGoalSelect,
    required this.onLevelSelect,
    required this.onRegionSelect,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 16, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterRow(
            icon: LucideIcons.target,
            label: 'Objectif',
            items: goals,
            selected: selectedGoal,
            onSelect: onGoalSelect,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: colorScheme.outline),
          const SizedBox(height: 14),
          _FilterRow(
            icon: LucideIcons.barChart2,
            label: 'Niveau',
            items: levels,
            selected: selectedLevel,
            onSelect: onLevelSelect,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: colorScheme.outline),
          const SizedBox(height: 14),
          _FilterRow(
            icon: LucideIcons.mapPin,
            label: 'Région',
            items: regions,
            selected: selectedRegion,
            onSelect: onRegionSelect,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;
  final ColorScheme colorScheme;

  const _FilterRow({
    required this.icon,
    required this.label,
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 12, color: colorScheme.primary),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: colorScheme.primary, letterSpacing: 0.5,
          )),
        ]),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: items.map((item) {
            final sel = selected == item;
            return GestureDetector(
              onTap: () => onSelect(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                      color: sel ? colorScheme.primary : colorScheme.outline),
                ),
                child: Text(item, style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: sel ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.6),
                )),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Partner Card ─────────────────────────────────────────────
class PartnerCard extends StatefulWidget {
  final PartnerModel partner;
  final int index;
  final ColorScheme colorScheme;
  const PartnerCard({super.key, required this.partner, required this.index, required this.colorScheme});

  @override
  State<PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<PartnerCard> {
  bool _messaged = false;

  Color get _avatarColor =>
      _avatarColors[widget.index % _avatarColors.length];

  String get _initials {
    final parts = widget.partner.name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final p = widget.partner;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
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

          // ── Avatar + Name row ────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: _avatarColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(_initials, style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: Colors.white,
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: GoogleFonts.outfit(
                      fontSize: 15, fontWeight: FontWeight.w800,
                      color: cs.onSurface, letterSpacing: -0.3,
                    )),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(LucideIcons.mapPin, size: 11, color: cs.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 3),
                      Text(p.region, style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5),
                      )),
                      const SizedBox(width: 10),
                      Icon(LucideIcons.calendarDays, size: 11, color: cs.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 3),
                      Text(p.frequency, style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5),
                      )),
                    ]),
                  ],
                ),
              ),
              // Level badge
              _LevelBadge(level: p.level, colorScheme: cs),
            ],
          ),

          const SizedBox(height: 12),

          // ── Goal badge ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: cs.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(LucideIcons.target, size: 10, color: cs.primary),
              const SizedBox(width: 5),
              Text(p.goal, style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700, color: cs.primary,
              )),
            ]),
          ),

          const SizedBox(height: 10),

          // ── Description ──────────────────────────────────
          Text(p.description, style: GoogleFonts.inter(
            fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6), height: 1.5,
          )),

          const SizedBox(height: 10),

          // ── Tags ─────────────────────────────────────────
          Wrap(
            spacing: 5, runSpacing: 5,
            children: p.tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text('#$tag', style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700, color: cs.primary,
              )),
            )).toList(),
          ),

          const SizedBox(height: 14),

          // ── CTA ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _messaged
                  ? _MessagedBtn(key: const ValueKey('done'), colorScheme: cs)
                  : _MessageBtn(
                      key: const ValueKey('idle'),
                      onTap: () => setState(() => _messaged = true),
                      colorScheme: cs,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Level Badge ──────────────────────────────────────────────
class _LevelBadge extends StatelessWidget {
  final String level;
  final ColorScheme colorScheme;
  const _LevelBadge({required this.level, required this.colorScheme});

  Color get _bg {
    switch (level) {
      case 'Débutant':      return colorScheme.primary.withValues(alpha: 0.12);
      case 'Intermédiaire': return const Color(0xFFFFF3E0);
      case 'Avancé':        return colorScheme.error.withValues(alpha: 0.12);
      default:              return colorScheme.outline.withValues(alpha: 0.1);
    }
  }

  Color get _fg {
    switch (level) {
      case 'Débutant':      return colorScheme.primary;
      case 'Intermédiaire': return const Color(0xFF9A5F00);
      case 'Avancé':        return colorScheme.error;
      default:              return colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(level, style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w700, color: _fg,
      )),
    );
  }
}

// ─── Message Buttons ──────────────────────────────────────────
class _MessageBtn extends StatelessWidget {
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  const _MessageBtn({super.key, required this.onTap, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.messageSquare, size: 13, color: colorScheme.onPrimary),
          const SizedBox(width: 8),
          Text('Envoyer un message', style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w800,
            color: colorScheme.onPrimary, letterSpacing: 0.2,
          )),
        ]),
      ),
    );
  }
}

class _MessagedBtn extends StatelessWidget {
  final ColorScheme colorScheme;
  const _MessagedBtn({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.checkCircle, size: 13, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text('Message envoyé !', style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w800, color: colorScheme.primary,
        )),
      ]),
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
      decoration: BoxDecoration(
        color: cs.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.target, size: 10, color: cs.primary),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w700, color: cs.primary,
        )),
      ]),
    );
  }
}

class LevelBadge extends StatelessWidget {
  final String level;
  const LevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) => _LevelBadge(level: level, colorScheme: Theme.of(context).colorScheme,);
}