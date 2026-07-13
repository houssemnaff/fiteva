import 'package:fiteva/screens/nutrition/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/boutique_item.dart';

import 'timer_badge.dart';

class BoutiqueCard extends StatelessWidget {
  final BoutiqueItem item;
  final int userDiamonds;
  final VoidCallback onTap;

  const BoutiqueCard({
    super.key,
    required this.item,
    required this.userDiamonds,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canAfford = userDiamonds >= item.diamonds;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: item.primaryColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [item.primaryColor, item.secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                          colorScheme.scrim.withOpacity(0.65),
                        ],
                        stops: const [0.35, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: TimerBadge(days: item.daysLeft),
                  ),
                  if (!canAfford)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.scrim.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.lock_outline,
                            color: colorScheme.onPrimary.withOpacity(0.85), size: 13),
                      ),
                    ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.brand,
                          style: TextStyle(
                            color: colorScheme.onPrimary.withOpacity(0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          item.discount,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'sur le site',
                          style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.85), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: colorScheme.primary, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            '${item.diamonds}',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: canAfford
                              ? colorScheme.primary.withOpacity(0.12)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          canAfford ? 'Échanger' : 'Insuffisant',
                          style: TextStyle(
                            color: canAfford ? colorScheme.primary : colorScheme.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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