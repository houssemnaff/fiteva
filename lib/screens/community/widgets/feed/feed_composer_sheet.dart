// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'dart:io';
import 'package:fiteva/models/post_model.dart';
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/community/providers/community_providers.dart';
import 'package:fiteva/services/cloudinary_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
class FeedComposerSheet extends ConsumerStatefulWidget {
  /// Si [post] est fourni, la sheet s'ouvre en mode édition.
  final PostModel? post;
  const FeedComposerSheet({super.key, this.post});

  @override
  ConsumerState<FeedComposerSheet> createState() => _FeedComposerSheetState();
}

class _FeedComposerSheetState extends ConsumerState<FeedComposerSheet>
    with SingleTickerProviderStateMixin {

  final _titleCtrl    = TextEditingController();
  final _contentCtrl  = TextEditingController();
  final _titleFocus   = FocusNode();
  final _contentFocus = FocusNode();

  String _type       = 'Texte';
  String _category   = '';        // catégorie fitness, indépendante du type format
  bool   _publishing = false;

  XFile? _pickedImage;   // type == 'Photo'
  XFile? _beforeImage;   // type == 'Avant/Après'
  XFile? _afterImage;

  // URLs déjà publiées (mode édition) — remplacées si l'utilisateur choisit
  // une nouvelle photo, effacées s'il appuie sur retirer.
  String _existingImageUrl  = '';
  String _existingBeforeUrl = '';
  String _existingAfterUrl  = '';

  late final AnimationController _anim;
  late final Animation<double>   _slide;

  bool get _isEditing => widget.post != null;

  static const _types = ['Texte', 'Photo', 'Avant/Après'];

  static const _categories = [
    (value: 'Workout',   label: 'Workout',   icon: LucideIcons.dumbbell),
    (value: 'Challenge', label: 'Challenge', icon: LucideIcons.trophy),
    (value: 'Nutrition', label: 'Nutrition', icon: LucideIcons.apple),
    (value: 'Lifestyle', label: 'Lifestyle', icon: LucideIcons.heart),
    (value: 'Other',     label: 'Autre',     icon: LucideIcons.sparkles),
  ];

  @override
  void initState() {
    super.initState();
    _anim  = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
    _slide = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.forward();

    // Pré-remplissage en mode édition.
    if (_isEditing) {
      final post = widget.post!;
      _titleCtrl.text   = post.title;
      _contentCtrl.text = post.content;
      _category         = post.category;
      if (post.isBeforeAfter) {
        _type               = 'Avant/Après';
        _existingBeforeUrl  = post.beforeImageUrl;
        _existingAfterUrl   = post.afterImageUrl;
      } else if (post.imageUrl.trim().isNotEmpty) {
        _type              = 'Photo';
        _existingImageUrl  = post.imageUrl;
      }
    }
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

  String _resolvedName(WidgetRef ref) {
    final profile = ref.read(userProfileProvider);
    final user    = ref.read(userProfileProvider);
    return profile.username.isNotEmpty ? profile.username : user.username;
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery, imageQuality: 82, maxWidth: 1600);
    if (picked != null) setState(() => _pickedImage = picked);
  }

  Future<void> _pickBefore() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery, imageQuality: 82, maxWidth: 1600);
    if (picked != null) setState(() => _beforeImage = picked);
  }

  Future<void> _pickAfter() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery, imageQuality: 82, maxWidth: 1600);
    if (picked != null) setState(() => _afterImage = picked);
  }

  Future<void> _publish() async {
    final title   = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez un titre ou un contenu avant de publier.')));
      return;
    }
    if (_type == 'Photo' && _pickedImage == null && _existingImageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez une photo avant de publier.')));
      return;
    }
    if (_type == 'Avant/Après' &&
        ((_beforeImage == null && _existingBeforeUrl.isEmpty) ||
         (_afterImage == null && _existingAfterUrl.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez une photo "avant" et une photo "après".')));
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _publishing = true);

    // Recalcule l'image à partir de ce qui existait déjà (mode édition) et
    // de ce que l'utilisateur vient éventuellement de choisir/retirer.
    var imageUrl = '';
    if (_type == 'Photo') {
      imageUrl = _existingImageUrl;
      if (_pickedImage != null) {
        final uploaded = await CloudinaryConfig.uploadImage(_pickedImage!);
        if (uploaded == null) {
          if (!mounted) return;
          setState(() => _publishing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec de l\'envoi de la photo.')));
          return;
        }
        imageUrl = uploaded;
      }
    } else if (_type == 'Avant/Après') {
      var beforeUrl = _existingBeforeUrl;
      var afterUrl  = _existingAfterUrl;
      if (_beforeImage != null) {
        final uploaded = await CloudinaryConfig.uploadImage(_beforeImage!);
        if (uploaded == null) {
          if (!mounted) return;
          setState(() => _publishing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec de l\'envoi des photos.')));
          return;
        }
        beforeUrl = uploaded;
      }
      if (_afterImage != null) {
        final uploaded = await CloudinaryConfig.uploadImage(_afterImage!);
        if (uploaded == null) {
          if (!mounted) return;
          setState(() => _publishing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec de l\'envoi des photos.')));
          return;
        }
        afterUrl = uploaded;
      }
      imageUrl = jsonEncode({'before': beforeUrl, 'after': afterUrl});
    }

    bool ok;

    if (_isEditing) {
      final updated = widget.post!.copyWith(
        title:    title,
        content:  content,
        category: _category,
        imageUrl: imageUrl,
      );
      ok = await ref.read(postsNotifierProvider.notifier).updatePost(updated);
    } else {
      final displayName = _resolvedName(ref);
      final post = PostModel(
        id:           '',
        username:     displayName,
        userAvatarUrl:'',
        title:        title,
        content:      content,
        imageUrl:     imageUrl,
        likes:        0,
        comments:     0,
        timeAgo:      'À l\'instant',
        category:     _category,
      );
      ok = await ref.read(postsNotifierProvider.notifier).addPost(post);
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
        duration: const Duration(seconds: 4),
        content: Row(children: [
          Icon(LucideIcons.circleAlert, color: cs.onError, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isEditing
                  ? 'Erreur lors de la modification. Vérifiez votre connexion.'
                  : 'Erreur lors de la publication. Vérifiez votre connexion.',
              style: GoogleFonts.inter(color: cs.onError, fontWeight: FontWeight.w600)),
          ),
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
        Expanded(
          child: Text(
            _isEditing ? 'Post modifié avec succès !' : ref.read(l10nProvider).communityPublished,
            style: GoogleFonts.inter(color: cs.onPrimary, fontWeight: FontWeight.w600)),
        ),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final bottom  = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;
    final displayName = _resolvedName(ref);
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

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
            _TopBar(cs: cs, isEditing: _isEditing, onClose: () => Navigator.of(context).pop()),

            // ── Posting as ──────────────────────────────────────────────────
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
                  Text(ref.watch(l10nProvider).communityPublishCommunity, style: GoogleFonts.inter(
                    fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
                ]),
              ]),
            ),

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
                    const SizedBox(height: 16),
                    _CategoryPicker(
                      categories: _categories,
                      selected: _category,
                      cs: cs,
                      onSelect: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _category = _category == v ? '' : v);
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
                              Expanded(child: _PhotoSlot(
                                label: 'Avant', image: _beforeImage,
                                existingUrl: _existingBeforeUrl, cs: cs,
                                onPick: _pickBefore,
                                onRemove: () => setState(() {
                                  _beforeImage = null;
                                  _existingBeforeUrl = '';
                                }),
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: _PhotoSlot(
                                label: 'Après', image: _afterImage,
                                existingUrl: _existingAfterUrl, cs: cs,
                                onPick: _pickAfter,
                                onRemove: () => setState(() {
                                  _afterImage = null;
                                  _existingAfterUrl = '';
                                }),
                              )),
                            ])
                          : _PhotoSlot(
                              label: 'Ajouter une photo', image: _pickedImage,
                              existingUrl: _existingImageUrl, cs: cs,
                              onPick: _pickPhoto,
                              onRemove: () => setState(() {
                                _pickedImage = null;
                                _existingImageUrl = '';
                              }),
                            ),
                    ],

                    const SizedBox(height: 24),
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
          Text(
            isEditing ? 'MODIFIER' : l10n.communityNewPost,
            style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: cs.primary, letterSpacing: 2.5)),
          const SizedBox(height: 2),
          Text(
            isEditing ? 'Modifier votre post' : l10n.communityShareWith,
            style: GoogleFonts.outfit(
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
  final XFile? image;
  final String existingUrl;
  final ColorScheme cs;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  const _PhotoSlot({
    required this.label, required this.image, this.existingUrl = '',
    required this.cs, required this.onPick, required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasPicked   = image != null;
    final hasExisting = !hasPicked && existingUrl.trim().isNotEmpty;

    if (!hasPicked && !hasExisting) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onPick();
        },
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(children: [
        SizedBox(
          height: 130,
          width: double.infinity,
          child: hasPicked
              ? (kIsWeb
                  ? Image.network(image!.path, fit: BoxFit.cover)
                  : Image.file(File(image!.path), fit: BoxFit.cover))
              : Image.network(existingUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: cs.primary.withValues(alpha: 0.08),
                    child: Icon(LucideIcons.image, size: 24,
                        color: cs.primary.withValues(alpha: 0.3)),
                  )),
        ),
        Positioned(
          top: 6, right: 6,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onRemove();
            },
            child: Container(
              width: 26, height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.x, size: 13, color: Colors.white),
            ),
          ),
        ),
      ]),
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
                : Text(isEditing ? 'Modifier' : l10n.communityPublish,
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

// ─────────────────────────────────────────────────────────────────────────────
//  CATEGORY PICKER  (pills horizontaux avec icônes)
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryPicker extends StatelessWidget {
  final List<({String value, String label, IconData icon})> categories;
  final String selected;
  final ColorScheme cs;
  final void Function(String) onSelect;

  const _CategoryPicker({
    required this.categories,
    required this.selected,
    required this.cs,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final sel = selected == cat.value;
          return GestureDetector(
            onTap: () => onSelect(cat.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: sel
                    ? cs.primary
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: sel ? cs.primary : cs.outline,
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  cat.icon,
                  size: 13,
                  color: sel
                      ? cs.onPrimary
                      : cs.onSurface.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 6),
                Text(
                  cat.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel
                        ? cs.onPrimary
                        : cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
