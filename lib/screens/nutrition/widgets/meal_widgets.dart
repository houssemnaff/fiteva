import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/models.dart';
import 'shared/shared_widgets.dart';
import 'shared/donut_painters.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MEAL TYPE BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════════════════
class MealTypeSheet extends StatefulWidget {
  final VoidCallback onConfirm;
  const MealTypeSheet({super.key, required this.onConfirm});

  @override
  State<MealTypeSheet> createState() => _MealTypeSheetState();
}

class _MealTypeSheetState extends State<MealTypeSheet> {
  int? _selected;
  static const _types = [
    ('🍳', 'Petit déjeuner'),
    ('🥗', 'Déjeuner'),
    ('🍏', 'Collation'),
    ('🥘', 'Diner'),
    ('🍫', 'Extras'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
    decoration: const BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(2)))),
      const SizedBox(height: 16),
      Row(children: [
        const Expanded(child: Text('Indique ton repas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextDark))),
        GestureDetector(onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: kTextGrey)),
      ]),
      const SizedBox(height: 12),
      const Text('Quantité (en grammes)',
          style: TextStyle(fontSize: 12, color: kTextGrey, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withOpacity(0.06))),
        child: const Text('247',
            style: TextStyle(fontSize: 14, color: kTextDark, fontWeight: FontWeight.w500)),
      ),
      const SizedBox(height: 14),
      const Text('Type de repas',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kTextDark)),
      const SizedBox(height: 10),
      ..._types.asMap().entries.map((e) => GestureDetector(
        onTap: () => setState(() => _selected = e.key),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _selected == e.key ? kBrown.withOpacity(0.1) : kBg,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
                color: _selected == e.key ? kBrown : Colors.transparent, width: 1.5),
          ),
          child: Row(children: [
            Text(e.value.$1, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(e.value.$2, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: _selected == e.key ? kBrown : kTextDark)),
            if (_selected == e.key) ...[
              const Spacer(),
              const Icon(Icons.check, color: kBrown, size: 18),
            ],
          ]),
        ),
      )),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: _selected != null ? widget.onConfirm : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _selected != null ? kBrown : kBrown.withOpacity(0.3),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Center(child: Text('Ajouter',
              style: TextStyle(color: kWhite, fontSize: 15, fontWeight: FontWeight.w700))),
        ),
      ),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// OBJECTIF CARD (suivi screen)
// ══════════════════════════════════════════════════════════════════════════════
class ObjectifCard extends StatelessWidget {
  const ObjectifCard({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kWhite, borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Objectif du jour : ~1920 kcal',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kTextDark)),
      const SizedBox(height: 14),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          width: 100, height: 100,
          child: CustomPaint(
            painter: const SimpleDonutPainter(pct: 0.45),
            child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('865',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kTextDark)),
              Text('kcal', style: TextStyle(fontSize: 10, color: kTextGrey)),
            ])),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(children: const [
          MacroProgress('Protéines', 25, 101, kPink),
          SizedBox(height: 10),
          MacroProgress('Glucides', 128, 238, kBlue),
          SizedBox(height: 10),
          MacroProgress('Lipides', 26, 63, kLime),
        ])),
      ]),
    
    ]),
  );
}

class MacroProgress extends StatelessWidget {
  final String label;
  final int current, target;
  final Color color;
  const MacroProgress(this.label, this.current, this.target, this.color, {super.key});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: kTextGrey))),
          Text('$current g / $target g',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: kTextDark)),
        ]),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: current / target,
            backgroundColor: kBg,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ]);
}

// ══════════════════════════════════════════════════════════════════════════════
// EN ATTENTE CARD
// ══════════════════════════════════════════════════════════════════════════════
class EnAttenteCard extends StatelessWidget {
  const EnAttenteCard({super.key});

  static const _items = [
    ('🥪', 'Sandwich grillé à la patat...', 'Diner', 912),
    ('🫔', 'Enchiladas protéinées', 'Déjeuner', 1009),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: kWhite, borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.access_time_outlined, size: 14, color: kTextDark),
        SizedBox(width: 6),
        Text('En attente',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kTextDark)),
      ]),
      ..._items.map((e) => PendingMealItem(
            emoji: e.$1, name: e.$2, category: e.$3, calories: e.$4)),
    ]),
  );
}

class PendingMealItem extends StatelessWidget {
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: kDivider, width: 0.5))),
    child: Row(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
            color: const Color(0xFFE8D4C8),
            borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🥗 $category',
            style: const TextStyle(fontSize: 10, color: kGreenMid, fontWeight: FontWeight.w600)),
        const SizedBox(height: 1),
        Text(name,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: kTextDark)),
        Text('● Calories : $calories kcal',
            style: const TextStyle(fontSize: 11, color: kTextGrey)),
      ])),
      GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(color: kBrown, borderRadius: BorderRadius.circular(14)),
          child: const Text('Repas mangé 😊',
              style: TextStyle(color: kWhite, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// MEAL SECTION WIDGET
// ══════════════════════════════════════════════════════════════════════════════
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
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(section.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(section.title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700, color: kTextDark)),
          Text(' ($_totalKcal kcal)',
              style: const TextStyle(fontSize: 12, color: kTextGrey)),
          const Spacer(),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                  color: kWhite,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withOpacity(0.08))),
              child: const Icon(Icons.add, size: 18, color: kBrown),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        ...section.entries.map((e) => GestureDetector(
          onTap: onTapEntry,
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: kWhite, borderRadius: BorderRadius.circular(13)),
            child: Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                    color: const Color(0xFFD4E8D0),
                    borderRadius: BorderRadius.circular(9)),
                child: Center(child: Text(e.emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: kTextDark)),
                Text('● Calories : ${e.calories} kcal',
                    style: const TextStyle(fontSize: 11, color: kTextGrey)),
              ])),
              const Icon(Icons.more_vert, size: 14, color: kTextGrey),
            ]),
          ),
        )),
        if (section.entries.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xFFEAF8EC),
                borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Text('🍎', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Text('Complète avec un fruit ou dessert healthy',
                  style: TextStyle(fontSize: 12, color: Color(0xFF3B6D11))),
            ]),
          ),
      ]);
}

// ══════════════════════════════════════════════════════════════════════════════
// QUICK ADD BUTTON (bottom bar)
// ══════════════════════════════════════════════════════════════════════════════
class QuickAddBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const QuickAddBtn({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: kWhite, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Icon(icon, color: kTextDark, size: 18),
    ),
  );
}