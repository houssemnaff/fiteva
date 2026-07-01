// ignore_for_file: deprecated_member_use
import 'package:fiteva/core/nutrition/food_database.dart';
import 'package:fiteva/core/nutrition/models.dart';
import 'package:fiteva/screens/nutrition/nutrition_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../l10n/lang.dart';
import '../../l10n/app_localizations.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _kGreen   = Color(0xFF1C4D30);
const _kMint    = Color(0xFF7ABB98);
const _kMintBg  = Color(0xFFEAF3EC);
const _kCream   = Color(0xFFFAFAF8);
const _kBorder  = Color(0xFFECECEC);
const _kText1   = Color(0xFF1A1A1A);
const _kText2   = Color(0xFF6B7280);
const _kSurface = Colors.white;

// ── Food units ────────────────────────────────────────────────────────────────
enum FoodUnit { g, kg, ml, cup, tbsp, tsp, piece }

extension FoodUnitExt on FoodUnit {
  String get label => labelFor(Lang.code);

  String labelFor(String lang) {
    final l10n = AppL10n(lang);
    return switch (this) {
      FoodUnit.g     => 'g',
      FoodUnit.kg    => 'kg',
      FoodUnit.ml    => 'ml',
      FoodUnit.cup   => 'cup',
      FoodUnit.tbsp  => l10n.unitTbsp,
      FoodUnit.tsp   => l10n.unitTsp,
      FoodUnit.piece => l10n.unitPiece,
    };
  }

  String get shortLabel => switch (this) {
    FoodUnit.g     => 'g',
    FoodUnit.kg    => 'kg',
    FoodUnit.ml    => 'ml',
    FoodUnit.cup   => 'cup',
    FoodUnit.tbsp  => 'tbsp',
    FoodUnit.tsp   => 'tsp',
    FoodUnit.piece => 'pce',
  };

  double toGrams(double amount, {double pieceGrams = 100}) => switch (this) {
    FoodUnit.g     => amount,
    FoodUnit.kg    => amount * 1000,
    FoodUnit.ml    => amount,
    FoodUnit.cup   => amount * 240,
    FoodUnit.tbsp  => amount * 15,
    FoodUnit.tsp   => amount * 5,
    FoodUnit.piece => amount * pieceGrams,
  };

  double defaultAmount(double grams, {double pieceGrams = 100}) => switch (this) {
    FoodUnit.g     => grams,
    FoodUnit.kg    => grams / 1000,
    FoodUnit.ml    => grams,
    FoodUnit.cup   => grams / 240,
    FoodUnit.tbsp  => grams / 15,
    FoodUnit.tsp   => grams / 5,
    FoodUnit.piece => (pieceGrams > 0 ? grams / pieceGrams : 1),
  };
}

// ── Category icon & color ─────────────────────────────────────────────────────
IconData _catIcon(FoodCategory c) => switch (c) {
  FoodCategory.viandes      => LucideIcons.drumstick,
  FoodCategory.poissons     => LucideIcons.fish,
  FoodCategory.oeufslaitiers=> LucideIcons.egg,
  FoodCategory.cereales     => LucideIcons.wheat,
  FoodCategory.legumineuses => LucideIcons.leaf,
  FoodCategory.legumes      => LucideIcons.salad,
  FoodCategory.fruits       => LucideIcons.apple,
  FoodCategory.oleagineux   => LucideIcons.nut,
  FoodCategory.corpsGras    => LucideIcons.droplets,
  FoodCategory.platCompose  => LucideIcons.utensils,
  FoodCategory.boissons     => LucideIcons.glassWater,
  FoodCategory.desserts     => LucideIcons.cookie,
};

Color _catColor(FoodCategory c) => switch (c) {
  FoodCategory.viandes      => const Color(0xFFE53935),
  FoodCategory.poissons     => const Color(0xFF1E88E5),
  FoodCategory.oeufslaitiers=> const Color(0xFFF9A825),
  FoodCategory.cereales     => const Color(0xFF8D6E63),
  FoodCategory.legumineuses => const Color(0xFF43A047),
  FoodCategory.legumes      => const Color(0xFF2E7D32),
  FoodCategory.fruits       => const Color(0xFFE91E63),
  FoodCategory.oleagineux   => const Color(0xFFFF7043),
  FoodCategory.corpsGras    => const Color(0xFFFFC107),
  FoodCategory.platCompose  => const Color(0xFF7ABB98),
  FoodCategory.boissons     => const Color(0xFF00ACC1),
  FoodCategory.desserts     => const Color(0xFFAB47BC),
};

String _catPhoto(FoodCategory c) => switch (c) {
  FoodCategory.viandes      => 'https://images.unsplash.com/photo-1551446591-142875a901a1?w=80&q=70&fit=crop',
  FoodCategory.poissons     => 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=80&q=70&fit=crop',
  FoodCategory.oeufslaitiers=> 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=80&q=70&fit=crop',
  FoodCategory.cereales     => 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=80&q=70&fit=crop',
  FoodCategory.legumineuses => 'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=80&q=70&fit=crop',
  FoodCategory.legumes      => 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=80&q=70&fit=crop',
  FoodCategory.fruits       => 'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=80&q=70&fit=crop',
  FoodCategory.oleagineux   => 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=80&q=70&fit=crop',
  FoodCategory.corpsGras    => 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=80&q=70&fit=crop',
  FoodCategory.platCompose  => 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=80&q=70&fit=crop',
  FoodCategory.boissons     => 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=80&q=70&fit=crop',
  FoodCategory.desserts     => 'https://images.unsplash.com/photo-1587314168485-3236d6710814?w=80&q=70&fit=crop',
};

// ── Scan state ────────────────────────────────────────────────────────────────
enum _ScanState { idle, scanning, result }

// ── Basket item ───────────────────────────────────────────────────────────────
class _BasketItem {
  final FoodItem food;
  final double grams;
  const _BasketItem(this.food, this.grams);
  int get calories => food.kcalFor(grams).round();
  int get protein  => food.proteinFor(grams).round();
  int get carbs    => food.carbsFor(grams).round();
  int get fat      => food.fatFor(grams).round();
}

// ════════════════════════════════════════════════════════════════════════════
//  SCREEN
// ════════════════════════════════════════════════════════════════════════════
class AjoutRapideScreen extends StatefulWidget {
  final String? initialTypeId;
  const AjoutRapideScreen({super.key, this.initialTypeId});

  @override
  State<AjoutRapideScreen> createState() => _AjoutRapideScreenState();
}

class _AjoutRapideScreenState extends State<AjoutRapideScreen> {
  // 0 = Recherche, 1 = Manuel, 2 = Scanner
  int _mode = 0;

  MealType? get _preselectedType =>
      widget.initialTypeId != null
          ? MealType.fromId(widget.initialTypeId!)
          : null;

  // ── Basket ───────────────────────────────────────────────────────────────
  final List<_BasketItem> _basket = [];
  int get _basketCalories => _basket.fold(0, (s, i) => s + i.calories);

  // ── Search mode ──────────────────────────────────────────────────────────
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  FoodItem? _selectedFood;
  double _selectedGrams = 100;
  FoodUnit _selectedUnit = FoodUnit.g;
  final _amountCtrl = TextEditingController(text: '100');
  FoodCategory? _activeCategory;

  List<FoodItem> _searchResults(List<FoodItem> allFoods) {
    if (_selectedFood != null) return [];
    if (_searchQuery.isNotEmpty) return FoodDatabase.searchIn(allFoods, _searchQuery);
    if (_activeCategory != null) return FoodDatabase.byCategoryIn(allFoods, _activeCategory!);
    return FoodDatabase.popularIn(allFoods);
  }

  // ── Scanner mode ─────────────────────────────────────────────────────────
  _ScanState _scanState = _ScanState.idle;
  FoodItem?  _scannedFood;

  // Mock foods returned by "image scan"
  static final _mockScanResults = [
    FoodItem(id: 'scan_1', name: 'Saumon grillé',
      category: FoodCategory.poissons,
      kcal: 208, protein: 20, carbs: 0, fat: 13, defaultGrams: 150, portionLabel: '1 filet'),
    FoodItem(id: 'scan_2', name: 'Riz basmati cuit',
      category: FoodCategory.cereales,
      kcal: 130, protein: 2.7, carbs: 28, fat: 0.3, defaultGrams: 200, portionLabel: '1 bol'),
    FoodItem(id: 'scan_3', name: 'Poulet rôti',
      category: FoodCategory.viandes,
      kcal: 215, protein: 25, carbs: 0, fat: 12, defaultGrams: 150, portionLabel: '1 portion'),
    FoodItem(id: 'scan_4', name: 'Salade verte',
      category: FoodCategory.legumes,
      kcal: 15, protein: 1.4, carbs: 1.8, fat: 0.2, defaultGrams: 80, portionLabel: '1 assiette'),
    FoodItem(id: 'scan_5', name: 'Pâtes bolognaise',
      category: FoodCategory.platCompose,
      kcal: 185, protein: 9, carbs: 24, fat: 5, defaultGrams: 300, portionLabel: '1 assiette'),
    FoodItem(id: 'scan_6', name: 'Yaourt nature',
      category: FoodCategory.oeufslaitiers,
      kcal: 61, protein: 5, carbs: 4.7, fat: 3.2, defaultGrams: 125, portionLabel: '1 pot'),
    FoodItem(id: 'scan_7', name: 'Omelette 2 œufs',
      category: FoodCategory.oeufslaitiers,
      kcal: 154, protein: 11, carbs: 1, fat: 12, defaultGrams: 100, portionLabel: '1 omelette'),
  ];

  Future<void> _startImageScan() async {
    HapticFeedback.mediumImpact();
    setState(() { _scanState = _ScanState.scanning; _scannedFood = null; });
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final picked = _mockScanResults[
      DateTime.now().millisecond % _mockScanResults.length];
    setState(() {
      _scanState   = _ScanState.result;
      _scannedFood = picked;
      // pre-fill the food detail state so user can adjust
      _selectedFood  = picked;
      _selectedGrams = picked.defaultGrams;
      _selectedUnit  = FoodUnit.g;
      _amountCtrl.text = picked.defaultGrams.round().toString();
    });
  }

  void _resetScan() => setState(() {
    _scanState    = _ScanState.idle;
    _scannedFood  = null;
    _selectedFood = null;
  });

  // ── Manual mode ──────────────────────────────────────────────────────────
  final _nameCtrl  = TextEditingController();
  final _calCtrl   = TextEditingController();
  final _protCtrl  = TextEditingController();
  final _glucCtrl  = TextEditingController();
  final _lipCtrl   = TextEditingController();

  bool get _canAddToBasket {
    if (_mode == 0) return _selectedFood != null;
    if (_mode == 1) return _nameCtrl.text.isNotEmpty && _calCtrl.text.isNotEmpty;
    return false;
  }

  bool get _canSubmit => _basket.isNotEmpty;

  @override
  void dispose() {
    _searchCtrl.dispose(); _amountCtrl.dispose();
    _nameCtrl.dispose(); _calCtrl.dispose();
    _protCtrl.dispose(); _glucCtrl.dispose(); _lipCtrl.dispose();
    super.dispose();
  }

  void _setUnit(FoodUnit unit) {
    final pieceGrams = _selectedFood?.defaultGrams ?? 100;
    final newAmount = unit.defaultAmount(_selectedGrams, pieceGrams: pieceGrams);
    setState(() {
      _selectedUnit = unit;
      _amountCtrl.text = newAmount < 10
          ? newAmount.toStringAsFixed(1)
          : newAmount.round().toString();
    });
  }

  void _setAmount(double amount) {
    final pieceGrams = _selectedFood?.defaultGrams ?? 100;
    setState(() {
      _selectedGrams = _selectedUnit.toGrams(amount, pieceGrams: pieceGrams);
    });
  }

  // ── Add / update basket ───────────────────────────────────────────────────
  void _addToBasket() {
    FoodItem food;
    double grams;

    if ((_mode == 0 || _mode == 2) && _selectedFood != null) {
      food  = _selectedFood!;
      grams = _selectedGrams;
      if (grams <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La quantité doit être supérieure à 0.')));
        return;
      }
    } else {
      final name    = _nameCtrl.text.trim();
      final kcal    = double.tryParse(_calCtrl.text) ?? 0;
      final protein = double.tryParse(_protCtrl.text) ?? 0;
      final carbs   = double.tryParse(_glucCtrl.text) ?? 0;
      final fat     = double.tryParse(_lipCtrl.text) ?? 0;
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le nom de l\'aliment est requis.')));
        return;
      }
      if (kcal < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les calories ne peuvent pas être négatives.')));
        return;
      }
      food = FoodItem(
        id:       'manual_${DateTime.now().millisecondsSinceEpoch}',
        name:     name,
        category: FoodCategory.platCompose,
        kcal: kcal, protein: protein, carbs: carbs, fat: fat,
        defaultGrams: 100,
      );
      grams = 100;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      // If already in basket (editing quantity), replace instead of appending
      final idx = _basket.indexWhere((b) => b.food.id == food.id);
      if (idx != -1) {
        _basket[idx] = _BasketItem(food, grams);
      } else {
        _basket.add(_BasketItem(food, grams));
      }
      _selectedFood   = null;
      _searchQuery    = '';
      _activeCategory = null;
      _selectedGrams  = 100;
      _selectedUnit   = FoodUnit.g;
      _amountCtrl.text = '100';
      _searchCtrl.clear();
      _nameCtrl.clear(); _calCtrl.clear();
      _protCtrl.clear(); _glucCtrl.clear(); _lipCtrl.clear();
    });
  }

  // ── Confirm basket → pop with entries list ────────────────────────────────
  Future<void> _submit() async {
    if (_basket.isEmpty) return;
    MealType? type = _preselectedType;
    if (type == null) {
      type = await showModalBottomSheet<MealType>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _MealTypePickerSheet(),
      );
      if (type == null || !mounted) return;
    }

    final now = DateTime.now();
    final entries = _basket.asMap().entries.map((e) => MealEntry(
      id:       '${now.millisecondsSinceEpoch}_${e.key}',
      food:     e.value.food,
      grams:    e.value.grams,
      mealType: type!,
      dateTime: now,
    )).toList();

    if (mounted) Navigator.pop(context, {'entries': entries});
  }

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final nc     = NutritionColors.of(context);
    final allFoods = ref.watch(foodItemsProvider).asData?.value ?? FoodDatabase.all;
    final results  = _searchResults(allFoods);

    final l10n = AppL10n(Lang.code);
    return Scaffold(
      backgroundColor: nc.bg,
      body: Column(children: [
        // ── Header ───────────────────────────────────────────────────────────
        Container(
          color: nc.surface,
          padding: EdgeInsets.fromLTRB(20, top + 14, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: nc.mintBg, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.chevronLeft,
                    color: _kGreen, size: 18))),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.addMealTitle, style: GoogleFonts.inter(
                  color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
                  letterSpacing: 2.5)),
                Text(
                  _preselectedType != null
                      ? _preselectedType!.labelFor(Lang.code)
                      : l10n.addMealSubtitle,
                  style: GoogleFonts.outfit(
                    color: _kGreen, fontSize: 22,
                    fontWeight: FontWeight.w800, letterSpacing: -0.4)),
              ])),
              // basket badge
              if (_basket.isNotEmpty)
                GestureDetector(
                  onTap: () => _showBasketSheet(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: nc.mintBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _kMint.withOpacity(0.4))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.shoppingBasket, size: 14, color: _kGreen),
                      const SizedBox(width: 5),
                      Text('${_basket.length}', style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w800, color: _kGreen)),
                    ])),
                ),
            ]),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: nc.chipBg,
                borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                _ModeTab(icon: LucideIcons.search,    label: l10n.addMealSearch,  active: _mode == 0,
                  onTap: () => setState(() { _mode = 0; _selectedFood = null; })),
                _ModeTab(icon: LucideIcons.squarePen, label: l10n.addMealManual,  active: _mode == 1,
                  onTap: () => setState(() => _mode = 1)),
                _ModeTab(icon: LucideIcons.scanLine,  label: l10n.addMealScanner, active: _mode == 2,
                  onTap: () => setState(() => _mode = 2)),
              ]),
            ),
          ]),
        ),

        // ── Body ─────────────────────────────────────────────────────────────
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _mode == 0
                      ? _buildSearch()
                      : _mode == 1
                          ? _buildManual()
                          : _buildScanner(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        ),

        // ── Bottom actions ────────────────────────────────────────────────────
        Container(
          color: nc.surface,
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // "Add / update" button — shown when a food is selected in detail
            if (_canAddToBasket) ...[
              GestureDetector(
                onTap: _addToBasket,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: nc.mintBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kMint.withOpacity(0.5))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(
                      _selectedFood != null &&
                          _basket.any((b) => b.food.id == _selectedFood!.id)
                        ? LucideIcons.check
                        : LucideIcons.plus,
                      size: 16, color: _kGreen),
                    const SizedBox(width: 7),
                    Text(
                      _selectedFood != null &&
                          _basket.any((b) => b.food.id == _selectedFood!.id)
                        ? l10n.addMealUpdateQty
                        : l10n.addMealAddToList,
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w700, color: _kGreen)),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Main confirm button — only enabled when basket has items
            GestureDetector(
              onTap: _canSubmit ? () {
                HapticFeedback.mediumImpact();
                _submit();
              } : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _canSubmit ? _kGreen : nc.border,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: _canSubmit ? [BoxShadow(
                    color: _kGreen.withOpacity(0.3),
                    blurRadius: 16, offset: const Offset(0, 5))] : []),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(LucideIcons.check, size: 17,
                    color: _canSubmit ? Colors.white : nc.text2),
                  const SizedBox(width: 8),
                  Text(
                    _basket.isEmpty
                        ? l10n.addMealFirstAdd
                        : l10n.addMealConfirm(_basket.length, _basketCalories),
                    style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: _canSubmit ? Colors.white : nc.text2)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Basket bottom sheet ───────────────────────────────────────────────────
  Future<void> _showBasketSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => _BasketSheet(
          basket: _basket,
          onRemove: (i) => setState(() => _basket.removeAt(i)),
        )),
    );
    setState(() {}); // refresh after sheet closes
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  SEARCH MODE
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSearch() {
    if (_selectedFood != null) return _buildFoodDetail(_selectedFood!);
    final nc = NutritionColors.of(context);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── Selected chips row ──────────────────────────────────────────────────
      if (_basket.isNotEmpty) ...[
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: _basket.length,
            itemBuilder: (_, i) {
              final item = _basket[i];
              return GestureDetector(
                onTap: () => setState(() => _basket.removeAt(i)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kGreen,
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(item.food.name, style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: Colors.white)),
                    const SizedBox(width: 6),
                    const Icon(LucideIcons.x, size: 11, color: Colors.white70),
                  ])));
            })),
        const SizedBox(height: 14),
      ],

      // ── Search bar ──────────────────────────────────────────────────────────
      Container(
        height: 48,
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: nc.border),
          boxShadow: nc.isDark ? [] : [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))]),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Icon(LucideIcons.search, size: 16, color: nc.text2),
          const SizedBox(width: 10),
          Expanded(child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() {
              _searchQuery    = v;
              _activeCategory = null;
            }),
            style: GoogleFonts.inter(fontSize: 14, color: nc.text1),
            decoration: InputDecoration(
              hintText: AppL10n(Lang.code).addMealHint,
              hintStyle: GoogleFonts.inter(fontSize: 14, color: nc.text2),
              border: InputBorder.none, isDense: true,
              contentPadding: EdgeInsets.zero),
          )),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                setState(() { _searchQuery = ''; _activeCategory = null; });
              },
              child: Icon(LucideIcons.x, size: 14, color: nc.text2)),
        ]),
      ),

      const SizedBox(height: 14),

      // ── Category pills ──────────────────────────────────────────────────────
      if (_searchQuery.isEmpty) ...[
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            separatorBuilder: (_, __) => const SizedBox(width: 7),
            itemCount: FoodCategory.values.length,
            itemBuilder: (_, i) {
              final cat = FoodCategory.values[i];
              final sel = _activeCategory == cat;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _activeCategory = sel ? null : cat);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? _kGreen : nc.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? _kGreen : nc.border)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_catIcon(cat), size: 13,
                      color: sel ? Colors.white : _catColor(cat)),
                    const SizedBox(width: 5),
                    Text(cat.label.split(' ').first, style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : nc.text1)),
                  ])));
            })),
        const SizedBox(height: 14),
      ],

      // ── Section label ───────────────────────────────────────────────────────
      Text(
        _searchQuery.isNotEmpty
            ? AppL10n(Lang.code).addMealResults(results.length)
            : _activeCategory != null
                ? _activeCategory!.label.toUpperCase()
                : AppL10n(Lang.code).addMealPopular,
        style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w700,
          color: nc.text2, letterSpacing: 2.0)),
      const SizedBox(height: 8),

      // ── Food list (multi-select) ─────────────────────────────────────────────
      if (results.isEmpty && _searchQuery.isNotEmpty)
        _EmptySearch(query: _searchQuery)
      else
        Column(children: results.map((food) {
          final basketIdx = _basket.indexWhere((b) => b.food.id == food.id);
          final isSelected = basketIdx != -1;
          final item = isSelected ? _basket[basketIdx] : null;

          return _FoodSelectTile(
            food: food,
            isSelected: isSelected,
            selectedGrams: item?.grams,
            onToggle: () {
              HapticFeedback.selectionClick();
              if (isSelected) {
                setState(() => _basket.removeAt(basketIdx));
              } else {
                setState(() => _basket.add(_BasketItem(food, food.defaultGrams)));
              }
            },
            onEditQuantity: () {
              setState(() {
                _selectedFood  = food;
                _selectedGrams = item?.grams ?? food.defaultGrams;
                _selectedUnit  = FoodUnit.g;
                _amountCtrl.text = (item?.grams ?? food.defaultGrams).round().toString();
              });
            },
          );
        }).toList()),
    ]);
  }

  // ── Food detail ───────────────────────────────────────────────────────────
  Widget _buildFoodDetail(FoodItem food) {
    final nc      = NutritionColors.of(context);
    final grams   = _selectedGrams;
    final kcal    = food.kcalFor(grams).round();
    final protein = food.proteinFor(grams).round();
    final carbs   = food.carbsFor(grams).round();
    final fat     = food.fatFor(grams).round();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() { _selectedFood = null; _searchQuery = ''; _searchCtrl.clear(); }),
        child: Row(children: [
          const Icon(LucideIcons.chevronLeft, size: 14, color: _kMint),
          const SizedBox(width: 4),
          Text(AppL10n(Lang.code).addMealBack, style: GoogleFonts.inter(
            fontSize: 12, color: _kMint, fontWeight: FontWeight.w600)),
        ])),

      const SizedBox(height: 16),

      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: nc.border),
          boxShadow: nc.isDark ? [] : [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 44, height: 44,
                child: Image.network(
                  _catPhoto(food.category),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _catColor(food.category).withOpacity(0.12),
                    child: Icon(_catIcon(food.category),
                      size: 22, color: _catColor(food.category)))))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(food.name, style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w800, color: nc.text1)),
              Text(food.category.label, style: GoogleFonts.inter(
                fontSize: 11, color: nc.text2)),
            ])),
          ]),

          const SizedBox(height: 16),

          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$kcal', style: GoogleFonts.outfit(
              fontSize: 44, fontWeight: FontWeight.w800,
              color: _kGreen, height: 1)),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text('kcal', style: GoogleFonts.inter(
                fontSize: 15, color: _kText2))),
            const Spacer(),
            _MacroBadge('P ${protein}g', _kGreen, _kMintBg),
            const SizedBox(width: 6),
            _MacroBadge('G ${carbs}g', const Color(0xFF3B7FD4), const Color(0xFFEBF2FC)),
            const SizedBox(width: 6),
            _MacroBadge('L ${fat}g', const Color(0xFFC47A00), const Color(0xFFFFF3DC)),
          ]),

          const SizedBox(height: 16),
          _MacroBar(AppL10n(Lang.code).nutritionProtein, protein, food.proteinFor(100).round(), _kGreen),
          const SizedBox(height: 10),
          _MacroBar(AppL10n(Lang.code).nutritionCarbs, carbs, food.carbsFor(100).round(), const Color(0xFF3B7FD4)),
          const SizedBox(height: 10),
          _MacroBar(AppL10n(Lang.code).nutritionFat, fat, food.fatFor(100).round(), const Color(0xFFC47A00)),
          if (food.fiber > 0) ...[
            const SizedBox(height: 10),
            _MacroBar(AppL10n(Lang.code).addMealFibers, food.fiberFor(grams).round(),
              food.fiberFor(100).round(), const Color(0xFF5BAE8A)),
          ],

          const SizedBox(height: 16),
          Divider(height: 1, color: nc.border),
          const SizedBox(height: 14),

          Text(AppL10n(Lang.code).addMealQuantity, style: GoogleFonts.inter(
            color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 2.5)),
          const SizedBox(height: 10),

          // Quick portion chips (always in grams)
          Wrap(spacing: 7, runSpacing: 7, children: [
            for (final g in <double>{50, 100, food.defaultGrams, 150, 200}
                .toList()..sort())
              _PortionChip(
                label: g == food.defaultGrams && food.portionLabel != '100 g'
                    ? '${g.round()}g · ${food.portionLabel}'
                    : '${g.round()}g',
                selected: _selectedGrams == g && _selectedUnit == FoodUnit.g,
                onTap: () => setState(() {
                  _selectedUnit  = FoodUnit.g;
                  _selectedGrams = g;
                  _amountCtrl.text = g.round().toString();
                })),
          ]),

          const SizedBox(height: 12),

          // Amount + unit row
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final val = double.tryParse(v);
                  if (val != null && val > 0) _setAmount(val);
                },
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: nc.text1),
                decoration: InputDecoration(
                  filled: true, fillColor: nc.chipBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kMint, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13)),
              ),
            ),
            const SizedBox(width: 10),
            _UnitSelector(
              selected: _selectedUnit,
              onChanged: _setUnit,
            ),
          ]),

          if (_selectedUnit != FoodUnit.g)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '≈ ${_selectedGrams.round()} g',
                style: GoogleFonts.inter(fontSize: 11, color: nc.text2))),
        ]),
      ),
    ]);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  MANUEL MODE
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildManual() {
    final nc = NutritionColors.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: nc.mintBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kMint.withOpacity(0.3))),
      child: Row(children: [
        const Icon(LucideIcons.pencilLine, size: 14, color: _kGreen),
        const SizedBox(width: 10),
        Expanded(child: Text(
          AppL10n(Lang.code).addMealInfoHint,
          style: GoogleFonts.inter(fontSize: 12, color: _kGreen, height: 1.5))),
      ])),

    const SizedBox(height: 16),

    Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: nc.border),
        boxShadow: nc.isDark ? [] : [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppL10n(Lang.code).addMealInfoTitle, style: GoogleFonts.inter(
          color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
          letterSpacing: 2.5)),
        const SizedBox(height: 14),
        _AppField(AppL10n(Lang.code).addMealNameLabel, AppL10n(Lang.code).addMealNameHint, _nameCtrl,
          onChanged: (_) => setState(() {})),
        const SizedBox(height: 12),
        _AppField(AppL10n(Lang.code).addMealCalLabel, AppL10n(Lang.code).addMealCalHint, _calCtrl,
          keyboard: TextInputType.number,
          onChanged: (_) => setState(() {})),
        const SizedBox(height: 20),
        Divider(height: 1, color: nc.border),
        const SizedBox(height: 18),
        Text(AppL10n(Lang.code).addMealMacros, style: GoogleFonts.inter(
          color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
          letterSpacing: 2.5)),
        const SizedBox(height: 4),
        Text(AppL10n(Lang.code).addMealOptional, style: GoogleFonts.inter(fontSize: 11, color: nc.text2)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _MacroInput(AppL10n(Lang.code).nutritionProtein, 'g', _kGreen, _protCtrl)),
          const SizedBox(width: 12),
          Expanded(child: _MacroInput(AppL10n(Lang.code).nutritionCarbs, 'g', const Color(0xFF3B7FD4), _glucCtrl)),
          const SizedBox(width: 12),
          Expanded(child: _MacroInput(AppL10n(Lang.code).nutritionFat, 'g', const Color(0xFFC47A00), _lipCtrl)),
        ]),
      ])),
  ]);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  SCANNER MODE
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildScanner() {
    return switch (_scanState) {
      _ScanState.idle     => _buildScannerIdle(),
      _ScanState.scanning => _buildScannerScanning(),
      _ScanState.result   => _buildScannerResult(),
    };
  }

  // ── Scanner: idle ────────────────────────────────────────────────────────
  Widget _buildScannerIdle() => Column(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kMintBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kMint.withOpacity(0.3))),
      child: Row(children: [
        const Icon(LucideIcons.scanLine, size: 14, color: _kGreen),
        const SizedBox(width: 10),
        Expanded(child: Text(
          AppL10n(Lang.code).addMealScanHint,
          style: GoogleFonts.inter(fontSize: 12, color: _kGreen, height: 1.5))),
      ])),
    const SizedBox(height: 16),

    // Viewfinder
    Container(
      width: double.infinity, height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF0E1E15),
        borderRadius: BorderRadius.circular(22)),
      child: Stack(children: [
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 160, height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, _kMint, Colors.transparent]),
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          const Icon(LucideIcons.scanLine, size: 38, color: Colors.white24),
          const SizedBox(height: 10),
          Text(AppL10n(Lang.code).addMealScanPress, style: GoogleFonts.inter(
            fontSize: 12, color: Colors.white54)),
        ])),
        _Corner(_kMint, top: true,  left: true),
        _Corner(_kMint, top: true,  left: false),
        _Corner(_kMint, top: false, left: true),
        _Corner(_kMint, top: false, left: false),
      ])),

    const SizedBox(height: 12),

    // Buttons
    Row(children: [
      Expanded(child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _kGreen,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
              color: _kGreen.withOpacity(0.25),
              blurRadius: 12, offset: const Offset(0, 4))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(LucideIcons.scanLine, size: 17, color: Colors.white),
            const SizedBox(width: 8),
            Text(AppL10n(Lang.code).addMealScanner, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ])))),
      const SizedBox(width: 10),
      Expanded(child: GestureDetector(
        onTap: _startImageScan,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF1A3A50),
            borderRadius: BorderRadius.circular(16)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(LucideIcons.image, size: 17, color: Colors.white),
            const SizedBox(width: 8),
            Text(AppL10n(Lang.code).nutritionPhoto, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ])))),
    ]),
  ]);

  // ── Scanner: scanning (animated) ─────────────────────────────────────────
  Widget _buildScannerScanning() => Column(children: [
    Container(
      width: double.infinity, height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF0E1E15),
        borderRadius: BorderRadius.circular(22)),
      child: Stack(alignment: Alignment.center, children: [
        _Corner(_kMint, top: true,  left: true),
        _Corner(_kMint, top: true,  left: false),
        _Corner(_kMint, top: false, left: true),
        _Corner(_kMint, top: false, left: false),
        Column(mainAxisSize: MainAxisSize.min, children: [
          const _ScanningDots(),
          const SizedBox(height: 16),
          Text(AppL10n(Lang.code).addMealAnalyzing, style: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 6),
          Text(AppL10n(Lang.code).addMealNutrients, style: GoogleFonts.inter(
            fontSize: 11, color: Colors.white38)),
        ]),
      ])),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kMintBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kMint.withOpacity(0.3))),
      child: Row(children: [
        SizedBox(width: 14, height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2, color: _kGreen)),
        const SizedBox(width: 10),
        Text(AppL10n(Lang.code).addMealAiAnalysis,
          style: GoogleFonts.inter(fontSize: 12, color: _kGreen)),
      ])),
  ]);

  // ── Scanner: result (editable card) ──────────────────────────────────────
  Widget _buildScannerResult() {
    final nc      = NutritionColors.of(context);
    final food    = _scannedFood!;
    final kcal    = food.kcalFor(_selectedGrams).round();
    final protein = food.proteinFor(_selectedGrams).round();
    final carbs   = food.carbsFor(_selectedGrams).round();
    final fat     = food.fatFor(_selectedGrams).round();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // "Résultat" header
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _kMintBg, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.sparkles, size: 12, color: _kGreen),
            const SizedBox(width: 4),
            Text(AppL10n(Lang.code).addMealScanResult, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700, color: _kGreen)),
          ])),
        const Spacer(),
        GestureDetector(
          onTap: _resetScan,
          child: Text(AppL10n(Lang.code).addMealNewPhoto, style: GoogleFonts.inter(
            fontSize: 12, color: nc.text2,
            decoration: TextDecoration.underline))),
      ]),
      const SizedBox(height: 12),

      // Food card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: nc.border),
          boxShadow: nc.isDark ? [] : [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Food name + category chip
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: nc.mintBg, borderRadius: BorderRadius.circular(12)),
              child: const Icon(LucideIcons.utensils, size: 20, color: _kGreen)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(food.name, style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w800, color: nc.text1)),
              Text(food.category.label, style: GoogleFonts.inter(
                fontSize: 11, color: nc.text2)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _kMintBg, borderRadius: BorderRadius.circular(8)),
              child: Text('$kcal kcal', style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700, color: _kGreen))),
          ]),

          const SizedBox(height: 16),
          Divider(height: 1, color: nc.border),
          const SizedBox(height: 14),

          // Macro pills
          Row(children: [
            _ScanMacroPill(AppL10n(Lang.code).nutritionProtein, protein, 'g', const Color(0xFF4CAF82)),
            const SizedBox(width: 8),
            _ScanMacroPill(AppL10n(Lang.code).nutritionCarbs, carbs, 'g', const Color(0xFF7BD4FF)),
            const SizedBox(width: 8),
            _ScanMacroPill(AppL10n(Lang.code).nutritionFat, fat, 'g', const Color(0xFFFFB347)),
          ]),

          const SizedBox(height: 16),

          // Quantity selector
          Row(children: [
            Text(AppL10n(Lang.code).addMealQtyLabel, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: nc.text1)),
            const SizedBox(width: 12),
            SizedBox(width: 72,
              child: TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                onChanged: (v) {
                  final n = double.tryParse(v);
                  if (n != null && n > 0) _setAmount(n);
                },
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kBorder)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kMint, width: 1.5))),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            _UnitSelector(
              selected: _selectedUnit,
              onChanged: _setUnit),
          ]),
        ])),

      const SizedBox(height: 16),

      // CTA: add to basket + scan another
      // CTA buttons
      Row(children: [
        Expanded(child: GestureDetector(
          onTap: _resetScan,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _kMintBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kMint.withOpacity(0.4))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.camera, size: 16, color: _kGreen),
              const SizedBox(width: 6),
              Text(AppL10n(Lang.code).addMealOtherPhoto, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: _kGreen)),
            ])))),
        const SizedBox(width: 10),
        Expanded(child: GestureDetector(
          onTap: _selectedFood == null ? null : () {
            _addToBasket();
            _resetScan();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _kGreen,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                color: _kGreen.withOpacity(0.3),
                blurRadius: 10, offset: const Offset(0, 3))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.check, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(AppL10n(Lang.code).addMealAdd, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ])))),
      ]),

      const SizedBox(height: 10),

      // Add more ingredients — switches to search tab keeping the basket
      GestureDetector(
        onTap: _selectedFood == null ? null : () {
          _addToBasket();
          _resetScan();
          setState(() => _mode = 0);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: nc.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: nc.border)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(LucideIcons.search, size: 15, color: nc.text2),
            const SizedBox(width: 7),
            Text(AppL10n(Lang.code).addMealMoreIngr, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: nc.text2)),
          ]))),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  BASKET SHEET
// ══════════════════════════════════════════════════════════════════════════════
class _BasketSheet extends StatefulWidget {
  final List<_BasketItem> basket;
  final ValueChanged<int> onRemove;
  const _BasketSheet({required this.basket, required this.onRemove});

  @override
  State<_BasketSheet> createState() => _BasketSheetState();
}

class _BasketSheetState extends State<_BasketSheet> {
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final totalCal  = widget.basket.fold(0, (s, i) => s + i.calories);
    final totalProt = widget.basket.fold(0, (s, i) => s + i.protein);
    final totalCarb = widget.basket.fold(0, (s, i) => s + i.carbs);
    final totalFat  = widget.basket.fold(0, (s, i) => s + i.fat);

    final nc = NutritionColors.of(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // handle
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Container(width: 36, height: 4,
            decoration: BoxDecoration(
              color: nc.border,
              borderRadius: BorderRadius.circular(2)))),

        // title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(children: [
            Text(AppL10n(Lang.code).addMealBasketTitle, style: GoogleFonts.outfit(
              fontSize: 18, fontWeight: FontWeight.w800, color: nc.text1)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: nc.mintBg, borderRadius: BorderRadius.circular(20)),
              child: Text(AppL10n(Lang.code).addMealBasketCount(widget.basket.length),
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700, color: _kGreen))),
          ])),

        // totals row
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: nc.mintBg,
            borderRadius: BorderRadius.circular(14)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TotalChip('$totalCal', 'kcal', const Color(0xFF7BA7FF)),
              _TotalChip('${totalProt}g', AppL10n(Lang.code).addMealProt, _kGreen),
              _TotalChip('${totalCarb}g', AppL10n(Lang.code).addMealGluc, const Color(0xFF3B7FD4)),
              _TotalChip('${totalFat}g', AppL10n(Lang.code).addMealLip, const Color(0xFFC47A00)),
            ],
          ),
        ),

        // list
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: widget.basket.length,
            itemBuilder: (_, i) {
              final item = widget.basket[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: nc.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: nc.border)),
                child: Row(children: [
                  Text(item.food.category.emoji,
                    style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.food.name, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: nc.text1)),
                    Text('${item.grams.round()}g · ${item.calories} kcal',
                      style: GoogleFonts.inter(fontSize: 11, color: nc.text2)),
                  ])),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onRemove(i);
                      setState(() {});
                      if (widget.basket.isEmpty) Navigator.pop(context);
                    },
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEEE),
                        borderRadius: BorderRadius.circular(8)),
                      child: const Icon(LucideIcons.trash2,
                        size: 13, color: Color(0xFFE03050)))),
                ]),
              );
            },
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _kGreen,
                borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(AppL10n(Lang.code).addMealClose, style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)))),
          )),
      ]),
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String value, label;
  final Color color;
  const _TotalChip(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(value, style: GoogleFonts.outfit(
      fontSize: 16, fontWeight: FontWeight.w800, color: color)),
    Text(label, style: GoogleFonts.inter(fontSize: 10, color: _kText2)),
  ]);
}

// ══════════════════════════════════════════════════════════════════════════════
//  UNIT SELECTOR
// ══════════════════════════════════════════════════════════════════════════════
class _UnitSelector extends StatelessWidget {
  final FoodUnit selected;
  final ValueChanged<FoodUnit> onChanged;
  const _UnitSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final unit = await showModalBottomSheet<FoodUnit>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _UnitPickerSheet(selected: selected),
        );
        if (unit != null) onChanged(unit);
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _kMintBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kMint.withOpacity(0.4))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(selected.shortLabel, style: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w700, color: _kGreen)),
          const SizedBox(width: 6),
          const Icon(LucideIcons.chevronsUpDown, size: 14, color: _kGreen),
        ]),
      ),
    );
  }
}

class _UnitPickerSheet extends StatelessWidget {
  final FoodUnit selected;
  const _UnitPickerSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    final nc     = NutritionColors.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4,
          decoration: BoxDecoration(
            color: nc.border,
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Text(AppL10n(Lang.code).addMealUnitTitle, style: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w800, color: nc.text1)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: FoodUnit.values.map((unit) {
            final isSelected = unit == selected;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context, unit);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _kGreen : nc.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? _kGreen : nc.border)),
                child: Text(unit.label, style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : nc.text1)),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  MEAL TYPE PICKER SHEET
// ══════════════════════════════════════════════════════════════════════════════
class _MealTypePickerSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final nc     = NutritionColors.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4,
          decoration: BoxDecoration(
            color: nc.border,
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text(AppL10n(Lang.code).addMealWhichMeal, style: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w800,
          color: nc.text1)),
        const SizedBox(height: 16),
        ...MealType.values.map((type) => GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context, type);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: nc.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: nc.border)),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: nc.mintBg,
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(_typeIcon(type), size: 16,
                  color: const Color(0xFF1C4D30))),
              const SizedBox(width: 12),
              Text(type.labelFor(Lang.code), style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: nc.text1)),
              const Spacer(),
              Text('${type.budgetKcal} kcal', style: GoogleFonts.inter(
                fontSize: 12, color: nc.text2)),
            ])))),
      ]));
  }

  IconData _typeIcon(MealType t) => switch (t) {
    MealType.breakfast => LucideIcons.coffee,
    MealType.lunch     => LucideIcons.utensils,
    MealType.snack     => LucideIcons.apple,
    MealType.dinner    => LucideIcons.moon,
  };
}

// ══════════════════════════════════════════════════════════════════════════════
//  SMALL WIDGETS
// ══════════════════════════════════════════════════════════════════════════════
class _FoodSelectTile extends StatelessWidget {
  final FoodItem food;
  final bool isSelected;
  final double? selectedGrams;
  final VoidCallback onToggle;
  final VoidCallback onEditQuantity;
  const _FoodSelectTile({
    required this.food,
    required this.isSelected,
    required this.onToggle,
    required this.onEditQuantity,
    this.selectedGrams,
  });

  @override
  Widget build(BuildContext context) {
    final nc    = NutritionColors.of(context);
    final grams = selectedGrams ?? food.defaultGrams;
    final kcal  = food.kcalFor(grams).round();

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? nc.mintBg : nc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _kMint : nc.border,
            width: isSelected ? 1.5 : 1.0)),
        child: Row(children: [

          // Food photo
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 42, height: 42,
              child: Image.network(
                _catPhoto(food.category),
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        color: _catColor(food.category).withOpacity(0.12),
                        child: Icon(_catIcon(food.category),
                          size: 18, color: _catColor(food.category))),
                errorBuilder: (_, __, ___) => Container(
                  color: _catColor(food.category).withOpacity(0.12),
                  child: Icon(_catIcon(food.category),
                    size: 18, color: _catColor(food.category))),
              ))),

          const SizedBox(width: 12),

          // Name + serving info
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(food.name, style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: nc.text1)),
            const SizedBox(height: 3),
            Row(children: [
              // Serving/quantity pill — tap to edit when selected
              GestureDetector(
                onTap: isSelected ? onEditQuantity : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? nc.surface : nc.chipBg,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: _kMint.withOpacity(0.5))
                        : null),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      isSelected
                          ? '${grams.round()} g'
                          : food.portionLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: isSelected ? _kGreen : nc.text2)),
                    if (isSelected) ...[
                      const SizedBox(width: 3),
                      const Icon(LucideIcons.chevronDown, size: 10, color: _kGreen),
                    ],
                  ])),
              ),
              const SizedBox(width: 8),
              Text('$kcal kcal',
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: isSelected ? _kGreen : nc.text2)),
            ]),
          ])),

          const SizedBox(width: 10),

          // Toggle button
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: isSelected ? _kGreen : nc.chipBg,
              shape: BoxShape.circle,
              boxShadow: isSelected ? [BoxShadow(
                color: _kGreen.withOpacity(0.3),
                blurRadius: 8, offset: const Offset(0, 2))] : []),
            child: Icon(
              isSelected ? LucideIcons.check : LucideIcons.plus,
              size: 16,
              color: isSelected ? Colors.white : nc.text2)),
        ])));
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: nc.surface, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: nc.border)),
    child: Column(children: [
      Icon(LucideIcons.searchX, size: 32, color: nc.text2),
      const SizedBox(height: 10),
      Text(AppL10n(Lang.code).addMealNoResults(query),
        style: GoogleFonts.inter(fontSize: 13, color: nc.text2)),
      const SizedBox(height: 4),
      Text(AppL10n(Lang.code).addMealTryManual,
        style: GoogleFonts.inter(fontSize: 11, color: nc.text2)),
    ]));
  }
}

class _PortionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PortionChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? _kGreen : nc.chipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? _kGreen : nc.border)),
      child: Text(label, style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: selected ? Colors.white : nc.text1))));
  }
}

class _ModeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeTab({required this.icon, required this.label,
    required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? _kGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active ? [BoxShadow(
            color: _kGreen.withOpacity(0.2),
            blurRadius: 8, offset: const Offset(0, 2))] : []),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: active ? Colors.white : nc.text2),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.inter(
            fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : nc.text2)),
        ]))));
  }
}

class _AppField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType keyboard;
  final ValueChanged<String>? onChanged;
  const _AppField(this.label, this.hint, this.controller, {
    this.keyboard = TextInputType.text, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w600, color: nc.text2)),
    const SizedBox(height: 6),
    TextField(
      controller: controller, keyboardType: keyboard, onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 14, color: nc.text1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: nc.text2),
        filled: true, fillColor: nc.chipBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kMint, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13)))]);
  }
}

class _MacroInput extends StatelessWidget {
  final String label, unit;
  final Color color;
  final TextEditingController controller;
  const _MacroInput(this.label, this.unit, this.color, this.controller);

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(width: 6, height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.inter(
        fontSize: 10, color: nc.text2, fontWeight: FontWeight.w600)),
    ]),
    const SizedBox(height: 6),
    TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.inter(fontSize: 14, color: nc.text1),
      decoration: InputDecoration(
        hintText: unit,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: nc.text2),
        filled: true, fillColor: nc.chipBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))),
    ]);
  }
}

class _MacroBadge extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _MacroBadge(this.label, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w700, color: color)));
}

class _MacroBar extends StatelessWidget {
  final String label;
  final int value, maxPer100;
  final Color color;
  const _MacroBar(this.label, this.value, this.maxPer100, this.color);

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w600, color: nc.text1)),
      Text('${value}g', style: GoogleFonts.inter(fontSize: 11, color: nc.text2)),
    ]),
    const SizedBox(height: 6),
    ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: LinearProgressIndicator(
        value: maxPer100 > 0 ? (value / maxPer100).clamp(0.0, 1.0) : 0,
        minHeight: 5,
        backgroundColor: color.withOpacity(0.12),
        valueColor: AlwaysStoppedAnimation(color))),
    ]);
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final bool top, left;
  const _Corner(this.color, {required this.top, required this.left});

  @override
  Widget build(BuildContext context) => Positioned(
    top: top ? 16 : null, bottom: !top ? 16 : null,
    left: left ? 16 : null, right: !left ? 16 : null,
    child: Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        border: Border(
          top:    top  ? BorderSide(color: color, width: 2.5) : BorderSide.none,
          bottom: !top ? BorderSide(color: color, width: 2.5) : BorderSide.none,
          left:   left ? BorderSide(color: color, width: 2.5) : BorderSide.none,
          right:  !left ? BorderSide(color: color, width: 2.5) : BorderSide.none))));
}

// ── Scanning animated dots ─────────────────────────────────────────────────
class _ScanningDots extends StatefulWidget {
  const _ScanningDots();
  @override
  State<_ScanningDots> createState() => _ScanningDotsState();
}

class _ScanningDotsState extends State<_ScanningDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
          final scale = (1 + 0.5 * ((t * 3 - i).clamp(0, 1) *
            (1 - (t * 3 - i).clamp(0, 1)) * 4)).clamp(0.7, 1.5);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: _kMint,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: _kMint.withOpacity(0.5 * (scale - 0.7)),
                    blurRadius: 8)]))));
        }));
      });
  }
}

// ── Scan macro pill ────────────────────────────────────────────────────────
class _ScanMacroPill extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final Color color;
  const _ScanMacroPill(this.label, this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Text('$value$unit', style: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(
          fontSize: 10, color: _kText2)),
      ])));
}
