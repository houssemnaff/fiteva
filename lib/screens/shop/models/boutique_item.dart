import 'package:flutter/material.dart';

class BoutiqueItem {
  final String id;
  final String brand;
  final String title;
  final String discount;
  final int discountValue;
  /// Coût en diamants (colonne shop_items.diamonds_cost).
  final int diamonds;
  final int daysLeft;
  final Color primaryColor;
  final Color secondaryColor;
  final String imageUrl;
  final String promoCode;
  final String validUntil;
  final String siteUrl;
  final String description;
  final String category;

  const BoutiqueItem({
    required this.id,
    required this.brand,
    required this.title,
    required this.discount,
    required this.discountValue,
    required this.diamonds,
    required this.daysLeft,
    required this.primaryColor,
    required this.secondaryColor,
    required this.imageUrl,
    required this.promoCode,
    required this.validUntil,
    required this.siteUrl,
    required this.description,
      required this.category, // 👈 ADD THIS

  });
}