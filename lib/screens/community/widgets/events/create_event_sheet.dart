import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─── Design tokens ────────────────────────────────────────────
const _kGreen     = Color(0xFF1C4D30);
const _kMint      = Color(0xFF7ABB98);
const _kMintLight = Color(0xFFEAF3EC);
const _kBg        = Color(0xFFFEFEFE);
const _kSurface   = Colors.white;
const _kBorder    = Color(0xFFECECEC);
const _kText1     = Color(0xFF1A1A1A);
const _kText2     = Color(0xFF757575);
const _kText3     = Color(0xFFAAAAAA);

// ─── Entry point ──────────────────────────────────────────────
void showCreateEventSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (_) => const CreateEventSheet(),
  );
}

// ─── Main widget ──────────────────────────────────────────────
class CreateEventSheet extends StatefulWidget {
  const CreateEventSheet({super.key});

  @override
  State<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends State<CreateEventSheet>
    with SingleTickerProviderStateMixin {
  final _titleCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _detailsCtrl  = TextEditingController();
  final _scrollCtrl   = ScrollController();

  int  _typeIndex  = 0;
  int  _spots      = 12;
  bool _isPublic   = true;
  bool _publishing = false;

  late final AnimationController _anim;
  late final Animation<double>   _fade;

  static const _types = [
    (icon: Icons.directions_run_rounded,    label: 'Running'),
    (icon: Icons.fitness_center_rounded,    label: 'Muscu'),
    (icon: Icons.self_improvement_rounded,  label: 'Yoga'),
    (icon: Icons.pool_rounded,              label: 'Natation'),
    (icon: Icons.directions_bike_rounded,   label: 'Vélo'),
    (icon: Icons.add_rounded,               label: 'Autre'),
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _locationCtrl.dispose();
    _detailsCtrl.dispose(); _scrollCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    HapticFeedback.mediumImpact();
    setState(() => _publishing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _publishing = false);
    Navigator.of(context).pop();
    _showToast(context);
  }

  static void _showToast(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: _kBorder),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
        content: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: _kMintLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.checkCircle,
                color: _kGreen, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Événement publié !',
                    style: GoogleFonts.outfit(
                      color: _kText1, fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )),
                Text('La communauté peut désormais s\'inscrire.',
                    style: GoogleFonts.inter(
                        color: _kText2, fontSize: 11)),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06), end: Offset.zero,
        ).animate(_fade),
        child: Container(
          margin: EdgeInsets.only(bottom: bottom),
          decoration: const BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              _buildHero(),
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _sectionLabel('TYPE D\'ACTIVITÉ'),
                      const SizedBox(height: 12),
                      _buildTypePicker(),
                      const SizedBox(height: 20),
                      _sectionLabel('TITRE'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _titleCtrl,
                        hint: 'Morning Run — Corniche Sousse',
                        icon: LucideIcons.type,
                      ),
                      const SizedBox(height: 16),
                      _buildDateTimeRow(),
                      const SizedBox(height: 16),
                      _sectionLabel('LIEU'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _locationCtrl,
                        hint: 'Corniche, Sousse',
                        icon: LucideIcons.mapPin,
                      ),
                      const SizedBox(height: 16),
                      _sectionLabel('PLACES'),
                      const SizedBox(height: 8),
                      _buildSpotsStepper(),
                      const SizedBox(height: 16),
                      _sectionLabel('DESCRIPTION'),
                      const SizedBox(height: 8),
                      _Field(
                        controller: _detailsCtrl,
                        hint: 'Équipement requis, niveau, consignes...',
                        icon: LucideIcons.alignLeft,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      _buildVisibilityToggle(),
                      const SizedBox(height: 8),
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

  // ── Handle ────────────────────────────────────────────────
  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: _kBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  // ── Hero header ───────────────────────────────────────────
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NOUVEL ÉVÉNEMENT',
                  style: GoogleFonts.inter(
                    color: _kMint, fontSize: 9,
                    fontWeight: FontWeight.w700, letterSpacing: 3,
                  )),
              const SizedBox(height: 6),
              Text('Crée ta session,\ninvite la communauté',
                  style: GoogleFonts.outfit(
                    color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5, height: 1.1,
                  )),
            ],
          ),
        ),
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(LucideIcons.zap, color: Colors.white, size: 22),
        ),
      ]),
    );
  }

  // ── Type picker ───────────────────────────────────────────
  Widget _buildTypePicker() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: List.generate(_types.length, (i) {
        final sel = _typeIndex == i;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _typeIndex = i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? _kGreen : _kSurface,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                  color: sel ? _kGreen : _kBorder),
              boxShadow: sel
                  ? [BoxShadow(
                      color: _kGreen.withOpacity(0.2),
                      blurRadius: 8, offset: const Offset(0, 2))]
                  : [],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_types[i].icon,
                  size: 14,
                  color: sel ? _kMint : _kText2),
              const SizedBox(width: 7),
              Text(_types[i].label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : _kText2,
                  )),
            ]),
          ),
        );
      }),
    );
  }

  // ── Date / time row ───────────────────────────────────────
  Widget _buildDateTimeRow() {
    return Row(children: [
      Expanded(child: _DateCard(
        label: 'DATE', value: 'Sam 3 Mai', sub: '2025',
        icon: LucideIcons.calendarDays,
      )),
      const SizedBox(width: 10),
      Expanded(child: _DateCard(
        label: 'HEURE', value: '06:30', sub: 'du matin',
        icon: LucideIcons.clock,
      )),
    ]);
  }

  // ── Spots stepper ─────────────────────────────────────────
  Widget _buildSpotsStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: _kMintLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(LucideIcons.users, color: _kGreen, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Participants max', style: GoogleFonts.inter(
                fontSize: 10, color: _kText2,
                fontWeight: FontWeight.w500,
              )),
              Text('$_spots places', style: GoogleFonts.outfit(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: _kText1, letterSpacing: -0.3,
              )),
            ],
          ),
        ),
        // Stepper controls
        _StepBtn(
          icon: LucideIcons.minus,
          onTap: () {
            if (_spots > 2) setState(() => _spots--);
            HapticFeedback.selectionClick();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('$_spots', style: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w800, color: _kGreen,
          )),
        ),
        _StepBtn(
          icon: LucideIcons.plus,
          onTap: () {
            if (_spots < 100) setState(() => _spots++);
            HapticFeedback.selectionClick();
          },
        ),
      ]),
    );
  }

  // ── Visibility toggle ─────────────────────────────────────
  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: _isPublic ? _kMintLight : const Color(0xFFF4F4F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _isPublic ? LucideIcons.globe : LucideIcons.lock,
            color: _isPublic ? _kGreen : _kText2, size: 16,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isPublic ? 'Événement public' : 'Événement privé',
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: _kText1,
                  )),
              Text(
                _isPublic
                    ? 'Visible par toute la communauté'
                    : 'Accessible uniquement sur invitation',
                style: GoogleFonts.inter(fontSize: 11, color: _kText2),
              ),
            ],
          ),
        ),
        _Toggle(value: _isPublic,
            onChanged: (v) => setState(() => _isPublic = v)),
      ]),
    );
  }

  // ── Actions bar ───────────────────────────────────────────
  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Row(children: [
        // Cancel
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Text('Annuler', style: GoogleFonts.inter(
              color: _kText2, fontSize: 13,
              fontWeight: FontWeight.w600,
            )),
          ),
        ),
        const SizedBox(width: 10),
        // Publish
        Expanded(
          child: GestureDetector(
            onTap: _publishing ? null : _publish,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _kGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _publishing
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.send,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 8),
                          Text('Publier l\'événement',
                              style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              )),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Helper ────────────────────────────────────────────────
  static Widget _sectionLabel(String text) {
    return Row(children: [
      Container(width: 20, height: 2, color: _kMint),
      const SizedBox(width: 8),
      Text(text, style: GoogleFonts.inter(
        color: _kText2, fontSize: 9,
        fontWeight: FontWeight.w700, letterSpacing: 2,
      )),
    ]);
  }
}

// ─── Date Card ────────────────────────────────────────────────
class _DateCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  const _DateCard({
    required this.label, required this.value,
    required this.sub,   required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _kMintLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _kGreen, size: 15),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(
                color: _kText3, fontSize: 9,
                fontWeight: FontWeight.w700, letterSpacing: 1,
              )),
              Text(value, style: GoogleFonts.outfit(
                color: _kText1, fontSize: 15,
                fontWeight: FontWeight.w800, letterSpacing: -0.3,
              )),
              Text(sub, style: GoogleFonts.inter(
                  color: _kText3, fontSize: 10)),
            ],
          ),
        ]),
      ),
    );
  }
}

// ─── Field ────────────────────────────────────────────────────
class _Field extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _focused ? _kGreen.withOpacity(0.5) : _kBorder,
            width: _focused ? 1.5 : 1,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          style: GoogleFonts.inter(
            color: _kText1, fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.inter(
                color: _kText3, fontSize: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(widget.icon,
                  color: _focused ? _kGreen : _kText3, size: 15),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 44, minHeight: 0),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// ─── Stepper button ───────────────────────────────────────────
class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: _kMintLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kMint.withOpacity(0.3)),
        ),
        child: Icon(icon, color: _kGreen, size: 14),
      ),
    );
  }
}

// ─── Toggle switch ────────────────────────────────────────────
class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46, height: 26,
        decoration: BoxDecoration(
          color: value ? _kGreen : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20, height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}