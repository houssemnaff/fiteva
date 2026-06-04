import 'package:flutter/material.dart';
import 'widgets/meal_widgets.dart';
import 'widgets/shared/shared_widgets.dart';

// ── Mock AI scan result ───────────────────────────────────────────────────────
const _kScanName       = 'Poulet rôti & légumes';
const _kScanKcal       = 380;
const _kScanProtein    = 42;
const _kScanCarbs      = 28;
const _kScanFat        = 12;
const _kScanConfidence = 94;

enum _ScanState { idle, scanning, result }

// ── Ingredient data ───────────────────────────────────────────────────────────
class _Ingredient {
  final String name, unit;
  final int kcal, protein, carbs, fat;
  const _Ingredient({
    required this.name, required this.unit,
    required this.kcal, required this.protein,
    required this.carbs, required this.fat,
  });
}

const _kIngredients = [
  _Ingredient(name: 'Poulet (filet)',    unit: '100 g', kcal: 165, protein: 31, carbs: 0,  fat: 4),
  _Ingredient(name: 'Riz cuit',          unit: '100 g', kcal: 130, protein: 3,  carbs: 28, fat: 0),
  _Ingredient(name: 'Avocat (½)',        unit: '½ pc',  kcal: 120, protein: 2,  carbs: 6,  fat: 11),
  _Ingredient(name: 'Œuf entier',        unit: '1 pc',  kcal: 78,  protein: 6,  carbs: 1,  fat: 5),
  _Ingredient(name: 'Yaourt grec',       unit: '150 g', kcal: 100, protein: 10, carbs: 5,  fat: 3),
  _Ingredient(name: 'Amandes',           unit: '20 g',  kcal: 116, protein: 4,  carbs: 4,  fat: 10),
  _Ingredient(name: 'Épinards',          unit: '80 g',  kcal: 18,  protein: 2,  carbs: 2,  fat: 0),
  _Ingredient(name: 'Quinoa cuit',       unit: '100 g', kcal: 120, protein: 4,  carbs: 21, fat: 2),
  _Ingredient(name: 'Saumon',            unit: '120 g', kcal: 248, protein: 27, carbs: 0,  fat: 15),
  _Ingredient(name: 'Banane',            unit: '1 pc',  kcal: 89,  protein: 1,  carbs: 23, fat: 0),
  _Ingredient(name: 'Pain complet',      unit: '1 tranche', kcal: 80, protein: 3, carbs: 15, fat: 1),
  _Ingredient(name: 'Lentilles cuites',  unit: '100 g', kcal: 116, protein: 9,  carbs: 20, fat: 0),
];

final _kRecentIngredients = [
  _kIngredients[0], // Poulet
  _kIngredients[1], // Riz
  _kIngredients[3], // Œuf
  _kIngredients[4], // Yaourt grec
];

// ─────────────────────────────────────────────────────────────────────────────
class AjoutRapideScreen extends StatefulWidget {
  const AjoutRapideScreen({super.key});
  @override
  State<AjoutRapideScreen> createState() => _AjoutRapideScreenState();
}

class _AjoutRapideScreenState extends State<AjoutRapideScreen> {
  int _mode = 0;
  _ScanState _scanState = _ScanState.idle;

  // Ingredient search (scan mode)
  final List<_Ingredient> _addedIngredients = [];
  String _ingredientQuery = '';
  final _ingredientSearchCtrl = TextEditingController();

  // Form controllers (modes 1-3)
  final _nameCtrl  = TextEditingController();
  final _calCtrl   = TextEditingController();
  final _poidsCtrl = TextEditingController();
  final _protCtrl  = TextEditingController();
  final _glucCtrl  = TextEditingController();
  final _lipCtrl   = TextEditingController();

  // Computed scan totals (base + manually added ingredients)
  int get _totalKcal    => _kScanKcal    + _addedIngredients.fold(0, (s, i) => s + i.kcal);
  int get _totalProtein => _kScanProtein + _addedIngredients.fold(0, (s, i) => s + i.protein);
  int get _totalCarbs   => _kScanCarbs   + _addedIngredients.fold(0, (s, i) => s + i.carbs);
  int get _totalFat     => _kScanFat     + _addedIngredients.fold(0, (s, i) => s + i.fat);

  bool get _canAdd {
    if (_mode == 0) return _scanState == _ScanState.result;
    return _nameCtrl.text.isNotEmpty && _calCtrl.text.isNotEmpty;
  }

  static const _modeIcons = [
    Icons.camera_alt_outlined,
    Icons.qr_code_outlined,
    Icons.restaurant_menu_outlined,
    Icons.edit_outlined,
  ];
  static const _modeLabels = ['Photo IA', 'Code-barre', 'Recettes', 'Manuel'];

  @override
  void dispose() {
    _ingredientSearchCtrl.dispose();
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _poidsCtrl.dispose();
    _protCtrl.dispose();
    _glucCtrl.dispose();
    _lipCtrl.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() => _scanState = _ScanState.scanning);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _scanState = _ScanState.result);
  }

  void _resetScan() => setState(() => _scanState = _ScanState.idle);

  void _showMealTypeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MealTypeSheet(onConfirm: () {
        Navigator.pop(context);
        Navigator.pop(context);
      }),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Row(children: [
                        BackBtn(onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Ajout rapide',
                          style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.w800, color: cs.onSurface))),
                      ]),
                    ),
                  ),
                ),

                // Mode selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: List.generate(4, (i) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _mode = i;
                            if (i == 0) _scanState = _ScanState.idle;
                          }),
                          child: Container(
                            margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                            height: 60,
                            decoration: BoxDecoration(
                              color: _mode == i ? cs.primary : cs.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_modeIcons[i], size: 20,
                                  color: _mode == i ? cs.onPrimary : cs.onSurfaceVariant),
                                const SizedBox(height: 2),
                                Text(_modeLabels[i], style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.w600,
                                  color: _mode == i ? cs.onPrimary : cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                      )),
                    ),
                  ),
                ),

                // Main content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _mode == 0
                        ? _buildScanContent(cs)
                        : _buildFormContent(cs),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),

          // Bottom CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            color: cs.surface,
            child: GestureDetector(
              onTap: _canAdd ? _showMealTypeModal : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _canAdd
                      ? cs.primary
                      : cs.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add, size: 18,
                    color: _canAdd
                        ? cs.onPrimary
                        : cs.primary.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Text(
                    _mode == 0 && _scanState == _ScanState.result
                        ? 'Ajouter à ma journée'
                        : 'Ajouter au suivi',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: _canAdd
                          ? cs.onPrimary
                          : cs.primary.withValues(alpha: 0.5)),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scan content ──────────────────────────────────────────────────────────
  Widget _buildScanContent(ColorScheme cs) {
    return switch (_scanState) {
      _ScanState.idle     => _buildScanIdle(cs),
      _ScanState.scanning => _buildScanScanning(cs),
      _ScanState.result   => _buildScanResult(cs),
    };
  }

  Widget _buildScanIdle(ColorScheme cs) {
    return Column(children: [
      // Tip
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.secondaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Pointe l\'appareil photo vers ton assiette — l\'IA identifie les aliments et calcule les macros automatiquement.',
          style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.5),
        ),
      ),
      const SizedBox(height: 16),

      // Camera frame
      Container(
        width: double.infinity, height: 220,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(children: [
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.camera_alt_outlined, size: 52,
                color: cs.primary.withValues(alpha: 0.35)),
              const SizedBox(height: 12),
              Text('Pointer vers un plat', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant)),
            ]),
          ),
          // Corner marks
          _corner(cs.primary, top: true,  left: true),
          _corner(cs.primary, top: true,  left: false),
          _corner(cs.primary, top: false, left: true),
          _corner(cs.primary, top: false, left: false),
        ]),
      ),
      const SizedBox(height: 16),

      // Analyse button
      GestureDetector(
        onTap: _startScan,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.document_scanner_outlined, color: cs.onPrimary, size: 18),
            const SizedBox(width: 8),
            Text('Analyser le plat', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: cs.onPrimary)),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildScanScanning(ColorScheme cs) {
    return Container(
      width: double.infinity, height: 260,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 48, height: 48,
          child: CircularProgressIndicator(
            color: cs.primary, strokeWidth: 2.5),
        ),
        const SizedBox(height: 20),
        Text('Analyse en cours…', style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 6),
        Text('Identification des aliments', style: TextStyle(
          fontSize: 12, color: cs.onSurfaceVariant)),
      ]),
    );
  }

  Widget _buildScanResult(ColorScheme cs) {
    return Column(children: [
      // ── Result card (dynamic totals) ──────────────────────────────────────
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: cs.shadow.withValues(alpha: 0.08),
              blurRadius: 14, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // AI badge
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: cs.primary, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.auto_awesome_rounded, size: 10, color: cs.onPrimary),
                const SizedBox(width: 5),
                Text('IA · $_kScanConfidence% de confiance',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: cs.onPrimary)),
              ]),
            ),
            if (_addedIngredients.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20)),
                child: Text('+${_addedIngredients.length} ingrédient${_addedIngredients.length > 1 ? "s" : ""}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    color: cs.primary)),
              ),
            ],
          ]),
          const SizedBox(height: 12),

          // Meal name
          Text(_kScanName, style: TextStyle(fontSize: 20,
            fontWeight: FontWeight.w800, color: cs.onSurface,
            letterSpacing: -0.3)),
          const SizedBox(height: 3),
          Text('Estimation par portion (300 g)',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),

          // Kcal + macro chips (dynamic)
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$_totalKcal', style: TextStyle(fontSize: 44,
              fontWeight: FontWeight.w800, color: cs.primary, height: 1)),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('kcal', style: TextStyle(
                fontSize: 15, color: cs.onSurfaceVariant)),
            ),
            const Spacer(),
            _MacroChipBadge('P ${_totalProtein}g', cs.primary,
              cs.secondaryContainer.withValues(alpha: 0.5)),
            const SizedBox(width: 6),
            _MacroChipBadge('G ${_totalCarbs}g', cs.secondary,
              cs.secondaryContainer.withValues(alpha: 0.3)),
            const SizedBox(width: 6),
            _MacroChipBadge('L ${_totalFat}g', cs.tertiary,
              cs.tertiaryContainer.withValues(alpha: 0.3)),
          ]),
          const SizedBox(height: 18),

          Divider(height: 1, color: cs.outlineVariant),
          const SizedBox(height: 16),

          // Macro bars (dynamic)
          _MacroProgressBar('Protéines', _totalProtein, 60,  cs.primary),
          const SizedBox(height: 12),
          _MacroProgressBar('Glucides',  _totalCarbs,   100, cs.secondary),
          const SizedBox(height: 12),
          _MacroProgressBar('Lipides',   _totalFat,     40,  cs.tertiary),
        ]),
      ),

      const SizedBox(height: 14),

      // ── Ingredient picker ─────────────────────────────────────────────────
      _buildIngredientPicker(cs),

      const SizedBox(height: 12),

      // ── Rescanner ─────────────────────────────────────────────────────────
      GestureDetector(
        onTap: () {
          setState(() {
            _addedIngredients.clear();
            _ingredientQuery = '';
            _ingredientSearchCtrl.clear();
          });
          _resetScan();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.refresh_rounded, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text('Rescanner', style: TextStyle(fontSize: 13,
              fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildIngredientPicker(ColorScheme cs) {
    final query = _ingredientQuery.toLowerCase();
    final suggestions = query.isEmpty
        ? _kIngredients.take(6).toList()
        : _kIngredients
            .where((i) => i.name.toLowerCase().contains(query))
            .take(6)
            .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.06),
          blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Icon(Icons.add_circle_outline_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Text('Affiner avec des ingrédients',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: cs.onSurface)),
        ]),
        const SizedBox(height: 12),

        // Search bar
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Icon(Icons.search_rounded, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _ingredientSearchCtrl,
                onChanged: (v) => setState(() => _ingredientQuery = v),
                style: TextStyle(fontSize: 13, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Chercher un ingrédient…',
                  hintStyle: TextStyle(
                    fontSize: 13, color: cs.onSurfaceVariant),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),

        // Recents (when no query)
        if (query.isEmpty) ...[
          Text('Récents', style: TextStyle(fontSize: 11,
            fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            ..._kRecentIngredients.map((ing) {
              final added = _addedIngredients.contains(ing);
              return GestureDetector(
                onTap: () => setState(() => added
                    ? _addedIngredients.remove(ing)
                    : _addedIngredients.add(ing)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: added ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: added ? cs.primary : cs.outlineVariant),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (added) ...[
                      Icon(Icons.check_rounded, size: 11, color: cs.onPrimary),
                      const SizedBox(width: 4),
                    ],
                    Text(ing.name, style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: added ? cs.onPrimary : cs.onSurface)),
                    const SizedBox(width: 5),
                    Text('${ing.kcal} kcal', style: TextStyle(
                      fontSize: 10,
                      color: added
                          ? cs.onPrimary.withValues(alpha: 0.7)
                          : cs.onSurfaceVariant)),
                  ]),
                ),
              );
            }),
          ]),
          const SizedBox(height: 12),
          Divider(height: 1, color: cs.outlineVariant),
          const SizedBox(height: 12),
        ],

        // Suggestion list
        Text(query.isEmpty ? 'Tous les ingrédients' : 'Résultats',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        ...suggestions.map((ing) {
          final added = _addedIngredients.contains(ing);
          return GestureDetector(
            onTap: () => setState(() => added
                ? _addedIngredients.remove(ing)
                : _addedIngredients.add(ing)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: added
                    ? cs.primary.withValues(alpha: 0.08)
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: added ? cs.primary.withValues(alpha: 0.3)
                      : Colors.transparent),
              ),
              child: Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ing.name, style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: cs.onSurface)),
                    Text('${ing.unit} · P ${ing.protein}g  G ${ing.carbs}g  L ${ing.fat}g',
                      style: TextStyle(
                        fontSize: 11, color: cs.onSurfaceVariant)),
                  ],
                )),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: added ? cs.primary : cs.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    added ? '✓ Ajouté' : '${ing.kcal} kcal',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: added ? cs.onPrimary : cs.primary)),
                ),
              ]),
            ),
          );
        }),

        // Added chips summary
        if (_addedIngredients.isNotEmpty) ...[
          const SizedBox(height: 10),
          Divider(height: 1, color: cs.outlineVariant),
          const SizedBox(height: 10),
          Text('Ajoutés', style: TextStyle(fontSize: 11,
            fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: [
            ..._addedIngredients.map((ing) => GestureDetector(
              onTap: () => setState(() => _addedIngredients.remove(ing)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(ing.name, style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: cs.onPrimary)),
                  const SizedBox(width: 5),
                  Icon(Icons.close_rounded, size: 12, color: cs.onPrimary),
                ]),
              ),
            )),
          ]),
        ],
      ]),
    );
  }

  // ── Form content (modes 1-3) ──────────────────────────────────────────────
  Widget _buildFormContent(ColorScheme cs) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.secondaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Saisis le nom du produit ou plat. Si les macros ne sont pas connues, tu peux juste mettre les calories.',
          style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.5),
        ),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surface, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _FormField('Nom du plat / produit', 'Ex: Riz thaï au poulet',
            controller: _nameCtrl, onChanged: (_) => setState(() {})),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _FormField('Calories (kcal)', 'Ex: 450',
              controller: _calCtrl, keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(child: _FormField('Poids (g)', 'Ex: 250',
              controller: _poidsCtrl, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 14),
          Text('Macronutriments', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MacroInputLabel('Protéines', cs.secondary),
                const SizedBox(height: 4),
                _FormField('', 'g', controller: _protCtrl,
                  keyboardType: TextInputType.number),
              ])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MacroInputLabel('Glucides', cs.primary),
                const SizedBox(height: 4),
                _FormField('', 'g', controller: _glucCtrl,
                  keyboardType: TextInputType.number),
              ])),
          ]),
          const SizedBox(height: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _MacroInputLabel('Lipides', cs.tertiary),
            const SizedBox(height: 4),
            SizedBox(
              width: 140,
              child: _FormField('', 'g', controller: _lipCtrl,
                keyboardType: TextInputType.number),
            ),
          ]),
        ]),
      ),
    ]);
  }

  // ── Corner scan marks ─────────────────────────────────────────────────────
  Widget _corner(Color color, {required bool top, required bool left}) {
    return Positioned(
      top:    top  ? 14 : null,
      bottom: !top ? 14 : null,
      left:   left ? 14 : null,
      right:  !left ? 14 : null,
      child: Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          border: Border(
            top:    top  ? BorderSide(color: color, width: 3) : BorderSide.none,
            bottom: !top ? BorderSide(color: color, width: 3) : BorderSide.none,
            left:   left ? BorderSide(color: color, width: 3) : BorderSide.none,
            right:  !left ? BorderSide(color: color, width: 3) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared form widgets (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  const _FormField(this.label, this.hint, {
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label.isNotEmpty) ...[
        Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 6),
      ],
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: cs.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 14),
          filled: true,
          fillColor: cs.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: cs.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
        ),
      ),
    ]);
  }
}

class _MacroInputLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _MacroInputLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 7, height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: TextStyle(
      fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Scan result helpers
// ─────────────────────────────────────────────────────────────────────────────
class _MacroChipBadge extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _MacroChipBadge(this.label, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w700, color: color)),
  );
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final int value, max;
  final Color color;
  const _MacroProgressBar(this.label, this.value, this.max, this.color);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface)),
        Text('${value}g / ${max}g recommandés',
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
      ]),
      const SizedBox(height: 7),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: (value / max).clamp(0.0, 1.0),
          minHeight: 7,
          backgroundColor: color.withValues(alpha: 0.12),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ]);
  }
}
