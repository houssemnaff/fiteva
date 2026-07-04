import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/mascot_provider.dart';
import '../../widgets/mascot_widget.dart';

class AvatarCustomizationScreen extends ConsumerStatefulWidget {
  final String userName;
  const AvatarCustomizationScreen({super.key, required this.userName});

  @override
  ConsumerState<AvatarCustomizationScreen> createState() => _AvatarCustomizationScreenState();
}

class _AvatarCustomizationScreenState extends ConsumerState<AvatarCustomizationScreen> {
  late MascotType _type;
  late MascotMood _mood;

  static const _types = [
    (MascotType.blob,  'Blob'),
    (MascotType.sun,   'Soleil'),
    (MascotType.star,  'Étoile'),
    (MascotType.cloud, 'Nuage'),
    (MascotType.leaf,  'Feuille'),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final bg       = isDarkMode ? const Color(0xFF0D0D0D) : const Color(0xFFF6F9F7);
    final surf     = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final ink      = isDarkMode ? const Color(0xFFF0F0EE) : const Color(0xFF1C4D30);
    final muted    = isDarkMode ? const Color(0xFF888886) : const Color(0xFF6B7280);
    final border   = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE0EBE5);
    final green    = const Color(0xFF1C4D30);
    final greenBg  = isDarkMode ? const Color(0xFF1E2A1E) : const Color(0xFFE8F3EC);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bg,
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
                        color: surf,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border)),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: ink)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('Mon Mascotte',
                      style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: ink)),
                  ),
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: green,
                        borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.check_rounded,
                          size: 20, color: Colors.white),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              // ── Preview ─────────────────────────────────────────────
              Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  color: greenBg,
                  shape: BoxShape.circle),
                child: Center(
                  child: MascotWidget(type: _type, mood: _mood, size: 110),
                ),
              ),

              const SizedBox(height: 8),
              Text('Aperçu en direct',
                style: GoogleFonts.inter(
                  fontSize: 12, color: muted)),

              const SizedBox(height: 24),

              // ── Scroll content ──────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type
                      _SectionLabel('Forme du mascotte', muted),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        children: _types.map((t) {
                          final sel = _type == t.$1;
                          return GestureDetector(
                            onTap: () => setState(() => _type = t.$1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 76,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? greenBg : surf,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: sel ? green : border,
                                  width: sel ? 1.5 : 1),
                                boxShadow: sel ? [
                                  BoxShadow(color: green.withValues(alpha: 0.20),
                                      blurRadius: 8, offset: const Offset(0, 3))
                                ] : [],
                              ),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                SizedBox(
                                  width: 44, height: 44,
                                  child: MascotWidget(type: t.$1, mood: _mood, size: 44),
                                ),
                                const SizedBox(height: 6),
                                Text(t.$2,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 12, fontWeight: FontWeight.w600,
                                    color: sel ? green : ink)),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      // Mood
                      _SectionLabel('Humeur', muted),
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
                                color: sel ? green : surf,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel ? green : border),
                                boxShadow: sel ? [
                                  BoxShadow(color: green.withValues(alpha: 0.25),
                                      blurRadius: 8, offset: const Offset(0, 3))
                                ] : [],
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text(m.$3, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(m.$2,
                                  style: GoogleFonts.inter(
                                    fontSize: 13, fontWeight: FontWeight.w600,
                                    color: sel ? Colors.white : ink)),
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
  final Color color;
  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: GoogleFonts.inter(
      fontSize: 10, fontWeight: FontWeight.w700,
      color: color, letterSpacing: 1.2),
  );
}
