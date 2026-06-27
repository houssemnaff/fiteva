import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/app_localizations.dart';

import '../models/models.dart';
import 'shared/shared_widgets.dart';
import 'shared/donut_painters.dart';

class MealTypeSheet extends StatefulWidget {
  final String? initialTypeId;
  const MealTypeSheet({super.key, this.initialTypeId});

  @override
  State<MealTypeSheet> createState() => _MealTypeSheetState();
}

class _MealTypeSheetState extends State<MealTypeSheet> {
  int? _selected;

  // (icon, label, typeId)
  static const _types = [
    (LucideIcons.coffee,   'Petit déjeuner', 'breakfast'),
    (LucideIcons.utensils, 'Déjeuner',       'lunch'),
    (LucideIcons.apple,    'Collation',      'snack'),
    (LucideIcons.moon,     'Dîner',          'dinner'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialTypeId != null) {
      _selected = _types.indexWhere((t) => t.$3 == widget.initialTypeId);
      if (_selected == -1) _selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Indique ton repas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Quantité (en grammes)',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '247',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Type de repas',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                ..._types.asMap().entries.map(
                      (e) => GestureDetector(
                        onTap: () => setState(() => _selected = e.key),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: _selected == e.key
                                ? colorScheme.primary.withOpacity(0.1)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: _selected == e.key
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(e.value.$1,
                                size: 18,
                                color: _selected == e.key
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant),
                              const SizedBox(width: 12),
                              Text(
                                e.value.$2,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selected == e.key
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              if (_selected == e.key) ...[
                                const Spacer(),
                                Icon(Icons.check, color: colorScheme.primary, size: 18),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _selected != null
                      ? () => Navigator.pop(context, _types[_selected!].$3)
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: _selected != null
                          ? colorScheme.primary
                          : colorScheme.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Text(
                        'Ajouter',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ObjectifCard extends StatelessWidget {
  const ObjectifCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Objectif du jour : ~1920 kcal',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Builder(builder: (ctx) {
                final sw = MediaQuery.of(ctx).size.width;
                final ring = sw < 380 ? 82.0 : 96.0;
                return SizedBox(
                  width: ring, height: ring,
                  child: CustomPaint(
                    painter: const SimpleDonutPainter(pct: 0.45),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(fit: BoxFit.scaleDown,
                            child: Text('865', style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface))),
                          Text('kcal', style: TextStyle(
                            fontSize: 9, color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: const [
                    MacroProgress('Protéines', 25, 101, Color(0xFF1D9E75)),
                    SizedBox(height: 10),
                    MacroProgress('Glucides', 128, 238, Color(0xFF378ADD)),
                    SizedBox(height: 10),
                    MacroProgress('Lipides', 26, 63, Color(0xFFEF9F27)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MacroProgress extends StatelessWidget {
  final String label;
  final int current, target;
  final Color color;
  const MacroProgress(this.label, this.current, this.target, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
            ),
            Text(
              '$current g / $target g',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / target,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class EnAttenteCard extends StatelessWidget {
  const EnAttenteCard({super.key});

  static const _items = [
    ('🥪', 'Sandwich grillé à la patat...', 'Diner', 912),
    ('🫔', 'Enchiladas protéinées', 'Déjeuner', 1009),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_outlined, size: 14, color: colorScheme.onSurface),
              const SizedBox(width: 6),
              Text(
                'En attente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          ..._items.map(
            (e) => PendingMealItem(
              emoji: e.$1,
              name: e.$2,
              category: e.$3,
              calories: e.$4,
            ),
          ),
        ],
      ),
    );
  }
}

class PendingMealItem extends ConsumerWidget {
  final String emoji, name, category;
  final int calories;
  const PendingMealItem({
    super.key,
    required this.emoji,
    required this.name,
    required this.category,
    required this.calories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🥗 $category',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: colorScheme.primary,
                      fontWeight: FontWeight.w600)),
                const SizedBox(height: 1),
                Text(name,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface)),
                Text('$calories kcal',
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(l10n.mealMange,
                style: TextStyle(color: colorScheme.onPrimary,
                    fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class MealSectionWidget extends StatelessWidget {
  final MealSection section;
  final VoidCallback onAdd;
  final VoidCallback? onTapEntry;
  const MealSectionWidget({
    super.key,
    required this.section,
    required this.onAdd,
    this.onTapEntry,
  });

  int get _totalKcal => section.entries.fold(0, (s, e) => s + e.calories);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(section.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Row(children: [
                Flexible(child: Text(section.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface))),
                Text(' · $_totalKcal kcal',
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
              ]),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Icon(Icons.add, size: 18, color: colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...section.entries.map(
          (e) => GestureDetector(
            onTap: onTapEntry,
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(child: Text(e.emoji, style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '● Calories : ${e.calories} kcal',
                          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_vert, size: 14, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
        if (section.entries.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🍎', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Complète avec un fruit ou dessert healthy',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class QuickAddBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const QuickAddBtn({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Icon(icon, color: colorScheme.onSurface, size: 18),
      ),
    );
  }
}
