import 'package:fiteva/screens/shop/widgets/promo_modal.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/boutique_item.dart';

import '../widgets/info_row.dart';


class BoutiqueDetailScreen extends StatelessWidget {
  final BoutiqueItem item;
  final int userEtoiles;

  const BoutiqueDetailScreen({
    super.key,
    required this.item,
    required this.userEtoiles,
  });

  bool get _canAfford => userEtoiles >= item.etoiles;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandChip(context),
                        const SizedBox(height: 12),
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInfoCard(context),
                        const SizedBox(height: 16),
                        _buildHowToUseCard(context),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildCTABar(context),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: item.primaryColor,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.scrim.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new,
                color: colorScheme.onPrimary, size: 18),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: colorScheme.scrim.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
              child: Icon(Icons.share_outlined,
                  color: colorScheme.onPrimary, size: 18),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [item.primaryColor, item.secondaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(),
              errorWidget: (_, __, ___) => Container(),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colorScheme.scrim.withOpacity(0.7),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.brand,
                    style: TextStyle(
                      color: colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    item.discount,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -3,
                    ),
                  ),
                  Text(
                    'sur le site',
                    style: TextStyle(
                      color: colorScheme.onPrimary.withOpacity(0.85),
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: item.primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        item.brand,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InfoRow(
            icon: Icons.water_drop,
            iconColor: colorScheme.primary,
            label: 'Coût',
            value: '${item.etoiles} etoiles',
            valueColor: colorScheme.primary,
          ),
          const Divider(height: 24, thickness: 0.5),
          InfoRow(
            icon: Icons.calendar_today_outlined,
            iconColor: colorScheme.onSurfaceVariant,
            label: 'Valable jusqu\'au',
            value: item.validUntil,
          ),
          const Divider(height: 24, thickness: 0.5),
          InfoRow(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: _canAfford ? colorScheme.primary : colorScheme.tertiary,
            label: 'Mes etoiles',
            value: '$userEtoiles disponibles',
            valueColor: _canAfford ? colorScheme.primary : colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildHowToUseCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comment ça marche ?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const StepItem(number: '1', text: 'Clique sur "Échanger mes etoiles"'),
          const SizedBox(height: 10),
          const StepItem(number: '2', text: 'Reçois ton code promo + QR code'),
          const SizedBox(height: 10),
          const StepItem(number: '3', text: 'Télécharge ta carte en PDF'),
          const SizedBox(height: 10),
          const StepItem(
              number: '4', text: 'Utilise-le lors de ta commande sur le site'),
        ],
      ),
    );
  }

  Widget _buildCTABar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_canAfford)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 14, color: colorScheme.tertiary),
                  const SizedBox(width: 6),
                  Text(
                    'Il te manque ${item.etoiles - userEtoiles} etoiles',
                    style: TextStyle(
                        color: colorScheme.tertiary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _canAfford ? () => _showPromoModal(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _canAfford ? Icons.water_drop : Icons.lock_outline,
                    color: _canAfford ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _canAfford
                        ? 'Échanger ${item.etoiles} etoiles'
                        : 'etoiles insuffisantes',
                    style: TextStyle(
                      color: _canAfford ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPromoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PromoModal(item: item),
    );
  }
}