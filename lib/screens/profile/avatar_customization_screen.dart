import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dice_bear/dice_bear.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AvatarCustomizationScreen extends StatefulWidget {
  final String userName;
  const AvatarCustomizationScreen({super.key, required this.userName});

  @override
  State<AvatarCustomizationScreen> createState() =>
      _AvatarCustomizationScreenState();
}

class _AvatarCustomizationScreenState
    extends State<AvatarCustomizationScreen> {
  DiceBearStyle _sprite = DiceBearStyle.lorelei;
  String _seed    = '';
  String _bgColor = 'b6e3f4';

  static const Color _accent = Color(0xFFD4856A);

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
  ];

  @override
  void initState() {
    super.initState();
    _seed = widget.userName;
  }

  // ── URL builder (new DiceBearRequest API) ────────────────────────────────
  String _buildUrl({DiceBearStyle? style, String? seed}) =>
      DiceBearRequest(
        style: style ?? _sprite,
        format: DiceBearFormat.svg,
        coreOptions: DiceBearCoreOptions(
          seed: seed ?? _seed,
          backgroundColor: [_bgColor],
          radius: 50,
        ),
      ).uri.toString();

  String get _avatarUrl => _buildUrl();

  String _urlFor(DiceBearStyle style) =>
      _buildUrl(style: style, seed: widget.userName);

  void _randomize() {
    setState(() => _seed = DateTime.now().millisecondsSinceEpoch.toString());
    HapticFeedback.lightImpact();
  }

  // ── Dark-mode palette ────────────────────────────────────────────────────
  Color _bg(Brightness b)      => b == Brightness.light ? const Color(0xFFF5F5F3) : const Color(0xFF0F0F0F);
  Color _surface(Brightness b) => b == Brightness.light ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C);
  Color _ink(Brightness b)     => b == Brightness.light ? const Color(0xFF1A1A24) : const Color(0xFFF2F2F0);
  Color _inkSub(Brightness b)  => b == Brightness.light ? const Color(0xFF9898A4) : const Color(0xFF7A7A80);
  Color _divider(Brightness b) => b == Brightness.light ? const Color(0xFFEFEFF3) : const Color(0xFF2A2A28);
  Color _chipSel(Brightness b) => b == Brightness.light ? const Color(0xFFFFF0EB) : const Color(0xFF2A1810);
  Color _btnBg(Brightness b)   => b == Brightness.light ? const Color(0xFF1A1A24) : const Color(0xFFF2F2F0);
  Color _btnFg(Brightness b)   => b == Brightness.light ? Colors.white             : const Color(0xFF1A1A24);

  @override
  Widget build(BuildContext context) {
    final b         = Theme.of(context).brightness;
    final avatarUrl = _avatarUrl;

    return Scaffold(
      backgroundColor: _bg(b),
      appBar: AppBar(
        backgroundColor: _surface(b),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: _ink(b), size: 18),
        ),
        title: Text('Ton avatar',
            style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _ink(b))),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, {
              'seed': _seed,
              'sprite': _sprite.name,
              'url': avatarUrl,
            }),
            child: Text('Sauvegarder',
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _accent)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(height: 0.5, color: _divider(b)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Avatar preview ─────────────────────────────────────────
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _divider(b), width: 3),
                      boxShadow: b == Brightness.light
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.07),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [],
                    ),
                    child: ClipOval(
                      child: SvgPicture.network(
                        avatarUrl,
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                        placeholderBuilder: (_) => Container(
                          color: _surface(b),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _randomize,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shuffle_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Center(
              child: Text('Appuie sur le bouton shuffle pour un avatar aléatoire',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                      fontSize: 12, color: _inkSub(b))),
            ),

            const SizedBox(height: 32),

            // ── Style picker ───────────────────────────────────────────
            Text('Style',
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ink(b))),
            const SizedBox(height: 12),

            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _sprites.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final (style, name) = _sprites[i];
                  final selected = _sprite == style;
                  final url = _urlFor(style);

                  return GestureDetector(
                    onTap: () {
                      setState(() => _sprite = style);
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 76,
                      decoration: BoxDecoration(
                        color: selected ? _chipSel(b) : _surface(b),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? _accent : _divider(b),
                          width: selected ? 2 : 0.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: SvgPicture.network(
                              url,
                              width: 46,
                              height: 46,
                              fit: BoxFit.cover,
                              placeholderBuilder: (_) => Container(
                                width: 46,
                                height: 46,
                                color: _bg(b),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(name,
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected ? _accent : _inkSub(b),
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // ── Background color ───────────────────────────────────────
            Text('Couleur de fond',
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ink(b))),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _bgColors.map((hex) {
                final selected = _bgColor == hex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _bgColor = hex);
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Color(int.parse('FF$hex', radix: 16)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? _accent : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            size: 16, color: _accent)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 36),

            // ── Save button ────────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.pop(context, {
                'seed': _seed,
                'sprite': _sprite.name,
                'url': avatarUrl,
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: _btnBg(b),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text('Utiliser cet avatar',
                      style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _btnFg(b))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
