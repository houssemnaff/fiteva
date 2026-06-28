import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/mascot_provider.dart';
import '../../widgets/mascot_widget.dart';

class AvatarCustomizationScreen extends ConsumerStatefulWidget {
  final String userName;
  const AvatarCustomizationScreen({super.key, required this.userName});

  @override
  ConsumerState<AvatarCustomizationScreen> createState() => _AvatarCustomizationScreenState();
}

class _AvatarCustomizationScreenState extends ConsumerState<AvatarCustomizationScreen> {
  static const _kGreen     = Color(0xFF1C4D30);
  static const _kGreenLight = Color(0xFFE8F3EC);

  late MascotType _type;
  late MascotMood _mood;

  static const _types = [
    (MascotType.blob,  'Blob',   '🫧'),
    (MascotType.sun,   'Soleil', '☀️'),
    (MascotType.star,  'Étoile', '⭐'),
    (MascotType.cloud, 'Nuage',  '☁️'),
    (MascotType.leaf,  'Feuille','🍃'),
  ];

  static const _moods = [
    (MascotMood.happy,       'Joyeux',    '😊'),
    (MascotMood.excited,     'Excité',    '🤩'),
    (MascotMood.sleepy,      'Endormi',   '😴'),
    (MascotMood.proud,       'Fier',      '😎'),
    (MascotMood.celebrating, 'Fête',      '🎉'),
  ];

  @override
  void initState() {
    super.initState();
    final mascot = ref.read(mascotProvider);
    _type = mascot.type;
    _mood = mascot.mood;
  }

  Future<void> _save() async {
    await ref.read(mascotProvider.notifier).update(type: _type, mood: _mood);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n(Lang.code);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9F7),
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0EBE5))),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: _kGreen)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('Mon Mascotte',
                      style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: _kGreen)),
                  ),
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: _kGreen,
                        borderRadius: BorderRadius.circular(12)),
                      child: Text('Sauvegarder',
                        style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 13,
                          fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              // ── Preview ─────────────────────────────────────────────
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  color: _kGreenLight,
                  shape: BoxShape.circle),
                child: Center(
                  child: MascotWidget(type: _type, mood: _mood, size: 110),
                ),
              ),

              const SizedBox(height: 8),
              Text('Aperçu en direct',
                style: GoogleFonts.inter(
                  fontSize: 12, color: const Color(0xFF6B7280))),

              const SizedBox(height: 24),

              // ── Scroll content ──────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type
                      _SectionLabel('Forme du mascotte'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        children: _types.map((t) {
                          final sel = _type == t.$1;
                          return GestureDetector(
                            onTap: () => setState(() => _type = t.$1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? _kGreen : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel ? _kGreen : const Color(0xFFE0EBE5)),
                                boxShadow: sel ? [
                                  BoxShadow(color: _kGreen.withOpacity(0.25),
                                      blurRadius: 8, offset: const Offset(0, 3))
                                ] : [],
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text(t.$3, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(t.$2,
                                  style: GoogleFonts.inter(
                                    fontSize: 13, fontWeight: FontWeight.w600,
                                    color: sel ? Colors.white : _kGreen)),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Mood
                      _SectionLabel('Humeur'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        children: _moods.map((m) {
                          final sel = _mood == m.$1;
                          return GestureDetector(
                            onTap: () => setState(() => _mood = m.$1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? _kGreen : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel ? _kGreen : const Color(0xFFE0EBE5)),
                                boxShadow: sel ? [
                                  BoxShadow(color: _kGreen.withOpacity(0.25),
                                      blurRadius: 8, offset: const Offset(0, 3))
                                ] : [],
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text(m.$3, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(m.$2,
                                  style: GoogleFonts.inter(
                                    fontSize: 13, fontWeight: FontWeight.w600,
                                    color: sel ? Colors.white : _kGreen)),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: GoogleFonts.inter(
      fontSize: 10, fontWeight: FontWeight.w700,
      color: const Color(0xFF9CA3AF), letterSpacing: 1.2),
  );
}
