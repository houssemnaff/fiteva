// ignore_for_file: deprecated_member_use
import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


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
    (icon: LucideIcons.footprints, label: 'Running'),
    (icon: LucideIcons.dumbbell,   label: 'Muscu'),
    (icon: LucideIcons.wind,       label: 'Yoga'),
    (icon: LucideIcons.waves,      label: 'Natation'),
    (icon: LucideIcons.bike,       label: 'Vélo'),
    (icon: LucideIcons.plus,       label: 'Autre'),
  ];

  @override
  void initState() {
    super.initState();
    _anim  = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
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
        Text('Événement publié !',
            style: GoogleFonts.inter(color: cs.onPrimary, fontWeight: FontWeight.w600)),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final bottom  = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(_slide),
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
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Type picker ──────────────────────────────
                    _SectionLabel(text: 'Type d\'activité', cs: cs),
                    const SizedBox(height: 10),
                    _TypePicker(
                      types: _types,
                      selectedIndex: _typeIndex,
                      cs: cs,
                      onSelect: (i) {
                        HapticFeedback.selectionClick();
                        setState(() => _typeIndex = i);
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Title ────────────────────────────────────
                    _SectionLabel(text: 'Titre', cs: cs),
                    const SizedBox(height: 8),
                    _BorderlessField(
                      controller: _titleCtrl,
                      hint: 'Morning Run — Corniche Sousse',
                      cs: cs,
                      style: GoogleFonts.outfit(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: cs.onSurface, height: 1.3),
                      hintStyle: GoogleFonts.outfit(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: cs.onSurface.withValues(alpha: 0.25), height: 1.3),
                      maxLines: 2,
                    ),
                    Divider(height: 24, color: cs.outline.withValues(alpha: 0.6)),

                    // ── Date & time ──────────────────────────────
                    _SectionLabel(text: 'Date & heure', cs: cs),
                    const SizedBox(height: 10),
                    _DateTimeRow(cs: cs),
                    const SizedBox(height: 24),

                    // ── Location ─────────────────────────────────
                    _SectionLabel(text: 'Lieu', cs: cs),
                    const SizedBox(height: 8),
                    _BorderlessField(
                      controller: _locationCtrl,
                      hint: 'Corniche, Sousse',
                      cs: cs,
                      style: GoogleFonts.inter(
                        fontSize: 15, color: cs.onSurface, height: 1.65),
                      hintStyle: GoogleFonts.inter(
                        fontSize: 15,
                        color: cs.onSurface.withValues(alpha: 0.3), height: 1.65),
                    ),
                    Divider(height: 24, color: cs.outline.withValues(alpha: 0.6)),

                    // ── Spots ────────────────────────────────────
                    _SectionLabel(text: 'Participants max', cs: cs),
                    const SizedBox(height: 10),
                    _SpotsStepper(
                      spots: _spots,
                      cs: cs,
                      onDecrement: () {
                        if (_spots > 2) setState(() => _spots--);
                        HapticFeedback.selectionClick();
                      },
                      onIncrement: () {
                        if (_spots < 100) setState(() => _spots++);
                        HapticFeedback.selectionClick();
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Description ──────────────────────────────
                    _SectionLabel(text: 'Description  (optionnel)', cs: cs),
                    const SizedBox(height: 8),
                    _BorderlessField(
                      controller: _detailsCtrl,
                      hint: 'Équipement requis, niveau, consignes…',
                      cs: cs,
                      style: GoogleFonts.inter(
                        fontSize: 15, color: cs.onSurface, height: 1.65),
                      hintStyle: GoogleFonts.inter(
                        fontSize: 15,
                        color: cs.onSurface.withValues(alpha: 0.3), height: 1.65),
                      maxLines: 4,
                    ),
                    Divider(height: 24, color: cs.outline.withValues(alpha: 0.6)),

                    // ── Visibility ───────────────────────────────
                    _VisibilityToggle(
                      isPublic: _isPublic,
                      cs: cs,
                      onChanged: (v) => setState(() => _isPublic = v),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _BottomBar(cs: cs, publishing: _publishing, onPublish: _publish),
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
class _TopBar extends StatelessWidget {
  final ColorScheme cs;
  final VoidCallback onClose;
  const _TopBar({required this.cs, required this.onClose});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 16, 16),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NOUVEL ÉVÉNEMENT', style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w700,
          color: cs.primary, letterSpacing: 2.5)),
        const SizedBox(height: 2),
        Text('Invite la communauté', style: GoogleFonts.outfit(
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
//  TYPE PICKER  (pill wrap, green when selected)
// ─────────────────────────────────────────────────────────────────────────────
class _TypePicker extends StatelessWidget {
  final List<({IconData icon, String label})> types;
  final int selectedIndex;
  final ColorScheme cs;
  final void Function(int) onSelect;
  const _TypePicker({
    required this.types, required this.selectedIndex,
    required this.cs, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: List.generate(types.length, (i) {
        final sel = selectedIndex == i;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: sel ? cs.primary : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: sel ? cs.primary : cs.outline,
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(types[i].icon,
                  size: 13,
                  color: sel ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 7),
              Text(types[i].label, style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: sel ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
              )),
            ]),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BORDERLESS FIELD  (editorial, no box)
// ─────────────────────────────────────────────────────────────────────────────
class _BorderlessField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ColorScheme cs;
  final TextStyle style, hintStyle;
  final int maxLines;
  const _BorderlessField({
    required this.controller, required this.hint,
    required this.cs, required this.style, required this.hintStyle,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: style,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: hintStyle,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DATE TIME ROW
// ─────────────────────────────────────────────────────────────────────────────
class _DateTimeRow extends StatelessWidget {
  final ColorScheme cs;
  const _DateTimeRow({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _DateCard(
        label: 'Date', value: 'Sam 3 Mai', sub: '2025',
        icon: LucideIcons.calendarDays, cs: cs,
      )),
      const SizedBox(width: 10),
      Expanded(child: _DateCard(
        label: 'Heure', value: '06 : 30', sub: 'du matin',
        icon: LucideIcons.clock, cs: cs,
      )),
    ]);
  }
}

class _DateCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final ColorScheme cs;
  const _DateCard({
    required this.label, required this.value, required this.sub,
    required this.icon, required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.primary, size: 15),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label.toUpperCase(), style: GoogleFonts.inter(
              color: cs.onSurface.withValues(alpha: 0.5),
              fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
            )),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.outfit(
              color: cs.onSurface, fontSize: 14,
              fontWeight: FontWeight.w800, letterSpacing: -0.3,
            )),
            Text(sub, style: GoogleFonts.inter(
              color: cs.onSurface.withValues(alpha: 0.5), fontSize: 10)),
          ]),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SPOTS STEPPER
// ─────────────────────────────────────────────────────────────────────────────
class _SpotsStepper extends StatelessWidget {
  final int spots;
  final ColorScheme cs;
  final VoidCallback onDecrement, onIncrement;
  const _SpotsStepper({
    required this.spots, required this.cs,
    required this.onDecrement, required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Row(children: [
        Icon(LucideIcons.users, color: cs.primary, size: 17),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Places disponibles', style: GoogleFonts.inter(
              fontSize: 10, color: cs.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            )),
            Text('$spots places', style: GoogleFonts.outfit(
              fontSize: 16, fontWeight: FontWeight.w800,
              color: cs.onSurface, letterSpacing: -0.3,
            )),
          ]),
        ),
        _StepBtn(icon: LucideIcons.minus, onTap: onDecrement, cs: cs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('$spots', style: GoogleFonts.outfit(
            fontSize: 18, fontWeight: FontWeight.w800, color: cs.primary,
          )),
        ),
        _StepBtn(icon: LucideIcons.plus, onTap: onIncrement, cs: cs),
      ]),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _StepBtn({required this.icon, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: cs.primary, size: 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  VISIBILITY TOGGLE
// ─────────────────────────────────────────────────────────────────────────────
class _VisibilityToggle extends StatelessWidget {
  final bool isPublic;
  final ColorScheme cs;
  final ValueChanged<bool> onChanged;
  const _VisibilityToggle({
    required this.isPublic, required this.cs, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isPublic
            ? cs.primary.withValues(alpha: 0.06)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPublic ? cs.primary.withValues(alpha: 0.3) : cs.outline,
        ),
      ),
      child: Row(children: [
        Icon(
          isPublic ? LucideIcons.globe : LucideIcons.lock,
          color: isPublic ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
          size: 17,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              isPublic ? 'Événement public' : 'Événement privé',
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: isPublic ? cs.primary : cs.onSurface,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              isPublic
                  ? 'Visible par toute la communauté'
                  : 'Accessible uniquement sur invitation',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.5)),
            ),
          ]),
        ),
        _Toggle(value: isPublic, onChanged: onChanged, cs: cs),
      ]),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final ColorScheme cs;
  const _Toggle({required this.value, required this.onChanged, required this.cs});

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
          color: value ? cs.primary : cs.outline.withValues(alpha: 0.3),
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
              boxShadow: [BoxShadow(
                color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BOTTOM BAR
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final ColorScheme cs;
  final bool publishing;
  final VoidCallback onPublish;
  const _BottomBar({required this.cs, required this.publishing, required this.onPublish});

  @override
  Widget build(BuildContext context) {
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
                : Text('Publier l\'événement',
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
