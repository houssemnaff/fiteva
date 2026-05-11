import 'package:fiteva/screens/nutrition/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../widgets/boutique_card.dart';
import 'boutique_detail_screen.dart';

class AllPartenairesScreen extends StatefulWidget {
  const AllPartenairesScreen({super.key});

  @override
  State<AllPartenairesScreen> createState() => _AllPartenairesScreenState();
}

class _AllPartenairesScreenState extends State<AllPartenairesScreen> {
  String _search = '';

  List get _filtered => mockItems
      .where((e) =>
          e.brand.toLowerCase().contains(_search.toLowerCase()) ||
          e.title.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Nav bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      children: [
                        Icon(
                          CupertinoIcons.chevron_left,
                          color: kAccent,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Boutique',
                          style: TextStyle(
                            color: kAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Partenaires',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const Spacer(),
                  // Espace symétrique
                  const SizedBox(width: 80),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Search bar iOS ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoSearchTextField(
                placeholder: 'Rechercher un partenaire...',
                onChanged: (v) => setState(() => _search = v),
              ),
            ),

            const SizedBox(height: 16),

            // ── Count label ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filtered.length} partenaire${_filtered.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.secondaryLabel,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Grid ──
            Expanded(
              child: _filtered.isEmpty
                  ? const _EmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) => BoutiqueCard(
                        item: _filtered[i],
                        userEtoiles: 60,
                        onTap: () => Navigator.push(
                          ctx,
                          CupertinoPageRoute(
                            builder: (_) => BoutiqueDetailScreen(
                              item: _filtered[i],
                              userEtoiles: 60,
                            ),
                          ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.search,
            size: 40,
            color: CupertinoColors.systemGrey3,
          ),
          SizedBox(height: 12),
          Text(
            'Aucun partenaire trouvé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}