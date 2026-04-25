import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../providers/community_providers.dart';
import 'create_partner_sheet.dart';

// ─── Design Tokens ────────────────────────────────────────────
class _T {
  static const bg = Colors.white;
  static const surface = Colors.white;
  static const surfaceElevated = Colors.white;
  static const border = Colors.white;
  static const borderSubtle = Colors.white;

  static const accent = Color(0xFF1C4D30);
  static const accentLight = Color(0xFFEAF3E8);
  static const accentFg = Colors.white;

  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textMuted = Color(0xFFAAAAAA);

  static const goalBg = Color(0xFFDCF5E8);
  static const goalFg = Color(0xFF1C4D30);

  static const begBg = Color(0xFFDCF5E8);
  static const begFg = Color(0xFF1C4D30);

  static const intBg = Color(0xFFFFF3E0);
  static const intFg = Color(0xFF9A5F00);

  static const advBg = Color(0xFFFFEBEB);
  static const advFg = Color(0xFFA32D2D);

  static const av0 = Color(0xFF7C3AED);
  static const av1 = Color(0xFF059669);
  static const av2 = Color(0xFFD97706);
  static const av3 = Color(0xFF2563EB);
  static const av4 = Color(0xFFDB2777);
}

// ─── Partners Tab ─────────────────────────────────────────────
class PartnerTab extends ConsumerStatefulWidget {
  const PartnerTab({super.key});

  @override
  ConsumerState<PartnerTab> createState() => _PartnerTabState();
}

class _PartnerTabState extends ConsumerState<PartnerTab> {
  String _selectedGoal = 'Tous';
  String _selectedLevel = 'Tous';
  String _selectedRegion = 'Tous';

  static const _goals = [
    'Tous', 'Perdre du poids', 'Tonifier', 'Masse', 'Bien-être',
  ];
  static const _levels = ['Tous', 'Débutant', 'Intermédiaire', 'Avancé'];
  static const _regions = ['Tous', 'Sousse', 'Monastir', 'Tunis', 'Sfax'];

  @override
  Widget build(BuildContext context) {
    final partners = ref.watch(partnersProvider);
    final filtered = partners.where((p) {
      final goalOk = _selectedGoal == 'Tous' || p.goal == _selectedGoal;
      final levelOk = _selectedLevel == 'Tous' || p.level == _selectedLevel;
      final regionOk = _selectedRegion == 'Tous' || p.region == _selectedRegion;
      return goalOk && levelOk && regionOk;
    }).toList();

    return ColoredBox(
      color: _T.bg,
      child: CustomScrollView(
        slivers: [
          // ── Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _T.textPrimary,
                              height: 1.1,
                              letterSpacing: -0.8,
                            ),
                            children: [
                              TextSpan(text: 'Partenaires\n'),
                              TextSpan(
                                text: "d'entraînement",
                                style: TextStyle(color: _T.accent),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${filtered.length} partenaire${filtered.length > 1 ? 's' : ''} trouvé${filtered.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _T.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ProposeButton(
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const CreatePartnerSheet(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Filter Panel
          SliverToBoxAdapter(
            child: _FilterPanel(
              selectedGoal: _selectedGoal,
              selectedLevel: _selectedLevel,
              selectedRegion: _selectedRegion,
              goals: _goals,
              levels: _levels,
              regions: _regions,
              onGoalSelect: (v) => setState(() => _selectedGoal = v),
              onLevelSelect: (v) => setState(() => _selectedLevel = v),
              onRegionSelect: (v) => setState(() => _selectedRegion = v),
            ),
          ),

          // ── Cards
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            sliver: SliverList.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  PartnerCard(partner: filtered[index], index: index),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Panel ─────────────────────────────────────────────
class _FilterPanel extends StatelessWidget {
  final String selectedGoal;
  final String selectedLevel;
  final String selectedRegion;
  final List<String> goals;
  final List<String> levels;
  final List<String> regions;
  final ValueChanged<String> onGoalSelect;
  final ValueChanged<String> onLevelSelect;
  final ValueChanged<String> onRegionSelect;

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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _T.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _T.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterSection(
            icon: LucideIcons.target,
            label: 'Objectif',
            items: goals,
            selected: selectedGoal,
            onSelect: onGoalSelect,
          ),
          const SizedBox(height: 12),
          const Divider(color: _T.border, height: 1),
          const SizedBox(height: 12),
          _FilterSection(
            icon: LucideIcons.barChart2,
            label: 'Niveau',
            items: levels,
            selected: selectedLevel,
            onSelect: onLevelSelect,
          ),
          const SizedBox(height: 12),
          const Divider(color: _T.border, height: 1),
          const SizedBox(height: 12),
          _FilterSection(
            icon: LucideIcons.mapPin,
            label: 'Région',
            items: regions,
            selected: selectedRegion,
            onSelect: onRegionSelect,
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterSection({
    required this.icon,
    required this.label,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: _T.accent),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _T.accent,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .map((item) => _ChipItem(
                    label: item,
                    selected: selected == item,
                    onTap: () => onSelect(item),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _ChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _T.accent : _T.bg,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? _T.accent : _T.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? _T.accentFg : _T.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Propose Button ───────────────────────────────────────────
class _ProposeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ProposeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _T.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.plus, size: 13, color: _T.accentFg),
            SizedBox(width: 5),
            Text(
              'Proposer',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _T.accentFg,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Partner Card ─────────────────────────────────────────────
class PartnerCard extends StatefulWidget {
  final PartnerModel partner;
  final int index;

  const PartnerCard({super.key, required this.partner, required this.index});

  @override
  State<PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<PartnerCard> {
  bool _commented = false;

  static const _avatarColors = [_T.av0, _T.av1, _T.av2, _T.av3, _T.av4];

  Color get _avatarColor =>
      _avatarColors[widget.index % _avatarColors.length];

  String get _initials {
    final parts = widget.partner.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.partner;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + name
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _avatarColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _T.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _MiniTag(label: p.region, icon: LucideIcons.mapPin),
                        const SizedBox(width: 10),
                        _MiniTag(
                          label: p.frequency,
                          icon: LucideIcons.calendarDays,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Badges
          Row(
            children: [
              GoalBadge(label: p.goal),
              const SizedBox(width: 6),
              LevelBadge(level: p.level),
            ],
          ),

          const SizedBox(height: 10),

          // ── Description
          Text(
            p.description,
            style: const TextStyle(
              fontSize: 13,
              color: _T.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 10),

          // ── Tags
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: p.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _T.accentLight,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '#$tag',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _T.accent,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 13),

          // ── Comment button
          SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _commented
                  ? _CommentedButton(key: const ValueKey('done'))
                  : _CommentButton(
                      key: const ValueKey('idle'),
                      onTap: () => setState(() => _commented = true),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Comment Buttons ──────────────────────────────────────────
class _CommentButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CommentButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _T.accent),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.messageSquare, size: 13, color: _T.accent),
            SizedBox(width: 7),
            Text(
              'Laisser un commentaire',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _T.accent,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentedButton extends StatelessWidget {
  const _CommentedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: _T.begBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.checkCircle, size: 13, color: _T.begFg),
          SizedBox(width: 7),
          Text(
            'Commentaire envoyé',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _T.begFg,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini helpers ─────────────────────────────────────────────
class _MiniTag extends StatelessWidget {
  final String label;
  final IconData icon;
  const _MiniTag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: _T.textMuted),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: _T.textMuted),
        ),
      ],
    );
  }
}

class GoalBadge extends StatelessWidget {
  final String label;
  const GoalBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _T.goalBg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.target, size: 10, color: _T.goalFg),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _T.goalFg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class LevelBadge extends StatelessWidget {
  final String level;
  const LevelBadge({super.key, required this.level});

  Color get _bg {
    switch (level) {
      case 'Débutant':     return _T.begBg;
      case 'Intermédiaire': return _T.intBg;
      case 'Avancé':       return _T.advBg;
      default:             return _T.surfaceElevated;
    }
  }

  Color get _fg {
    switch (level) {
      case 'Débutant':     return _T.begFg;
      case 'Intermédiaire': return _T.intFg;
      case 'Avancé':       return _T.advFg;
      default:             return _T.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        level,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}