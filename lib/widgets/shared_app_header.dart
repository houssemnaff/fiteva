// ignore_for_file: deprecated_member_use
import 'package:fiteva/providers/mascot_provider.dart';
import 'package:fiteva/widgets/mascot_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SharedAppHeader
//  Un header commun (eyebrow + titre + avatar + notifs) pour toutes les
//  sections principales : Cycle, Workout, Nutrition, Communauté, Boutique.
//
//  Usage normal (widget inline) :
//    SharedAppHeader(eyebrow: 'CYCLE', title: 'Mon Cycle', accentColor: ...)
//
//  Usage SliverAppBar (CustomScrollView) :
//    SharedAppHeader.sliver(eyebrow: ..., title: ..., accentColor: ...)
// ─────────────────────────────────────────────────────────────────────────────

class SharedAppHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Color  accentColor;
  final Color  bgColor;

  /// Actions supplémentaires affichées à droite (avant l'avatar).
  final List<Widget> actions;

  /// Initiale affichée dans l'avatar (ex. 'Y' pour Yassine).
  final String avatarInitial;

  /// Badge rouge sur la cloche (0 = pas de badge).
 

  /// Callback notif.
 

  /// Callback avatar.
  final VoidCallback? onAvatarTap;

  /// Si non-null, affiche un chevron gauche cliquable avant le titre.
  final VoidCallback? onBack;

  const SharedAppHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.accentColor,
    this.bgColor         = Colors.white,
    this.actions         = const [],
    this.avatarInitial   = 'S',
    this.onAvatarTap,
    this.onBack,
  });

  // ── Sliver factory ──────────────────────────────────────────────────────────

  /// Retourne un SliverAppBar collant pour les CustomScrollView.
  static Widget sliver({
    required String eyebrow,
    required String title,
    required Color  accentColor,
    Color    bgColor            = Colors.white,
    List<Widget> actions        = const [],
    String   avatarInitial      = 'S',
   
    
    VoidCallback? onAvatarTap,
  }) {
    return _SharedSliverAppHeader(
      eyebrow:           eyebrow,
      title:             title,
      accentColor:       accentColor,
      bgColor:           bgColor,
      actions:           actions,
      avatarInitial:     avatarInitial,
      
      onAvatarTap:       onAvatarTap,
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return _HeaderContent(
      eyebrow:       eyebrow,
      title:         title,
      accentColor:   accentColor,
      bgColor:       bgColor,
      actions:       actions,
      avatarInitial: avatarInitial,
      onAvatarTap:   onAvatarTap,
      onBack:        onBack,
      topPadding:    top,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _HeaderContent — contenu partagé (utilisé en inline et en sliver)
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderContent extends ConsumerWidget {
  final String eyebrow;
  final String title;
  final Color  accentColor;
  final Color  bgColor;
  final List<Widget> actions;
  final String avatarInitial;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onBack;
  final double topPadding;

  const _HeaderContent({
    required this.eyebrow,
    required this.title,
    required this.accentColor,
    required this.bgColor,
    required this.actions,
    required this.avatarInitial,
    required this.topPadding,
    this.onAvatarTap,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedBg    = isDark ? cs.surface : bgColor;
    final resolvedText1 = cs.onSurface;
    final mascot = ref.watch(mascotProvider);
    return Container(
      color: resolvedBg,
      padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Back button (optionnel) ───────────────────────────────────────
          if (onBack != null) ...[
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.chevronLeft,
                    size: 20, color: accentColor),
              ),
            ),
            const SizedBox(width: 12),
          ],
          // ── Left: eyebrow + title ─────────────────────────────────────────
          Expanded(
            child: ClipRect(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (eyebrow.isNotEmpty) ...[
                    Text(
                      eyebrow.toUpperCase(),
                      style: GoogleFonts.inter(
                        color:        accentColor,
                        fontSize:     9,
                        fontWeight:   FontWeight.w700,
                        letterSpacing: 3.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color:        resolvedText1,
                      fontSize:     22,
                      fontWeight:   FontWeight.w800,
                      letterSpacing: -0.5,
                      height:       1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Extra actions passées en param ────────────────────────────────
          ...actions,
          if (actions.isNotEmpty) const SizedBox(width: 10),

          

          const SizedBox(width: 10),

          // ── Mascotte → profil ─────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: ClipOval(
              child: MascotWidget(
                type: mascot.type,
                mood: mascot.mood,
                size: 38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _SharedSliverAppHeader — version SliverAppBar collant
// ─────────────────────────────────────────────────────────────────────────────

class _SharedSliverAppHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Color  accentColor;
  final Color  bgColor;
  final List<Widget> actions;
  final String avatarInitial;
 
  
  final VoidCallback? onAvatarTap;

  const _SharedSliverAppHeader({
    required this.eyebrow,
    required this.title,
    required this.accentColor,
    required this.bgColor,
    required this.actions,
    required this.avatarInitial,
    
    
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SliverToBoxAdapter(
      child: _HeaderContent(
        eyebrow:       eyebrow,
        title:         title,
        accentColor:   accentColor,
        bgColor:       bgColor,
        actions:       actions,
        avatarInitial: avatarInitial,
        topPadding:    top,
        onAvatarTap:   onAvatarTap,
      ),
    );
  }
}
