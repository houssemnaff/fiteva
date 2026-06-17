// ignore_for_file: deprecated_member_use
import 'package:fiteva/models/post_model.dart';
import 'package:fiteva/providers/mock_data_provider.dart';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
class FeedComposerSheet extends ConsumerStatefulWidget {
  const FeedComposerSheet({super.key});

  @override
  ConsumerState<FeedComposerSheet> createState() => _FeedComposerSheetState();
}

class _FeedComposerSheetState extends ConsumerState<FeedComposerSheet>
    with SingleTickerProviderStateMixin {

  final _titleCtrl   = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _titleFocus  = FocusNode();
  final _contentFocus = FocusNode();

  String _type       = 'Texte';
  bool   _publishing = false;

  late final AnimationController _anim;
  late final Animation<double>   _slide;

  static const _types = ['Texte', 'Photo', 'Avant/Après'];

  @override
  void initState() {
    super.initState();
    _anim  = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _slide = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.forward();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final title   = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty && content.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => _publishing = true);
    final user = ref.read(userProvider);
    final post = PostModel(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      username: user.name.isNotEmpty ? user.name : 'Moi',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=1',
      content: [title, content].where((s) => s.isNotEmpty).join('\n'),
      imageUrl: '',
      likes: 0,
      comments: 0,
      timeAgo: 'À l\'instant',
      category: _type == 'Texte' ? '' : _type,
    );
    await ref.read(postsNotifierProvider.notifier).addPost(post);
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
        Text('Post publié !',
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
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(_slide),
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
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TypeSelector(
                      types: _types,
                      selected: _type,
                      cs: cs,
                      onSelect: (t) {
                        HapticFeedback.selectionClick();
                        setState(() => _type = t);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Title
                    _ComposerField(
                      controller: _titleCtrl,
                      focus: _titleFocus,
                      hint: 'Titre de votre post',
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

                    // Content
                    _ComposerField(
                      controller: _contentCtrl,
                      focus: _contentFocus,
                      hint: _contentHint,
                      cs: cs,
                      style: GoogleFonts.inter(
                        fontSize: 15, color: cs.onSurface, height: 1.65),
                      hintStyle: GoogleFonts.inter(
                        fontSize: 15,
                        color: cs.onSurface.withValues(alpha: 0.3), height: 1.65),
                      maxLines: 6,
                    ),

                    // Photo zone
                    if (_type != 'Texte') ...[
                      const SizedBox(height: 20),
                      _type == 'Avant/Après'
                          ? Row(children: [
                              Expanded(child: _PhotoSlot(label: 'Avant', cs: cs)),
                              const SizedBox(width: 12),
                              Expanded(child: _PhotoSlot(label: 'Après', cs: cs)),
                            ])
                          : _PhotoSlot(label: 'Ajouter une photo', cs: cs),
                    ],

                    const SizedBox(height: 24),
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

  String get _contentHint {
    switch (_type) {
      case 'Photo':       return 'Ajoute une légende…';
      case 'Avant/Après': return 'Décris ta transformation…';
      default:            return 'Partage quelque chose avec la communauté…';
    }
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
        Text('NOUVEAU POST', style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w700,
          color: cs.primary, letterSpacing: 2.5)),
        const SizedBox(height: 2),
        Text('Partage avec la communauté', style: GoogleFonts.outfit(
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
//  TYPE SELECTOR  (segmented)
// ─────────────────────────────────────────────────────────────────────────────
class _TypeSelector extends StatelessWidget {
  final List<String> types;
  final String selected;
  final ColorScheme cs;
  final void Function(String) onSelect;
  const _TypeSelector({
    required this.types, required this.selected,
    required this.cs, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: types.map((t) {
        final sel = t == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? cs.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
                boxShadow: sel ? [BoxShadow(
                  color: cs.shadow.withValues(alpha: 0.06),
                  blurRadius: 6, offset: const Offset(0, 2))] : [],
              ),
              child: Center(child: Text(t, style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
              ))),
            ),
          ),
        );
      }).toList()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  COMPOSER FIELD  (borderless, editorial)
// ─────────────────────────────────────────────────────────────────────────────
class _ComposerField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focus;
  final String hint;
  final ColorScheme cs;
  final TextStyle style, hintStyle;
  final int maxLines;
  const _ComposerField({
    required this.controller, required this.focus, required this.hint,
    required this.cs, required this.style, required this.hintStyle,
    this.maxLines = 1,
  });

  @override
  State<_ComposerField> createState() => _ComposerFieldState();
}

class _ComposerFieldState extends State<_ComposerField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focus,
      maxLines: widget.maxLines,
      style: widget.style,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: widget.hintStyle,
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
//  PHOTO SLOT
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoSlot extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _PhotoSlot({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.imagePlus, size: 24,
              color: cs.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w500,
            color: cs.onSurface.withValues(alpha: 0.4))),
        ]),
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
            color: publishing
                ? cs.primary.withValues(alpha: 0.5)
                : cs.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: publishing
                ? SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: cs.onPrimary))
                : Text('Publier',
                    style: GoogleFonts.outfit(
                      color: cs.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    )),
          ),
        ),
      ),
    );
  }
}
