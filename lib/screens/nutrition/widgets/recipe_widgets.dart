import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ── Hero Meta chip ────────────────────────────────────────────────────────────
class HeroMeta extends StatelessWidget {
  final IconData icon;
  final String label;
  const HeroMeta({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 12, color: Colors.white.withOpacity(0.85)),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
  ]);
}

// ── Recipe Tag (hero overlay) ─────────────────────────────────────────────────
class RecipeTag extends StatelessWidget {
  final String label;
  const RecipeTag(this.label, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12)),
    child: Text(label,
        style: const TextStyle(color: kWhite, fontSize: 10, fontWeight: FontWeight.w500)),
  );
}

// ── Recipe Action icon+label ──────────────────────────────────────────────────
class RecipeAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const RecipeAction({super.key, required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(
        width: 44, height: 44,
        decoration: const BoxDecoration(color: kWhite, shape: BoxShape.circle),
        child: Icon(icon, color: kBrown, size: 18),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: kTextGrey)),
    ]),
  );
}

// ── Ingredients Tab ───────────────────────────────────────────────────────────
class IngredientsTab extends StatelessWidget {
  const IngredientsTab({super.key});

  static const _items = [
    '2 rice cakes',
    '100g fromage blanc 0%',
    '1 cc café soluble',
    '10g chocolat noir 70%',
    '1 cs mascarpone light',
  ];

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ingrédients',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kTextDark)),
        const SizedBox(height: 8),
        ..._items.map((i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                const Text('• ', style: TextStyle(color: kTextGrey)),
                Text(i, style: const TextStyle(fontSize: 13, color: kTextDark)),
              ]),
            )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(12)),
          child: const Text(
              'Astuce : Prépare cette recette la veille pour un résultat encore meilleur !',
              style: TextStyle(fontSize: 12, color: kTextGrey, height: 1.5)),
        ),
      ]);
}

// ── Steps Tab ─────────────────────────────────────────────────────────────────
class StepsTab extends StatelessWidget {
  const StepsTab({super.key});

  static const _steps = [
    'Mélange le fromage blanc avec le café soluble.',
    'Étale sur les rice cakes.',
    'Râpe le chocolat noir par-dessus.',
    'Dépose une cuillère de mascarpone light.',
    'Réfrigère 30 min avant de déguster.',
  ];

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ..._steps.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 24, height: 24,
                  decoration: const BoxDecoration(color: kBrown, shape: BoxShape.circle),
                  child: Center(child: Text('${e.key + 1}',
                      style: const TextStyle(
                          color: kWhite, fontSize: 11, fontWeight: FontWeight.w700))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(e.value,
                    style: const TextStyle(fontSize: 13, color: kTextDark, height: 1.5))),
              ]),
            )),
      ]);
}

// ── Nutrition Tab ─────────────────────────────────────────────────────────────
class NutritionTab extends StatelessWidget {
  const NutritionTab({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(14)),
    child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _NutriStat('Calories', '198 kcal', kYellow),
      _NutriStat('Protéines', '12g', kPink),
      _NutriStat('Glucides', '28g', kBlue),
      _NutriStat('Lipides', '4g', kLime),
    ]),
  );
}

class _NutriStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _NutriStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
    const SizedBox(height: 2),
    Text(label, style: const TextStyle(fontSize: 10, color: kTextGrey)),
  ]);
}