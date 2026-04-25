import 'package:fiteva/providers/nutrution_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'dart:math' as math;

// ── Palette ───────────────────────────────────────────────────────────────────
const _bgBeige    = Color(0xFFF5F7F6);
const _brown      = Color(0xFF2D5A45);
const _brownLight = Color(0xFFAB8066);
const _greenDark  = Color(0xFF2D5A45);
const _greenMid   = Color(0xFF4A7C5F);
const _greenLight = Color(0xFF6EAB84);
const _pinkMacro  = Color(0xFFE8A0C0);
const _blueMacro  = Color(0xFF7EC8E3);
const _greenMacro = Color(0xFF8FD1A0);
const _yellowBtn  = Color(0xFFF5D876);
const _white      = Color(0xFFFFFFFF);
const _textDark   = Color(0xFF2C1F14);
const _textGrey   = Color(0xFF9E8E80);

// ══════════════════════════════════════════════════════════════════════════════
// Main Screen
// ══════════════════════════════════════════════════════════════════════════════
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});
  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => _NutritionBody(gaugeAnim: _anim);
}

class _NutritionBody extends ConsumerWidget {
  final Animation<double> gaugeAnim;
  const _NutritionBody({required this.gaugeAnim});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionProvider);

    return Scaffold(
      backgroundColor: _bgBeige,
      appBar: const _TopBar(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Search bar ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _SearchBar(),
              ),
            ),
            // ── Daily tracking card ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _DailyTrackingCard(state: state, gaugeAnim: gaugeAnim),
              ),
            ),
            // ── AI plan banner ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _AIPlanBanner(),
              ),
            ),
            // ── Meal categories ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mes repas', style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: _textDark)),
                    Text('Tout voir >', style: TextStyle(
                        fontSize: 13, color: _textGrey)),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final cat = state.categories[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: _CategoryCard(category: cat),
                  );
                },
                childCount: state.categories.length,
              ),
            ),
            // ── New recipes ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nouvelles recettes', style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: _textDark)),
                    Text('Tout voir >', style: TextStyle(
                        fontSize: 13, color: _textGrey)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: _RecipesHorizontalList(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Top Bar
// ══════════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(104);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: _bgBeige,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Nutrition', style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: _textDark)),
                const SizedBox(width: 11),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _brown.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Beta', style: TextStyle(
                      fontSize: 11, color: _brown, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 2),
              Text('Nourris tes objectifs', style: TextStyle(
                  fontSize: 13, color: _textGrey)),
            ]),
            const Spacer(),
            // Notebook icon
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                    blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Icon(LucideIcons.clipboardList, color: _textDark, size: 20),
            ),
            const SizedBox(width: 10),
            // Avatar
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _white,
                border: Border.all(color: _brownLight.withOpacity(0.4), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                    blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Icon(LucideIcons.user, color: _textGrey, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Search Bar
// ══════════════════════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _brown,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(children: [
        Icon(LucideIcons.search, color: _white.withOpacity(0.8), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Trouve ta recette', style: TextStyle(
              color: _white.withOpacity(0.85), fontSize: 15,
              fontWeight: FontWeight.w500)),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(LucideIcons.sliders, color: _white, size: 16),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Daily Tracking Card
// ══════════════════════════════════════════════════════════════════════════════
class _DailyTrackingCard extends StatelessWidget {
  final NutritionState state;
  final Animation<double> gaugeAnim;
  const _DailyTrackingCard({required this.state, required this.gaugeAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _bgBeige,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.trendingUp,
                    color: _brown, size: 16),
              ),
              const SizedBox(width: 10),
              Text('Suivi journalier', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: _textDark)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _greenDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Text('Consulter', style: TextStyle(
                    color: _white, fontSize: 13,
                    fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(LucideIcons.chevronRight, color: _white, size: 14),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Donut + macros
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // Donut chart
          SizedBox(
            width: 130, height: 130,
            child: AnimatedBuilder(
              animation: gaugeAnim,
              builder: (context, _) {
                return CustomPaint(
                  painter: _DonutPainter(
                    proteinRatio: state.totalProtein / 120,
                    carbsRatio: state.totalCarbs / 200,
                    fatRatio: state.totalFat / 60,
                    animValue: gaugeAnim.value,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${state.totalCalories}',
                            style: TextStyle(fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: _textDark)),
                        Text('kcal', style: TextStyle(
                            fontSize: 12, color: _textGrey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 20),
          // Macros list
          Expanded(
            child: Column(children: [
              _MacroRow2('Protéines', '${state.totalProtein.round()} g',
                  _pinkMacro),
              const Divider(height: 16, color: Color(0xFFEEE8E0)),
              _MacroRow2('Glucides', '${state.totalCarbs.round()} g',
                  _blueMacro),
              const Divider(height: 16, color: Color(0xFFEEE8E0)),
              _MacroRow2('Lipides', '${state.totalFat.round()} g',
                  _greenMacro),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        // Action buttons row
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _ActionBtn(LucideIcons.camera),
          _ActionBtn(LucideIcons.qrCode),
          _ActionBtn(LucideIcons.chefHat),
          _ActionBtn(LucideIcons.fileEdit),
        ]),
        const SizedBox(height: 14),
        // Goal button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _yellowBtn,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎯', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text('Définir un objectif', style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: _brown)),
            ],
          ),
        ),
      ]),
    );
  }
}

class _MacroRow2 extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MacroRow2(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(
            fontSize: 13, color: _textDark))),
        Text(value, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
      ]);
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  const _ActionBtn(this.icon);

  @override
  Widget build(BuildContext context) => Container(
        width: 54, height: 54,
        decoration: BoxDecoration(
          color: _bgBeige,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Icon(icon, color: _textDark, size: 22),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// Donut Painter
// ══════════════════════════════════════════════════════════════════════════════
class _DonutPainter extends CustomPainter {
  final double proteinRatio, carbsRatio, fatRatio, animValue;
  const _DonutPainter({
    required this.proteinRatio,
    required this.carbsRatio,
    required this.fatRatio,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.42;
    final strokeW = 14.0;
    final gap = 0.04;

    // Background ring
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()
          ..color = const Color(0xFFEEE8E0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW);

    // Segments: protein (pink), carbs (blue), fat (green)
    final total = (proteinRatio + carbsRatio + fatRatio).clamp(0.01, 10.0);
    final pAngle = (proteinRatio / total) * 2 * math.pi * animValue;
    final cAngle = (carbsRatio  / total) * 2 * math.pi * animValue;
    final fAngle = (fatRatio    / total) * 2 * math.pi * animValue;

    void arc(double start, double sweep, Color color) {
      if (sweep < 0.01) return;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start, sweep - gap, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
    }

    arc(-math.pi / 2,           pAngle, _pinkMacro);
    arc(-math.pi / 2 + pAngle,  cAngle, _blueMacro);
    arc(-math.pi / 2 + pAngle + cAngle, fAngle, _greenMacro);
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.animValue != animValue ||
      old.proteinRatio != proteinRatio;
}

// ══════════════════════════════════════════════════════════════════════════════
// AI Plan Banner
// ══════════════════════════════════════════════════════════════════════════════
class _AIPlanBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB8E4F0), Color(0xFFF0D9A8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text('✨', style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Générer un plan alimentaire personnalisé',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5B3FA0),
            ),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Category Card (meal category)
// ══════════════════════════════════════════════════════════════════════════════
class _CategoryCard extends ConsumerWidget {
  final MealCategory category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = category.budgetCalories > 0
        ? (category.totalCalories / category.budgetCalories).clamp(0.0, 1.0)
        : 0.0;
    final over = category.remainingCalories < 0;

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(
              builder: (_) => CategoryDetailPage(categoryId: category.id))),
      child: Container(
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                  color: _bgBeige,
                  borderRadius: BorderRadius.circular(13)),
              child: Center(child: Text(category.emoji,
                  style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(category.name, style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14,
                  color: _textDark)),
              Text('${category.recipes.length} recette${category.recipes.length != 1 ? "s" : ""}',
                  style: TextStyle(color: _textGrey, fontSize: 12)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              RichText(text: TextSpan(children: [
                TextSpan(text: '${category.totalCalories}',
                    style: TextStyle(fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: over ? Colors.red.shade400 : _textDark)),
                TextSpan(text: ' / ${category.budgetCalories}',
                    style: TextStyle(fontSize: 12, color: _textGrey)),
              ])),
              Text('kcal', style: TextStyle(
                  color: _greenLight, fontSize: 11,
                  fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(width: 6),
            Icon(LucideIcons.chevronRight, color: _textGrey, size: 16),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: _bgBeige,
              valueColor: AlwaysStoppedAnimation(
                  over ? Colors.red.shade300 : _greenLight),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            _Pill(
              icon: LucideIcons.flame,
              label: over
                  ? '+${(-category.remainingCalories)} kcal dépassés'
                  : '${category.remainingCalories} kcal restantes',
              color: over ? Colors.red.shade400 : _greenDark,
              bg: over ? Colors.red.shade50 : const Color(0xFFE8F3ED),
            ),
            const SizedBox(width: 8),
            _Pill(
              icon: LucideIcons.dumbbell,
              label: '${category.remainingProtein.abs().toStringAsFixed(1)}g prot.',
              color: _brown,
              bg: _bgBeige,
            ),
          ]),
        ]),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  const _Pill({required this.icon, required this.label,
      required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: bg,
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 11,
              color: color, fontWeight: FontWeight.w600)),
        ]),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// Recipes Horizontal List (placeholder cards)
// ══════════════════════════════════════════════════════════════════════════════
class _RecipesHorizontalList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (context, _) => const SizedBox(width: 12),
        itemCount: 4,
        itemBuilder: (_, i) => _RecipeCard(index: i),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final int index;
  const _RecipeCard({required this.index});

  static const _colors = [
    Color(0xFFD4E8D0),
    Color(0xFFE8D4C8),
    Color(0xFFD0D8E8),
    Color(0xFFE8E0D0),
  ];
  static const _emojis = ['🥗', '🍳', '🥑', '🍲'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: _colors[index % _colors.length],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(children: [
        Center(child: Text(_emojis[index % _emojis.length],
            style: const TextStyle(fontSize: 52))),
        Positioned(
          bottom: 10, left: 10, right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: _white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Recette ${index + 1}',
                style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w600, color: _textDark),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Category Detail Page (unchanged logic, updated style)
// ══════════════════════════════════════════════════════════════════════════════
class CategoryDetailPage extends ConsumerWidget {
  final String categoryId;
  const CategoryDetailPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(nutritionProvider);
    final notifier = ref.read(nutritionProvider.notifier);
    final cat      = state.categories.firstWhere((c) => c.id == categoryId);

    return Scaffold(
      backgroundColor: _bgBeige,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _DetailHeader(cat: cat, notifier: notifier)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _DetailMacroCard(cat: cat),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _ScanCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel('Recettes'),
                  TextButton.icon(
                    onPressed: () => _showAddRecipeSheet(context, notifier, cat.id),
                    style: TextButton.styleFrom(foregroundColor: _greenDark),
                    icon: const Icon(LucideIcons.plus, size: 15),
                    label: const Text('Ajouter',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
          cat.recipes.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(children: [
                      Icon(LucideIcons.utensils,
                          color: _greenLight.withOpacity(0.4), size: 48),
                      const SizedBox(height: 12),
                      Text('Aucune recette pour ce repas',
                          style: TextStyle(color: _textGrey, fontSize: 14)),
                    ]),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final recipe = cat.recipes[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: _RecipeTile(
                          recipe: recipe,
                          onDelete: () => notifier.removeRecipe(cat.id, recipe.id),
                        ),
                      );
                    },
                    childCount: cat.recipes.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  void _showAddRecipeSheet(BuildContext context,
      NutritionNotifier notifier, String catId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddRecipeSheet(notifier: notifier, categoryId: catId),
    );
  }
}

// ── Detail Header ──────────────────────────────────────────────────────────────
class _DetailHeader extends StatelessWidget {
  final MealCategory cat;
  final NutritionNotifier notifier;
  const _DetailHeader({required this.cat, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final pct = cat.budgetCalories > 0
        ? (cat.totalCalories / cat.budgetCalories).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: _greenDark,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.arrowLeft, color: _white, size: 18),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showBudgetSheet(context, notifier, cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: _white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: const [
                    Icon(LucideIcons.settings2, color: _white, size: 14),
                    SizedBox(width: 6),
                    Text('Budget', style: TextStyle(color: _white, fontSize: 13,
                        fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              Text(cat.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cat.name, style: const TextStyle(color: _white, fontSize: 24,
                    fontWeight: FontWeight.w700)),
                Text('Budget : ${cat.budgetCalories} kcal · ${cat.budgetProtein.round()}g prot.',
                    style: TextStyle(color: _white.withOpacity(0.65), fontSize: 12)),
              ]),
            ]),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: _white.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(
                    pct >= 1.0 ? Colors.red.shade300 : _greenLight),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${cat.totalCalories} kcal consommées',
                  style: TextStyle(color: _white.withOpacity(0.7), fontSize: 12)),
              Text(cat.remainingCalories >= 0
                  ? '${cat.remainingCalories} restantes'
                  : '${-cat.remainingCalories} dépassées',
                  style: TextStyle(
                      color: cat.remainingCalories >= 0
                          ? _greenLight
                          : Colors.red.shade300,
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showBudgetSheet(BuildContext context,
      NutritionNotifier notifier, MealCategory cat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BudgetSheet(notifier: notifier, cat: cat),
    );
  }
}

// ── Detail Macro Card ─────────────────────────────────────────────────────────
class _DetailMacroCard extends StatelessWidget {
  final MealCategory cat;
  const _DetailMacroCard({required this.cat});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Row(children: [
          _StatBlock('Total kcal', '${cat.totalCalories}',
              '/ ${cat.budgetCalories}', _greenDark),
          _vDiv(),
          _StatBlock('Protéines', '${cat.totalProtein.toStringAsFixed(1)}g',
              '/ ${cat.budgetProtein.round()}g', _pinkMacro),
          _vDiv(),
          _StatBlock('Glucides', '${cat.totalCarbs.toStringAsFixed(1)}g',
              '', _blueMacro),
          _vDiv(),
          _StatBlock('Lipides', '${cat.totalFat.toStringAsFixed(1)}g',
              '', _greenMacro),
        ]),
      );

  Widget _vDiv() => Container(width: 1, height: 44,
      color: const Color(0xFFEEE8E0),
      margin: const EdgeInsets.symmetric(horizontal: 6));
}

class _StatBlock extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _StatBlock(this.label, this.value, this.sub, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w700,
              fontSize: 15, color: color)),
          if (sub.isNotEmpty)
            Text(sub, style: TextStyle(fontSize: 10, color: _textGrey)),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: _textGrey,
              fontSize: 10, fontWeight: FontWeight.w500)),
        ]),
      );
}

// ── Recipe Tile ───────────────────────────────────────────────────────────────
class _RecipeTile extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onDelete;
  const _RecipeTile({required this.recipe, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
                color: _bgBeige, borderRadius: BorderRadius.circular(13)),
            child: Icon(LucideIcons.utensils, color: _greenDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(recipe.name, style: TextStyle(fontWeight: FontWeight.w600,
                fontSize: 14, color: _textDark)),
            const SizedBox(height: 6),
            Row(children: [
              _MiniPill('${recipe.calories} kcal', _greenDark, _bgBeige),
              const SizedBox(width: 6),
              _MiniPill('P ${recipe.protein.round()}g',
                  const Color(0xFF4A7C5F), const Color(0xFFDCEEE4)),
              const SizedBox(width: 6),
              _MiniPill('G ${recipe.carbs.round()}g', _blueMacro,
                  const Color(0xFFDDF0F8)),
            ]),
          ])),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(LucideIcons.trash2,
                  color: Colors.red.shade300, size: 15),
            ),
          ),
        ]),
      );
}

class _MiniPill extends StatelessWidget {
  final String text;
  final Color color, bg;
  const _MiniPill(this.text, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: bg,
            borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(fontSize: 10,
            color: color, fontWeight: FontWeight.w600)),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// Add Recipe Bottom Sheet
// ══════════════════════════════════════════════════════════════════════════════
class _AddRecipeSheet extends StatefulWidget {
  final NutritionNotifier notifier;
  final String categoryId;
  const _AddRecipeSheet({required this.notifier, required this.categoryId});

  @override
  State<_AddRecipeSheet> createState() => _AddRecipeSheetState();
}

class _AddRecipeSheetState extends State<_AddRecipeSheet> {
  final _nameCtrl    = TextEditingController();
  final _calCtrl     = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl   = TextEditingController();
  final _fatCtrl     = TextEditingController();

  double get _cal  => double.tryParse(_calCtrl.text)     ?? 0;
  double get _pro  => double.tryParse(_proteinCtrl.text) ?? 0;
  double get _carb => double.tryParse(_carbsCtrl.text)   ?? 0;
  double get _fat  => double.tryParse(_fatCtrl.text)     ?? 0;

  @override
  void dispose() {
    _nameCtrl.dispose(); _calCtrl.dispose(); _proteinCtrl.dispose();
    _carbsCtrl.dispose(); _fatCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _cal <= 0) return;
    widget.notifier.addRecipe(
      widget.categoryId,
      RecipeModel(
        id: widget.notifier.newId(),
        name: name,
        calories: _cal.round(),
        protein: _pro, carbs: _carb, fat: _fat,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: _bgBeige,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Row(children: [
            Icon(LucideIcons.chefHat, color: _greenDark, size: 20),
            const SizedBox(width: 10),
            Text('Nouvelle recette', style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.w700, color: _textDark)),
          ]),
          const SizedBox(height: 20),
          _Field(controller: _nameCtrl, label: 'Nom de la recette',
              hint: 'ex: Bol de quinoa', icon: LucideIcons.pencil),
          const SizedBox(height: 12),
          _Field(controller: _calCtrl, label: 'Calories (kcal)',
              hint: '450', icon: LucideIcons.flame,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft,
            child: Text('Macronutriments', style: TextStyle(
                fontSize: 12, color: _textGrey,
                fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _Field(controller: _proteinCtrl,
                label: 'Protéines (g)', hint: '30',
                icon: LucideIcons.dumbbell,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(child: _Field(controller: _carbsCtrl,
                label: 'Glucides (g)', hint: '55',
                icon: LucideIcons.wheat,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}))),
          ]),
          const SizedBox(height: 10),
          SizedBox(width: 160,
            child: _Field(controller: _fatCtrl, label: 'Lipides (g)',
                hint: '10', icon: LucideIcons.droplet,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}))),
          if (_cal > 0) ...[
            const SizedBox(height: 16),
            _PreviewCard(cal: _cal, protein: _pro, carbs: _carb, fat: _fat),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _greenDark,
                foregroundColor: _white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Ajouter la recette',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Budget Edit Sheet
// ══════════════════════════════════════════════════════════════════════════════
class _BudgetSheet extends StatefulWidget {
  final NutritionNotifier notifier;
  final MealCategory cat;
  const _BudgetSheet({required this.notifier, required this.cat});

  @override
  State<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends State<_BudgetSheet> {
  late final TextEditingController _calCtrl;
  late final TextEditingController _protCtrl;

  @override
  void initState() {
    super.initState();
    _calCtrl  = TextEditingController(text: widget.cat.budgetCalories.toString());
    _protCtrl = TextEditingController(text: widget.cat.budgetProtein.round().toString());
  }

  @override
  void dispose() { _calCtrl.dispose(); _protCtrl.dispose(); super.dispose(); }

  void _save() {
    final cal  = int.tryParse(_calCtrl.text.trim())    ?? widget.cat.budgetCalories;
    final prot = double.tryParse(_protCtrl.text.trim()) ?? widget.cat.budgetProtein;
    widget.notifier.updateBudget(widget.cat.id, cal, prot);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: _bgBeige,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Row(children: [
          Text(widget.cat.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Modifier le budget', style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.w700, color: _textDark)),
            Text(widget.cat.name, style: TextStyle(
                color: _textGrey, fontSize: 13)),
          ]),
        ]),
        const SizedBox(height: 22),
        _Field(controller: _calCtrl, label: 'Budget calories (kcal)',
            hint: '500', icon: LucideIcons.flame,
            keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        _Field(controller: _protCtrl, label: 'Budget protéines (g)',
            hint: '30', icon: LucideIcons.dumbbell,
            keyboardType: TextInputType.number),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: _greenDark,
              foregroundColor: _white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Enregistrer',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared Widgets
// ══════════════════════════════════════════════════════════════════════════════
class _ScanCard extends StatelessWidget {
  const _ScanCard();
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_greenDark, _greenMid],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _greenDark.withOpacity(0.3),
              blurRadius: 16, offset: const Offset(0, 6))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: _white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(LucideIcons.camera, color: _white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Scanner un repas', style: TextStyle(color: _white,
                fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(height: 2),
            Text('Analyse automatique des calories',
                style: TextStyle(color: Color(0x88FFFFFF), fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: _greenLight,
                borderRadius: BorderRadius.circular(9)),
            child: const Icon(LucideIcons.arrowRight,
                color: _white, size: 15),
          ),
        ]),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 4, height: 18,
            decoration: BoxDecoration(color: _greenLight,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(fontSize: 17,
            fontWeight: FontWeight.w700, color: _textDark,
            letterSpacing: 0.2)),
      ]);
}

class _PreviewCard extends StatelessWidget {
  final double cal, protein, carbs, fat;
  const _PreviewCard({required this.cal, required this.protein,
      required this.carbs, required this.fat});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bgBeige,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _greenLight.withOpacity(0.4)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _PvStat('Kcal',     cal.round().toString(),            _greenDark),
          _PvStat('Prot.',    '${protein.toStringAsFixed(1)}g',  _pinkMacro),
          _PvStat('Glucides', '${carbs.toStringAsFixed(1)}g',    _blueMacro),
          _PvStat('Lipides',  '${fat.toStringAsFixed(1)}g',      _greenMacro),
        ]),
      );
}

class _PvStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _PvStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value, style: TextStyle(fontSize: 15,
            fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: _textGrey)),
      ]);
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  const _Field({
    required this.controller, required this.label,
    required this.hint, required this.icon,
    this.keyboardType = TextInputType.text, this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12,
              color: _textGrey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(fontSize: 14, color: _textDark,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: _textGrey.withOpacity(0.5),
                  fontSize: 14),
              prefixIcon: Icon(icon, size: 16, color: _greenLight),
              filled: true, fillColor: _bgBeige,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: _greenLight, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
            ),
          ),
        ],
      );
}