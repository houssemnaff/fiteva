// ─────────────────────────────────────────────
// add_symptom_sheet.dart
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'symptom_entry.dart';

class AddSymptomSheet extends StatefulWidget {
  const AddSymptomSheet({
    super.key,
    required this.accentColor,
    required this.onSave,
  });

  final Color accentColor;
  final ValueChanged<SymptomEntry> onSave;

  static Future<void> show({
    required BuildContext context,
    required Color accentColor,
    required ValueChanged<SymptomEntry> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Lets the sheet grow up to 92% of screen height
      useSafeArea: false,
      builder: (_) => AddSymptomSheet(
        accentColor: accentColor,
        onSave: onSave,
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
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_selected == null) return;
    HapticFeedback.lightImpact();
    widget.onSave(
      SymptomEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selected!,
        intensity: _intensity.round(),
        date: DateTime.now(),
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // safeBottom = home indicator + nav bar height
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    final Color accent = widget.accentColor;

    return Container(
      // Sits just above the nav bar — the 12 px bottom margin is enough
      // because we also add safeBottom inside the scroll padding below.
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      constraints: BoxConstraints(
        // Never taller than 92 % of screen so there's breathing room at top
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFBF8),
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      // Wrap in a scrollable so content never gets clipped on small phones
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          // 24 base + keyboard height + nav-bar / home-indicator safe area
          24 + keyboardHeight + safeBottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ──────────────────────────────────────────
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDD8D0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Header ───────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.add_circle_outline_rounded,
                      size: 16, color: accent),
                ),
                const SizedBox(width: 10),
                Text(
                  'Log a Symptom',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ── Symptom picker grid ──────────────────────────────────
            _SectionLabel(label: 'What are you feeling?', accent: accent),
            const SizedBox(height: 12),
            _SymptomGrid(
              selected: _selected,
              onSelect: (t) => setState(() => _selected = t),
              accent: accent,
            ),

            const SizedBox(height: 22),

            // ── Intensity slider ─────────────────────────────────────
            _SectionLabel(
              label: 'Intensity  •  ${_intensity.round()} / 5',
              accent: accent,
            ),
            const SizedBox(height: 8),
            _IntensitySlider(
              value: _intensity,
              accent: accent,
              onChanged: (v) => setState(() => _intensity = v),
            ),

            const SizedBox(height: 22),

            // ── Note input ───────────────────────────────────────────
            _SectionLabel(label: 'Add a note (optional)', accent: accent),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4A5A),
              ),
              decoration: InputDecoration(
                hintText: 'Anything else you\'d like to remember…',
                hintStyle: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F0EA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),

            const SizedBox(height: 24),

            // ── Save button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selected != null ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  disabledBackgroundColor: accent.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Entry',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal widgets ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.accent});
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: accent.withOpacity(0.75),
      ),
    );
  }
}

class _SymptomGrid extends StatelessWidget {
  const _SymptomGrid({
    required this.selected,
    required this.onSelect,
    required this.accent,
  });

  final SymptomType? selected;
  final ValueChanged<SymptomType> onSelect;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: SymptomType.values.length,
      itemBuilder: (_, i) {
        final type = SymptomType.values[i];
        final isSelected = type == selected;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect(type);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: isSelected
                  ? accent.withOpacity(0.12)
                  : const Color(0xFFF5F0EA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? accent : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(type.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color:
                        isSelected ? accent : const Color(0xFF7A7A8A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IntensitySlider extends StatelessWidget {
  const _IntensitySlider({
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  final double value;
  final Color accent;
  final ValueChanged<double> onChanged;

  static const List<String> _labels = [
    'None',
    'Mild',
    'Mild',
    'Moderate',
    'High',
    'Strong',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: accent,
            inactiveTrackColor: accent.withOpacity(0.15),
            thumbColor: accent,
            overlayColor: accent.withOpacity(0.1),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 5,
            divisions: 5,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'None',
                style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
              ),
              Text(
                _labels[value.round()],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
              const Text(
                'Strong',
                style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}