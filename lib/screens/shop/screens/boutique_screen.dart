import 'package:fiteva/screens/nutrition/theme/app_colors.dart';
import 'package:fiteva/screens/shop/screens/all_partenaires_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../widgets/etoiles_card.dart';
import '../widgets/boutique_card.dart';
import 'boutique_detail_screen.dart';

class BoutiqueScreen extends StatelessWidget {
  const BoutiqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Affiche seulement les 4 premiers sur la home
    final preview = mockItems.take(4).toList();

    return Scaffold(
      backgroundColor:Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            // ── Header ──
            const _BoutiqueHeader(),
            const SizedBox(height: 14),

            // ── Étoiles card ──
            const EtoilesCard(etoiles: 60),
            const SizedBox(height: 28),

            // ── Section partenaires ──
            Row(
              children: [
                const Text(
                  'PARTENAIRES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.secondaryLabel,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const AllPartenairesScreen(),
                    ),
                  ),
                  child: const Text(
                    'Voir plus',
                    style: TextStyle(
                      fontSize: 14,
                      color: kAccent,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Grille 2 colonnes ──
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: preview.length,
              itemBuilder: (ctx, i) => BoutiqueCard(
                item: preview[i],
                userEtoiles: 60,
                onTap: () => Navigator.push(
                  ctx,
                  CupertinoPageRoute(
                    builder: (_) => BoutiqueDetailScreen(
                      item: preview[i],
                      userEtoiles: 60,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Bouton voir tous ──
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => const AllPartenairesScreen(),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Voir tous les partenaires',
                      style: TextStyle(
                        color: kAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: kAccent,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────

class _BoutiqueHeader extends StatelessWidget {
  const _BoutiqueHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Boutique',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Échange tes étoiles contre des récompenses.',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: kAccent,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.person_fill,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }
}