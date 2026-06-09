import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TOKENS LOCAUX — cohérents avec le reste de l'app
// ─────────────────────────────────────────────────────────────────────────────
abstract class _C {
  static const bg        = Color(0xFFF5F3EE); // même fond que NutritionHomeScreen
  static const white     = Colors.white;
  static const card      = Colors.white;
  static const border    = Color(0x14000000); // black 8%
  static const green     = Color(0xFF085041);
  static const greenDark = Color(0xFF085041);
  static const greenBg   = Color(0xFFE1F5EE);
  static const textDark  = Color(0xFF1A1A1A);
  static const textGrey  = Color(0xFF888780);
  static const pill      = Color(0xFFF1EFE8);
  static const orange    = Color(0xFFD85A30);
  static const orangeBg  = Color(0xFFFAECE7);
  static const blue      = Color(0xFF378ADD);
  static const blueBg    = Color(0xFFE6F1FB);
  static const amber     = Color(0xFFBA7517);
  static const amberBg   = Color(0xFFFAEEDA);
  static const purple    = Color(0xFF534AB7);
  static const purpleBg  = Color(0xFFEEEDFE);
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class Ingredient {
  final String name, qty, imageUrl;
  final int kcal;
  const Ingredient({
    required this.name, required this.qty,
    required this.kcal, required this.imageUrl,
  });
}

class RecipeStep {
  final int number;
  final String title, description;
  const RecipeStep({required this.number, required this.title, required this.description});
}

class MacroStat {
  final String label;
  final int value, max;
  final Color color, bg;
  const MacroStat({
    required this.label, required this.value,
    required this.max, required this.color, required this.bg,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// STATIC DATA
// ─────────────────────────────────────────────────────────────────────────────
const _heroUrl =
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=900&q=80';

const _ingredients = [
  Ingredient(name: 'Oats',         qty: '80g',     kcal: 297, imageUrl: 'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=120&q=70'),
  Ingredient(name: 'Greek Yogurt', qty: '150g',    kcal: 88,  imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=120&q=70'),
  Ingredient(name: 'Banana',       qty: '1 pc',    kcal: 89,  imageUrl: 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=120&q=70'),
  Ingredient(name: 'Honey',        qty: '1 tbsp',  kcal: 64,  imageUrl: 'https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?w=120&q=70'),
  Ingredient(name: 'Almonds',      qty: '20g',     kcal: 116, imageUrl: 'https://images.unsplash.com/photo-1574184864703-3487b13f0edd?w=120&q=70'),
  Ingredient(name: 'Whey Protein', qty: '1 scoop', kcal: 120, imageUrl: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=120&q=70'),
];

const _steps = [
  RecipeStep(number: 1, title: 'Préparer la base',    description: 'Mesurer 80g de flocons d\'avoine et les placer dans un bol. Ajouter une pincée de sel.'),
  RecipeStep(number: 2, title: 'Mixer les protéines', description: 'Mélanger 1 dose de whey avec 150g de yaourt grec jusqu\'à obtenir une texture lisse.'),
  RecipeStep(number: 3, title: 'Incorporer',          description: 'Incorporer délicatement le yaourt aux flocons. Trancher la banane et en ajouter la moitié.'),
  RecipeStep(number: 4, title: 'Garnir',              description: 'Ajouter le reste de banane, les amandes concassées et un filet de miel cru.'),
  RecipeStep(number: 5, title: 'Repos (optionnel)',   description: 'Couvrir et réfrigérer 10 min pour ramollir les flocons. Servir frais ou à température ambiante.'),
];

const _macros = [
  MacroStat(label: 'Protéines', value: 38, max: 60,  color: _C.green,  bg: _C.greenBg),
  MacroStat(label: 'Glucides',  value: 52, max: 100, color: _C.blue,   bg: _C.blueBg),
  MacroStat(label: 'Lipides',   value: 14, max: 40,  color: _C.amber,  bg: _C.amberBg),
  MacroStat(label: 'Fibres',    value: 7,  max: 30,  color: _C.purple, bg: _C.purpleBg),
];

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class RecipeDetailScreen extends StatefulWidget {
  final dynamic recipe;
  const RecipeDetailScreen({super.key, this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with TickerProviderStateMixin {
  int  _tab      = 0;
  int  _portions = 1;
  bool _saved    = false;

  late final ScrollController _scroll;
  VideoPlayerController? _videoCtrl;
  ChewieController?      _chewieCtrl;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final ctrl = VideoPlayerController.asset('assets/videos/workout1.mp4');
    try {
      await ctrl.initialize();
      final chewie = ChewieController(
        videoPlayerController: ctrl,
        autoPlay: false,
        looping: false,
        aspectRatio: ctrl.value.aspectRatio,
        placeholder: Image.network(_heroUrl, fit: BoxFit.cover),
      );
      if (!mounted) { ctrl.dispose(); return; }
      setState(() { _videoCtrl = ctrl; _chewieCtrl = chewie; });
    } catch (_) {
      ctrl.dispose();
    }
  }

  @override
  void dispose() {
    _chewieCtrl?.dispose();
    _videoCtrl?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _showMealModal() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _MealTypeModal(),
  );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              // ── Hero ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: _HeroSection(
                  recipeName: widget.recipe?.name as String? ?? 'Oeufs brouillés',
                  saved: _saved,
                  onSave: () => setState(() => _saved = !_saved),
                  onBack: () => Navigator.maybePop(context),
                  chewieCtrl: _chewieCtrl,
                ),
              ),

              // ── Actions ───────────────────────────────────────
              const SliverToBoxAdapter(child: _ActionsRow()),

              // ── Portions + kcal ───────────────────────────────
              SliverToBoxAdapter(
                child: _PortionKcalSection(
                  portions: _portions,
                  onPortionChanged: (v) => setState(() => _portions = v),
                ),
              ),

              // ── Tab bar ───────────────────────────────────────
              SliverToBoxAdapter(
                child: _TabSelector(
                  active: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ),

              // ── Tab content ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: KeyedSubtree(
                      key: ValueKey(_tab),
                      child: switch (_tab) {
                        0 => const _IngredientsTab(),
                        1 => const _StepsTab(),
                        _ => const _NutritionTab(),
                      },
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // ── Bottom CTA ────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomCta(
              onBack:  () => Navigator.maybePop(context),
              onEaten: _showMealModal,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final String recipeName;
  final bool saved;
  final VoidCallback onSave, onBack;
  final ChewieController? chewieCtrl;

  const _HeroSection({
    required this.recipeName,
    required this.saved,
    required this.onSave,
    required this.onBack,
    this.chewieCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final cs  = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Video player (or fallback image) ──────────────────
        SizedBox(
          height: top + 240,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video or image
              chewieCtrl != null
                  ? Chewie(controller: chewieCtrl!)
                  : Image.network(
                      _heroUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: cs.secondaryContainer.withValues(alpha: 0.35)),
                    ),

              // Top gradient for buttons legibility
              Positioned(
                top: 0, left: 0, right: 0,
                height: top + 70,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Back + save buttons
              Positioned(
                top: top + 12, left: 16, right: 16,
                child: Row(children: [
                  _CircleBtn(icon: Icons.chevron_left, onTap: onBack),
                  const Spacer(),
                  _CircleBtn(
                    icon: saved ? Icons.favorite : Icons.favorite_border,
                    iconColor: saved ? Colors.red.shade300 : Colors.white,
                    onTap: onSave,
                  ),
                ]),
              ),
            ],
          ),
        ),

        // ── Info section below video ───────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tags
              Wrap(spacing: 6, children: const [
                _Tag('High Protein'),
                _Tag('Sugar-Free'),
                _Tag('Gluten-Free'),
              ]),
              const SizedBox(height: 10),
              // Recipe name
              Text(recipeName, style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w700,
                color: cs.onSurface, height: 1.15, letterSpacing: -.3,
              )),
              const SizedBox(height: 10),
              // Meta pills
              Wrap(spacing: 8, children: const [
                _MetaPill(icon: Icons.flash_on_rounded,              label: '5 min prep'),
                _MetaPill(icon: Icons.schedule_rounded,              label: '20 min total'),
                _MetaPill(icon: Icons.local_fire_department_rounded, label: '198 kcal'),
              ]),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _CircleBtn({
    required this.icon, required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: colorScheme.scrim.withOpacity(0.28),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w600,
        color: cs.primary, letterSpacing: .5)),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaPill({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: colorScheme.primary),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIONS ROW
// ─────────────────────────────────────────────────────────────────────────────
class _ActionsRow extends StatelessWidget {
  const _ActionsRow();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
        
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ActionBtn({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Column(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(
          fontSize: 10, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PORTIONS + KCAL
// ─────────────────────────────────────────────────────────────────────────────
class _PortionKcalSection extends StatelessWidget {
  final int portions;
  final ValueChanged<int> onPortionChanged;
  const _PortionKcalSection({
    required this.portions, required this.onPortionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(children: [
        // Sélecteur portions
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: List.generate(4, (i) {
              final n = i + 1;
              final sel = n == portions;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onPortionChanged(n),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 36,
                    decoration: BoxDecoration(
                      color: sel ? colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$n ${n == 1 ? "portion" : "portions"}',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: sel ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 10),

        // Kcal card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.35),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.local_fire_department_rounded,
                size: 22, color: colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Calories par portion',
                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${198 * portions}',
                    style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface)),
                  const SizedBox(width: 4),
                  Text('kcal',
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                ]),
            ]),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _MacroChip('P: ${38 * portions}g', colorScheme.primary,  colorScheme.secondaryContainer.withOpacity(0.35)),
              const SizedBox(height: 4),
              _MacroChip('G: ${52 * portions}g', colorScheme.secondary,  colorScheme.secondaryContainer.withOpacity(0.25)),
              const SizedBox(height: 4),
              _MacroChip('L: ${14 * portions}g', colorScheme.tertiary,  colorScheme.tertiaryContainer.withOpacity(0.25)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _MacroChip(this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB SELECTOR
// ─────────────────────────────────────────────────────────────────────────────
class _TabSelector extends StatelessWidget {
  final int active;
  final ValueChanged<int> onChanged;
  const _TabSelector({required this.active, required this.onChanged});

  static const _labels = ['Ingrédients', 'Étapes', 'Nutrition'];

  @override
  Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_labels.length, (i) {
            final sel = i == active;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  height: 38,
                  decoration: BoxDecoration(
                    color: sel ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(_labels[i], style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: sel ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  )),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INGREDIENTS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _IngredientsTab extends StatelessWidget {
  const _IngredientsTab();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: _ingredients.map((ing) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _IngredientCard(ingredient: ing),
      )).toList(),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  const _IngredientCard({required this.ingredient});
  @override
  Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            ingredient.imageUrl,
            width: 52, height: 52, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 52, height: 52, color: _C.pill,
              child: Icon(Icons.restaurant, color: colorScheme.onSurfaceVariant, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ingredient.name, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
            const SizedBox(height: 3),
            Text(ingredient.qty, style: TextStyle(
              fontSize: 12, color: colorScheme.onSurfaceVariant)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withOpacity(0.35),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('${ingredient.kcal} kcal', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEPS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _StepsTab extends StatefulWidget {
  const _StepsTab();
  @override
  State<_StepsTab> createState() => _StepsTabState();
}

class _StepsTabState extends State<_StepsTab> {
  final Set<int> _done = {};

  @override
  Widget build(BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: _steps.map((step) {
        final isDone = _done.contains(step.number);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => setState(() {
              isDone ? _done.remove(step.number) : _done.add(step.number);
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDone ? colorScheme.secondaryContainer.withOpacity(0.35) : colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDone
                        ? colorScheme.primary.withOpacity(0.10)
                        : colorScheme.shadow.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isDone ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isDone
                        ? Icon(Icons.check, size: 16, color: colorScheme.onPrimary)
                        : Text('${step.number}', style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: colorScheme.onSurfaceVariant,
                    )),
                    const SizedBox(height: 5),
                    Text(step.description, style: TextStyle(
                      fontSize: 12, color: colorScheme.onSurfaceVariant, height: 1.6)),
                  ],
                )),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NUTRITION TAB
// ─────────────────────────────────────────────────────────────────────────────
class _NutritionTab extends StatefulWidget {
  const _NutritionTab();
  @override
  State<_NutritionTab> createState() => _NutritionTabState();
}

class _NutritionTabState extends State<_NutritionTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(children: [
        _KcalCard(progress: _anim.value),
        const SizedBox(height: 12),
        _MacrosCard(progress: _anim.value),
      ]),
    );
  }
}

class _KcalCard extends StatelessWidget {
  final double progress;
  const _KcalCard({required this.progress});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(children: [
        // Ring
        SizedBox(
          width: 72, height: 72,
          child: CustomPaint(
            painter: _RingPainter(
              progress: progress * 0.11,
              trackColor: colorScheme.surfaceContainerHighest,
              fillColor: colorScheme.primary,
            ),
            child: const Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('198', style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
                Text('kcal', style: TextStyle(
                  fontSize: 9, color: Color(0xFF888780))),
              ],
            )),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Objectif journalier',
              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: LinearProgressIndicator(
                value: progress * 0.11,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text('198 / 1 800 kcal · 11%',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
          ],
        )),
      ]),
    );
  }
}

class _MacrosCard extends StatelessWidget {
  final double progress;
  const _MacrosCard({required this.progress});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Macronutriments',
          style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant, letterSpacing: .5)),
        const SizedBox(height: 16),
        ..._macros.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(m.label, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: m.bg, borderRadius: BorderRadius.circular(8)),
                child: Text('${m.value}g', style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: m.color)),
              ),
            ]),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: LinearProgressIndicator(
                value: progress * (m.value / m.max),
                minHeight: 5,
                backgroundColor: m.bg,
                valueColor: AlwaysStoppedAnimation(m.color),
              ),
            ),
          ]),
        )),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor, fillColor;
  const _RingPainter({
    required this.progress, required this.trackColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 10) / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke ..strokeWidth = 7 ..color = trackColor;
    final fill = Paint()
      ..style = PaintingStyle.stroke ..strokeWidth = 7
      ..strokeCap = StrokeCap.round ..color = fillColor;
    canvas.drawCircle(c, r, track);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r),
      -1.5708, progress * 2 * 3.14159, false, fill);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM CTA
// ─────────────────────────────────────────────────────────────────────────────
class _BottomCta extends StatelessWidget {
  final VoidCallback onBack, onEaten;
  const _BottomCta({required this.onBack, required this.onEaten});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.background.withOpacity(0), colorScheme.background, colorScheme.background],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 20, 20, MediaQuery.of(context).padding.bottom + 16),
      child: Row(children: [
        // Bouton retour
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 50, height: 52,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.chevron_left, color: colorScheme.onSurface, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        // Bouton principal
        Expanded(
          child: GestureDetector(
            onTap: onEaten,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                    size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text("J'ai mangé ça !",
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEAL TYPE MODAL
// ─────────────────────────────────────────────────────────────────────────────
class _MealTypeModal extends StatefulWidget {
  const _MealTypeModal();
  @override
  State<_MealTypeModal> createState() => _MealTypeModalState();
}

class _MealTypeModalState extends State<_MealTypeModal> {
  String? _selected;

  static const _meals = [
    (id: 'breakfast', icon: Icons.wb_twilight_rounded,   label: 'Petit déjeuner'),
    (id: 'lunch',     icon: Icons.wb_sunny_outlined,     label: 'Déjeuner'),
    (id: 'dinner',    icon: Icons.nights_stay_outlined,  label: 'Dîner'),
    (id: 'snack',     icon: Icons.bolt_rounded,          label: 'Collation'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).padding.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(9)),
          )),
          const SizedBox(height: 22),
          Text('Ajouter à un repas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
              color: colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text('Pour quel repas était-ce ?',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12, mainAxisSpacing: 12,
            childAspectRatio: 2.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _meals.map((m) {
              final sel = _selected == m.id;
              return GestureDetector(
                onTap: () => setState(() => _selected = m.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel ? colorScheme.secondaryContainer.withOpacity(0.35) : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: sel
                            ? colorScheme.primary.withOpacity(0.10)
                            : colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(children: [
                    Icon(m.icon, size: 20,
                      color: sel ? colorScheme.primary : colorScheme.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Text(m.label, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: sel ? colorScheme.primary : colorScheme.onSurface)),
                  ]),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity, height: 52,
            child: GestureDetector(
              onTap: _selected == null ? null : () {
                Navigator.pop(context);
                Navigator.maybePop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _selected != null ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: (_selected != null ? colorScheme.primary : colorScheme.shadow).withOpacity(_selected != null ? 0.18 : 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                ),
                alignment: Alignment.center,
                child: _selected != null
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Confirmer & Ajouter',
                            style: TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                        ])
                    : Text('Sélectionner un repas',
                        style: TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}