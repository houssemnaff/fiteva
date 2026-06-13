// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pregnancy_colors.dart';
import 'symptom_entry.dart';

extension _Pg on BuildContext {
  PgColors get _p => PgColors.of(this);
}

class AddSymptomSheet extends StatefulWidget {
  const AddSymptomSheet({super.key, required this.onSave});

  final ValueChanged<SymptomEntry> onSave;

  static Future<void> show({
    required BuildContext context,
    required ValueChanged<SymptomEntry> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (_) => Theme(
        data: Theme.of(context),
        child: AddSymptomSheet(onSave: onSave),
      ),
    );
  }

  @override
  State<AddSymptomSheet> createState() => _AddSymptomSheetState();
}

class _AddSymptomSheetState extends State<AddSymptomSheet> {
  SymptomType? _selected;
  double _intensity = 2;
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  void _save() {
    if (_selected == null) return;
    HapticFeedback.lightImpact();
    widget.onSave(SymptomEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selected!,
      intensity: _intensity.round().clamp(1, 5),
      date: DateTime.now(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final kb     = MediaQuery.of(context).viewInsets.bottom;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + kb + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context._p.border,
                borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 20),

            // title
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: context._p.mintLight,
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.add_circle_outline_rounded,
                    size: 18, color: context._p.green),
              ),
              const SizedBox(width: 12),
              Text('Comment tu te sens ?', style: GoogleFonts.outfit(
                fontSize: 17, fontWeight: FontWeight.w600, color: context._p.textDark)),
            ]),

            const SizedBox(height: 24),

            // symptom picker
            _Label('Choisis un symptôme'),
            const SizedBox(height: 12),
            _SymptomGrid(
              selected: _selected,
              onSelect: (t) => setState(() => _selected = t),
            ),

            const SizedBox(height: 24),

            // intensity
            _Label('Intensité  •  ${_intensity.round()} / 5'),
            const SizedBox(height: 10),
            _IntensityRow(
              value: _intensity,
              onChanged: (v) => setState(() => _intensity = v),
            ),

            const SizedBox(height: 24),

            // note
            _Label('Note (optionnel)'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              style: GoogleFonts.inter(fontSize: 14, color: context._p.textDark),
              decoration: InputDecoration(
                hintText: 'Un détail à retenir…',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: context._p.textSoft),
                filled: true,
                fillColor: context._p.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 28),

            // save button
            GestureDetector(
              onTap: _selected != null ? _save : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                decoration: BoxDecoration(
                  gradient: _selected != null
                      ? LinearGradient(
                          colors: [context._p.mint, context._p.green],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)
                      : null,
                  color: _selected != null ? null : context._p.mintLight,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: _selected != null
                      ? const [BoxShadow(
                          color: Color(0x401C4D30),
                          blurRadius: 16, offset: Offset(0, 6))]
                      : null,
                ),
                child: Center(child: Text('Enregistrer',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _selected != null ? Colors.white : context._p.textSoft,
                    letterSpacing: 0.2))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w600,
      color: context._p.textSoft, letterSpacing: 1.5));
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SymptomGrid extends StatelessWidget {
  final SymptomType? selected;
  final ValueChanged<SymptomType> onSelect;
  const _SymptomGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: SymptomType.values.length,
      itemBuilder: (_, i) {
        final type = SymptomType.values[i];
        final isSelected = type == selected;
        final color = type.baseColor;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.12)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : Theme.of(context).colorScheme.outline,
                width: isSelected ? 1.5 : 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.18)
                        : Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle),
                  child: Icon(type.icon,
                      size: 18,
                      color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                ),
                const SizedBox(height: 5),
                Text(type.label,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: isSelected
                        ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : context._p.textMid),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _IntensityRow extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _IntensityRow({required this.value, required this.onChanged});

  static const _labels = ['', 'Légère', 'Légère', 'Modérée', 'Forte', 'Intense'];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          activeTrackColor: context._p.green,
          inactiveTrackColor: context._p.mintLight,
          thumbColor: context._p.green,
          overlayColor: context._p.mint.withOpacity(0.15),
        ),
        child: Slider(
          value: value, min: 1, max: 5, divisions: 4,
          onChanged: onChanged,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Légère', style: GoogleFonts.inter(
              fontSize: 10, color: context._p.textSoft)),
            Text(_labels[value.round()], style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700, color: context._p.green)),
            Text('Intense', style: GoogleFonts.inter(
              fontSize: 10, color: context._p.textSoft)),
          ],
        ),
      ),
    ]);
  }
}
