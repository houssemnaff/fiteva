import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

// ─── Programme badge model ────────────────────────────────────────────────────
class ProgrammeBadge {
  final String id;
  final String programmeName;
  final String emoji;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final bool earned;
  final String? earnedDate;

  const ProgrammeBadge({
    required this.id,
    required this.programmeName,
    required this.emoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.earned,
    this.earnedDate,
  });
}

// Mock data — replace with real provider when programme completion is wired up
final kProgrammeBadges = [
  ProgrammeBadge(
    id: 'prog_debutante',
    programmeName: 'Débutante 30j',
    emoji: '🌱',
    primaryColor: const Color(0xFF4CAF50),
    secondaryColor: const Color(0xFFE8F5E9),
    icon: LucideIcons.sprout,
    earned: true,
    earnedDate: '12 mai 2025',
  ),
  ProgrammeBadge(
    id: 'prog_yoga',
    programmeName: 'Yoga & Sérénité',
    emoji: '🧘',
    primaryColor: const Color(0xFF9C27B0),
    secondaryColor: const Color(0xFFF3E5F5),
    icon: LucideIcons.flower2,
    earned: true,
    earnedDate: '3 avr. 2025',
  ),
  ProgrammeBadge(
    id: 'prog_cardio',
    programmeName: 'Cardio Intense',
    emoji: '🔥',
    primaryColor: const Color(0xFFFF5722),
    secondaryColor: const Color(0xFFFBE9E7),
    icon: LucideIcons.flame,
    earned: false,
  ),
  ProgrammeBadge(
    id: 'prog_force',
    programmeName: 'Force & Puissance',
    emoji: '💪',
    primaryColor: const Color(0xFF5B5FEF),
    secondaryColor: const Color(0xFFE8EAF6),
    icon: LucideIcons.dumbbell,
    earned: false,
  ),
  ProgrammeBadge(
    id: 'prog_grossesse',
    programmeName: 'Grossesse Active',
    emoji: '🤰',
    primaryColor: const Color(0xFFE91E8C),
    secondaryColor: const Color(0xFFFCE4EC),
    icon: LucideIcons.heart,
    earned: false,
  ),
  ProgrammeBadge(
    id: 'prog_champion',
    programmeName: 'Challenge 60j',
    emoji: '🏆',
    primaryColor: const Color(0xFFFF9800),
    secondaryColor: const Color(0xFFFFF3E0),
    icon: LucideIcons.trophy,
    earned: false,
  ),
];

// ─── Programme Badges Section widget (used inside profile_screen.dart) ────────
class ProgrammeBadgesSection extends StatelessWidget {
  const ProgrammeBadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sw = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Programmes complétés',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
            Text('${kProgrammeBadges.where((b) => b.earned).length}/${kProgrammeBadges.length}',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: cs.primary)),
          ],
        ),
        const SizedBox(height: 6),
        Text('Appuie sur un badge obtenu pour prendre un selfie 📸',
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        const SizedBox(height: 14),
        Wrap(
          spacing: sw < 380 ? 10 : 12,
          runSpacing: 14,
          children: kProgrammeBadges.map((b) => _ProgrammeBadgeTile(badge: b)).toList(),
        ),
      ],
    );
  }
}

class _ProgrammeBadgeTile extends StatelessWidget {
  final ProgrammeBadge badge;
  const _ProgrammeBadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sw = MediaQuery.of(context).size.width;
    final size = (sw - 40) / 3 - 10;

    return GestureDetector(
      onTap: badge.earned
          ? () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => BadgeSelfieScreen(badge: badge)))
          : null,
      child: Opacity(
        opacity: badge.earned ? 1.0 : 0.35,
        child: Container(
          width: size,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: badge.earned
                ? badge.primaryColor.withOpacity(0.08)
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: badge.earned
                  ? badge.primaryColor.withOpacity(0.30)
                  : cs.outlineVariant,
              width: 1.5,
            ),
            boxShadow: badge.earned
                ? [BoxShadow(color: badge.primaryColor.withOpacity(0.18),
                    blurRadius: 14, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: badge.earned
                          ? LinearGradient(
                              colors: [badge.primaryColor, badge.secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight)
                          : null,
                      color: badge.earned ? null : cs.surfaceContainerHighest,
                    ),
                    child: Center(child: Text(badge.emoji,
                        style: const TextStyle(fontSize: 22))),
                  ),
                  if (badge.earned)
                    Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: badge.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(Icons.check, size: 10, color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(badge.programmeName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: badge.earned ? badge.primaryColor : cs.onSurfaceVariant,
                  height: 1.2,
                )),
              if (badge.earned && badge.earnedDate != null) ...[
                const SizedBox(height: 3),
                Text(badge.earnedDate!,
                  style: TextStyle(fontSize: 8.5, color: cs.onSurfaceVariant)),
              ],
              if (badge.earned) ...[
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(LucideIcons.camera, size: 10, color: badge.primaryColor),
                  const SizedBox(width: 3),
                  Text('Selfie', style: TextStyle(fontSize: 9,
                      color: badge.primaryColor, fontWeight: FontWeight.w600)),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Badge Selfie Screen ──────────────────────────────────────────────────────
class BadgeSelfieScreen extends StatefulWidget {
  final ProgrammeBadge badge;
  const BadgeSelfieScreen({super.key, required this.badge});

  @override
  State<BadgeSelfieScreen> createState() => _BadgeSelfieScreenState();
}

class _BadgeSelfieScreenState extends State<BadgeSelfieScreen>
    with SingleTickerProviderStateMixin {
  Uint8List? _photoBytes;
  bool _saving = false;
  bool _saved = false;
  final _boundaryKey = GlobalKey();
  late AnimationController _shimmer;

  // Badge drag position (relative to photo overlay)
  Offset _badgeOffset = const Offset(0.5, 0.7);
  double _badgeScale = 1.0;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _saved = false;
      });
    }
  }

  Future<void> _exportImage() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      // Check/request gallery permission
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();

      final boundary = _boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/fiteva_badge_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(path).writeAsBytes(bytes);
      await Gal.putImage(path, album: 'FitEva');
      setState(() { _saved = true; _saving = false; });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Text('Sauvegardé dans la galerie !',
                style: TextStyle(fontWeight: FontWeight.w600)),
            ]),
            backgroundColor: const Color(0xFF1D9E75),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final badge = widget.badge;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12)),
                      child: const Icon(LucideIcons.arrowLeft,
                          color: Colors.white, size: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Badge Selfie',
                          style: const TextStyle(color: Colors.white,
                              fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(badge.programmeName,
                          style: TextStyle(color: Colors.white.withOpacity(0.6),
                              fontSize: 12)),
                      ],
                    ),
                  ),
                  if (_photoBytes != null)
                    GestureDetector(
                      onTap: _saving ? null : _exportImage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [badge.primaryColor,
                              badge.primaryColor.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(
                            color: badge.primaryColor.withOpacity(0.4),
                            blurRadius: 10, offset: const Offset(0, 3))],
                        ),
                        child: _saving
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(_saved ? LucideIcons.checkCircle
                                    : LucideIcons.download,
                                    color: Colors.white, size: 15),
                                const SizedBox(width: 6),
                                Text(_saved ? 'Sauvegardé' : 'Exporter',
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 13, fontWeight: FontWeight.w700)),
                              ]),
                      ),
                    ),
                ],
              ),
            ),

            // ── Preview area ──
            Expanded(
              child: _photoBytes == null
                  ? _buildEmptyState(cs, badge)
                  : _buildPhotoWithBadge(sw, sh, badge, _photoBytes!),
            ),

            // ── Bottom actions ──
            _buildBottomBar(cs, badge),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs, ProgrammeBadge badge) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Big badge preview
          _BadgeGraphic(badge: badge, size: 160, shimmer: _shimmer),
          const SizedBox(height: 32),
          Text('Montre ton badge au monde ! 🌟',
            style: const TextStyle(color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Prends une photo ou un selfie\net superpose ton badge dessus.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5),
                fontSize: 13, height: 1.5)),
          const SizedBox(height: 32),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionBtn(
                icon: LucideIcons.camera,
                label: 'Selfie',
                color: badge.primaryColor,
                onTap: () => _pickPhoto(ImageSource.camera),
              ),
              const SizedBox(width: 16),
              _ActionBtn(
                icon: LucideIcons.image,
                label: 'Galerie',
                color: Colors.white.withOpacity(0.15),
                onTap: () => _pickPhoto(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoWithBadge(double sw, double sh, ProgrammeBadge badge, Uint8List photoBytes) {
    final photoHeight = sh * 0.62;

    return Column(
      children: [
        RepaintBoundary(
          key: _boundaryKey,
          child: SizedBox(
            width: sw,
            height: photoHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photo
                Image.memory(photoBytes, fit: BoxFit.cover),

                // Gradient overlay at bottom
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: photoHeight * 0.35,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent,
                          Colors.black.withOpacity(0.6)],
                      ),
                    ),
                  ),
                ),

                // FitEva watermark
                Positioned(
                  bottom: 14, left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FitEva · Programme complété 🎉',
                        style: TextStyle(color: Colors.white.withOpacity(0.9),
                            fontSize: 11, fontWeight: FontWeight.w700,
                            letterSpacing: 0.3)),
                      Text(badge.earnedDate ?? '',
                        style: TextStyle(color: Colors.white.withOpacity(0.6),
                            fontSize: 9)),
                    ],
                  ),
                ),

                // Draggable badge overlay
                Positioned(
                  left: sw * _badgeOffset.dx - 70,
                  top: photoHeight * _badgeOffset.dy - 70,
                  child: GestureDetector(
                    onPanUpdate: (d) {
                      setState(() {
                        _badgeOffset = Offset(
                          (_badgeOffset.dx + d.delta.dx / sw)
                              .clamp(0.1, 0.9),
                          (_badgeOffset.dy + d.delta.dy / photoHeight)
                              .clamp(0.1, 0.9),
                        );
                      });
                    },
                    onScaleUpdate: (d) {
                      setState(() {
                        _badgeScale = (_badgeScale * d.scale).clamp(0.5, 2.5);
                      });
                    },
                    child: Transform.scale(
                      scale: _badgeScale,
                      child: _BadgeGraphic(badge: badge, size: 140,
                          shimmer: _shimmer),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Drag hint
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.move, size: 13,
                  color: Colors.white.withOpacity(0.4)),
              const SizedBox(width: 5),
              Text('Déplace et redimensionne le badge',
                style: TextStyle(fontSize: 11,
                    color: Colors.white.withOpacity(0.4))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ColorScheme cs, ProgrammeBadge badge) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: _ActionBtn(
              icon: LucideIcons.camera,
              label: 'Selfie',
              color: badge.primaryColor,
              onTap: () => _pickPhoto(ImageSource.camera),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionBtn(
              icon: LucideIcons.image,
              label: 'Galerie',
              color: Colors.white.withOpacity(0.12),
              onTap: () => _pickPhoto(ImageSource.gallery),
            ),
          ),
          if (_photoBytes != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _ActionBtn(
                icon: _saved ? LucideIcons.checkCircle : LucideIcons.download,
                label: _saved ? 'Sauvegardé !' : 'Exporter',
                color: _saved
                    ? const Color(0xFF1D9E75)
                    : badge.primaryColor,
                onTap: _saving ? null : _exportImage,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Badge graphic (the actual visual badge design) ───────────────────────────
class _BadgeGraphic extends StatelessWidget {
  final ProgrammeBadge badge;
  final double size;
  final AnimationController shimmer;

  const _BadgeGraphic({
    required this.badge,
    required this.size,
    required this.shimmer,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (_, __) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _BadgePainter(
              primaryColor: badge.primaryColor,
              secondaryColor: badge.secondaryColor,
              shimmerT: shimmer.value,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(badge.emoji,
                    style: TextStyle(fontSize: size * 0.26)),
                  SizedBox(height: size * 0.04),
                  SizedBox(
                    width: size * 0.65,
                    child: Text(badge.programmeName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: size * 0.095,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(color: Colors.black.withOpacity(0.4),
                              blurRadius: 4),
                        ],
                      )),
                  ),
                  SizedBox(height: size * 0.03),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size * 0.07, vertical: size * 0.02),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(size * 0.08),
                    ),
                    child: Text('COMPLÉTÉ ✓',
                      style: TextStyle(
                        fontSize: size * 0.07,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      )),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BadgePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double shimmerT;

  _BadgePainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.shimmerT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final rr = r - 4;

    // Outer star/shield shape (16-point)
    final path = Path();
    const points = 16;
    for (var i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final radius = i.isEven ? rr : rr * 0.88;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();

    // Drop shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.35), 10, false);

    // Gradient fill
    final gradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(size.width, size.height),
      [
        primaryColor,
        Color.lerp(primaryColor, Colors.white, 0.25)!,
        primaryColor.withOpacity(0.85),
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawPath(path,
        Paint()..shader = gradient..style = PaintingStyle.fill);

    // Inner ring
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), rr * 0.82, ringPaint);

    // Shimmer sweep
    final shimmerRect = Rect.fromCircle(center: Offset(cx, cy), radius: rr);
    canvas.save();
    canvas.clipPath(path);
    final shimmerGrad = ui.Gradient.linear(
      Offset(shimmerT * size.width * 2 - size.width, 0),
      Offset(shimmerT * size.width * 2 - size.width + size.width * 0.6, 0),
      [
        Colors.white.withOpacity(0),
        Colors.white.withOpacity(0.18),
        Colors.white.withOpacity(0),
      ],
      [0.0, 0.5, 1.0],
    );
    canvas.drawRect(shimmerRect,
        Paint()..shader = shimmerGrad..blendMode = BlendMode.plus);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BadgePainter old) =>
      old.shimmerT != shimmerT || old.primaryColor != primaryColor;
}

// ─── Reusable action button ───────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
