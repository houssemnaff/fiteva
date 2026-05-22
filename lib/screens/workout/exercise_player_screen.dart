import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final String workoutTitle;
  final String exerciseName;
  final int exerciseIndex;
  final int totalExercises;
  final VoidCallback onCompleted;

  const ExercisePlayerScreen({
    super.key,
    required this.workoutTitle,
    required this.exerciseName,
    required this.exerciseIndex,
    required this.totalExercises,
    required this.onCompleted,
  });

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  bool _isDone = false;
  double _buttonScale = 1.0;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoReady = false;

  final List<String> _videoUrls = [
    'assets/videos/workout1.mp4',
    'assets/videos/workout2.mp4',
    'assets/videos/workout3.mp4',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final url = _videoUrls[widget.exerciseIndex % _videoUrls.length];
    _videoPlayerController = VideoPlayerController.asset(url);
    try {
      await _videoPlayerController!.initialize();
      if (!mounted) return;
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio, // ← هكا
        // aspectRatio: 9 / 16,
        placeholder: const ColoredBox(color: Colors.black),
      );
      setState(() {
        _isVideoReady = true;
      });
    } catch (e) {
      debugPrint('Video error: $e');
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _markAsDone() async {
    if (_isDone) return;
    setState(() => _buttonScale = 0.95);
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() {
      _isDone = true;
      _buttonScale = 1.0;
    });
    widget.onCompleted();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── VIDEO FULLSCREEN ──────────────────────────────────────
          Positioned.fill(
            child:
                _isVideoReady && _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
          ),
          // ── APPBAR OVERLAY ────────────────────────────────────────
       
          // ── BOTTOM SHEET ──────────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.13,
            minChildSize: 0.13,
            maxChildSize: 0.68,
            snap: true,
            snapSizes: const [0.13, 0.68],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: cs.background,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 14),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + pills
                          Text(
                            widget.exerciseName,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            children: [
                              _Pill('Fessiers'),
                              _Pill('Tapis'),
                              _Pill(
                                'Modéré',
                                icon: Icons.local_fire_department_rounded,
                                bg: cs.primary.withOpacity(0.12),
                                iconColor: cs.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Stats row
                          Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceVariant.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                _StatCell(value: '3', label: 'séries'),
                                _Divider(),
                                _StatCell(value: '45 sec', label: 'travail'),
                                _Divider(),
                                _StatCell(value: '15 sec', label: 'repos'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            'Debout, pieds écartés largeur épaules. Descends en pliant les genoux à 90° en gardant le dos bien droit et la poitrine sortie. Pousse sur tes talons pour remonter.',
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.65),
                              fontSize: 13,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tips card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cs.secondary.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: cs.secondary.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      size: 16,
                                      color: cs.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Conseils de forme',
                                      style: TextStyle(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _TipRow(
                                  'Garde les genoux alignés avec tes orteils.',
                                  cs,
                                ),
                                const SizedBox(height: 4),
                                _TipRow(
                                  'Engage ta sangle abdominale pendant tout le mouvement.',
                                  cs,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Prev / Next
                          Row(
                            children: [
                              Expanded(
                                child: _NavButton(
                                  label: '← Précédent',
                                  onTap: () {},
                                  cs: cs,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _NavButton(
                                  label: 'Suivant →',
                                  onTap: () {},
                                  cs: cs,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // CTA
                          GestureDetector(
                            onTap: _markAsDone,
                            child: AnimatedScale(
                              scale: _buttonScale,
                              duration: const Duration(milliseconds: 150),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: _isDone ? cs.secondary : cs.primary,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Center(
                                  child: Text(
                                    _isDone
                                        ? 'Terminé ✓'
                                        : 'Marquer comme terminé',
                                    style: TextStyle(
                                      color:
                                          _isDone
                                              ? cs.onSecondary
                                              : cs.onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
       
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    _CircleButton(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.exerciseName,
                        textAlign: TextAlign.center,
                        
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          shadows: [
                            Shadow(blurRadius: 8, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.exerciseIndex + 1} / ${widget.totalExercises}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ── HELPERS ───────────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _CircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.black38,
        shape: BoxShape.circle,
      ),
      child: child,
    ),
  );
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? bg;
  final Color? iconColor;
  const _Pill(this.text, {this.icon, this.bg, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? cs.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: iconColor ?? cs.primary),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.55),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 28,
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
  );
}

class _TipRow extends StatelessWidget {
  final String text;
  final ColorScheme cs;
  const _TipRow(this.text, this.cs);

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('• ', style: TextStyle(color: cs.onSurface.withOpacity(0.5))),
      Expanded(
        child: Text(
          text,
          style: TextStyle(color: cs.onSurface.withOpacity(0.65), fontSize: 13),
        ),
      ),
    ],
  );
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _NavButton({
    required this.label,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: cs.primary.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(vertical: 11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: Text(label, style: TextStyle(color: cs.primary, fontSize: 12)),
  );
}
