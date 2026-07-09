// ignore_for_file: deprecated_member_use
import '../../../../../l10n/app_localizations.dart';
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/screens/community/widgets/community_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
/// Si [partner] est fourni, la sheet s'ouvre en mode édition.
void showCreatePartnerSheet(BuildContext context, {PartnerModel? partner}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (_) => CreatePartnerSheet(partner: partner),
  );
}

// Palette dédiée au formulaire — un accent distinct par objectif / niveau / fréquence
const Color _cGoalLose   = Color(0xFFE0684A); // orange corail
const Color _cGoalTone   = Color(0xFF3FA796); // sarcelle
const Color _cGoalMass   = Color(0xFF5B8DEF); // bleu
const Color _cGoalWell   = Color(0xFFD65C8A); // rose

const Color _cLevelBeg = Color(0xFF3FA796);
const Color _cLevelInt = Color(0xFFD69A2C);
const Color _cLevelAdv = Color(0xFFB4483E);

const Color _cFreqSun   = Color(0xFFD69A2C);
const Color _cFreqBlue  = Color(0xFF5B8DEF);
const Color _cFreqGreen = Color(0xFF3FA796);
const Color _cFreqFlame = Color(0xFFB4483E);

// ─────────────────────────────────────────────────────────────────────────────
class CreatePartnerSheet extends ConsumerStatefulWidget {
  /// Si [partner] est fourni, la sheet s'ouvre en mode édition.
  final PartnerModel? partner;
  const CreatePartnerSheet({super.key, this.partner});

  @override
  ConsumerState<CreatePartnerSheet> createState() => _CreatePartnerSheetState();
}

class _CreatePartnerSheetState extends ConsumerState<CreatePartnerSheet>
    with SingleTickerProviderStateMixin {

  final _descCtrl      = TextEditingController();
  final _whatsappCtrl  = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _facebookCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();

  String _selectedGoal   = 'Tonifier';
  String _selectedLevel  = 'Intermédiaire';
  String _selectedRegion = 'Sousse';
  String _selectedFreq   = '3x / sem';
  bool   _isPublishing   = false;

  late final AnimationController _enterCtrl;
  late final Animation<double>   _enterAnim;

  static const _goals = [
    (value: 'Perdre du poids', icon: LucideIcons.flame,    color: _cGoalLose),
    (value: 'Tonifier',        icon: LucideIcons.zap,      color: _cGoalTone),
    (value: 'Prise de masse',  icon: LucideIcons.dumbbell, color: _cGoalMass),
    (value: 'Bien-être',       icon: LucideIcons.heart,    color: _cGoalWell),
  ];

  static const _levels = [
    (value: 'Débutant',      color: _cLevelBeg),
    (value: 'Intermédiaire', color: _cLevelInt),
    (value: 'Avancé',        color: _cLevelAdv),
  ];

  static const _regions = ['Sousse', 'Monastir', 'Tunis', 'Sfax', 'Autre'];

  static const _freqs = [
    (value: '1x / sem', icon: LucideIcons.sun,    color: _cFreqSun),
    (value: '2x / sem', icon: LucideIcons.repeat, color: _cFreqBlue),
    (value: '3x / sem', icon: LucideIcons.zap,    color: _cFreqGreen),
    (value: '5x / sem', icon: LucideIcons.flame,  color: _cFreqFlame),
  ];

  Color get _selectedGoalColor =>
      _goals.firstWhere((g) => g.value == _selectedGoal).color;

  bool get _isEditing => widget.partner != null;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _enterAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
    _enterCtrl.forward();

    // Pré-remplissage en mode édition.
    final p = widget.partner;
    if (p != null) {
      if (_goals.any((g) => g.value == p.goal)) _selectedGoal = p.goal;
      if (_levels.any((l) => l.value == p.level)) _selectedLevel = p.level;
      if (_regions.contains(p.region)) _selectedRegion = p.region;
      if (_freqs.any((f) => f.value == p.frequency)) _selectedFreq = p.frequency;
      _descCtrl.text = p.description;
      _whatsappCtrl.text = p.contactWhatsapp;
      _instagramCtrl.text = p.contactInstagram;
      _facebookCtrl.text = p.contactFacebook;
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _whatsappCtrl.dispose();
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _scrollCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  String _resolvedName() => ref.read(userProfileProvider).username;

  Future<void> _publish() async {
    HapticFeedback.mediumImpact();
    setState(() => _isPublishing = true);
    final l10n = ref.read(l10nProvider);

    bool ok;
    if (_isEditing) {
      final p = widget.partner!;
      final updated = PartnerModel(
        id:          p.id,
        userId:      p.userId,
        name:        p.name,
        avatar:      p.avatar,
        mascotType:  p.mascotType,
        mascotMood:  p.mascotMood,
        goal:        _selectedGoal,
        level:       _selectedLevel,
        region:      _selectedRegion,
        frequency:   _selectedFreq,
        description: _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : l10n.communityPartnerDescHint,
        tags: [_selectedGoal.split(' ').first, _selectedLevel],
        contactWhatsapp: _whatsappCtrl.text.trim(),
        contactInstagram: _instagramCtrl.text.trim(),
        contactFacebook: _facebookCtrl.text.trim(),
      );
      ok = await ref.read(partnersNotifierProvider.notifier).updatePartner(updated);
    } else {
      final partner = PartnerModel(
        id:          '',
        name:        _resolvedName(),
        avatar:      '',
        goal:        _selectedGoal,
        level:       _selectedLevel,
        region:      _selectedRegion,
        frequency:   _selectedFreq,
        description: _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : l10n.communityPartnerDescHint,
        tags: [_selectedGoal.split(' ').first, _selectedLevel],
        contactWhatsapp: _whatsappCtrl.text.trim(),
        contactInstagram: _instagramCtrl.text.trim(),
        contactFacebook: _facebookCtrl.text.trim(),
      );
      ok = await ref.read(partnersNotifierProvider.notifier).addPartner(partner);
    }

    if (!mounted) return;
    setState(() => _isPublishing = false);
    final cs = Theme.of(context).colorScheme;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        content: Row(children: [
          Icon(LucideIcons.circleAlert, color: cs.onError, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(l10n.communityPartnerPublishError,
              style: GoogleFonts.inter(color: cs.onError, fontWeight: FontWeight.w600))),
        ]),
      ));
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: cs.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(seconds: 3),
      content: Row(children: [
        Icon(LucideIcons.checkCircle, color: cs.onPrimary, size: 18),
        const SizedBox(width: 10),
        Text(
          _isEditing ? 'Annonce modifiée avec succès !' : l10n.communityProfilePublished,
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
    final accent = _selectedGoalColor;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(_enterAnim),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.94),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Handle(cs: cs),

            // ── Header — dégradé teinté selon l'objectif sélectionné ────
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [accent.withValues(alpha: cs.brightness == Brightness.dark ? 0.16 : 0.10), Colors.transparent],
                ),
              ),
              child: _TopBar(cs: cs, accent: accent, isEditing: _isEditing, onClose: () => Navigator.of(context).pop()),
            ),

            // ── Publier en tant que ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  CommunityAvatar(avatarUrl: '', name: displayName, radius: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(displayName, style: GoogleFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: cs.onSurface, letterSpacing: -0.2)),
                      Text(l10n.communityPublishProfileFull, style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
                    ]),
                  ),
                ]),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Objectif ─────────────────────────────────
                    _SectionLabel(text: l10n.communityPartnerGoalLabel, step: 1, color: accent, cs: cs),
                    const SizedBox(height: 10),
                    _GoalGrid(
                      goals: _goals,
                      selected: _selectedGoal,
                      cs: cs, l10n: l10n,
                      onSelect: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedGoal = v);
                      },
                    ),
                    const SizedBox(height: 26),

                    // ── Niveau ───────────────────────────────────
                    _SectionLabel(text: l10n.communityLevelLabel, step: 2, color: _cLevelInt, cs: cs),
                    const SizedBox(height: 10),
                    _PillRow(
                      items: _levels,
                      selected: _selectedLevel,
                      cs: cs, l10n: l10n,
                      onSelect: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedLevel = v);
                      },
                    ),
                    const SizedBox(height: 26),

                    // ── Fréquence ────────────────────────────────
                    _SectionLabel(text: l10n.communityPartnerFrequencyLabel, step: 3, color: _cFreqBlue, cs: cs),
                    const SizedBox(height: 10),
                    _FreqRow(
                      freqs: _freqs,
                      selected: _selectedFreq,
                      cs: cs, l10n: l10n,
                      onSelect: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedFreq = v);
                      },
                    ),
                    const SizedBox(height: 26),

                    // ── Région ───────────────────────────────────
                    _SectionLabel(text: l10n.communityPartnerRegionLabel, step: 4, color: cs.primary, cs: cs),
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
                    const SizedBox(height: 26),

                    // ── À propos ─────────────────────────────────
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: _SectionLabel(
                        text: l10n.communityPartnerAboutOptional, step: 5, color: const Color(0xFF8B6FD6), cs: cs)),
                      AnimatedBuilder(
                        animation: _descCtrl,
                        builder: (_, __) => Text(l10n.communityPartnerCharCount(_descCtrl.text.length),
                          style: GoogleFonts.inter(
                            fontSize: 10.5, color: cs.onSurface.withValues(alpha: 0.35))),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    _DescriptionField(controller: _descCtrl, cs: cs, hint: l10n.communityPartnerDescHint),
                    const SizedBox(height: 26),

                    // ── Contact (révélé une fois la demande acceptée) ──
                    _SectionLabel(
                        text: l10n.communityPartnerContactPrompt,
                        step: 6, color: const Color(0xFF25D366), cs: cs),
                    const SizedBox(height: 10),
                    _ContactGroup(cs: cs, rows: [
                      (
                        icon: LucideIcons.messageCircle, color: const Color(0xFF25D366),
                        label: 'WhatsApp', hint: l10n.communityPartnerWhatsappHint,
                        controller: _whatsappCtrl, keyboardType: TextInputType.phone,
                      ),
                      (
                        icon: LucideIcons.atSign, color: const Color(0xFFD62A7A),
                        label: 'Instagram', hint: l10n.communityPartnerInstagramHint,
                        controller: _instagramCtrl, keyboardType: null,
                      ),
                      (
                        icon: LucideIcons.globe, color: const Color(0xFF3B6FE0),
                        label: 'Facebook', hint: l10n.communityPartnerFacebookHint,
                        controller: _facebookCtrl, keyboardType: null,
                      ),
                    ]),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _BottomBar(cs: cs, accent: accent, publishing: _isPublishing, isEditing: _isEditing, onPublish: _publish),
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
  final Color accent;
  final bool isEditing;
  final VoidCallback onClose;
  const _TopBar({required this.cs, required this.accent, required this.isEditing, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 16),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.userPlus, size: 19, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isEditing ? 'MODIFIER' : l10n.communityPartnerLabel, style: GoogleFonts.inter(
            fontSize: 9, fontWeight: FontWeight.w700,
            color: accent, letterSpacing: 2.5)),
          const SizedBox(height: 2),
          Text(isEditing ? 'Modifier ton annonce' : l10n.communityDescribeProfile, style: GoogleFonts.outfit(
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
  final int step;
  final Color color;
  final ColorScheme cs;
  const _SectionLabel({required this.text, required this.step, required this.color, required this.cs});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 18, height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Text('$step', style: GoogleFonts.inter(
        fontSize: 9.5, fontWeight: FontWeight.w800, color: color)),
    ),
    const SizedBox(width: 8),
    Flexible(child: Text(
      text,
      style: GoogleFonts.inter(
        color: cs.onSurface.withValues(alpha: 0.6),
        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3,
      ),
    )),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
//  GOAL GRID
// ─────────────────────────────────────────────────────────────────────────────
class _GoalGrid extends StatelessWidget {
  final List<({String value, IconData icon, Color color})> goals;
  final String selected;
  final ColorScheme cs;
  final AppL10n l10n;
  final ValueChanged<String> onSelect;
  const _GoalGrid({
    required this.goals, required this.selected,
    required this.cs, required this.l10n, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.6,
      children: goals.map((g) {
        final sel = selected == g.value;
        return GestureDetector(
          onTap: () => onSelect(g.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: sel ? g.color.withValues(alpha: 0.14) : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sel ? g.color : cs.outline, width: sel ? 1.6 : 1,
              ),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(
                  color: sel ? g.color : cs.onSurface.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(g.icon, size: 13,
                    color: sel ? Colors.white : cs.onSurface.withValues(alpha: 0.5)),
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(l10n.communityPartnerGoalOption(g.value), style: GoogleFonts.inter(
                color: sel ? g.color : cs.onSurface.withValues(alpha: 0.65),
                fontSize: 12.5,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              ), overflow: TextOverflow.ellipsis)),
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
  final List<({String value, Color color})> items;
  final String selected;
  final ColorScheme cs;
  final AppL10n l10n;
  final ValueChanged<String> onSelect;
  const _PillRow({
    required this.items, required this.selected,
    required this.cs, required this.l10n, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.asMap().entries.map((e) {
        final item = e.value;
        final sel = selected == item.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < items.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onSelect(item.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: sel ? item.color.withValues(alpha: 0.14) : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? item.color : cs.outline, width: sel ? 1.6 : 1,
                  ),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 7, height: 7,
                    decoration: BoxDecoration(
                      color: sel ? item.color : cs.onSurface.withValues(alpha: 0.2),
                      shape: BoxShape.circle)),
                  const SizedBox(height: 6),
                  Text(l10n.communityPartnerLevelOption(item.value), textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: sel ? item.color : cs.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
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
//  FREQ ROW
// ─────────────────────────────────────────────────────────────────────────────
class _FreqRow extends StatelessWidget {
  final List<({String value, IconData icon, Color color})> freqs;
  final String selected;
  final ColorScheme cs;
  final AppL10n l10n;
  final ValueChanged<String> onSelect;
  const _FreqRow({
    required this.freqs, required this.selected,
    required this.cs, required this.l10n, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: freqs.asMap().entries.map((e) {
        final f = e.value;
        final sel = selected == f.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < freqs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onSelect(f.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: sel ? f.color.withValues(alpha: 0.14) : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? f.color : cs.outline, width: sel ? 1.6 : 1,
                  ),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(f.icon, size: 14,
                      color: sel ? f.color : cs.onSurface.withValues(alpha: 0.45)),
                  const SizedBox(height: 5),
                  Text(l10n.communityPartnerFreqOption(f.value), textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: sel ? f.color : cs.onSurface.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
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
  final String hint;
  const _DescriptionField({required this.controller, required this.cs, required this.hint});

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  bool _focused = false;
  static const _accent = Color(0xFF8B6FD6);

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: _focused ? 0.06 : 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _focused ? _accent : _accent.withValues(alpha: 0.22),
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: _focused
            ? [BoxShadow(
                color: _accent.withValues(alpha: 0.14),
                blurRadius: 14, offset: const Offset(0, 4))]
            : [],
      ),
      child: Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: TextField(
          controller: widget.controller,
          maxLines: 4,
          maxLength: 240,
          style: GoogleFonts.inter(color: cs.onSurface, fontSize: 14.5, height: 1.6),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.inter(
                color: cs.onSurface.withValues(alpha: 0.32), fontSize: 13.5, height: 1.5),
            contentPadding: const EdgeInsets.all(16),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            counterText: '',
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CONTACT GROUP  (WhatsApp / Instagram / Facebook — révélés après acceptation)
//  Une seule carte groupée, avec libellé au-dessus de chaque champ.
// ─────────────────────────────────────────────────────────────────────────────
class _ContactGroup extends StatelessWidget {
  final ColorScheme cs;
  final List<({IconData icon, Color color, String label, String hint,
      TextEditingController controller, TextInputType? keyboardType})> rows;
  const _ContactGroup({required this.cs, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline),
      ),
      child: Column(children: [
        for (int i = 0; i < rows.length; i++) ...[
          if (i > 0) Divider(height: 1, indent: 16, endIndent: 16, color: cs.outline.withValues(alpha: 0.6)),
          _ContactRow(row: rows[i], cs: cs),
        ],
      ]),
    );
  }
}

class _ContactRow extends StatefulWidget {
  final ({IconData icon, Color color, String label, String hint,
      TextEditingController controller, TextInputType? keyboardType}) row;
  final ColorScheme cs;
  const _ContactRow({required this.row, required this.cs});

  @override
  State<_ContactRow> createState() => _ContactRowState();
}

class _ContactRowState extends State<_ContactRow> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final r = widget.row;
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: r.color.withValues(alpha: _focused ? 0.22 : 0.14), shape: BoxShape.circle),
            child: Icon(r.icon, size: 15, color: r.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.label, style: GoogleFonts.inter(
                  fontSize: 10.5, fontWeight: FontWeight.w700,
                  color: _focused ? r.color : cs.onSurface.withValues(alpha: 0.45))),
                TextField(
                  controller: r.controller,
                  keyboardType: r.keyboardType,
                  style: GoogleFonts.inter(color: cs.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: r.hint,
                    hintStyle: GoogleFonts.inter(
                        color: cs.onSurface.withValues(alpha: 0.32), fontSize: 13.5),
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 3),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BOTTOM BAR
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends ConsumerWidget {
  final ColorScheme cs;
  final Color accent;
  final bool publishing;
  final bool isEditing;
  final VoidCallback onPublish;
  const _BottomBar({required this.cs, required this.accent, required this.publishing, required this.isEditing, required this.onPublish});

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
            color: publishing ? accent.withValues(alpha: 0.5) : accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: publishing ? [] : [BoxShadow(
              color: accent.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Center(
            child: publishing
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(isEditing ? 'Modifier' : l10n.communityPublishProfile,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    )),
          ),
        ),
      ),
    );
  }
}
