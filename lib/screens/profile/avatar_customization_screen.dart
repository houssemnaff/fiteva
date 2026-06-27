import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dice_bear/dice_bear.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';

class AvatarCustomizationScreen extends ConsumerStatefulWidget {
  final String userName;
  const AvatarCustomizationScreen({super.key, required this.userName});

  @override
  ConsumerState<AvatarCustomizationScreen> createState() => _AvatarCustomizationScreenState();
}

class _AvatarCustomizationScreenState extends ConsumerState<AvatarCustomizationScreen> {
  DiceBearStyle _sprite = DiceBearStyle.lorelei;
  String _seed    = '';
  String _bgColor = 'b6e3f4';

  static const Color _accent = Color(0xFF7ABB98);

  final _sprites = [
    (DiceBearStyle.lorelei,    'Lorelei'),
    (DiceBearStyle.adventurer, 'Adventurer'),
    (DiceBearStyle.avataaars,  'Avataaars'),
    (DiceBearStyle.micah,      'Micah'),
    (DiceBearStyle.pixelArt,   'Pixel Art'),
    (DiceBearStyle.openPeeps,  'Open Peeps'),
    (DiceBearStyle.funEmoji,   'Fun Emoji'),
    (DiceBearStyle.bottts,     'Bottts'),
  ];

  final _bgColors = [
    'b6e3f4', 'ffdfbf', 'ffd5dc', 'd1f0c2',
    'e8d5f5', 'fff3b0', 'f0e6ff', 'fce4d6',
    'c8e6c9', 'f8bbd9', 'b3e5fc', 'ffe0b2',
  ];

  @override
  void initState() {
    super.initState();
    _seed = widget.userName;
  }

  String _buildUrl({DiceBearStyle? style, String? seed, String? bg}) =>
      DiceBearRequest(
        style: style ?? _sprite,
        format: DiceBearFormat.svg,
        coreOptions: DiceBearCoreOptions(
          seed: seed ?? _seed,
          backgroundColor: [bg ?? _bgColor],
          radius: 50,
        ),
      ).uri.toString();

  String get _avatarUrl => _buildUrl();
  String _urlFor(DiceBearStyle style) => _buildUrl(style: style, seed: widget.userName);

  void _randomize() {
    setState(() => _seed = DateTime.now().millisecondsSinceEpoch.toString());
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final l10n      = ref.watch(l10nProvider);
    final avatarUrl = _avatarUrl;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.avatarTitle,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, {
              'seed': _seed, 'sprite': _sprite.name, 'url': avatarUrl,
            }),
            child: Text(l10n.avatarEnregistrer,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _accent)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: cs.outline.withOpacity(0.3)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Avatar preview ────────────────────────────────────────────
          Center(child: Stack(alignment: Alignment.bottomRight, children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _accent.withOpacity(0.35), width: 3),
              ),
              child: ClipOval(
                child: SvgPicture.network(
                  avatarUrl, width: 120, height: 120, fit: BoxFit.cover,
                  placeholderBuilder: (_) => Container(
                    color: cs.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: _accent)),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _randomize,
              child: Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
                child: const Icon(Icons.shuffle_rounded, color: Colors.white, size: 18),
              ),
            ),
          ])),

          const SizedBox(height: 8),
          Center(child: Text(l10n.avatarAleatoire,
            style: GoogleFonts.inter(fontSize: 12, color: cs.onSurface.withOpacity(0.45)))),

          const SizedBox(height: 32),

          // ── Style ────────────────────────────────────────────────────
          Text(l10n.avatarStyle, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
            color: cs.onSurface.withOpacity(0.45), letterSpacing: 1.2)),
          const SizedBox(height: 12),

          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _sprites.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (ctx, i) {
                final (style, name) = _sprites[i];
                final selected = _sprite == style;
                return GestureDetector(
                  onTap: () {
                    setState(() => _sprite = style);
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 72,
                    decoration: BoxDecoration(
                      color: selected ? _accent.withOpacity(0.12) : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? _accent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: SvgPicture.network(_urlFor(style),
                          width: 44, height: 44, fit: BoxFit.cover,
                          placeholderBuilder: (_) => SizedBox(
                            width: 44, height: 44,
                            child: Center(child: CircularProgressIndicator(
                              strokeWidth: 1.5, color: _accent)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(name,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? _accent : cs.onSurface.withOpacity(0.5)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // ── Couleur de fond ──────────────────────────────────────────
          Text(l10n.avatarCouleur, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
            color: cs.onSurface.withOpacity(0.45), letterSpacing: 1.2)),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10, runSpacing: 10,
            children: _bgColors.map((hex) {
              final selected = _bgColor == hex;
              final color = Color(int.parse('FF$hex', radix: 16));
              return GestureDetector(
                onTap: () {
                  setState(() => _bgColor = hex);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? _accent : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(color: _accent.withOpacity(0.35), blurRadius: 8)]
                        : [],
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          // ── Bouton save ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'seed': _seed, 'sprite': _sprite.name, 'url': avatarUrl,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l10n.avatarUtiliser,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}
