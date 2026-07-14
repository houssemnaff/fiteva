// ignore_for_file: deprecated_member_use
import 'package:fiteva/core/nutrition/favorites_provider.dart';
import 'package:fiteva/screens/nutrition/nutrition_colors.dart';
import 'package:fiteva/screens/nutrition/recipes_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'recipe_author_screen.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
Color _kGreen(BuildContext c) => Theme.of(c).colorScheme.primary;
const _kMint   = Color(0xFF7ABB98);
const _kMintBg = Color(0xFFEAF3EC);
const _kCream  = Color(0xFFFAFAF8);
const _kBorder = Color(0xFFECECEC);
const _kText1  = Color(0xFF111110);
const _kText2  = Color(0xFF6B7280);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class RecipeVideoPlayerScreen extends ConsumerStatefulWidget {
  final VideoRecipe recipe;
  const RecipeVideoPlayerScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeVideoPlayerScreen> createState() => _RecipeVideoPlayerScreenState();
}

class _RecipeVideoPlayerScreenState extends ConsumerState<RecipeVideoPlayerScreen> {
  VideoPlayerController? _ctrl;
  bool _videoReady = false;
  bool _playing    = false;
  bool _showCtrl   = true; // show play/pause overlay
  int  _activeStep = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _initVideo();
  }

  Future<void> _initVideo() async {
    final asset = widget.recipe.videoAsset;
    if (asset == null) return;
    final isUrl = asset.startsWith('http://') || asset.startsWith('https://');
    final ctrl = isUrl
        ? VideoPlayerController.networkUrl(Uri.parse(asset))
        : VideoPlayerController.asset(asset);
    try {
      await ctrl.initialize();
      ctrl.addListener(_onVideoUpdate);
      if (!mounted) { ctrl.dispose(); return; }
      setState(() { _ctrl = ctrl; _videoReady = true; });
    } catch (_) {
      ctrl.dispose();
    }
  }

  void _onVideoUpdate() {
    if (_ctrl == null) return;
    // hide controls 2s after play starts
    if (_ctrl!.value.isPlaying && _showCtrl) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _ctrl!.value.isPlaying) {
          setState(() => _showCtrl = false);
        }
      });
    }
    if (!_ctrl!.value.isPlaying && !_showCtrl) {
      setState(() => _showCtrl = true);
    }
  }

  void _tapVideo() {
    if (!_videoReady || _ctrl == null) return;
    if (!_playing) {
      _ctrl!.play();
      setState(() { _playing = true; _showCtrl = true; });
    } else {
      setState(() => _showCtrl = !_showCtrl);
    }
  }

  void _togglePlayPause() {
    if (_ctrl == null) return;
    if (_ctrl!.value.isPlaying) {
      _ctrl!.pause();
    } else {
      _ctrl!.play();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onVideoUpdate);
    _ctrl?.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final cs  = Theme.of(context).colorScheme;
    final nc  = NutritionColors.of(context);
    final l10n = ref.watch(l10nProvider);
    final videoH = top + 260.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: nc.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Sticky video header ───────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _VideoHeaderDelegate(
                height: videoH,
                child: _buildVideoHeader(top),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildMeta(nc, l10n)),
            SliverToBoxAdapter(child: _buildIngredients(nc, l10n)),
            SliverToBoxAdapter(child: _buildSteps(nc)),
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }

  // ── VIDEO HEADER ───────────────────────────────────────────────────────────
  Widget _buildVideoHeader(double top) {
    final cs = Theme.of(context).colorScheme;
    final hasVideo = widget.recipe.videoAsset != null;

    return GestureDetector(
      onTap: _tapVideo,
      child: Container(
        color: Colors.black,
        child: Stack(fit: StackFit.expand, children: [

          // ── Video frame (raw VideoPlayer) ──
          if (_ctrl != null && _playing)
            VideoPlayer(_ctrl!),

          // ── Cover image (shown before play) ──
          if (!_playing)
            Image.network(
              widget.recipe.imageUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: cs.primary.withOpacity(0.08))),

          // ── Gradient overlay ──
          if (!_playing)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.15), Colors.black.withOpacity(0.50)]))),

          // ── Play button (before play) ──
          if (hasVideo && !_playing)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 68, height: 68,
                decoration: BoxDecoration(
                  color: _videoReady ? _kGreen(context) : Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 16, offset: const Offset(0, 4))]),
                child: _videoReady
                    ? const Icon(LucideIcons.play, color: Colors.white, size: 26)
                    : const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)))),

          // ── Play/pause overlay (during playback, appears on tap) ──
          if (_playing && _showCtrl)
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 54, height: 54,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.50),
                    shape: BoxShape.circle),
                  child: Icon(
                    _ctrl!.value.isPlaying
                        ? LucideIcons.pause
                        : LucideIcons.play,
                    color: Colors.white, size: 22)))),

          // ── Progress bar (during playback) ──
          if (_playing && _ctrl != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: VideoProgressIndicator(
                _ctrl!,
                allowScrubbing: true,
                padding: EdgeInsets.zero,
                colors: VideoProgressColors(
                  playedColor: _kGreen(context),
                  bufferedColor: Colors.white.withOpacity(0.3),
                  backgroundColor: Colors.white.withOpacity(0.15)),
              )),

          // ── Top gradient for buttons ──
          Positioned(
            top: 0, left: 0, right: 0, height: top + 70,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.55), Colors.transparent]))))),

          // ── Back button ──
          Positioned(
            top: top + 12, left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.40),
                  shape: BoxShape.circle),
                child: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 20)))),

          // ── Fav button (top-right) ──
          Positioned(
            top: top + 12, right: 16,
            child: Builder(builder: (ctx) {
              final isFav = ref.watch(favoritesProvider)
                  .contains(widget.recipe.name);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(favoritesProvider.notifier)
                      .toggle(widget.recipe.name);
                },
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: isFav
                        ? const Color(0xFFE03050)
                        : Colors.black.withOpacity(0.40),
                    shape: BoxShape.circle),
                  child: Icon(
                    LucideIcons.heart,
                    color: Colors.white,
                    size: 18)));
            })),

          // ── Phase badge ──
          Positioned(
            top: top + 14, right: 64,
            child: Builder(builder: (_) {
              final pi = PhaseInfo.from(widget.recipe.phase);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: pi.color.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(pi.label, style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ]));
            })),

          // ── Duration + video badge (before play) ──
          if (!_playing)
            Positioned(
              bottom: 16, left: 16,
              child: Row(children: [
                _DarkBadge(icon: LucideIcons.clock, label: widget.recipe.duration),
                if (hasVideo) ...[
                  const SizedBox(width: 8),
                  _DarkBadge(
                    icon: LucideIcons.video,
                    label: 'Vidéo disponible',
                    color: _kGreen(context).withOpacity(0.88)),
                ],
              ])),
        ]),
      ),
    );
  }

  // ── META ──────────────────────────────────────────────────────────────────
  Widget _buildMeta(NutritionColors nc, AppL10n l10n) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.recipe.name, style: GoogleFonts.outfit(
          fontSize: 26, fontWeight: FontWeight.w800,
          color: nc.text1, letterSpacing: -0.5, height: 1.15)),
        const SizedBox(height: 4),
        Text(widget.recipe.subtitle, style: GoogleFonts.inter(
          fontSize: 14, color: nc.text2, height: 1.4)),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _MetaChip(icon: LucideIcons.clock,     label: widget.recipe.duration),
          _MetaChip(icon: LucideIcons.flame,     label: '${widget.recipe.kcal} kcal'),
          _MetaChip(icon: LucideIcons.dumbbell,  label: '${widget.recipe.proteins}g protéines'),
          _MetaChip(icon: LucideIcons.barChart2, label: widget.recipe.difficulty),
        ]),
        // Author row
        if (widget.recipe.authorName != null) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: widget.recipe.authorId != null ? () {
              HapticFeedback.lightImpact();
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => RecipeAuthorScreen(
                  userId: widget.recipe.authorId!,
                  username: widget.recipe.authorName!)));
            } : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12), shape: BoxShape.circle),
                  child: Center(child: Text(
                    widget.recipe.authorName![0].toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 14,
                      fontWeight: FontWeight.w800, color: cs.primary)))),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('par ${widget.recipe.authorName}', style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface)),
                    Text('Voir toutes ses recettes', style: GoogleFonts.inter(
                      fontSize: 11, color: cs.primary)),
                  ])),
                Icon(LucideIcons.chevronRight, size: 16, color: cs.primary),
              ]))),
        ],
        const SizedBox(height: 20),
        _WhyPhaseCard(l10n: l10n, phase: widget.recipe.phase),
      ]),
    );
  }

  // ── INGREDIENTS ───────────────────────────────────────────────────────────
  Widget _buildIngredients(NutritionColors nc, AppL10n l10n) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionLabel(
          icon: LucideIcons.shoppingBasket,
          eyebrow: 'POUR ${widget.recipe.ingredients.length} PORTIONS',
          title: 'Ingrédients',
        ),
        const SizedBox(height: 14),
        ...widget.recipe.ingredients.map((ing) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: nc.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: nc.border)),
            child: Row(children: [
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Text(ing.name, style: GoogleFonts.inter(
                fontSize: 13.5, fontWeight: FontWeight.w600, color: nc.text1))),
              Text(ing.qty, style: GoogleFonts.inter(fontSize: 12, color: nc.text2)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: nc.mintBg, borderRadius: BorderRadius.circular(8)),
                child: Text('${ing.kcal} kcal', style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700, color: _kGreen(context)))),
            ]),
          ),
        )),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: nc.mintBg,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _kMint.withOpacity(0.35))),
          child: Row(children: [
            Icon(LucideIcons.zap, size: 15, color: _kGreen(context)),
            const SizedBox(width: 8),
            Text(l10n.videoTotalEstime, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: _kGreen(context))),
            const Spacer(),
            Text('${widget.recipe.kcal} kcal  ·  ${widget.recipe.proteins}g protéines',
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: _kGreen(context))),
          ]),
        ),
      ]),
    );
  }

  // ── STEPS ─────────────────────────────────────────────────────────────────
  Widget _buildSteps(NutritionColors nc) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionLabel(
          icon: LucideIcons.listOrdered,
          eyebrow: '${widget.recipe.steps.length} ÉTAPES',
          title: 'Préparation',
        ),
        const SizedBox(height: 14),
        ...widget.recipe.steps.asMap().entries.map((e) {
          final i    = e.key;
          final step = e.value;
          final active = _activeStep == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _activeStep = active ? -1 : i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: active ? _kGreen(context) : nc.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: active ? _kGreen(context) : nc.border,
                    width: active ? 0 : 1),
                  boxShadow: active ? [BoxShadow(
                    color: _kGreen(context).withOpacity(0.20),
                    blurRadius: 12, offset: const Offset(0, 4))] : [],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white.withOpacity(0.18)
                            : nc.mintBg,
                        shape: BoxShape.circle),
                      child: Center(child: Text('${step.number}',
                        style: GoogleFonts.outfit(
                          fontSize: 14, fontWeight: FontWeight.w800,
                          color: active ? Colors.white : _kGreen(context))))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.title, style: GoogleFonts.outfit(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: active ? Colors.white : nc.text1)),
                        if (active) ...[
                          const SizedBox(height: 8),
                          Text(step.description, style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: Colors.white.withOpacity(0.88),
                            height: 1.55)),
                        ] else ...[
                          const SizedBox(height: 3),
                          Text(step.description,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.5, color: nc.text2, height: 1.4)),
                        ],
                      ],
                    )),
                    const SizedBox(width: 8),
                    Icon(
                      active ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                      size: 16,
                      color: active ? Colors.white.withOpacity(0.7) : nc.text2),
                  ]),
                ),
              ),
            ),
          );
        }),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SliverPersistentHeaderDelegate — hauteur fixe
// ─────────────────────────────────────────────────────────────────────────────
class _VideoHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  const _VideoHeaderDelegate({required this.height, required this.child});

  @override double get minExtent => height;
  @override double get maxExtent => height;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(_VideoHeaderDelegate old) =>
      old.height != height || old.child != child;
}

// ─────────────────────────────────────────────────────────────────────────────
// Small widgets
// ─────────────────────────────────────────────────────────────────────────────
class _DarkBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _DarkBadge({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color ?? Colors.black.withOpacity(0.50),
      borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: Colors.white),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
    ]));
}

class _WhyPhaseCard extends StatelessWidget {
  final AppL10n l10n;
  final String phase;
  const _WhyPhaseCard({required this.l10n, this.phase = 'all'});

  String get _tip => switch (phase) {
    'menstrual'  => 'Pendant tes règles, privilégie le fer et le magnésium pour compenser les pertes et réduire la fatigue.',
    'follicular' => 'En phase folliculaire, les protéines et fibres soutiennent la montée d\'énergie et la reconstruction.',
    'ovulation'  => 'Autour de l\'ovulation, les antioxydants et le zinc favorisent l\'équilibre hormonal.',
    'luteal'     => 'En phase lutéale, les glucides complexes et le calcium aident à stabiliser l\'humeur.',
    _            => 'Cette recette est conçue pour soutenir ton bien-être avec des ingrédients riches en nutriments essentiels.',
  };

  @override
  Widget build(BuildContext context) {
    final pi = PhaseInfo.from(phase);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pi.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: pi.color.withOpacity(0.2))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(LucideIcons.lightbulb, size: 18, color: pi.color),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 6, height: 6,
              decoration: BoxDecoration(color: pi.color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(pi.label, style: GoogleFonts.inter(
              fontSize: 12.5, fontWeight: FontWeight.w700, color: pi.color)),
          ]),
          const SizedBox(height: 4),
          Text(_tip, style: GoogleFonts.inter(
            fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), height: 1.5)),
        ])),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String eyebrow, title;
  const _SectionLabel({required this.icon, required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Row(children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(color: nc.mintBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 15, color: _kGreen(context))),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(eyebrow, style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w700, color: _kMint, letterSpacing: 2.2)),
        Text(title, style: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w800, color: nc.text1, letterSpacing: -0.3)),
      ]),
    ]);
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: nc.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: _kGreen(context)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: nc.text1)),
      ]),
    );
  }
}
