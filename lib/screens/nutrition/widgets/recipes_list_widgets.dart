import 'package:flutter/material.dart';

import '../models/models.dart';
import 'shared/shared_widgets.dart';

class ThemeCard extends StatelessWidget {
  final String name, sub;
  final Color color;
  const ThemeCard(this.name, this.sub, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 130,
        height: 90,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'COOK WITH',
              style: TextStyle(
                fontSize: 7,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.75),
                letterSpacing: 0.5,
              ),
            ),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                fontSize: 7,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.75),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
}

class CatCard extends StatelessWidget {
  final String emoji, name;
  final Color color;
  const CatCard(this.emoji, this.name, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 80,
        height: 86,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Center(child: Text(emoji, style: const TextStyle(fontSize: 32)),),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class PlanCard extends StatelessWidget {
  final String title, sub;
  final Color color;
  const PlanCard(this.title, this.sub, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: 160,
        height: 90,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PLAN ALIMENTAIRE',
              style: TextStyle(
                fontSize: 7,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.75),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 8,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.75),
              ),
            ),
          ],
        ),
      );
}

class RecipeBigCard extends StatelessWidget {
  final RecipeItem recipe;
  final VoidCallback? onTap;
  const RecipeBigCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: recipe.bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Stack(
                children: [
                  Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 60))),
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.scrim.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🌿 Existe en version végé',
                        style: TextStyle(color: colorScheme.onPrimary, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.bolt_outlined, size: 12, color: colorScheme.onSurfaceVariant),
                      Text(' 20 min  ', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                      Icon(Icons.access_time_outlined, size: 12, color: colorScheme.onSurfaceVariant),
                      Text(' 15 min', style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Wrap(spacing: 6, children: [
                    SmallTag('Protéiné'),
                    SmallTag('Sans Sucre Blanc'),
                  ]),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _InlineAction(icon: Icons.bookmark_border, label: 'Favoris'),
                      _InlineAction(icon: Icons.shopping_cart_outlined, label: 'Mes courses'),
                      _InlineAction(icon: Icons.calendar_month_outlined, label: 'Planifier'),
                      _InlineAction(icon: Icons.share_outlined, label: 'Partager'),
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

class _InlineAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InlineAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
          child: Icon(icon, color: colorScheme.primary, size: 18),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
