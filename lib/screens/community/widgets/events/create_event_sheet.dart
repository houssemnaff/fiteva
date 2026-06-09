// ignore_for_file: deprecated_member_use
import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS  (même palette que create_partner_sheet)
// ─────────────────────────────────────────────────────────────────────────────
abstract class _K {
  static const green     = Color(0xFF1C4D30);
  static const mint      = Color(0xFF7ABB98);
  static const mintBg    = Color(0xFFEAF3EC);
  static const surface   = Colors.white;
  static const ink       = Color(0xFF111110);
  static const inkMuted  = Color(0xFF6B7280);
  static const inkSubtle = Color(0xFFAAAAAA);
  static const divider   = Color(0xFFEEEEEC);
  static const chipBg    = Color(0xFFF4F4F3);
}

// ─────────────────────────────────────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
void showCreateEventSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (_) => const CreateEventSheet(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class CreateEventSheet extends ConsumerStatefulWidget {
  const CreateEventSheet({super.key});

  @override
  ConsumerState<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends ConsumerState<CreateEventSheet>
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
  late final Animation<double>   _slide;

  static const _types = [
    (icon: LucideIcons.footprints,   label: 'Running'),
    (icon: LucideIcons.dumbbell,     label: 'Muscu'),
    (icon: LucideIcons.wind,         label: 'Yoga'),
    (icon: LucideIcons.waves,        label: 'Natation'),
    (icon: LucideIcons.bike,         label: 'Vélo'),
    (icon: LucideIcons.plus,         label: 'Autre'),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _anim  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slide = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.forward();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _detailsCtrl.dispose();
    _scrollCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  // ── Publish ────────────────────────────────────────────────────────────────

  Future<void> _publish() async {
    if (_titleCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _publishing = true);
    final event = EventModel(
      id: 'ev_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      organizer: 'Moi',
      organizerAvatar: 'https://i.pravatar.cc/150?img=1',
      type: _types[_typeIndex].label.toLowerCase(),
      date: 'Sam 3 Mai',
      time: '06:30',
      location: _locationCtrl.text.trim(),
      maxSpots: _spots,
      joinedCount: 0,
      participantAvatars: [],
      imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=600&q=80',
    );
    await ref.read(eventsNotifierProvider.notifier).addEvent(event);
    if (!mounted) return;
    setState(() => _publishing = false);
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
          Text('Événement publié !',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottom  = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1), end: Offset.zero,
      ).animate(_slide),
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
                    _label('Type d\'activité'),
                    const SizedBox(height: 10),
                    _buildTypePicker(),
                    const SizedBox(height: 24),
                    _label('Titre'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _titleCtrl,
                      hint: 'Morning Run — Corniche Sousse',
                      icon: LucideIcons.type,
                    ),
                    const SizedBox(height: 24),
                    _label('Date & heure'),
                    const SizedBox(height: 10),
                    _buildDateTimeRow(),
                    const SizedBox(height: 24),
                    _label('Lieu'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _locationCtrl,
                      hint: 'Corniche, Sousse',
                      icon: LucideIcons.mapPin,
                    ),
                    const SizedBox(height: 24),
                    _label('Participants max'),
                    const SizedBox(height: 10),
                    _buildSpotsStepper(),
                    const SizedBox(height: 24),
                    _label('Description  (optionnel)'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _detailsCtrl,
                      hint: 'Équipement requis, niveau, consignes…',
                      icon: LucideIcons.alignLeft,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
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
            child: const Icon(LucideIcons.calendarPlus,
                color: _K.green, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Créer un événement',
                    style: GoogleFonts.outfit(
                      color: _K.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 2),
                Text('Invite la communauté à ta session',
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
              child: const Icon(LucideIcons.x,
                  size: 15, color: _K.inkMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ── Type picker ────────────────────────────────────────────────────────────

  Widget _buildTypePicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_types.length, (i) {
        final sel = _typeIndex == i;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _typeIndex = i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: sel ? _K.mintBg : _K.chipBg,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: sel ? _K.mint.withOpacity(0.6) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_types[i].icon,
                  size: 14,
                  color: sel ? _K.green : _K.inkSubtle),
              const SizedBox(width: 7),
              Text(_types[i].label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sel ? _K.green : _K.inkMuted,
                  )),
            ]),
          ),
        );
      }),
    );
  }

  // ── Date / time row ────────────────────────────────────────────────────────

  Widget _buildDateTimeRow() {
    return Row(children: [
      Expanded(child: _DateCard(
        label: 'Date',
        value: 'Sam 3 Mai',
        sub: '2025',
        icon: LucideIcons.calendarDays,
      )),
      const SizedBox(width: 10),
      Expanded(child: _DateCard(
        label: 'Heure',
        value: '06 : 30',
        sub: 'du matin',
        icon: LucideIcons.clock,
      )),
    ]);
  }

  // ── Spots stepper ──────────────────────────────────────────────────────────

  Widget _buildSpotsStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _K.chipBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _K.mintBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(LucideIcons.users, color: _K.green, size: 17),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Places disponibles',
                  style: GoogleFonts.inter(
                    fontSize: 10, color: _K.inkMuted,
                    fontWeight: FontWeight.w500,
                  )),
              Text('$_spots places',
                  style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: _K.ink, letterSpacing: -0.3,
                  )),
            ],
          ),
        ),
        _StepBtn(
          icon: LucideIcons.minus,
          onTap: () {
            if (_spots > 2) setState(() => _spots--);
            HapticFeedback.selectionClick();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('$_spots',
              style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w800, color: _K.green,
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

  // ── Visibility toggle ──────────────────────────────────────────────────────

  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _isPublic ? _K.mintBg : _K.chipBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPublic ? _K.mint.withOpacity(0.4) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _isPublic
                ? _K.green.withOpacity(0.1)
                : const Color(0xFFE8E8E6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _isPublic ? LucideIcons.globe : LucideIcons.lock,
            color: _isPublic ? _K.green : _K.inkMuted,
            size: 17,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isPublic ? 'Événement public' : 'Événement privé',
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: _isPublic ? _K.green : _K.ink,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                _isPublic
                    ? 'Visible par toute la communauté'
                    : 'Accessible uniquement sur invitation',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _isPublic ? _K.mint : _K.inkMuted),
              ),
            ],
          ),
        ),
        _Toggle(
          value: _isPublic,
          onChanged: (v) => setState(() => _isPublic = v),
        ),
      ]),
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
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: _K.chipBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text('Annuler',
                style: GoogleFonts.inter(
                  color: _K.inkMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: _publishing ? null : _publish,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: _publishing ? _K.mint : _K.green,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _publishing
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.send,
                              color: Colors.white, size: 15),
                          const SizedBox(width: 8),
                          Text('Publier l\'événement',
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
      ]),
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
//  DATE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _DateCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;

  const _DateCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _K.chipBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: _K.mintBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _K.green, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: _K.inkSubtle,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.outfit(
                    color: _K.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  )),
              Text(sub,
                  style: GoogleFonts.inter(
                      color: _K.inkSubtle, fontSize: 10)),
            ],
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TEXT FIELD
// ─────────────────────────────────────────────────────────────────────────────
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
          style: GoogleFonts.inter(color: _K.ink, fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.inter(
                color: _K.inkSubtle, fontSize: 13),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(widget.icon,
                  color: _focused ? _K.green : _K.inkSubtle,
                  size: 15),
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

// ─────────────────────────────────────────────────────────────────────────────
//  STEPPER BUTTON
// ─────────────────────────────────────────────────────────────────────────────
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
          color: _K.mintBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _K.green, size: 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TOGGLE SWITCH
// ─────────────────────────────────────────────────────────────────────────────
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
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 46, height: 26,
        decoration: BoxDecoration(
          color: value ? _K.green : const Color(0xFFDDDDDB),
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20, height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x22000000),
                    blurRadius: 4, offset: Offset(0, 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
