import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────
//  DESIGN TOKENS  (partagés avec le reste de l'app)
// ─────────────────────────────────────────────
class _C {
  static const bg            = Colors.white;
  static const surface       = Colors.white;
  static const card          = Colors.white;
  static const cardHigh      = Colors.white;
  static const border        = Colors.white;
  static const borderHigh    = Colors.white;

  // Rose-corail — identité féminine fitness premium
  static const accent        = Colors.white;
  static const accentDim     = Color(0xFF1C4D30);
  static const accentSoft    = Color(0xFF1C4D30);

  static const textPrimary   = Colors.white;
  static const textSecondary = Color(0xFF8A8A96);
  static const textTertiary  = Color(0xFF4A4A54);

  static const success       = Color(0xFF3DCC7A);
  static const successDim    = Color(0x1A3DCC7A);
}

// ─────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────
void showCreatePartnerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.red,
    barrierColor: Colors.red,
    builder: (_) => const CreatePartnerSheet(),
  );
}

// ─────────────────────────────────────────────
//  MAIN WIDGET
// ─────────────────────────────────────────────
class CreatePartnerSheet extends StatefulWidget {
  const CreatePartnerSheet({super.key});

  @override
  State<CreatePartnerSheet> createState() => _CreatePartnerSheetState();
}

class _CreatePartnerSheetState extends State<CreatePartnerSheet>
    with SingleTickerProviderStateMixin {
  final _descCtrl   = TextEditingController();
  final _scrollCtrl = ScrollController();

  String _selectedGoal   = 'Tonifier';
  String _selectedLevel  = 'Intermédiaire';
  String _selectedRegion = 'Sousse';
  String _selectedFreq   = '3x/semaine';
  bool   _isPublishing   = false;

  late final AnimationController _enterCtrl;
  late final Animation<double>   _enterAnim;

  // ── Data ──────────────────────────────────
  static const _goals = [
    _Chip('Perdre du poids', LucideIcons.flame),
    _Chip('Tonifier',        LucideIcons.zap),
    _Chip('Prise de masse',  LucideIcons.dumbbell),
    _Chip('Bien-être',       LucideIcons.heart),
  ];

  static const _levels = [
    _Level('Débutant',      Color(0xFF3DCC7A)),
    _Level('Intermédiaire', Color(0xFFFFAA00)),
    _Level('Avancé',        Color(0xFFFF6B8A)),
  ];

  static const _regions = [
    'Sousse', 'Monastir', 'Tunis', 'Sfax', 'Autre',
  ];

  static const _freqs = [
    _Freq('1x / sem', LucideIcons.sun),
    _Freq('2x / sem', LucideIcons.repeat),
    _Freq('3x / sem', LucideIcons.zap),
    _Freq('5x / sem', LucideIcons.flame),
  ];

  // ── Lifecycle ─────────────────────────────
  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _enterAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _scrollCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  // ── Publish ───────────────────────────────
  Future<void> _publish() async {
    HapticFeedback.mediumImpact();
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() => _isPublishing = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _C.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _C.border),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _C.successDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.checkCircle,
                  color: _C.success, size: 16),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Annonce publiée',
                      style: TextStyle(
                          color: _C.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text('Les partenaires peuvent maintenant te contacter.',
                      style: TextStyle(color: _C.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _enterAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_enterAnim),
        child: Container(
          margin: EdgeInsets.only(bottom: bottom),
          decoration: const BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Objectif
                      _sectionLabel('Objectif'),
                      const SizedBox(height: 10),
                      _buildGoalPicker(),

                      const SizedBox(height: 22),

                      // Niveau
                      _sectionLabel('Niveau'),
                      const SizedBox(height: 10),
                      _buildLevelPicker(),

                      const SizedBox(height: 22),

                      // Fréquence
                      _sectionLabel('Fréquence d\'entraînement'),
                      const SizedBox(height: 10),
                      _buildFreqPicker(),

                      const SizedBox(height: 22),

                      // Région
                      _sectionLabel('Région'),
                      const SizedBox(height: 10),
                      _buildRegionPicker(),

                      const SizedBox(height: 22),

                      // Description
                      _sectionLabel('À propos de toi'),
                      const SizedBox(height: 10),
                      _buildDescField(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon badge
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _C.accentDim,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _C.accent.withOpacity(0.25), width: 0.5),
                ),
                child: const Icon(LucideIcons.users,
                    color: _C.accent, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Trouver un partenaire',
                      style: TextStyle(
                        color: _C.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Décris ton profil pour trouver le match parfait',
                      style: TextStyle(color: _C.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Goal Picker ───────────────────────────
  Widget _buildGoalPicker() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3.0,
      children: _goals.map((g) {
        final selected = _selectedGoal == g.label;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedGoal = g.label);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: selected ? _C.accentDim : _C.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? _C.accent.withOpacity(0.5) : _C.border,
                width: selected ? 1 : 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(g.icon,
                    size: 14,
                    color: selected ? _C.accent : _C.textTertiary),
                const SizedBox(width: 8),
                Text(
                  g.label,
                  style: TextStyle(
                    color: selected ? _C.accent : _C.textSecondary,
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Level Picker ──────────────────────────
  Widget _buildLevelPicker() {
    return Row(
      children: _levels.map((lvl) {
        final selected = _selectedLevel == lvl.label;
        final idx = _levels.indexOf(lvl);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: idx < _levels.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedLevel = lvl.label);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: selected
                      ? lvl.color.withOpacity(0.1)
                      : _C.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? lvl.color.withOpacity(0.45)
                        : _C.border,
                    width: selected ? 1 : 0.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: lvl.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lvl.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? lvl.color : _C.textSecondary,
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Frequency Picker ──────────────────────
  Widget _buildFreqPicker() {
    return Row(
      children: _freqs.map((f) {
        final selected = _selectedFreq == f.label;
        final idx = _freqs.indexOf(f);
        return Expanded(
          child: Padding(
            padding:
                EdgeInsets.only(right: idx < _freqs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFreq = f.label);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? _C.accentDim : _C.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? _C.accent.withOpacity(0.5)
                        : _C.border,
                    width: selected ? 1 : 0.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(f.icon,
                        size: 15,
                        color: selected ? _C.accent : _C.textTertiary),
                    const SizedBox(height: 5),
                    Text(
                      f.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? _C.accent : _C.textSecondary,
                        fontSize: 10,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Region Picker ─────────────────────────
  Widget _buildRegionPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _regions.map((r) {
        final selected = _selectedRegion == r;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedRegion = r);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? _C.accentDim : _C.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? _C.accent.withOpacity(0.5)
                    : _C.border,
                width: selected ? 1 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(LucideIcons.mapPin,
                      size: 11, color: _C.accent),
                  const SizedBox(width: 5),
                ],
                Text(
                  r,
                  style: TextStyle(
                    color: selected ? _C.accent : _C.textSecondary,
                    fontSize: 13,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Description Field ─────────────────────
  Widget _buildDescField() {
    return _FocusTextField(
      controller: _descCtrl,
      hint:
          'Je cherche une partenaire pour salle 3x/semaine à Sousse, niveau intermédiaire...',
      maxLines: 4,
    );
  }

  // ── Actions ───────────────────────────────
  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _C.border, width: 0.5)),
        color: _C.surface,
      ),
      child: Row(
        children: [
          // Cancel
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 14),
              decoration: BoxDecoration(
                color: _C.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border, width: 0.5),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: _C.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Publish
          Expanded(
            child: GestureDetector(
              onTap: _isPublishing ? null : _publish,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _C.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isPublishing
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(LucideIcons.sparkles,
                                size: 15, color:Color(0xFF1C4D30),),
                            SizedBox(width: 8),
                            Text(
                              'Publier mon profil',
                              style: TextStyle(
                                color: Color(0xFF1C4D30),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────
  static Widget _sectionLabel(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: _C.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
        ),
      );
}

// ─────────────────────────────────────────────
//  FOCUS TEXT FIELD
// ─────────────────────────────────────────────
class _FocusTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _FocusTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  State<_FocusTextField> createState() => _FocusTextFieldState();
}

class _FocusTextFieldState extends State<_FocusTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused
                ? _C.accent.withOpacity(0.45)
                : _C.border,
            width: _focused ? 1 : 0.5,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          style: const TextStyle(
            color: _C.textPrimary,
            fontSize: 14,
            height: 1.55,
            letterSpacing: -0.1,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
                color: _C.textTertiary, fontSize: 13, height: 1.5),
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

// ─────────────────────────────────────────────
//  DATA MODELS  (privés au fichier)
// ─────────────────────────────────────────────
class _Chip {
  final String label;
  final IconData icon;
  const _Chip(this.label, this.icon);
}

class _Level {
  final String label;
  final Color color;
  const _Level(this.label, this.color);
}

class _Freq {
  final String label;
  final IconData icon;
  const _Freq(this.label, this.icon);
}