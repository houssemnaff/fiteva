import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/screens/workout/corpszone_playerscreen.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ── Zone definitions ──────────────────────────────────────────────────────────
class _ZoneDef {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color base;
  final Color dark;
  const _ZoneDef(this.label, this.sublabel, this.icon, this.base, this.dark);
}

const _zones = [
  _ZoneDef('Abdos',          'Gainage · Crunch',     LucideIcons.zap,        Color(0xFF1C4D30), Color(0xFF0E2B1A)),
  _ZoneDef('Haut du corps',  'Épaules · Dos · Bras', LucideIcons.dumbbell,   Color(0xFF4F7D66), Color(0xFF2A4A3A)),
  _ZoneDef('Bas du corps',   'Fessiers · Cuisses',   LucideIcons.activity,   Color(0xFF2E6F5E), Color(0xFF173D33)),
  _ZoneDef('Full body',      'Cardio · Force',       LucideIcons.target,     Color(0xFF2F3E46), Color(0xFF161E22)),
  _ZoneDef('Yoga',           'Souplesse · Équilibre',LucideIcons.sparkles,   Color(0xFF7ABB98), Color(0xFF3D6E54)),
  _ZoneDef('Méditation',     'Respiration · Calme',  LucideIcons.sun,        Color(0xFFA7B8AD), Color(0xFF5A7268)),
];

// ══════════════════════════════════════════════════════════════════════════════
class ZonesSection extends StatelessWidget {
  final List<Map<String, dynamic>> bodyZones;
  const ZonesSection({super.key, required this.bodyZones});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ZonesHeader(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Row 1 — wide left + narrow right
              SizedBox(
                height: 162,
                child: Row(children: [
                  Expanded(
                    flex: 5,
                    child: _ZoneTile(
                        zone: _zones[0], index: 0, bodyZones: bodyZones)),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: _ZoneTile(
                        zone: _zones[1], index: 1, bodyZones: bodyZones)),
                ]),
              ),

              const SizedBox(height: 12),

              // Row 2 — equal
              SizedBox(
                height: 148,
                child: Row(children: [
                  Expanded(
                    child: _ZoneTile(
                        zone: _zones[2], index: 2, bodyZones: bodyZones)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ZoneTile(
                        zone: _zones[3], index: 3, bodyZones: bodyZones)),
                ]),
              ),

              const SizedBox(height: 12),

              // Row 3 — narrow left + wide right
              SizedBox(
                height: 148,
                child: Row(children: [
                  Expanded(
                    flex: 4,
                    child: _ZoneTile(
                        zone: _zones[4], index: 4, bodyZones: bodyZones)),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: _ZoneTile(
                        zone: _zones[5], index: 5, bodyZones: bodyZones)),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _ZonesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const color = WorkoutColors.zone;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3,
            height: 42,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 12),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Center(
                child: Icon(LucideIcons.target,
                    size: 20, color: Colors.white))),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zones du corps',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cible une zone précise',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

// ── Zone bento tile ───────────────────────────────────────────────────────────
class _ZoneTile extends StatelessWidget {
  final _ZoneDef zone;
  final int index;
  final List<Map<String, dynamic>> bodyZones;

  const _ZoneTile(
      {required this.zone, required this.index, required this.bodyZones});

  void _navigate(BuildContext context) {
    final z = bodyZones.firstWhere(
      (b) => b['title']
          .toString()
          .toLowerCase()
          .contains(zone.label.toLowerCase().split(' ').first),
      orElse: () =>
          bodyZones.isNotEmpty ? bodyZones[0] : <String, dynamic>{},
    );
    if (z.isEmpty) return;
    final w = WorkoutModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: z['title'] ?? zone.label,
      category: 'Zone',
      duration: '15 min',
      level: 'Tous niveaux',
      calories: '150',
      imageUrl: z['imageUrl'] ?? '',
      exercises: List<String>.from(z['exercises'] ?? []),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              CorpsZonePlayerScreen(workout: w, zoneName: zone.label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final num = (index + 1).toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () => _navigate(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [zone.base, zone.dark],
          ),
          boxShadow: [
            BoxShadow(
                color: zone.base.withValues(alpha: 0.40),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ghost number backdrop
            Positioned(
              right: -10,
              bottom: -16,
              child: Text(
                num,
                style: GoogleFonts.outfit(
                  fontSize: 110,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withValues(alpha: 0.07),
                  height: 1,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28)),
                    ),
                    child:
                        Center(child: Icon(zone.icon, color: Colors.white, size: 18)),
                  ),

                  const Spacer(),

                  // Zone name
                  Text(
                    zone.label,
                    maxLines: 2,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Sub-label
                  Text(
                    zone.sublabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Cibler CTA
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  Colors.white.withValues(alpha: 0.30)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Cibler',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(LucideIcons.arrowRight,
                                size: 10, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
