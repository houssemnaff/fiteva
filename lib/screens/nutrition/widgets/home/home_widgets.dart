import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_colors.dart';
import '../shared/donut_painters.dart';
import '../shared/shared_widgets.dart';

// ── Header ────────────────────────────────────────────────────────────────────
class NutritionHeader extends StatelessWidget {
  const NutritionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Container(
        color: colorScheme.background,
        padding: EdgeInsets.fromLTRB(20, top + 12, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ligne 1 : titre + actions ──────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Titre
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Nutrition',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                       
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.trending_up_rounded,
                            size: 12, color: Color(0xFF1D9E75)),
                        const SizedBox(width: 4),
                        Text(
                          'Nourris tes objectifs',
                          style: TextStyle(
                              fontSize: 12, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // Bouton journal
                
            
                // Avatar
              
              ],
            ),

            // ── Séparateur ─────────────────────────────────────
            const SizedBox(height: 14),
            Divider(
                height: 1,
                thickness: 0.5,
              color: colorScheme.outlineVariant),
            const SizedBox(height: 10),

            // ── Ligne 2 : date + statut ────────────────────────
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 13, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 5),
                Text(
                  _todayLabel(),
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: colorScheme.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                    Text(
                  'Sur la bonne voie',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const jours = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
      'Vendredi', 'Samedi', 'Dimanche'
    ];
    const mois = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${jours[now.weekday - 1]} ${now.day} ${mois[now.month - 1]} ${now.year}';
  }
}

// ── Bouton icône header ───────────────────────────────────────────────────────
class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: colorScheme.outlineVariant, width: 0.5),
        ),
        child: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
// carde mta cercle calories
class DailyTrackingCard extends StatelessWidget {
  final Animation<double> anim;
  final VoidCallback onConsulter;
  final VoidCallback onCamera;
  final VoidCallback onBarcode;
  final VoidCallback onRecipes;
  final VoidCallback onEdit;
  final int caloriesConsumed;
  final int caloriesGoal;

  const DailyTrackingCard({
    super.key,
    required this.anim,
    required this.onConsulter,
    required this.onCamera,
    required this.onBarcode,
    required this.onRecipes,
    required this.onEdit,
    required this.caloriesConsumed,
    required this.caloriesGoal,
  });
@override
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final int remaining = caloriesGoal - caloriesConsumed;

  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Column(
      children: [

        // 🔹 HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // LEFT
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: colorScheme.primary,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Suivi journalier',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // RIGHT BUTTON
            GestureDetector(
              onTap: onConsulter,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Text(
                      'Consulter',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.chevron_right,
                        color: colorScheme.onPrimary, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 🔥 BODY
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // LEFT (donut)
            Column(
              children: [
                SizedBox(
                  width: 118,
                  height: 118,
                  child: AnimatedBuilder(
                    animation: anim,
                    builder: (_, __) => CustomPaint(
                      painter: DonutPainter(
                        proteinRatio: 0.25,
                        carbsRatio: 0.54,
                        fatRatio: 0.41,
                        animValue: anim.value,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$caloriesConsumed',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                             Text(
                              'kcal',
                              style: TextStyle(
                                  fontSize: 11, color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Objectif: $caloriesGoal kcal',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  remaining >= 0
                      ? '$remaining restantes'
                      : '${remaining.abs()} en surplus',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: remaining >= 0 ? colorScheme.primary : colorScheme.error,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 18),

            // RIGHT (macros)
            Expanded(
              child: Column(
                children: [
                  MacroRow('Protéines', '25 g', colorScheme.primary),
                  Divider(height: 14, color: colorScheme.outlineVariant),
                  MacroRow('Glucides', '128 g', colorScheme.secondary),
                  Divider(height: 14, color: colorScheme.outlineVariant),
                  MacroRow('Lipides', '26 g', colorScheme.tertiary),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ⚡ ACTIONS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ActionBtn(icon: Icons.camera_alt_outlined, onTap: onCamera),
            _ActionBtn(icon: Icons.qr_code_outlined, onTap: onBarcode),
            _ActionBtn(icon: Icons.restaurant_menu_outlined, onTap: onRecipes),
            _ActionBtn(icon: Icons.edit_note_outlined, onTap: onEdit),
          ],
        ),
      ],
    ),
  );
}





}
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: colorScheme.primary),
      ),
    );
  }
}


class MealCategoryCard extends StatelessWidget {
  final MealCategoryData data;
  final VoidCallback onTap;
  const MealCategoryCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final over = data.remaining < 0;
    final progressColor = over ? colorScheme.tertiary : colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image avec overlay ───────────────────────────
            _MealHero(data: data, over: over),

            // ── Corps de la carte ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pourcentage / dépassement
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      over
                          ? '+${-data.remaining} kcal'
                          : '${(data.pct * 100).round()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: progressColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Barre de progression
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: data.pct.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(progressColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Pills
                  Row(
                    children: [
                      Expanded(
                        child: _Pill(
                          icon: Icons.access_time_rounded,
                          label: over
                              ? '+${-data.remaining} kcal dépassés'
                              : '${data.remaining} kcal restantes',
                          color: over
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                          bg: over
                              ? colorScheme.tertiaryContainer.withOpacity(0.3)
                              : colorScheme.secondaryContainer.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _Pill(
                          icon: Icons.align_horizontal_left_rounded,
                          label:
                              '${(data.proteinBudget - data.proteinConsumed).toStringAsFixed(1)}g prot. restantes',
                          color: colorScheme.onSurfaceVariant,
                          bg: colorScheme.surfaceContainerHighest,
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
// ── Hero image ────────────────────────────────────────────────────────────────
class _MealHero extends StatelessWidget {
  final MealCategoryData data;
  final bool over;
  const _MealHero({required this.data, required this.over});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          Image.network(
            data.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: colorScheme.surfaceContainerHighest),
          ),
          // Gradient sombre en bas
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.scrim.withOpacity(0.08),
                  colorScheme.scrim.withOpacity(0.55),
                ],
              ),
            ),
          ),
          // Contenu superposé
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // ← clé
              children: [
                // Ligne du haut : heure + badge dépassé
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassPill(data.time),
                    if (over)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD85A30).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Dépassé',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                      ),
                  ],
                ),
                // Ligne du bas : nom + kcal — FIXED avec Expanded + Flexible
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ← Expanded pour contraindre le texte à gauche
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis, // ← évite le débord
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 1.2),
                          ),
                          Text(
                            '${data.recipeCount} recettes',
                            style: TextStyle(
                                fontSize: 11,
                              color: Colors.white.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ← Partie droite à taille naturelle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${data.consumed}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: over
                                ? colorScheme.tertiaryContainer
                                  : Colors.white,
                              height: 1),
                        ),
                        Text(
                          '/ ${data.budget} kcal',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.65)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pill transparente pour l'heure ───────────────────────────────────────────
class _GlassPill extends StatelessWidget {
  final String label;
  const _GlassPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.85))),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _Pill({required this.icon, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // ← ne prend que l'espace nécessaire
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible( // ← clé : le texte se wrap si trop long
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recipe Card (horizontal scroll) ──────────────────────────────────────────
class RecipeCard extends StatelessWidget {
  final RecipeItem recipe;
  final VoidCallback? onTap;
  const RecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 128, height: 150,
      decoration: BoxDecoration(
          color: recipe.bgColor, borderRadius: BorderRadius.circular(16)),
      child: Stack(children: [
        Center(child: ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.network(
    recipe.emoji, // ← contient maintenant l'URL
    width: double.infinity,
    height: double.infinity,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      color: recipe.bgColor,
      child: const Icon(Icons.restaurant, color: Colors.grey),
    ),
    loadingBuilder: (_, child, progress) => progress == null
        ? child
        : Container(color: recipe.bgColor), // placeholder pendant le chargement
  ),
),
        ),
        Positioned(
          bottom: 8, left: 6, right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(7)),
            child: Text(recipe.label,
              style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                    
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ),
      ]),
    ),
  );
}