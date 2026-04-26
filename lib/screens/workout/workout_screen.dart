import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/workout_model.dart';
import '../../providers/mock_data_provider.dart';
import '../../theme/app_theme.dart';
import 'workout_detail_screen.dart';
import 'corpszone_playerscreen.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS  — iOS Light
// ─────────────────────────────────────────────
class _T {
  // Backgrounds  (iOS system grouped palette)
  static const bg       = Colors.white;   // systemGroupedBackground
  static const surface  = Colors.white; // secondarySystemGroupedBackground
  static const surface2 = Colors.white; // subtle fill / separator

  // Borders
  static const border   = Color(0x1A000000);   // ~10 % black separator

  // Text  (iOS label scale)
  static const text     = Color(0xFF000000);   // label
  static const textSec  = Color(0xFF636366);   // secondaryLabel
  static const muted    = Color(0xFFAEAEB2);   // tertiaryLabel

  // Accent — iOS blue
  static const accent   = Color.fromARGB(255, 68, 212, 126);

  // Category colours — native iOS palette
  static const hiit     = Color(0xFFFF3B30);   // iOS red
  static const muscu    = Color(0xFF1C4D30);   // iOS blue
  static const pilates  = Color(0xFFAF52DE);   // iOS purple
  static const dance    = Color(0xFFFF2D55);   // iOS pink
  static const running  = Color(0xFF34C759);   // iOS green
  static const yoga     = Color(0xFFFF9500);   // iOS orange

  // ── SF Pro text styles ──────────────────────
  static const tsLargeTitle = TextStyle(
    color: text, fontSize: 34, fontWeight: FontWeight.w700,
    letterSpacing: 0.37, height: 1.21,
  );
  static const tsTitle3 = TextStyle(
    color: text, fontSize: 20, fontWeight: FontWeight.w600,
    letterSpacing: 0.38, height: 1.3,
  );
  static const tsHeadline = TextStyle(
    color: text, fontSize: 17, fontWeight: FontWeight.w600,
    letterSpacing: -0.41, height: 1.29,
  );
  static const tsCallout = TextStyle(
    color: textSec, fontSize: 16, fontWeight: FontWeight.w400,
    letterSpacing: -0.32, height: 1.31,
  );
  static const tsSubhead = TextStyle(
    color: textSec, fontSize: 15, fontWeight: FontWeight.w400,
    letterSpacing: -0.24, height: 1.33,
  );
  static const tsFootnote = TextStyle(
    color: muted, fontSize: 13, fontWeight: FontWeight.w400,
    letterSpacing: -0.08, height: 1.38,
  );
}

// ─────────────────────────────────────────────
// CATEGORY CONFIG
// ─────────────────────────────────────────────
class _Cat {
  final String   label;
  final String   key;
  final Color    color;
  final IconData icon;
  const _Cat(this.label, this.key, this.color, this.icon);
}

const _cats = [
  _Cat('Tout',    '',             _T.accent,  Icons.bolt_rounded),
  _Cat('Muscu',   'MUSCULATION',  _T.muscu,   Icons.fitness_center_rounded),
  _Cat('HIIT',    'HIIT',         _T.hiit,    Icons.local_fire_department_rounded),
  _Cat('Pilates', 'PILATES',      _T.pilates, Icons.self_improvement_rounded),
  _Cat('Danse',   'DANCE',        _T.dance,   Icons.music_note_rounded),
  _Cat('Running', 'RUNNING',      _T.running, Icons.directions_run_rounded),
];

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  int  _selectedCat = 0;
  bool _showAll     = false;

  Color _colorFor(String category) {
    switch (category.toUpperCase()) {
      case 'MUSCULATION': return _T.muscu;
      case 'HIIT':        return _T.hiit;
      case 'PILATES':     return _T.pilates;
      case 'DANCE':       return _T.dance;
      case 'RUNNING':     return _T.running;
      case 'YOGA':        return _T.yoga;
      default:            return _T.accent;
    }
  }

  List<WorkoutModel> _filtered(List<WorkoutModel> all) {
    if (_selectedCat == 0) return all;
    final key = _cats[_selectedCat].key;
    return all.where((w) => w.category.toUpperCase() == key).toList();
  }

  List<WorkoutModel> _onePerCategory(List<WorkoutModel> all) {
    final Map<String, WorkoutModel> seen = {};
    for (final w in all) seen.putIfAbsent(w.category.toUpperCase(), () => w);
    return seen.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final workouts  = ref.watch(workoutsProvider);
    final cycle     = ref.watch(cycleProvider);
    final bodyZones = ref.watch(bodyZonesProvider);
    final filtered  = _filtered(workouts);
    final swipe     = _onePerCategory(filtered);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,   // dark icons on white bg
      child: Scaffold(
        backgroundColor: _T.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── iOS LARGE TITLE APP BAR ─────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 96,
              backgroundColor: _T.bg,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1.0,
                titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Workouts', style: _T.tsLargeTitle),
                    Container(
                      width: 32, height: 32,
                      decoration: const BoxDecoration(
                        color: _T.surface2,
                        shape: BoxShape.circle,
                      ),
                    
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PhaseBanner(cycle: cycle),
                  const SizedBox(height: 20),
                  _CategoryChips(
                    selected: _selectedCat,
                    onSelect: (i) => setState(() {
                      _selectedCat = i;
                      _showAll     = false;
                    }),
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    title: _selectedCat == 0
                        ? 'Programmes recommandés'
                        : '${_cats[_selectedCat].label} workouts',
                    action: _showAll ? 'Voir moins' : 'Voir tout',
                    onAction: () => setState(() => _showAll = !_showAll),
                  ),
                  const SizedBox(height: 14),

                  if (_showAll)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _BentoGrid(
                        workouts: filtered,
                        colorFor: _colorFor,
                        onTap: _openDetail,
                      ),
                    )
                  else ...[
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: swipe.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _WorkoutCard(
                            workout: swipe[i],
                            color: _colorFor(swipe[i].category),
                            width: 210,
                            height: 280,
                            onTap: () => _openDetail(swipe[i]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _SectionHeader(
                      title: 'Par zone du corps',
                      action: 'Tout voir',
                      onAction: () {},
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _BodyZonesGrid(
                        zones: bodyZones,
                        onTap: (zone) => _openDetail(WorkoutModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: zone['title'] as String,
                          category: 'Zone',
                          duration: '15 min',
                          level: 'Tous niveaux',
                          calories: '150',
                          imageUrl: zone['imageUrl'] as String,
                          exercises: List<String>.from(zone['exercises'] as List),
                        )),
                      ),
                    ),
                  ],

                  const SizedBox(height: 110),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(WorkoutModel w) => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w)),
  );
}

// ─────────────────────────────────────────────
// PHASE BANNER
// ─────────────────────────────────────────────
class _PhaseBanner extends StatelessWidget {
  final dynamic cycle;
  const _PhaseBanner({required this.cycle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _T.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: _T.accent, shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'PHASE ${cycle.name.toUpperCase()}',
                  style: const TextStyle(
                    color: _T.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(cycle.advice, style: _T.tsCallout),
            const SizedBox(height: 14),
            
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CATEGORY CHIPS
// ─────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _CategoryChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: _cats.length,
        itemBuilder: (_, i) {
          final cat    = _cats[i];
          final active = selected == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: active ? cat.color : _T.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? cat.color : _T.border,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 13,
                        color: active ? Colors.white : _T.textSec),
                    const SizedBox(width: 6),
                    Text(
                      cat.label,
                      style: TextStyle(
                        color: active ? Colors.white : _T.textSec,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION HEADER  — iOS "Voir tout" in blue
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title, style: _T.tsTitle3,
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              action,
              style: const TextStyle(
                color: _T.accent,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WORKOUT CARD
// ─────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final Color        color;
  final double       width;
  final double       height;
  final VoidCallback onTap;
  const _WorkoutCard({
    required this.workout,
    required this.color,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: width, height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Real photo
              Image.network(
                workout.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _T.surface2),
              ),
              // Bottom gradient overlay
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),
              // Category badge — white pill, coloured text
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    workout.category.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Title + meta + play
              Positioned(
                left: 14, right: 14, bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      workout.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _MetaPill(icon: Icons.timer_outlined, label: workout.duration),
                        const SizedBox(width: 6),
                        _MetaPill(icon: Icons.bar_chart_rounded, label: workout.level),
                        const Spacer(),
                        // White circle play button, icon coloured by category
                        Container(
                          width: 36, height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: color, size: 22,
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
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BENTO GRID  (Voir tout mode)
// ─────────────────────────────────────────────
class _BentoGrid extends StatelessWidget {
  final List<WorkoutModel>          workouts;
  final Color Function(String)      colorFor;
  final void Function(WorkoutModel) onTap;
  const _BentoGrid({required this.workouts, required this.colorFor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final groups = <List<WorkoutModel>>[];
    for (int i = 0; i < workouts.length; i += 3) {
      groups.add(workouts.sublist(i, (i + 3).clamp(0, workouts.length)));
    }
    return Column(
      children: groups.map((g) =>
          _BentoRow(group: g, colorFor: colorFor, onTap: onTap)).toList(),
    );
  }
}

class _BentoRow extends StatelessWidget {
  final List<WorkoutModel>          group;
  final Color Function(String)      colorFor;
  final void Function(WorkoutModel) onTap;
  const _BentoRow({required this.group, required this.colorFor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final large  = group[0];
    final smalls = group.length > 1 ? group.sublist(1) : <WorkoutModel>[];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 11,
              child: _WorkoutCard(
                workout: large, color: colorFor(large.category),
                width: double.infinity, height: 224,
                onTap: () => onTap(large),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 10,
              child: Column(children: [
                if (smalls.isNotEmpty)
                  Expanded(child: _WorkoutCard(
                    workout: smalls[0], color: colorFor(smalls[0].category),
                    width: double.infinity, height: 108,
                    onTap: () => onTap(smalls[0]),
                  )),
                if (smalls.length > 1) ...[
                  const SizedBox(height: 8),
                  Expanded(child: _WorkoutCard(
                    workout: smalls[1], color: colorFor(smalls[1].category),
                    width: double.infinity, height: 108,
                    onTap: () => onTap(smalls[1]),
                  )),
                ],
                if (smalls.length == 1) const Expanded(child: SizedBox.shrink()),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BODY ZONES GRID
// ─────────────────────────────────────────────
class _BodyZonesGrid extends StatelessWidget {
  final List<Map<String, dynamic>>          zones;
  final void Function(Map<String, dynamic>) onTap;
  const _BodyZonesGrid({required this.zones, required this.onTap});

  static const _cfg = <Map<String, Object>>[
    {'label': 'Abdos',         'icon': Icons.radio_button_checked_rounded, 'color': _T.hiit},
    {'label': 'Haut du corps', 'icon': Icons.fitness_center_rounded,       'color': _T.muscu},
    {'label': 'Bas du corps',  'icon': Icons.directions_run_rounded,       'color': _T.running},
    {'label': 'Full body',     'icon': Icons.accessibility_new_rounded,    'color': _T.accent},
  ];

  Map<String, dynamic> _zoneFor(String label) => zones.firstWhere(
    (z) => z['title'].toString().toLowerCase()
        .contains(label.toLowerCase().split(' ').first),
    orElse: () => zones[0],
  );

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(child: _ZoneCard(cfg: _cfg[0], zone: _zoneFor('Abdos'), onTap: onTap)),
        const SizedBox(width: 10),
        Expanded(child: _ZoneCard(cfg: _cfg[1], zone: _zoneFor('Haut'),  onTap: onTap)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _ZoneCard(cfg: _cfg[2], zone: _zoneFor('Bas'),   onTap: onTap)),
        const SizedBox(width: 10),
        Expanded(child: _ZoneCard(cfg: _cfg[3], zone: _zoneFor('Full'),  onTap: onTap)),
      ]),
    ]);
  }
}

class _ZoneCard extends StatelessWidget {
  final Map<String, Object>                 cfg;
  final Map<String, dynamic>                zone;
  final void Function(Map<String, dynamic>) onTap;
  const _ZoneCard({required this.cfg, required this.zone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = cfg['color'] as Color;
    final icon  = cfg['icon']  as IconData;
    final label = cfg['label'] as String;

    return GestureDetector(
      onTap: () => onTap(zone),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 88,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                zone['imageUrl'] as String,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _T.surface2),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.68),
                      Colors.black.withOpacity(0.28),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 15),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}