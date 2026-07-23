// ignore_for_file: deprecated_member_use
import 'package:fiteva/core/nutrition/favorites_provider.dart';
import 'package:fiteva/screens/nutrition/recipes_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'recipe_author_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class RecipeVideoPlayerScreen extends ConsumerStatefulWidget {
  final VideoRecipe recipe;
  const RecipeVideoPlayerScreen({super.key, required this.recipe});

  @override
  ConsumerState<RecipeVideoPlayerScreen> createState() =>
      _RecipeVideoPlayerScreenState();
}

class _RecipeVideoPlayerScreenState
    extends ConsumerState<RecipeVideoPlayerScreen> {
  VideoPlayerController? _ctrl;
  bool _videoReady = false;
  bool _playing = false;
  bool _showCtrl = true;
  bool _expanded = false;
  double _speed = 1.0;
  bool _showSpeedPicker = false;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final asset = widget.recipe.videoAsset;
    if (asset == null || asset.isEmpty) return;
    final isUrl = asset.startsWith('http://') || asset.startsWith('https://');
    final ctrl = isUrl
        ? VideoPlayerController.networkUrl(Uri.parse(asset))
        : VideoPlayerController.asset(asset);
    try {
      await ctrl.initialize();
      ctrl.addListener(_onVideoUpdate);
      if (!mounted) { ctrl.dispose(); return; }
      setState(() { _ctrl = ctrl; _videoReady = true; });
    } catch (e) {
      debugPrint('Video init error for $asset: $e');
      ctrl.dispose();
    }
  }

  void _onVideoUpdate() {
    if (_ctrl == null) return;
    if (mounted) setState(() {});
    if (_ctrl!.value.isPlaying && _showCtrl && !_showSpeedPicker) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _ctrl!.value.isPlaying && !_showSpeedPicker) {
          setState(() => _showCtrl = false);
        }
      });
    }
    if (!_ctrl!.value.isPlaying && !_showCtrl) {
      setState(() => _showCtrl = true);
    }
  }

  void _tapVideo() {
    if (_showSpeedPicker) {
      setState(() => _showSpeedPicker = false);
      return;
    }
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
    _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play();
    setState(() {});
  }

  void _setSpeed(double s) {
    _ctrl?.setPlaybackSpeed(s);
    setState(() { _speed = s; _showSpeedPicker = false; });
  }

  void _toggleExpand() {
    HapticFeedback.lightImpact();
    if (!_expanded) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    setState(() => _expanded = !_expanded);
  }

  void _seekRelative(int seconds) {
    if (_ctrl == null) return;
    final pos = _ctrl!.value.position + Duration(seconds: seconds);
    _ctrl!.seekTo(pos);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onVideoUpdate);
    _ctrl?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;
    final r = widget.recipe;
    final pi = PhaseInfo.from(r.phase);
    final isFav = ref.watch(favoritesProvider).contains(r.name);
    final hasVideo = r.videoAsset != null;

    if (_expanded) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildVideo(cs, 0, hasVideo, isFav, pi, fullscreen: true),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Video / cover ────────────────────────────────────────
            SliverToBoxAdapter(
                child: _buildVideo(cs, top, hasVideo, isFav, pi)),

            // ── Title + meta ─────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(r.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        height: 1.15,
                        letterSpacing: -0.3)),
                if (r.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(r.subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: cs.onSurface.withOpacity(0.45),
                          height: 1.4)),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  _Chip(LucideIcons.clock, r.duration, cs),
                  const SizedBox(width: 8),
                  _Chip(LucideIcons.flame, '${r.kcal} kcal', cs),
                  const SizedBox(width: 8),
                  _Chip(LucideIcons.dumbbell, '${r.proteins}g prot.', cs),
                ]),
              ]),
            )),

            // ── Author ───────────────────────────────────────────────
            if (r.authorName != null)
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: GestureDetector(
                  onTap: r.authorId != null
                      ? () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => RecipeAuthorScreen(
                                      userId: r.authorId!,
                                      username: r.authorName!)));
                        }
                      : null,
                  child: Row(children: [
                    Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.1),
                            shape: BoxShape.circle),
                        child: Center(
                            child: Text(r.authorName![0].toUpperCase(),
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: cs.primary)))),
                    const SizedBox(width: 8),
                    Text('par ',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.4))),
                    Text(r.authorName!,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.primary)),
                  ]),
                ),
              )),

            // ── Phase tip ────────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _PhaseTip(phase: r.phase),
            )),

            // ── Macro cards ──────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                _MacroCard('Calories', '${r.kcal}', 'kcal',
                    const Color(0xFFE03050), cs),
                const SizedBox(width: 8),
                _MacroCard('Protéines', '${r.proteins}', 'g',
                    const Color(0xFF5BAE8A), cs),
                const SizedBox(width: 8),
                _MacroCard('Difficulté', r.difficulty, '',
                    const Color(0xFF6B8FD4), cs),
              ]),
            )),

            // ── Ingredients ──────────────────────────────────────────
            if (r.ingredients.isNotEmpty) ...[
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(children: [
                  Icon(LucideIcons.shoppingBasket,
                      size: 15, color: cs.primary),
                  const SizedBox(width: 8),
                  Text('Ingrédients',
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface)),
                  const Spacer(),
                  Text('${r.ingredients.length}',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withOpacity(0.3))),
                ]),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    children: r.ingredients.map((ing) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                          color: cs.outline.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(ing.name,
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface))),
                        Text(ing.qty,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: cs.onSurface.withOpacity(0.4))),
                        const SizedBox(width: 10),
                        Text('${ing.kcal} kcal',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: cs.primary)),
                      ]),
                    ),
                  );
                }).toList()),
              )),

              // Total bar
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Icon(LucideIcons.zap, size: 13, color: cs.primary),
                    const SizedBox(width: 8),
                    Text('Total estimé',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.primary)),
                    const Spacer(),
                    Text('${r.kcal} kcal  ·  ${r.proteins}g prot.',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.primary)),
                  ]),
                ),
              )),
            ],

            // ── Steps ────────────────────────────────────────────────
            if (r.steps.isNotEmpty) ...[
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(children: [
                  Icon(LucideIcons.listOrdered, size: 15, color: cs.primary),
                  const SizedBox(width: 8),
                  Text('Préparation',
                      style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface)),
                  const Spacer(),
                  Text('${r.steps.length} étapes',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withOpacity(0.3))),
                ]),
              )),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StepsList(steps: r.steps),
              )),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── VIDEO SECTION ──────────────────────────────────────────────────────────
  Widget _buildVideo(
      ColorScheme cs, double top, bool hasVideo, bool isFav, PhaseInfo pi,
      {bool fullscreen = false}) {
    final screenSize = MediaQuery.of(context).size;
    final videoH = fullscreen ? screenSize.height : top + 260;

    return GestureDetector(
      onTap: _tapVideo,
      child: SizedBox(
        height: videoH,
        child: Stack(fit: StackFit.expand, children: [
          // Video or cover
          if (_ctrl != null && _playing)
            Container(
              color: Colors.black,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _ctrl!.value.aspectRatio,
                  child: VideoPlayer(_ctrl!),
                ),
              ),
            ),
          if (!_playing)
            Image.network(widget.recipe.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: cs.primary.withOpacity(0.06))),
          if (!_playing)
            Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.5)
                ]))),

          // Bottom fade into surface (only in non-fullscreen)
          if (!fullscreen)
            Positioned(
                bottom: 0, left: 0, right: 0, height: 60,
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [cs.surface, cs.surface.withOpacity(0)])))),

          // Play button (before play)
          if (hasVideo && !_playing)
            Center(
                child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                        color: _videoReady ? cs.primary : Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle),
                    child: _videoReady
                        ? const Icon(LucideIcons.play, color: Colors.white, size: 24)
                        : const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))),

          // Playback controls (during playback)
          if (_playing && _showCtrl) ...[
            // Dim overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),

            // Center row: rewind / play-pause / forward
            Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                GestureDetector(
                  onTap: () => _seekRelative(-10),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(LucideIcons.rotateCcw, color: Colors.white, size: 18),
                      Text('10', style: GoogleFonts.inter(
                        fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white70)),
                    ]),
                  ),
                ),
                const SizedBox(width: 28),
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                    child: Icon(
                      _ctrl!.value.isPlaying ? LucideIcons.pause : LucideIcons.play,
                      color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 28),
                GestureDetector(
                  onTap: () => _seekRelative(10),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(LucideIcons.rotateCw, color: Colors.white, size: 18),
                      Text('10', style: GoogleFonts.inter(
                        fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white70)),
                    ]),
                  ),
                ),
              ]),
            ),
          ],

          // Bottom bar: time + progress + speed + expand
          if (_playing && _ctrl != null)
            Positioned(
              bottom: fullscreen ? 20 : 0,
              left: 0, right: 0,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Progress bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: fullscreen ? 16 : 0),
                  child: VideoProgressIndicator(_ctrl!,
                    allowScrubbing: true,
                    padding: EdgeInsets.zero,
                    colors: VideoProgressColors(
                      playedColor: cs.primary,
                      bufferedColor: Colors.white.withOpacity(0.3),
                      backgroundColor: Colors.white.withOpacity(0.15))),
                ),
                // Time + speed + expand row
                if (_showCtrl)
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      fullscreen ? 20 : 12, 6, fullscreen ? 20 : 12, fullscreen ? 0 : 4),
                    color: Colors.black.withOpacity(fullscreen ? 0.0 : 0.35),
                    child: Row(children: [
                      // Current time / total
                      Text(
                        '${_formatDuration(_ctrl!.value.position)} / ${_formatDuration(_ctrl!.value.duration)}',
                        style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                      ),
                      const Spacer(),
                      // Speed button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _showSpeedPicker = !_showSpeedPicker);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _speed != 1.0
                                ? cs.primary.withOpacity(0.9)
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            '${_speed}x',
                            style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: _speed != 1.0 ? Colors.white : Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Expand / collapse
                      GestureDetector(
                        onTap: _toggleExpand,
                        child: Icon(
                          fullscreen ? LucideIcons.minimize2 : LucideIcons.maximize2,
                          color: Colors.white70, size: 18),
                      ),
                    ]),
                  ),
              ]),
            ),

          // Speed picker popup
          if (_showSpeedPicker && _playing)
            Positioned(
              bottom: fullscreen ? 80 : 50,
              right: fullscreen ? 60 : 40,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xF01A1A1A),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min,
                  children: _speeds.map((s) {
                    final active = s == _speed;
                    return GestureDetector(
                      onTap: () => _setSpeed(s),
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        color: active ? cs.primary.withOpacity(0.2) : Colors.transparent,
                        child: Center(child: Text(
                          '${s}x',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                            color: active ? cs.primary : Colors.white70),
                        )),
                      ),
                    );
                  }).toList()),
              ),
            ),

          // Top gradient for buttons
          if (_showCtrl || !_playing)
            Positioned(
                top: 0, left: 0, right: 0, height: (fullscreen ? 0 : top) + 60,
                child: IgnorePointer(
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                      Colors.black.withOpacity(0.5), Colors.transparent
                    ]))))),

          // Back button
          Positioned(
              top: (fullscreen ? 10 : top + 10), left: 16,
              child: GestureDetector(
                  onTap: () {
                    if (_expanded) {
                      _toggleExpand();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25), shape: BoxShape.circle),
                      child: Icon(
                        _expanded ? LucideIcons.minimize2 : LucideIcons.chevronLeft,
                        color: Colors.white, size: 18)))),

          // Phase pill (non-fullscreen only)
          if (!fullscreen)
            Positioned(
                top: top + 12, right: 60,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: pi.color.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(pi.label,
                        style: GoogleFonts.inter(
                            fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)))),

          // Fav (non-fullscreen only)
          if (!fullscreen)
            Positioned(
                top: top + 10, right: 16,
                child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(favoritesProvider.notifier).toggle(widget.recipe.name);
                    },
                    child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                            color: isFav ? cs.primary : Colors.black.withOpacity(0.25),
                            shape: BoxShape.circle),
                        child: const Icon(LucideIcons.heart, color: Colors.white, size: 16)))),

          // Duration badge (before play)
          if (!_playing)
            Positioned(
                bottom: 20, left: 16,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.clock, size: 10, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(widget.recipe.duration,
                          style: GoogleFonts.inter(
                              fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                    ]))),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  const _Chip(this.icon, this.label, this.cs);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: cs.outline.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: cs.primary),
          const SizedBox(width: 5),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
        ]),
      );
}

class _MacroCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  final ColorScheme cs;
  const _MacroCard(this.label, this.value, this.unit, this.color, this.cs);

  @override
  Widget build(BuildContext context) => Expanded(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color)),
            if (unit.isNotEmpty)
              Text(' $unit',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color.withOpacity(0.7))),
          ]),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.7))),
        ]),
      ));
}

class _PhaseTip extends StatelessWidget {
  final String phase;
  const _PhaseTip({required this.phase});

  String get _tip => switch (phase) {
        'menstrual' =>
          'Pendant tes règles, privilégie le fer et le magnésium pour compenser les pertes et réduire la fatigue.',
        'follicular' =>
          'En phase folliculaire, les protéines et fibres soutiennent la montée d\'énergie et la reconstruction.',
        'ovulation' =>
          'Autour de l\'ovulation, les antioxydants et le zinc favorisent l\'équilibre hormonal.',
        'luteal' =>
          'En phase lutéale, les glucides complexes et le calcium aident à stabiliser l\'humeur.',
        _ =>
          'Cette recette est conçue pour soutenir ton bien-être avec des ingrédients riches en nutriments essentiels.',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pi = PhaseInfo.from(phase);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: pi.color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: pi.color.withOpacity(0.12))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(LucideIcons.lightbulb, size: 15, color: pi.color),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(pi.label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: pi.color)),
              const SizedBox(height: 3),
              Text(_tip,
                  style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: cs.onSurface.withOpacity(0.6),
                      height: 1.5)),
            ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEPS LIST (tap to expand)
// ─────────────────────────────────────────────────────────────────────────────
class _StepsList extends StatefulWidget {
  final List<VideoStep> steps;
  const _StepsList({required this.steps});

  @override
  State<_StepsList> createState() => _StepsListState();
}

class _StepsListState extends State<_StepsList> {
  int _active = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
        children: widget.steps.asMap().entries.map((e) {
      final i = e.key;
      final step = e.value;
      final active = _active == i;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _active = active ? -1 : i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: active
                    ? cs.primary
                    : cs.outline.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: active
                              ? Colors.white.withOpacity(0.18)
                              : cs.outline.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                          child: Text('${step.number}',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? Colors.white
                                      : cs.onSurface.withOpacity(0.4))))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(step.title,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? Colors.white
                                    : cs.onSurface)),
                        if (active) ...[
                          const SizedBox(height: 6),
                          Text(step.description,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color:
                                      Colors.white.withOpacity(0.8),
                                  height: 1.5)),
                        ] else ...[
                          const SizedBox(height: 2),
                          Text(step.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: cs.onSurface
                                      .withOpacity(0.35))),
                        ],
                      ])),
                  const SizedBox(width: 8),
                  Icon(
                      active
                          ? LucideIcons.chevronUp
                          : LucideIcons.chevronDown,
                      size: 14,
                      color: active
                          ? Colors.white.withOpacity(0.6)
                          : cs.onSurface.withOpacity(0.25)),
                ]),
          ),
        ),
      );
    }).toList());
  }
}
