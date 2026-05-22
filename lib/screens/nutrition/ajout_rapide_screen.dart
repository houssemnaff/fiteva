import 'package:flutter/material.dart';

import 'models/models.dart';
import 'widgets/meal_widgets.dart';
import 'widgets/shared/shared_widgets.dart';

class AjoutRapideScreen extends StatefulWidget {
  const AjoutRapideScreen({super.key});

  @override
  State<AjoutRapideScreen> createState() => _AjoutRapideScreenState();
}

class _AjoutRapideScreenState extends State<AjoutRapideScreen> {
  int _mode = 0;
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _poidsCtrl = TextEditingController();
  final _protCtrl = TextEditingController();
  final _glucCtrl = TextEditingController();
  final _lipCtrl = TextEditingController();

  bool get _canAdd => _nameCtrl.text.isNotEmpty && _calCtrl.text.isNotEmpty;

  static const _modeIcons = [
    Icons.camera_alt_outlined,
    Icons.qr_code_outlined,
    Icons.restaurant_menu_outlined,
    Icons.edit_outlined,
  ];
  static const _modeLabels = ['Photo', 'Code-barre', 'Recettes', 'Manuel'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calCtrl.dispose();
    _poidsCtrl.dispose();
    _protCtrl.dispose();
    _glucCtrl.dispose();
    _lipCtrl.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Row(
                        children: [
                          BackBtn(onTap: () => Navigator.pop(context)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ajout rapide',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: List.generate(
                        4,
                        (i) => Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _mode = i),
                            child: Container(
                              margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                              height: 60,
                              decoration: BoxDecoration(
                                color: _mode == i
                                    ? colorScheme.primary
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _modeIcons[i],
                                    size: 20,
                                    color: _mode == i
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _modeLabels[i],
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: _mode == i
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Saisis le nom du produit ou plat. Si les macros ne sont pas connues, tu peux juste mettre les calories.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FormField(
                            'Nom du plat / produit',
                            'Ex: Riz thaï au poulet',
                            controller: _nameCtrl,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _FormField(
                                  'Calories (kcal)',
                                  'Ex: 450',
                                  controller: _calCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _FormField(
                                  'Poids (g)',
                                  'Ex: 250',
                                  controller: _poidsCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Macronutriments',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _MacroInputLabel('Protéines', colorScheme.secondary),
                                    const SizedBox(height: 4),
                                    _FormField(
                                      '',
                                      'g',
                                      controller: _protCtrl,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _MacroInputLabel('Glucides', colorScheme.primary),
                                    const SizedBox(height: 4),
                                    _FormField(
                                      '',
                                      'g',
                                      controller: _glucCtrl,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MacroInputLabel('Lipides', colorScheme.tertiary),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 140,
                                child: _FormField(
                                  '',
                                  'g',
                                  controller: _lipCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            color: colorScheme.background,
            child: GestureDetector(
              onTap: _canAdd ? _showMealTypeModal : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _canAdd
                      ? colorScheme.primary
                      : colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: _canAdd
                          ? colorScheme.onPrimary
                          : colorScheme.primary.withOpacity(0.5),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ajouter au suivi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _canAdd
                            ? colorScheme.onPrimary
                            : colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  const _FormField(
    this.label,
    this.hint, {
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontSize: 14,
            ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _MacroInputLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _MacroInputLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      );
}
