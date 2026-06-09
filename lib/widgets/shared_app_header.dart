// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
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

  const SharedAppHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.accentColor,
    this.bgColor         = Colors.white,
    this.actions         = const [],
    this.avatarInitial   = 'S',
    
    
    this.onAvatarTap,
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
      eyebrow:           eyebrow,
      title:             title,
      accentColor:       accentColor,
      bgColor:           bgColor,
      actions:           actions,
      avatarInitial:     avatarInitial,
      
     
      onAvatarTap:       onAvatarTap,
      topPadding:        top,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _HeaderContent — contenu partagé (utilisé en inline et en sliver)
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderContent extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Color  accentColor;
  final Color  bgColor;
  final List<Widget> actions;
  final String avatarInitial;

  
  final VoidCallback? onAvatarTap;
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: eyebrow + title ─────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: GoogleFonts.inter(
                    color:       accentColor,
                    fontSize:    9,
                    fontWeight:  FontWeight.w700,
                    letterSpacing: 3.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color:       const Color(0xFF1A1A1A),
                    fontSize:    24,
                    fontWeight:  FontWeight.w800,
                    letterSpacing: -0.5,
                    height:      1.0,
                  ),
                ),
              ],
            ),
          ),

          // ── Extra actions passées en param ────────────────────────────────
          ...actions,
          if (actions.isNotEmpty) const SizedBox(width: 10),

          

          const SizedBox(width: 10),

          // ── Avatar ────────────────────────────────────────────────────────
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color:  accentColor.withOpacity(0.12),
                shape:  BoxShape.circle,
                border: Border.all(color: accentColor, width: 1.5),
              ),
              child: Center(
                child: Text(
                  avatarInitial.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color:      accentColor,
                    fontSize:   15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: top + 72,
      collapsedHeight: top + 64,
      backgroundColor:      bgColor,
      surfaceTintColor:     Colors.transparent,
      elevation:            0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(builder: (_, constraints) {
        return _HeaderContent(
          eyebrow:           eyebrow,
          title:             title,
          accentColor:       accentColor,
          bgColor:           bgColor,
          actions:           actions,
          avatarInitial:     avatarInitial,
          
          topPadding:        top,
        
          onAvatarTap:       onAvatarTap,
        );
      }),
    );
  }
}
