import 'package:chewie/chewie.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/Phasecolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class RecipeVideoPlayerScreen extends StatefulWidget {
  final String recipeName;
  final String imageUrl;
  final String duration;
  final String difficulty;
  final int kcal;
  final CyclePhase phase;

  const RecipeVideoPlayerScreen({
    super.key,
    required this.recipeName,
    required this.imageUrl,
    required this.duration,
    required this.difficulty,
    required this.kcal,
    required this.phase,
  });

  @override
  State<RecipeVideoPlayerScreen> createState() =>
      _RecipeVideoPlayerScreenState();
}

class _RecipeVideoPlayerScreenState extends State<RecipeVideoPlayerScreen> {
  VideoPlayerController? _videoCtrl;
  ChewieController?      _chewieCtrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _initVideo();
  }

  Future<void> _initVideo() async {
    final ctrl = VideoPlayerController.asset('assets/videos/workout1.mp4');
    try {
      await ctrl.initialize();
      final chewie = ChewieController(
        videoPlayerController: ctrl,
        autoPlay: true,
        looping: false,
        aspectRatio: ctrl.value.aspectRatio,
        placeholder: Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: PhaseColors.forPhase(widget.phase).light),
        ),
      );
      if (!mounted) { ctrl.dispose(); return; }
      setState(() { _videoCtrl = ctrl; _chewieCtrl = chewie; });
    } catch (_) {
      ctrl.dispose();
    }
  }

  @override
  void dispose() {
    _chewieCtrl?.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final cs  = Theme.of(context).colorScheme;
    final pc  = PhaseColors.forPhase(widget.phase);

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── Video player ──────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: top + 240,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _chewieCtrl != null
                      ? Chewie(controller: _chewieCtrl!)
                      : Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: pc.light),
                        ),

                  // Top gradient for button legibility
                  Positioned(
                    top: 0, left: 0, right: 0,
                    height: top + 64,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Back button
                  Positioned(
                    top: top + 12, left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_left, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Recipe info ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Phase badge
                  _PhaseBadge(pc: pc),
                  const SizedBox(height: 12),

                  // Recipe name
                  Text(widget.recipeName, style: GoogleFonts.outfit(
                    fontSize: 24, fontWeight: FontWeight.w800,
                    color: cs.onSurface, letterSpacing: -0.4, height: 1.15)),
                  const SizedBox(height: 12),

                  // Meta chips
                  Wrap(spacing: 8, children: [
                    _MetaChip(Icons.access_time_rounded, widget.duration, cs),
                    _MetaChip(Icons.local_fire_department_rounded,
                      '${widget.kcal} kcal', cs),
                    _MetaChip(Icons.bar_chart_rounded, widget.difficulty, cs),
                  ]),
                  const SizedBox(height: 20),

                  // Why this phase card
                  _WhyThisPhaseCard(pc: pc),
                  const SizedBox(height: 20),

                  // Ingredients preview
                  _IngredientsPreview(pc: pc),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Phase badge ───────────────────────────────────────────────────────────────
class _PhaseBadge extends StatelessWidget {
  final PhaseColorSet pc;
  const _PhaseBadge({required this.pc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pc.light,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pc.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 7, height: 7,
          decoration: BoxDecoration(
            color: pc.primary, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text('${pc.emoji}  ${pc.name}', style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: pc.text)),
      ]),
    );
  }
}

// ── Meta chip ─────────────────────────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  const _MetaChip(this.icon, this.label, this.cs);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: cs.primary),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface)),
      ]),
    );
  }
}

// ── Why this phase card ───────────────────────────────────────────────────────
class _WhyThisPhaseCard extends StatelessWidget {
  final PhaseColorSet pc;
  const _WhyThisPhaseCard({required this.pc});

  static const _explanations = {
    CyclePhase.menstrual:
        'Pendant les règles, privilégie des aliments riches en fer et anti-inflammatoires. Le chocolat chaud et les soupes réchauffantes soulagent les crampes et compensent les pertes de fer.',
    CyclePhase.follicular:
        'En phase folliculaire, ton énergie remonte. Les bowls légers, les salades protéinées et les aliments frais soutiennent la production d\'œstrogènes et boostent ta vitalité.',
    CyclePhase.ovulation:
        'Autour de l\'ovulation, ton corps est au pic de son énergie. Les aliments antioxydants, colorés et protéinés soutiennent la fertilité et maintiennent l\'endurance.',
    CyclePhase.luteal:
        'En phase lutéale, les envies de réconfort augmentent. Les glucides complexes et les aliments riches en magnésium réduisent les symptômes du SPM et stabilisent l\'humeur.',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pc.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pc.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(pc.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text('Pourquoi pour la phase ${pc.name} ?',
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: pc.text)),
        ]),
        const SizedBox(height: 8),
        Text(_explanations[pc.phase] ?? '', style: TextStyle(
          fontSize: 12, color: pc.text.withValues(alpha: 0.8), height: 1.55)),
      ]),
    );
  }
}

// ── Ingredients preview ───────────────────────────────────────────────────────
class _IngredientsPreview extends StatelessWidget {
  final PhaseColorSet pc;
  const _IngredientsPreview({required this.pc});

  static const _rows = [
    ('Filet de poulet', '150 g', 248),
    ('Légumes rôtis', '200 g', 80),
    ('Huile d\'olive', '1 c. à s.', 120),
    ('Épices & herbes', 'QS', 5),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Ingrédients', style: GoogleFonts.outfit(
        fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
      const SizedBox(height: 12),
      ..._rows.map((r) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: pc.primary, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(r.$1, style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface))),
            Text(r.$2, style: TextStyle(
              fontSize: 12, color: cs.onSurfaceVariant)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: pc.light,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${r.$3} kcal', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: pc.text)),
            ),
          ]),
        ),
      )),
    ]);
  }
}
