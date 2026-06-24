import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'badge_download_stub.dart'
    if (dart.library.html) 'badge_download_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import '../../l10n/app_localizations.dart';

// ─── Programme badge model ────────────────────────────────────────────────────
class ProgrammeBadge {
  final String id;
  final String programmeName;
  final String shortLabel; // e.g. "30J"
  final Color primaryColor;
  final Color accentColor;
  final IconData icon;
  final bool earned;
  final String? earnedDate;

  const ProgrammeBadge({
    required this.id,
    required this.programmeName,
    required this.shortLabel,
    required this.primaryColor,
    required this.accentColor,
    required this.icon,
    required this.earned,
    this.earnedDate,
  });
}

// Mock data
final kProgrammeBadges = [
  ProgrammeBadge(
    id: 'prog_debutante',
    programmeName: 'Débutante',
    shortLabel: '30J',
    primaryColor: const Color(0xFF00C853),
    accentColor: const Color(0xFF69F0AE),
    icon: LucideIcons.sprout,
    earned: true,
    earnedDate: '12 MAI 2025',
  ),
  ProgrammeBadge(
    id: 'prog_yoga',
    programmeName: 'Yoga & Zen',
    shortLabel: 'ZEN',
    primaryColor: const Color(0xFF7C4DFF),
    accentColor: const Color(0xFFB388FF),
    icon: LucideIcons.activity,
    earned: true,
    earnedDate: '3 AVR. 2025',
  ),
  ProgrammeBadge(
    id: 'prog_cardio',
    programmeName: 'Cardio',
    shortLabel: 'MAX',
    primaryColor: const Color(0xFFFF3D00),
    accentColor: const Color(0xFFFF9E80),
    icon: LucideIcons.zap,
    earned: false,
  ),
  ProgrammeBadge(
    id: 'prog_force',
    programmeName: 'Force',
    shortLabel: 'PRO',
    primaryColor: const Color(0xFF304FFE),
    accentColor: const Color(0xFF82B1FF),
    icon: LucideIcons.dumbbell,
    earned: false,
  ),
  ProgrammeBadge(
    id: 'prog_grossesse',
    programmeName: 'Maternité',
    shortLabel: 'MOM',
    primaryColor: const Color(0xFFE91E8C),
    accentColor: const Color(0xFFF48FB1),
    icon: LucideIcons.heart,
    earned: false,
  ),
  ProgrammeBadge(
    id: 'prog_champion',
    programmeName: 'Challenge',
    shortLabel: '60J',
    primaryColor: const Color(0xFFFF6D00),
    accentColor: const Color(0xFFFFD740),
    icon: LucideIcons.trophy,
    earned: false,
  ),
];

// ─── Programme Badges Section ─────────────────────────────────────────────────
class ProgrammeBadgesSection extends ConsumerWidget {
  const ProgrammeBadgesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final earned = kProgrammeBadges.where((b) => b.earned).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4, height: 20,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(l10n.badgeMesTophees,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w900,
                color: cs.onSurface, letterSpacing: 1.5,
              )),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('$earned / ${kProgrammeBadges.length}',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800,
                  color: cs.primary,
                )),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(l10n.badgeSelfieHint,
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant,
              letterSpacing: 0.2)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemCount: kProgrammeBadges.length,
          itemBuilder: (_, i) => _BadgeTile(badge: kProgrammeBadges[i]),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final ProgrammeBadge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: badge.earned
          ? () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => BadgeSelfieScreen(badge: badge)))
          : null,
      child: AnimatedOpacity(
        opacity: badge.earned ? 1.0 : 0.38,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: badge.earned
                ? badge.primaryColor.withOpacity(0.07)
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: badge.earned
                  ? badge.primaryColor.withOpacity(0.4)
                  : cs.outlineVariant.withOpacity(0.5),
              width: badge.earned ? 1.5 : 1,
            ),
            boxShadow: badge.earned
                ? [BoxShadow(
                    color: badge.primaryColor.withOpacity(0.22),
                    blurRadius: 16, offset: const Offset(0, 6))]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hexagonal badge
              SizedBox(
                width: 58, height: 58,
                child: CustomPaint(
                  painter: _HexPainter(
                    color: badge.primaryColor,
                    accent: badge.accentColor,
                    earned: badge.earned,
                  ),
                  child: Center(
                    child: Icon(badge.icon,
                      color: badge.earned ? Colors.white : cs.onSurfaceVariant,
                      size: 22),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Short label pill
              if (badge.earned)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: badge.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(badge.shortLabel,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 9,
                      fontWeight: FontWeight.w900, letterSpacing: 1.2,
                    )),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(badge.shortLabel,
                    style: TextStyle(
                      color: cs.onSurfaceVariant, fontSize: 9,
                      fontWeight: FontWeight.w900, letterSpacing: 1.2,
                    )),
                ),
              const SizedBox(height: 5),
              Text(badge.programmeName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: badge.earned ? cs.onSurface : cs.onSurfaceVariant,
                  letterSpacing: 0.2,
                )),
              if (badge.earned) ...[
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(LucideIcons.camera, size: 9,
                      color: badge.primaryColor),
                  const SizedBox(width: 3),
                  Text('SELFIE', style: TextStyle(
                    fontSize: 8, fontWeight: FontWeight.w900,
                    color: badge.primaryColor, letterSpacing: 0.8,
                  )),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hexagon tile painter ─────────────────────────────────────────────────────
class _HexPainter extends CustomPainter {
  final Color color;
  final Color accent;
  final bool earned;

  _HexPainter({required this.color, required this.accent, required this.earned});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 2;

    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * pi / 3) - pi / 6;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();

    if (earned) {
      canvas.drawShadow(path, color.withOpacity(0.5), 8, false);
      canvas.drawPath(path, Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0), Offset(size.width, size.height),
          [accent, color],
        ));
      // Inner lighter stroke
      canvas.drawPath(path, Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
    } else {
      canvas.drawPath(path, Paint()..color = const Color(0xFFE0E0E0));
    }
  }

  @override
  bool shouldRepaint(_HexPainter old) =>
      old.color != color || old.earned != earned;
}

// ─── Badge Selfie Screen ──────────────────────────────────────────────────────
class BadgeSelfieScreen extends ConsumerStatefulWidget {
  final ProgrammeBadge badge;
  const BadgeSelfieScreen({super.key, required this.badge});

  @override
  ConsumerState<BadgeSelfieScreen> createState() => _BadgeSelfieScreenState();
}

class _BadgeSelfieScreenState extends ConsumerState<BadgeSelfieScreen>
    with SingleTickerProviderStateMixin {
  Uint8List? _photoBytes;
  bool _saving = false;
  bool _saved = false;
  final _boundaryKey = GlobalKey();
  late AnimationController _shimmer;

  Offset _badgeOffset = const Offset(0.5, 0.65);
  double _badgeScale = 1.0;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 92,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() { _photoBytes = bytes; _saved = false; });
    }
  }

  Future<void> _exportImage() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final boundary = _boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final img = await boundary.toImage(pixelRatio: 3.0);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = data!.buffer.asUint8List();

      if (kIsWeb) {
        _downloadOnWeb(bytes);
      } else {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) await Gal.requestAccess();
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/fiteva_${DateTime.now().millisecondsSinceEpoch}.png';
        await File(path).writeAsBytes(bytes);
        await Gal.putImage(path, album: 'FitEva');
      }

      setState(() { _saved = true; _saving = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(kIsWeb ? ref.read(l10nProvider).badgeDownloaded : ref.read(l10nProvider).badgeSavedGallery,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
          backgroundColor: const Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: $e'), backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _downloadOnWeb(Uint8List bytes) => downloadImageOnWeb(bytes);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final badge = widget.badge;
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(badge, l10n),
            Expanded(
              child: _photoBytes == null
                  ? _buildEmptyState(badge, l10n)
                  : _buildPhotoPreview(sw, sh, badge, l10n),
            ),
            _buildBottomBar(badge, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ProgrammeBadge badge, AppL10n l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(LucideIcons.arrowLeft,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.badgeSelfieTitle,
                  style: TextStyle(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w900, letterSpacing: 2,
                  )),
                Text(badge.programmeName.toUpperCase(),
                  style: TextStyle(
                    color: badge.primaryColor, fontSize: 11,
                    fontWeight: FontWeight.w700, letterSpacing: 1,
                  )),
              ],
            ),
          ),
          if (_photoBytes != null)
            GestureDetector(
              onTap: _saving ? null : _exportImage,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: badge.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(
                    color: badge.primaryColor.withOpacity(0.45),
                    blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: _saving
                    ? const SizedBox(width: 14, height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          _saved ? LucideIcons.checkCircle : LucideIcons.download,
                          color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(_saved ? l10n.badgeSavedBtn : l10n.badgeExportBtn,
                          style: const TextStyle(
                            color: Colors.white, fontSize: 11,
                            fontWeight: FontWeight.w900, letterSpacing: 1,
                          )),
                      ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ProgrammeBadge badge, AppL10n l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Big athletic badge
          _SportBadgeGraphic(badge: badge, size: 180, shimmer: _shimmer),
          const SizedBox(height: 36),
          // Bold headline
          Text(l10n.badgeHeadline1,
            style: const TextStyle(
              color: Colors.white, fontSize: 26,
              fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1,
            )),
          Text(l10n.badgeHeadline2,
            style: TextStyle(
              color: badge.primaryColor, fontSize: 26,
              fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1,
            )),
          const SizedBox(height: 12),
          Text(l10n.badgeSubtext,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45), fontSize: 13,
              letterSpacing: 0.2,
            )),
          const SizedBox(height: 36),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SportBtn(
                icon: LucideIcons.camera,
                label: l10n.badgeSelfieBtn,
                color: badge.primaryColor,
                onTap: () => _pickPhoto(ImageSource.camera),
              ),
              const SizedBox(width: 12),
              _SportBtn(
                icon: LucideIcons.image,
                label: 'GALERIE',
                color: Colors.white.withOpacity(0.1),
                border: Colors.white.withOpacity(0.15),
                onTap: () => _pickPhoto(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview(double sw, double sh, ProgrammeBadge badge, AppL10n l10n) {
    final photoH = sh * 0.60;
    return Column(
      children: [
        RepaintBoundary(
          key: _boundaryKey,
          child: SizedBox(
            width: sw, height: photoH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(_photoBytes!, fit: BoxFit.cover),
                // Dark vignette at bottom
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: photoH * 0.4,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC000000)],
                      ),
                    ),
                  ),
                ),
                // FitEva tag bottom-left
                Positioned(
                  bottom: 14, left: 16,
                  child: Row(children: [
                    Container(
                      width: 3, height: 32,
                      color: badge.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.badgeFitEva,
                          style: TextStyle(
                            color: badge.primaryColor, fontSize: 10,
                            fontWeight: FontWeight.w900, letterSpacing: 2,
                          )),
                        Text(l10n.badgeProgCompleted,
                          style: const TextStyle(
                            color: Colors.white, fontSize: 9,
                            fontWeight: FontWeight.w700, letterSpacing: 1,
                          )),
                        if (badge.earnedDate != null)
                          Text(badge.earnedDate!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 8, letterSpacing: 0.5,
                            )),
                      ],
                    ),
                  ]),
                ),
                // Draggable badge
                Positioned(
                  left: sw * _badgeOffset.dx - 65,
                  top: photoH * _badgeOffset.dy - 65,
                  child: GestureDetector(
                    onScaleUpdate: (d) {
                      setState(() {
                        _badgeOffset = Offset(
                          (_badgeOffset.dx + d.focalPointDelta.dx / sw)
                              .clamp(0.1, 0.9),
                          (_badgeOffset.dy + d.focalPointDelta.dy / photoH)
                              .clamp(0.1, 0.9),
                        );
                        _badgeScale =
                            (_badgeScale * d.scale).clamp(0.4, 2.8);
                      });
                    },
                    child: Transform.scale(
                      scale: _badgeScale,
                      child: _SportBadgeGraphic(
                          badge: badge, size: 130, shimmer: _shimmer),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(LucideIcons.move, size: 12,
                color: Colors.white.withOpacity(0.3)),
            const SizedBox(width: 6),
            Text(l10n.badgeMoveHint,
              style: TextStyle(
                color: Colors.white.withOpacity(0.3), fontSize: 10,
                fontWeight: FontWeight.w700, letterSpacing: 1.2,
              )),
          ]),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ProgrammeBadge badge, AppL10n l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(
            color: Colors.white.withOpacity(0.06), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(child: _SportBtn(
            icon: LucideIcons.camera,
            label: l10n.badgeSelfieBtn,
            color: badge.primaryColor,
            onTap: () => _pickPhoto(ImageSource.camera),
          )),
          const SizedBox(width: 10),
          Expanded(child: _SportBtn(
            icon: LucideIcons.image,
            label: l10n.badgeGalleryBtn,
            color: Colors.white.withOpacity(0.08),
            border: Colors.white.withOpacity(0.12),
            onTap: () => _pickPhoto(ImageSource.gallery),
          )),
          if (_photoBytes != null) ...[
            const SizedBox(width: 10),
            Expanded(child: _SportBtn(
              icon: _saved ? LucideIcons.checkCircle : LucideIcons.download,
              label: _saved ? l10n.badgeSavedBtn : l10n.badgeExportBtn,
              color: _saved
                  ? const Color(0xFF00C853)
                  : badge.primaryColor,
              onTap: _saving ? null : _exportImage,
            )),
          ],
        ],
      ),
    );
  }
}

// ─── Sporty badge graphic ─────────────────────────────────────────────────────
class _SportBadgeGraphic extends StatelessWidget {
  final ProgrammeBadge badge;
  final double size;
  final AnimationController shimmer;

  const _SportBadgeGraphic({
    required this.badge,
    required this.size,
    required this.shimmer,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (_, __) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _SportBadgePainter(
            primary: badge.primaryColor,
            accent: badge.accentColor,
            t: shimmer.value,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badge.icon, color: Colors.white, size: size * 0.22,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 8)]),
                SizedBox(height: size * 0.05),
                Text(badge.shortLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.155,
                    fontWeight: FontWeight.w900,
                    letterSpacing: size * 0.02,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
                  )),
                SizedBox(height: size * 0.02),
                SizedBox(
                  width: size * 0.6,
                  child: Text(badge.programmeName.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: size * 0.072,
                      fontWeight: FontWeight.w800,
                      letterSpacing: size * 0.008,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SportBadgePainter extends CustomPainter {
  final Color primary;
  final Color accent;
  final double t;

  _SportBadgePainter({
    required this.primary,
    required this.accent,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 3;

    // Pentagon-like sporty shield shape
    final path = _shieldPath(cx, cy, r);

    // Outer glow shadow
    canvas.drawShadow(path, primary.withOpacity(0.6), 14, false);

    // Main gradient fill
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx - r * 0.4, cy - r),
          Offset(cx + r * 0.4, cy + r),
          [accent, primary, Color.lerp(primary, Colors.black, 0.3)!],
          [0.0, 0.55, 1.0],
        ),
    );

    // Diagonal speed lines (sporty feel)
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = size.width * 0.04
      ..style = PaintingStyle.stroke;
    canvas.save();
    canvas.clipPath(path);
    for (var i = -2; i <= 4; i++) {
      final x = cx + i * size.width * 0.22;
      canvas.drawLine(
          Offset(x - size.height * 0.5, cy - size.height * 0.6),
          Offset(x + size.height * 0.5, cy + size.height * 0.6),
          linePaint);
    }

    // Shimmer sweep
    final shimmerX = t * size.width * 2.4 - size.width * 0.8;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(shimmerX, 0),
          Offset(shimmerX + size.width * 0.45, 0),
          [
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(0.22),
            Colors.white.withOpacity(0),
          ],
          [0.0, 0.5, 1.0],
        )
        ..blendMode = BlendMode.plus,
    );
    canvas.restore();

    // Outer border
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Inner lighter border
    final innerPath = _shieldPath(cx, cy, r * 0.86);
    canvas.drawPath(
      innerPath,
      Paint()
        ..color = Colors.white.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  // Shield/pentagon hybrid — flat top, pointed bottom
  Path _shieldPath(double cx, double cy, double r) {
    final path = Path();
    // 6 control points for a sporty shield
    final pts = [
      Offset(cx - r * 0.72, cy - r * 0.85), // top-left
      Offset(cx + r * 0.72, cy - r * 0.85), // top-right
      Offset(cx + r,        cy - r * 0.15), // right
      Offset(cx + r * 0.55, cy + r * 0.70), // bottom-right
      Offset(cx,            cy + r),         // bottom point
      Offset(cx - r * 0.55, cy + r * 0.70), // bottom-left
      Offset(cx - r,        cy - r * 0.15), // left
    ];
    path.moveTo(pts[0].dx, pts[0].dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_SportBadgePainter old) =>
      old.t != t || old.primary != primary;
}

// ─── Sport button ─────────────────────────────────────────────────────────────
class _SportBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? border;
  final VoidCallback? onTap;

  const _SportBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.border,
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
          borderRadius: BorderRadius.circular(10),
          border: border != null
              ? Border.all(color: border!, width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 7),
            Text(label,
              style: const TextStyle(
                color: Colors.white, fontSize: 11,
                fontWeight: FontWeight.w900, letterSpacing: 1.2,
              )),
          ],
        ),
      ),
    );
  }
}
