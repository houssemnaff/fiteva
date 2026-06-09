// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
abstract class _K {
  static const green      = Color(0xFF1C4D30);
  static const mint       = Color(0xFF7ABB98);
  static const mintBg     = Color(0xFFEAF3EC);
  static const surface    = Colors.white;
  static const ink        = Color(0xFF111110);
  static const inkMuted   = Color(0xFF6B7280);
  static const inkSubtle  = Color(0xFFAAAAAA);
  static const divider    = Color(0xFFEEEEEC);
  static const chipBg     = Color(0xFFF4F4F3);
}

// ─────────────────────────────────────────────────────────────────────────────
//  ENTRY POINT
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
//  MAIN WIDGET
// ─────────────────────────────────────────────────────────────────────────────
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
  String _selectedFreq   = '3x / sem';
  bool   _isPublishing   = false;

  late final AnimationController _enterCtrl;
  late final Animation<double>   _enterAnim;

  // ── Data ──────────────────────────────────────────────────────────────────

  static const _goals = [
    (label: 'Perdre du poids', icon: LucideIcons.flame,    color: Color(0xFFFF6B6B)),
    (label: 'Tonifier',        icon: LucideIcons.zap,      color: Color(0xFFFFA500)),
    (label: 'Prise de masse',  icon: LucideIcons.dumbbell, color: Color(0xFF7ABB98)),
    (label: 'Bien-être',       icon: LucideIcons.heart,    color: Color(0xFF9B7FC7)),
  ];

  static const _levels = [
    (label: 'Débutant',       dot: Color(0xFF7ABB98)),
    (label: 'Intermédiaire',  dot: Color(0xFFFFA500)),
    (label: 'Avancé',         dot: Color(0xFFFF6B6B)),
  ];

  static const _regions = ['Sousse', 'Monastir', 'Tunis', 'Sfax', 'Autre'];

  static const _freqs = [
    (label: '1x / sem', icon: LucideIcons.sun),
    (label: '2x / sem', icon: LucideIcons.repeat),
    (label: '3x / sem', icon: LucideIcons.zap),
    (label: '5x / sem', icon: LucideIcons.flame),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _enterAnim =
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic);
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _scrollCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  // ── Publish ────────────────────────────────────────────────────────────────

  Future<void> _publish() async {
    HapticFeedback.mediumImpact();
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isPublishing = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _K.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
        content: Row(children: [
          const Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text('Profil publié !',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_enterAnim),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.92),
        decoration: const BoxDecoration(
          color: _K.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            const Divider(color: _K.divider, height: 1),
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Objectif'),
                    const SizedBox(height: 10),
                    _buildGoalGrid(),
                    const SizedBox(height: 24),
                    _label('Niveau'),
                    const SizedBox(height: 10),
                    _buildLevelRow(),
                    const SizedBox(height: 24),
                    _label('Fréquence'),
                    const SizedBox(height: 10),
                    _buildFreqRow(),
                    const SizedBox(height: 24),
                    _label('Région'),
                    const SizedBox(height: 10),
                    _buildRegionWrap(),
                    const SizedBox(height: 24),
                    _label('À propos de toi  (optionnel)'),
                    const SizedBox(height: 10),
                    _buildDescField(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  // ── Handle ─────────────────────────────────────────────────────────────────

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: _K.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _K.mintBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.users, color: _K.green, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trouver un partenaire',
                    style: GoogleFonts.outfit(
                      color: _K.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 2),
                Text('Décris ton profil pour trouver le match parfait',
                    style: GoogleFonts.inter(
                        color: _K.inkMuted, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _K.chipBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.x, size: 15, color: _K.inkMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ── Goal 2×2 grid ──────────────────────────────────────────────────────────

  Widget _buildGoalGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: _goals.map((g) {
        final sel = _selectedGoal == g.label;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedGoal = g.label);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: sel ? g.color.withOpacity(0.1) : _K.chipBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? g.color.withOpacity(0.6) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(g.icon,
                    size: 15,
                    color: sel ? g.color : _K.inkSubtle),
                const SizedBox(width: 7),
                Text(g.label,
                    style: GoogleFonts.inter(
                      color: sel ? g.color : _K.inkMuted,
                      fontSize: 12,
                      fontWeight:
                          sel ? FontWeight.w600 : FontWeight.w400,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Level row ──────────────────────────────────────────────────────────────

  Widget _buildLevelRow() {
    return Row(
      children: _levels.asMap().entries.map((e) {
        final lvl = e.value;
        final sel = _selectedLevel == lvl.label;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < _levels.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedLevel = lvl.label);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: sel ? lvl.dot.withOpacity(0.1) : _K.chipBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? lvl.dot.withOpacity(0.6) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                          color: lvl.dot, shape: BoxShape.circle),
                    ),
                    const SizedBox(height: 6),
                    Text(lvl.label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: sel ? lvl.dot : _K.inkMuted,
                          fontSize: 11,
                          fontWeight:
                              sel ? FontWeight.w600 : FontWeight.w400,
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Frequency row ──────────────────────────────────────────────────────────

  Widget _buildFreqRow() {
    return Row(
      children: _freqs.asMap().entries.map((e) {
        final f = e.value;
        final sel = _selectedFreq == f.label;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < _freqs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFreq = f.label);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: sel ? _K.mintBg : _K.chipBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? _K.mint.withOpacity(0.6) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(f.icon,
                        size: 15,
                        color: sel ? _K.green : _K.inkSubtle),
                    const SizedBox(height: 5),
                    Text(f.label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: sel ? _K.green : _K.inkMuted,
                          fontSize: 10,
                          fontWeight:
                              sel ? FontWeight.w700 : FontWeight.w400,
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Region wrap ────────────────────────────────────────────────────────────

  Widget _buildRegionWrap() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _regions.map((r) {
        final sel = _selectedRegion == r;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedRegion = r);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? _K.mintBg : _K.chipBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: sel ? _K.mint.withOpacity(0.7) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sel) ...[
                  const Icon(LucideIcons.mapPin,
                      size: 11, color: _K.green),
                  const SizedBox(width: 5),
                ],
                Text(r,
                    style: GoogleFonts.inter(
                      color: sel ? _K.green : _K.inkMuted,
                      fontSize: 13,
                      fontWeight:
                          sel ? FontWeight.w600 : FontWeight.w400,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Description field ──────────────────────────────────────────────────────

  Widget _buildDescField() {
    return _FocusField(
      controller: _descCtrl,
      hint: 'Je cherche une partenaire pour salle 3x/semaine à Sousse…',
      maxLines: 4,
    );
  }

  // ── Actions bar ────────────────────────────────────────────────────────────

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: _K.surface,
        border: Border(top: BorderSide(color: _K.divider)),
      ),
      child: Row(
        children: [
          // Cancel
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: _K.chipBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Annuler',
                  style: GoogleFonts.inter(
                      color: _K.inkMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
          ),

          const SizedBox(width: 10),

          // Publish
          Expanded(
            child: GestureDetector(
              onTap: _isPublishing ? null : _publish,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _isPublishing ? _K.mint : _K.green,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _isPublishing
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.sparkles,
                                size: 15, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Publier mon profil',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                )),
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

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(
          color: _K.inkMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  FOCUS TEXT FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _FocusField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _FocusField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  State<_FocusField> createState() => _FocusFieldState();
}

class _FocusFieldState extends State<_FocusField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _focused ? Colors.white : _K.chipBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused ? _K.mint : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: _focused
              ? [BoxShadow(
                  color: _K.mint.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2))]
              : [],
        ),
        child: TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          style: GoogleFonts.inter(
              color: _K.ink, fontSize: 14, height: 1.55),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.inter(
                color: _K.inkSubtle, fontSize: 13, height: 1.5),
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
