import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'widgets/shared/shared_widgets.dart';  
import 'widgets/meal_widgets.dart';

class AjoutRapideScreen extends StatefulWidget {
  const AjoutRapideScreen({super.key});

  @override
  State<AjoutRapideScreen> createState() => _AjoutRapideScreenState();
}

class _AjoutRapideScreenState extends State<AjoutRapideScreen> {
  int _mode = 0;
  final _nameCtrl  = TextEditingController();
  final _calCtrl   = TextEditingController();
  final _poidsCtrl = TextEditingController();
  final _protCtrl  = TextEditingController();
  final _glucCtrl  = TextEditingController();
  final _lipCtrl   = TextEditingController();

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
    _nameCtrl.dispose(); _calCtrl.dispose(); _poidsCtrl.dispose();
    _protCtrl.dispose(); _glucCtrl.dispose(); _lipCtrl.dispose();
    super.dispose();
  }

  void _showMealTypeModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MealTypeSheet(onConfirm: () {
        Navigator.pop(context); // close sheet
        Navigator.pop(context); // go back
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        Expanded(child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(children: [
                BackBtn(onTap: () => Navigator.pop(context)),
                const SizedBox(width: 12),
                const Expanded(child: Text('Ajout rapide',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark))),
              ]),
            ),
          )),
          // Mode tabs
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(children: List.generate(4, (i) => Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _mode = i),
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  height: 60,
                  decoration: BoxDecoration(
                    color: _mode == i ? kBrown : kWhite,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_modeIcons[i], size: 20,
                        color: _mode == i ? kWhite : kTextGrey),
                    const SizedBox(height: 2),
                    Text(_modeLabels[i],
                        style: TextStyle(
                            fontSize: 9, fontWeight: FontWeight.w600,
                            color: _mode == i ? kWhite : kTextGrey)),
                  ]),
                ),
              ),
            ))),
          )),
          // Guide banner
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFE8F4F8),
                  borderRadius: BorderRadius.circular(12)),
              child: const Text(
                  'Saisis le nom du produit ou plat. Si les macros ne sont pas connues, tu peux juste mettre les calories.',
                  style: TextStyle(fontSize: 12, color: kTextDark, height: 1.5)),
            ),
          )),
          // Form card
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: kWhite, borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _FormField(
                    'Nom du plat / produit', 'Ex: Riz thaï au poulet',
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
                const Text('Macronutriments',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: kTextDark)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _MacroInputLabel('Protéines', kPink),
                    const SizedBox(height: 4),
                    _FormField('', 'g', controller: _protCtrl,
                        keyboardType: TextInputType.number),
                  ])),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _MacroInputLabel('Glucides', kBlue),
                    const SizedBox(height: 4),
                    _FormField('', 'g', controller: _glucCtrl,
                        keyboardType: TextInputType.number),
                  ])),
                ]),
                const SizedBox(height: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _MacroInputLabel('Lipides', kLime),
                  const SizedBox(height: 4),
                  SizedBox(width: 140,
                      child: _FormField('', 'g', controller: _lipCtrl,
                          keyboardType: TextInputType.number)),
                ]),
              ]),
            ),
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ])),
        // Add button
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          color: kBg,
          child: GestureDetector(
            onTap: _canAdd ? _showMealTypeModal : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _canAdd ? kBrown : kBrown.withOpacity(0.2),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add, color: _canAdd ? kWhite : kBrown.withOpacity(0.5), size: 18),
                const SizedBox(width: 8),
                Text('Ajouter au suivi',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: _canAdd ? kWhite : kBrown.withOpacity(0.5))),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Local form helpers (scoped to this screen) ────────────────────────────────
class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  const _FormField(this.label, this.hint,
      {required this.controller,
      this.keyboardType = TextInputType.text,
      this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(label, style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: kTextDark)),
            const SizedBox(height: 6),
          ],
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14, color: kTextDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: kTextGrey.withOpacity(0.5), fontSize: 14),
              filled: true,
              fillColor: kBg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kGreenLight, width: 1.5)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ],
      );
}

class _MacroInputLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _MacroInputLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
        width: 7, height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(fontSize: 11, color: kTextGrey)),
  ]);
}