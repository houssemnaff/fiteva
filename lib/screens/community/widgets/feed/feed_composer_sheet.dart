// ignore_for_file: deprecated_member_use
import 'package:fiteva/models/post_model.dart';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DESIGN TOKENS  (cohérents avec les autres sheets)
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
//  MAIN WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class FeedComposerSheet extends ConsumerStatefulWidget {
  const FeedComposerSheet({super.key});

  @override
  ConsumerState<FeedComposerSheet> createState() => _FeedComposerSheetState();
}

class _FeedComposerSheetState extends ConsumerState<FeedComposerSheet>
    with SingleTickerProviderStateMixin {

  final _titleCtrl = TextEditingController();
  final _textCtrl  = TextEditingController();

  String _selectedType = 'Texte';
  bool   _publishing   = false;

  late final AnimationController _anim;
  late final Animation<double>   _slide;

  static const _types = [
    (label: 'Texte',       icon: LucideIcons.alignLeft),
    (label: 'Photo',       icon: LucideIcons.image),
    (label: 'Avant/Après', icon: LucideIcons.arrowLeftRight),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _anim  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _slide = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.forward();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _textCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  // ── Publish ────────────────────────────────────────────────────────────────

  Future<void> _publish() async {
    final content = _textCtrl.text.trim();
    if (content.isEmpty && _titleCtrl.text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _publishing = true);
    final post = PostModel(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      username: 'Moi',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=1',
      content: [
        if (_titleCtrl.text.trim().isNotEmpty) _titleCtrl.text.trim(),
        if (content.isNotEmpty) content,
      ].join('\n'),
      imageUrl: '',
      likes: 0,
      comments: 0,
      timeAgo: 'À l\'instant',
      category: _selectedType == 'Texte' ? '' : _selectedType,
    );
    await ref.read(postsNotifierProvider.notifier).addPost(post);
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
          Text('Post publié !',
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
                padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Type picker ──────────────────────────────────────
                    _label('Type de post'),
                    const SizedBox(height: 10),
                    _buildTypePicker(),
                    const SizedBox(height: 24),

                    // ── Titre ────────────────────────────────────────────
                    _label('Titre'),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _titleCtrl,
                      hint: 'Day 5 challenge FitEva 💪',
                      icon: LucideIcons.type,
                    ),
                    const SizedBox(height: 24),

                    // ── Contenu ──────────────────────────────────────────
                    _label(_contentLabel),
                    const SizedBox(height: 8),
                    _Field(
                      controller: _textCtrl,
                      hint: 'Partage quelque chose d\'inspirant…',
                      icon: LucideIcons.alignLeft,
                      maxLines: 5,
                    ),

                    // ── Photo upload (si Photo ou Avant/Après) ───────────
                    if (_selectedType != 'Texte') ...[
                      const SizedBox(height: 16),
                      _buildPhotoZone(),
                    ],

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

  String get _contentLabel {
    switch (_selectedType) {
      case 'Photo':       return 'Légende';
      case 'Avant/Après': return 'Décris ta transformation';
      default:            return 'Contenu';
    }
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
            child: const Icon(LucideIcons.penLine,
                color: _K.green, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nouveau post',
                    style: GoogleFonts.outfit(
                      color: _K.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 2),
                Text('Partage ta progression avec la communauté',
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
    return Row(
      children: _types.asMap().entries.map((e) {
        final t   = e.value;
        final sel = _selectedType == t.label;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: e.key < _types.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedType = t.label);
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
                    Icon(t.icon,
                        size: 18,
                        color: sel ? _K.green : _K.inkSubtle),
                    const SizedBox(height: 6),
                    Text(t.label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: sel
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: sel ? _K.green : _K.inkMuted,
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

  // ── Photo upload zone ──────────────────────────────────────────────────────

  Widget _buildPhotoZone() {
    final isBeforeAfter = _selectedType == 'Avant/Après';

    if (isBeforeAfter) {
      return Row(
        children: [
          Expanded(child: _PhotoSlot(label: 'Avant')),
          const SizedBox(width: 10),
          Expanded(child: _PhotoSlot(label: 'Après')),
        ],
      );
    }

    return _PhotoSlot(label: 'Ajouter une photo');
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
                          Text('Publier',
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

  // ── Label ──────────────────────────────────────────────────────────────────

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
          style: GoogleFonts.inter(color: _K.ink, fontSize: 14, height: 1.55),
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
//  PHOTO SLOT
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoSlot extends StatelessWidget {
  final String label;
  const _PhotoSlot({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: _K.chipBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _K.mint.withOpacity(0.35),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _K.mintBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.imagePlus,
                  color: _K.green, size: 18),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.inter(
                  color: _K.inkMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}
