import 'package:fiteva/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum FavoriteType { workout, recipe, product }

class FavoritesBottomSheet extends StatefulWidget {
  const FavoritesBottomSheet({super.key});

  @override
  State<FavoritesBottomSheet> createState() => _FavoritesBottomSheetState();
}

class _FavoritesBottomSheetState extends State<FavoritesBottomSheet> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Programmes', 'icon': LucideIcons.dumbbell, 'type': FavoriteType.workout},
    {'label': 'Recettes', 'icon': LucideIcons.utensils, 'type': FavoriteType.recipe},
    {'label': 'Boutique', 'icon': LucideIcons.shoppingBag, 'type': FavoriteType.product},
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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Mes favoris',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.neutral200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Tab bar
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

          // Content grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _getItems().length,
                itemBuilder: (context, index) {
                  final item = _getItems()[index];
                  return _FavoriteCard(
                    title: item['title']!,
                    subtitle: item['subtitle']!,
                    imageAsset: item['image']!,
                    type: _tabs[_selectedTab]['type'] as FavoriteType,
                    onRemove: () {
                      setState(() => _getItems().removeAt(index));
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getItems() {
    switch (_selectedTab) {
      case 0:
        return _favoriteWorkouts;
      case 1:
        return _favoriteRecipes;
      case 2:
        return _favoriteProducts;
      default:
        return [];
    }
  }
}

class _FavoriteCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageAsset;
  final FavoriteType type;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.type,
    required this.onRemove,
  });

  IconData get _typeIcon {
    switch (type) {
      case FavoriteType.workout:
        return LucideIcons.dumbbell;
      case FavoriteType.recipe:
        return LucideIcons.utensils;
      case FavoriteType.product:
        return LucideIcons.shoppingBag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFD5C9BF),
                      child: Center(
                        child: Icon(
                          _typeIcon,
                          color: const Color(0xFF9E948C),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemove,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
    );
  }
}
