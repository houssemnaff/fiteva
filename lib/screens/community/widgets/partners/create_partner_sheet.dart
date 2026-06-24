// ignore_for_file: deprecated_member_use
import 'package:fiteva/providers/mock_data_provider.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
void showCreatePartnerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (_) => const CreatePartnerSheet(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class CreatePartnerSheet extends ConsumerStatefulWidget {
  const CreatePartnerSheet({super.key});

  @override
  ConsumerState<CreatePartnerSheet> createState() => _CreatePartnerSheetState();
}

class _CreatePartnerSheetState extends ConsumerState<CreatePartnerSheet>
    with SingleTickerProviderStateMixin {

  final _descCtrl   = TextEditingController();
  final _scrollCtrl = ScrollController();

  String _selectedGoal   = 'Tonifier';
  String _selectedLevel  = 'Intermédiaire';
  String _selectedRegion = 'Sousse';
  String _selectedFreq   = '3x / sem';
  bool   _isPublishing   = false;

  late final AnimationController _enterCtrl;
  late final Animation<double>   _enterAnim;

  static const _goals = [
    (label: 'Perdre du poids', icon: LucideIcons.flame),
    (label: 'Tonifier',        icon: LucideIcons.zap),
    (label: 'Prise de masse',  icon: LucideIcons.dumbbell),
    (label: 'Bien-être',       icon: LucideIcons.heart),
  ];

  static const _levels = ['Débutant', 'Intermédiaire', 'Avancé'];

  static const _regions = ['Sousse', 'Monastir', 'Tunis', 'Sfax', 'Autre'];

  static const _freqs = [
    (label: '1x / sem', icon: LucideIcons.sun),
    (label: '2x / sem', icon: LucideIcons.repeat),
    (label: '3x / sem', icon: LucideIcons.zap),
    (label: '5x / sem', icon: LucideIcons.flame),
  ];

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _enterAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _scrollCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  String _resolvedName() {
    final profile = ref.read(userProfileProvider);
    final user    = ref.read(userProvider);
    return profile.username.isNotEmpty ? profile.username : user.name;
  }

  Future<void> _publish() async {
    HapticFeedback.mediumImpact();
    setState(() => _isPublishing = true);
    final partner = PartnerModel(
      id: 'pt_${DateTime.now().millisecondsSinceEpoch}',
      name: _resolvedName(),
      avatar: '',
      goal: _selectedGoal,
      level: _selectedLevel,
      region: _selectedRegion,
      frequency: _selectedFreq,
      description: _descCtrl.text.trim().isNotEmpty
          ? _descCtrl.text.trim()
          : 'Passionné de fitness, cherche partenaire motivé.',
      tags: [_selectedGoal.split(' ').first, _selectedLevel],
    );
    await ref.read(partnersNotifierProvider.notifier).addPartner(partner);
    if (!mounted) return;
    setState(() => _isPublishing = false);
    Navigator.of(context).pop();
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: cs.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(seconds: 3),
      content: Row(children: [
        Icon(LucideIcons.checkCircle, color: cs.onPrimary, size: 18),
        const SizedBox(width: 10),
        Text(ref.read(l10nProvider).communityProfilePublished,
            style: GoogleFonts.inter(color: cs.onPrimary, fontWeight: FontWeight.w600)),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final l10n    = ref.watch(l10nProvider);
    final bottom  = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;
    final displayName = _resolvedName();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(_enterAnim),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.92),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Handle(cs: cs),
            _TopBar(cs: cs, onClose: () => Navigator.of(context).pop()),

            // ── Publier en tant que ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.primary.withValues(alpha: 0.15),
                  child: Text(initial, style: TextStyle(
                    color: cs.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(displayName, style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: cs.onSurface, letterSpacing: -0.2)),
                  Text(l10n.communityPublishProfileFull, style: GoogleFonts.inter(
                    fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
                ]),
              ]),
            ),

            Flexible(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Objectif ─────────────────────────────────
                    _SectionLabel(text: 'Objectif', cs: cs),
                    const SizedBox(height: 10),
                    _GoalGrid(
                      goals: _goals,
                      selected: _selectedGoal,
                      cs: cs,
                      onSelect: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedGoal = v);
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Niveau ───────────────────────────────────
                    _SectionLabel(text: 'Niveau', cs: cs),
                    const SizedBox(height: 10),
                    _PillRow(
                      items: _levels,
                      selected: _selectedLevel,
                      cs: cs,
                      onSelect: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedLevel = v);
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Fréquence ────────────────────────────────
                    _SectionLabel(text: 'Fréquence', cs: cs),
                    const SizedBox(height: 10),
                    _FreqRow(
                      freqs: _freqs,
                      selected: _selectedFreq,
                      cs: cs,
                      onSelect: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedFreq = v);
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Région ───────────────────────────────────
                    _SectionLabel(text: 'Région', cs: cs),
                    const SizedBox(height: 10),
                    _RegionWrap(
                      regions: _regions,
                      selected: _selectedRegion,
                      cs: cs,
                      onSelect: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedRegion = v);
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── À propos ─────────────────────────────────
                    _SectionLabel(text: 'À propos de toi  (optionnel)', cs: cs),
                    const SizedBox(height: 8),
                    _DescriptionField(controller: _descCtrl, cs: cs),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _BottomBar(cs: cs, publishing: _isPublishing, onPublish: _publish),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HANDLE
// ─────────────────────────────────────────────────────────────────────────────
class _Handle extends StatelessWidget {
  final ColorScheme cs;
  const _Handle({required this.cs});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Center(
      child: Container(
        width: 36, height: 4,
        decoration: BoxDecoration(
          color: cs.outline.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(2)),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  TOP BAR
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends ConsumerWidget {
  final ColorScheme cs;
  final VoidCallback onClose;
  const _TopBar({required this.cs, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 16),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.communityPartnerLabel, style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w700,
            color: cs.primary, letterSpacing: 2.5)),
          const SizedBox(height: 2),
          Text(l10n.communityDescribeProfile, style: GoogleFonts.outfit(
            fontSize: 19, fontWeight: FontWeight.w700,
            color: cs.onSurface, letterSpacing: -0.3)),
        ])),
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12)),
            child: Icon(LucideIcons.x, size: 16,
                color: cs.onSurface.withValues(alpha: 0.6)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  final ColorScheme cs;
  const _SectionLabel({required this.text, required this.cs});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.inter(
      color: cs.onSurface.withValues(alpha: 0.5),
      fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  GOAL GRID
// ─────────────────────────────────────────────────────────────────────────────
class _GoalGrid extends StatelessWidget {
  final List<({String label, IconData icon})> goals;
  final String selected;
  final ColorScheme cs;
  final ValueChanged<String> onSelect;
  const _GoalGrid({
    required this.goals, required this.selected,
    required this.cs, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.8,
      children: goals.map((g) {
        final sel = selected == g.label;
        return GestureDetector(
          onTap: () => onSelect(g.label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: sel ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? cs.primary : cs.outline,
              ),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(g.icon, size: 14,
                  color: sel ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 7),
              Text(g.label, style: GoogleFonts.inter(
                color: sel ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              )),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PILL ROW  (level)
// ─────────────────────────────────────────────────────────────────────────────
class _PillRow extends StatelessWidget {
  final List<String> items;
  final String selected;
  final ColorScheme cs;
  final ValueChanged<String> onSelect;
  const _PillRow({
    required this.items, required this.selected,
    required this.cs, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.asMap().entries.map((e) {
        final sel = selected == e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < items.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onSelect(e.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: sel ? cs.primary : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? cs.primary : cs.outline,
                  ),
                ),
                child: Center(
                  child: Text(e.value, textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: sel ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      )),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FREQ ROW
// ─────────────────────────────────────────────────────────────────────────────
class _FreqRow extends StatelessWidget {
  final List<({String label, IconData icon})> freqs;
  final String selected;
  final ColorScheme cs;
  final ValueChanged<String> onSelect;
  const _FreqRow({
    required this.freqs, required this.selected,
    required this.cs, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: freqs.asMap().entries.map((e) {
        final f = e.value;
        final sel = selected == f.label;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < freqs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onSelect(f.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: sel ? cs.primary : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? cs.primary : cs.outline,
                  ),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(f.icon, size: 14,
                      color: sel ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(height: 5),
                  Text(f.label, textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: sel ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      )),
                ]),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  REGION WRAP
// ─────────────────────────────────────────────────────────────────────────────
class _RegionWrap extends StatelessWidget {
  final List<String> regions;
  final String selected;
  final ColorScheme cs;
  final ValueChanged<String> onSelect;
  const _RegionWrap({
    required this.regions, required this.selected,
    required this.cs, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: regions.map((r) {
        final sel = selected == r;
        return GestureDetector(
          onTap: () => onSelect(r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: sel ? cs.primary : cs.outline,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (sel) ...[
                Icon(LucideIcons.mapPin, size: 11, color: cs.onPrimary),
                const SizedBox(width: 5),
              ],
              Text(r, style: GoogleFonts.inter(
                color: sel ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              )),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DESCRIPTION FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _DescriptionField extends StatefulWidget {
  final TextEditingController controller;
  final ColorScheme cs;
  const _DescriptionField({required this.controller, required this.cs});

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _focused ? cs.surface : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused ? cs.primary : cs.outline,
            width: _focused ? 1.5 : 1,
          ),
          boxShadow: _focused
              ? [BoxShadow(
                  color: cs.primary.withValues(alpha: 0.08),
                  blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          maxLines: 4,
          style: GoogleFonts.inter(color: cs.onSurface, fontSize: 14, height: 1.55),
          decoration: InputDecoration(
            hintText: 'Je cherche une partenaire pour salle 3x/semaine à Sousse…',
            hintStyle: GoogleFonts.inter(
                color: cs.onSurface.withValues(alpha: 0.35), fontSize: 13, height: 1.5),
            contentPadding: const EdgeInsets.all(14),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BOTTOM BAR
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends ConsumerWidget {
  final ColorScheme cs;
  final bool publishing;
  final VoidCallback onPublish;
  const _BottomBar({required this.cs, required this.publishing, required this.onPublish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.6))),
      ),
      child: GestureDetector(
        onTap: publishing ? null : onPublish,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            color: publishing ? cs.primary.withValues(alpha: 0.5) : cs.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: publishing
                ? SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: cs.onPrimary))
                : Text(l10n.communityPublishProfile,
                    style: GoogleFonts.outfit(
                      color: cs.onPrimary,
                      fontSize: 16, fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    )),
          ),
        ),
      ),
    );
  }
}
