import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fiteva/theme/app_theme.dart';
import 'package:fiteva/screens/home/favorites_bottom_sheet.dart';

class LibrarySection extends StatefulWidget {
  const LibrarySection();

  @override
  State<LibrarySection> createState() => _LibrarySectionState();
}

class _LibrarySectionState extends State<LibrarySection> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _tabs = const [
    {'label': 'Workouts', 'icon': LucideIcons.dumbbell},
    {'label': 'Recettes', 'icon': LucideIcons.utensils},
    {'label': 'Boutique', 'icon': LucideIcons.shoppingBag},
  ];

  final List<Map<String, String>> _favoriteWorkouts = [
    {'title': 'Full Body Burn', 'subtitle': '45 min · Intermédiaire', 'image': 'assets/images/fullbody.jpg'},
    {'title': 'Cardio Intense', 'subtitle': '30 min · Avancé', 'image': 'assets/images/cardio.jpg'},
    {'title': 'Yoga Flow', 'subtitle': '20 min · Débutant', 'image': 'assets/images/yoga.jpg'},
    {'title': 'HIIT Express', 'subtitle': '25 min · Avancé', 'image': 'assets/images/hiit.jpg'},
  ];

  final List<Map<String, String>> _favoriteRecipes = [
    {'title': 'Bowl protéiné', 'subtitle': '520 kcal · 35g protéines', 'image': 'assets/images/bowl.jpg'},
    {'title': 'Smoothie vert', 'subtitle': '180 kcal · 8g protéines', 'image': 'assets/images/smoothie.jpg'},
    {'title': 'Pancakes avoine', 'subtitle': '310 kcal · 22g protéines', 'image': 'assets/images/pancakes.jpg'},
  ];

  final List<Map<String, String>> _favoriteProducts = [
    {'title': 'Whey Vanille', 'subtitle': '34,99 €', 'image': 'assets/images/whey.jpg'},
    {'title': 'Bande élastique', 'subtitle': '12,50 €', 'image': 'assets/images/band.jpg'},
    {'title': 'Shaker inox', 'subtitle': '18,00 €', 'image': 'assets/images/shaker.jpg'},
    {'title': 'BCAA Fruits', 'subtitle': '27,90 €', 'image': 'assets/images/bcaa.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.heart,
                      size: 20, color: AppTheme.textSecondaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Mes favoris',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const FavoritesBottomSheet(),
                  );
                },
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.inter(
                    color: AppTheme.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Tab bar (inchangé) ───────────────────────────────
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final selected = index == _selectedTab;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primaryColor
                        : const Color(0xFFEDE9E3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _tabs[index]['icon'] as IconData,
                        size: 14,
                        color: selected ? Colors.white : AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _tabs[index]['label'] as String,
                        style: GoogleFonts.inter(
                          color: selected ? Colors.white : AppTheme.textSecondaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // ── Content ─────────────────────────────────────────
        if (_selectedTab == 0) _buildHorizontalList(_favoriteWorkouts, type: _FavType.workout),
        if (_selectedTab == 1) _buildHorizontalList(_favoriteRecipes, type: _FavType.recipe),
        if (_selectedTab == 2) _buildHorizontalList(_favoriteProducts, type: _FavType.product),
      ],
    );
  }

  Widget _buildHorizontalList(List<Map<String, String>> items, {required _FavType type}) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.heartOff, size: 36, color: AppTheme.textSecondaryColor.withOpacity(0.4)),
              const SizedBox(height: 10),
              Text(
                'Aucun favori pour le moment',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _FavoriteCardVertical(
            title: item['title']!,
            subtitle: item['subtitle']!,
            imageAsset: item['image']!,
            type: type,
            onTap: () {},
            onUnfav: () {
              setState(() => items.removeAt(index));
            },
          );
        },
      ),
    );
  }
}

enum _FavType { workout, recipe, product }

// ── Carte verticale pour scroll horizontal ───────────────────
class _FavoriteCardVertical extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageAsset;
  final _FavType type;
  final VoidCallback onTap;
  final VoidCallback onUnfav;

  const _FavoriteCardVertical({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.type,
    required this.onTap,
    required this.onUnfav,
  });

  IconData get _typeIcon {
    switch (type) {
      case _FavType.workout: return LucideIcons.dumbbell;
      case _FavType.recipe: return LucideIcons.utensils;
      case _FavType.product: return LucideIcons.shoppingBag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4F1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + bouton unfav ────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: 140,
                    height: 110,
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFD5C9BF),
                        child: Center(
                          child: Icon(_typeIcon,
                              color: const Color(0xFF9E948C), size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onUnfav,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.heartOff,
                        size: 14,
                        color: Color(0xFFE57373),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Titre + sous-titre ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}