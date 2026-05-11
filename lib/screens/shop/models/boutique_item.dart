import 'package:flutter/material.dart';

class BoutiqueItem {
  final String id;
  final String brand;
  final String title;
  final String discount;
  final int discountValue;
  final int etoiles;
  final int daysLeft;
  final Color primaryColor;
  final Color secondaryColor;
  final String imageUrl;
  final String promoCode;
  final String validUntil;
  final String siteUrl;
  final String description;

  const BoutiqueItem({
    required this.id,
    required this.brand,
    required this.title,
    required this.discount,
    required this.discountValue,
    required this.etoiles,
    required this.daysLeft,
    required this.primaryColor,
    required this.secondaryColor,
    required this.imageUrl,
    required this.promoCode,
    required this.validUntil,
    required this.siteUrl,
    required this.description,
  });
}