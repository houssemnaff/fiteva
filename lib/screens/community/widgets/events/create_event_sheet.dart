// ignore_for_file: deprecated_member_use
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/screens/community/widgets/community_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../l10n/app_localizations.dart';


// ─────────────────────────────────────────────────────────────────────────────
/// Si [event] est fourni, la sheet s'ouvre en mode édition.
void showCreateEventSheet(BuildContext context, {EventModel? event}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.45),
    builder: (_) => CreateEventSheet(event: event),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class CreateEventSheet extends ConsumerStatefulWidget {
  /// Si [event] est fourni, la sheet s'ouvre en mode édition.
  final EventModel? event;
  const CreateEventSheet({super.key, this.event});

  @override
  ConsumerState<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends ConsumerState<CreateEventSheet>
    with SingleTickerProviderStateMixin {

  final _titleCtrl     = TextEditingController();
  final _locationCtrl  = TextEditingController();
  final _detailsCtrl   = TextEditingController();
  final _whatsappCtrl  = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _facebookCtrl  = TextEditingController();
  final _scrollCtrl    = ScrollController();

  int       _typeIndex    = 0;
  int       _spots        = 12;
  bool      _isPublic     = true;
  bool      _publishing   = false;
  DateTime  _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  late final AnimationController _anim;
  late final Animation<double>   _slide;

  bool get _isEditing => widget.event != null;

  /// Le nombre de places ne peut jamais être réduit sous le nombre
  /// de participants déjà inscrits.
  int get _minSpots => widget.event?.joinedCount ?? 2;

  // label → Supabase enum value
  static const _types = [
    (icon: LucideIcons.footprints, label: 'Running',  value: 'running'),
    (icon: LucideIcons.dumbbell,   label: 'Muscu',    value: 'gym'),
    (icon: LucideIcons.wind,       label: 'Yoga',     value: 'yoga'),
    (icon: LucideIcons.waves,      label: 'Natation', value: 'swimming'),
    (icon: LucideIcons.bike,       label: 'Vélo',     value: 'cycling'),
    (icon: LucideIcons.plus,       label: 'Autre',    value: 'other'),
  ];

  @override
  void initState() {
    super.initState();
    _anim  = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slide = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.forward();

    // Pré-remplissage en mode édition.
    final ev = widget.event;
    if (ev != null) {
      _titleCtrl.text = ev.title;
      _locationCtrl.text = ev.location;
      _detailsCtrl.text = ev.description;
      _whatsappCtrl.text = ev.contactWhatsapp;
      _instagramCtrl.text = ev.contactInstagram;
      _facebookCtrl.text = ev.contactFacebook;
      _spots = ev.maxSpots;
      final idx = _types.indexWhere((t) => t.value == ev.type);
      _typeIndex = idx >= 0 ? idx : 0;
      final parsedDate = DateTime.tryParse(ev.dateIso);
      if (parsedDate != null) _selectedDate = parsedDate;
      final timeParts = ev.time.split(':');
      if (timeParts.length == 2) {
        final h = int.tryParse(timeParts[0]);
        final m = int.tryParse(timeParts[1]);
        if (h != null && m != null) _selectedTime = TimeOfDay(hour: h, minute: m);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _detailsCtrl.dispose();
    _whatsappCtrl.dispose();
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _scrollCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  String _resolvedName() {
    final profile = ref.read(userProfileProvider);
    final user    = ref.read(userProfileProvider);
    return profile.username.isNotEmpty ? profile.username : user.username;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String get _displayDate {
    const months = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];
    const days   = ['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'];
    return '${days[_selectedDate.weekday - 1]} ${_selectedDate.day} ${months[_selectedDate.month - 1]}';
  }

  String get _displayTime {
    final h = _selectedTime.hour.toString().padLeft(2, '0');
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get _isoDate =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2,'0')}-${_selectedDate.day.toString().padLeft(2,'0')}';

  Future<void> _publish() async {
    if (_titleCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) return;
    final eventDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );
    if (eventDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La date et l\'heure de l\'événement doivent être dans le futur.'),
      ));
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _publishing = true);

    bool ok;
    if (_isEditing) {
      final updated = widget.event!.copyWith(
        title:              _titleCtrl.text.trim(),
        type:               _types[_typeIndex].value,
        dateIso:            _isoDate,
        time:               _displayTime,
        location:           _locationCtrl.text.trim(),
        maxSpots:           _spots,
        description:        _detailsCtrl.text.trim(),
        contactWhatsapp:    _whatsappCtrl.text.trim(),
        contactInstagram:   _instagramCtrl.text.trim(),
        contactFacebook:    _facebookCtrl.text.trim(),
      );
      ok = await ref.read(eventsNotifierProvider.notifier).updateEvent(updated);
    } else {
      final event = EventModel(
        id:                 '',
        title:              _titleCtrl.text.trim(),
        organizer:          _resolvedName(),
        organizerAvatar:    '',
        type:               _types[_typeIndex].value,
        date:               _isoDate,        // ISO for Supabase; service converts to display
        dateIso:            _isoDate,
        time:               _displayTime,
        location:           _locationCtrl.text.trim(),
        maxSpots:           _spots,
        joinedCount:        0,
        participantAvatars: [],
        imageUrl:           '',
        description:        _detailsCtrl.text.trim(),
        contactWhatsapp:    _whatsappCtrl.text.trim(),
        contactInstagram:   _instagramCtrl.text.trim(),
        contactFacebook:    _facebookCtrl.text.trim(),
      );
      ok = await ref.read(eventsNotifierProvider.notifier).addEvent(event);
    }

    if (!mounted) return;
    setState(() => _publishing = false);
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
          Expanded(child: Text(
            _isEditing
                ? 'Erreur lors de la modification. Vérifiez le nombre de places ou votre connexion.'
                : 'Erreur lors de la création. Vérifiez votre connexion.',
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
          _isEditing ? 'Événement modifié avec succès !' : ref.read(l10nProvider).communityEventPublished,
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
            _TopBar(cs: cs, isEditing: _isEditing, onClose: () => Navigator.of(context).pop()),

            // ── Posting as ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(children: [
                CommunityAvatar(
                  avatarUrl: '',
                  name: _resolvedName(),
                  radius: 18,
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_resolvedName(), style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: cs.onSurface, letterSpacing: -0.2)),
                  Text(l10n.communityOrganizeEvent, style: GoogleFonts.inter(
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
                    _DateTimeRow(
                      cs:          cs,
                      dateLabel:   _displayDate,
                      dateYear:    '${_selectedDate.year}',
                      timeLabel:   _displayTime,
                      onDateTap:   _pickDate,
                      onTimeTap:   _pickTime,
                    ),
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
                        if (_spots > _minSpots) {
                          setState(() => _spots--);
                          HapticFeedback.selectionClick();
                        } else if (_isEditing) {
                          HapticFeedback.heavyImpact();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                              'Impossible de réduire sous le nombre de participants déjà inscrits (${widget.event!.joinedCount}).'),
                          ));
                        }
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

                    // ── Contact organisateur ─────────────────────
                    _SectionLabel(text: l10n.communityEventContactOptional, cs: cs),
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
                    const SizedBox(height: 24),

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
            _BottomBar(cs: cs, publishing: _publishing, isEditing: _isEditing, onPublish: _publish),
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
  final bool isEditing;
  final VoidCallback onClose;
  const _TopBar({required this.cs, required this.isEditing, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    return Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 16, 16),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isEditing ? 'MODIFIER' : l10n.communityNewEvent, style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w700,
          color: cs.primary, letterSpacing: 2.5)),
        const SizedBox(height: 2),
        Text(isEditing ? 'Modifier l\'événement' : l10n.communityInvite, style: GoogleFonts.outfit(
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
//  TYPE PICKER  (pill wrap, green when selected)
// ─────────────────────────────────────────────────────────────────────────────
class _TypePicker extends StatelessWidget {
  final List<({IconData icon, String label, String value})> types;
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
  final String dateLabel;
  final String dateYear;
  final String timeLabel;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  const _DateTimeRow({
    required this.cs,
    required this.dateLabel,
    required this.dateYear,
    required this.timeLabel,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _DateCard(
        label: 'Date', value: dateLabel, sub: dateYear,
        icon: LucideIcons.calendarDays, cs: cs, onTap: onDateTap,
      )),
      const SizedBox(width: 10),
      Expanded(child: _DateCard(
        label: 'Heure', value: timeLabel, sub: '',
        icon: LucideIcons.clock, cs: cs, onTap: onTimeTap,
      )),
    ]);
  }
}

class _DateCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final ColorScheme cs;
  final VoidCallback onTap;
  const _DateCard({
    required this.label, required this.value, required this.sub,
    required this.icon, required this.cs, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
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
class _SpotsStepper extends ConsumerWidget {
  final int spots;
  final ColorScheme cs;
  final VoidCallback onDecrement, onIncrement;
  const _SpotsStepper({
    required this.spots, required this.cs,
    required this.onDecrement, required this.onIncrement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
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
            Text(l10n.communityAvailableSpots, style: GoogleFonts.inter(
              fontSize: 10, color: cs.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            )),
            Text(l10n.communityPlaces(spots), style: GoogleFonts.outfit(
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
    final cs        = Theme.of(context).colorScheme;
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
//  CONTACT GROUP  (WhatsApp / Instagram / Facebook — même pattern que partenaire)
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
  final bool publishing;
  final bool isEditing;
  final VoidCallback onPublish;
  const _BottomBar({required this.cs, required this.publishing, required this.isEditing, required this.onPublish});

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
                : Text(isEditing ? 'Modifier' : l10n.communityPublishEvent,
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
