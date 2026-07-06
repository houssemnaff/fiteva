import 'package:fiteva/screens/shop/models/boutique_item.dart';
import 'package:fiteva/services/supabase_config.dart';
import 'package:flutter/material.dart';

enum PartnerRequestCheck { ok, alreadyPending, error }

class ShopService {
  /// Vérifie si l'utilisateur a déjà une candidature "partenaire" en attente
  /// — évite les doublons de soumission (le formulaire promet un délai de
  /// traitement de 1-2 jours, une candidature en cours ne doit pas pouvoir
  /// être renvoyée entre-temps).
  static Future<PartnerRequestCheck> hasPendingPartnerRequest() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return PartnerRequestCheck.ok;
    try {
      final rows = await SupabaseConfig.table('partner_requests_shop')
          .select('id')
          .eq('user_id', uid)
          .eq('status', 'pending')
          .limit(1);
      return (rows as List).isNotEmpty
          ? PartnerRequestCheck.alreadyPending
          : PartnerRequestCheck.ok;
    } catch (e) {
      debugPrint('ShopService.hasPendingPartnerRequest error: $e');
      return PartnerRequestCheck.error;
    }
  }

  /// Candidatures "devenir partenaire" soumises par l'utilisateur courant.
  static Future<List<Map<String, dynamic>>> loadMyPartnerRequests() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];
    try {
      final rows = await SupabaseConfig.table('partner_requests_shop')
          .select('id, name, email, phone, brand, website, message, category, status, created_at')
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      return (rows as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('ShopService.loadMyPartnerRequests error: $e');
      return [];
    }
  }

  /// Retire une candidature "partenaire" — seul l'auteur peut la supprimer
  /// (filtre user_id en plus de l'id, par défense en profondeur au cas où
  /// les policies RLS ne seraient pas configurées).
  static Future<bool> deletePartnerRequest(String id) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return false;
    try {
      await SupabaseConfig.table('partner_requests_shop')
          .delete()
          .eq('id', id)
          .eq('user_id', uid);
      return true;
    } catch (e) {
      debugPrint('ShopService.deletePartnerRequest error: $e');
      return false;
    }
  }

  static Future<List<BoutiqueItem>> loadItems() async {
    try {
      final rows = await SupabaseConfig.table('shop_items')
          .select()
          .eq('is_active', true)
          .order('created_at');
      return (rows as List)
          .map((r) => _fromRow(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ShopService.loadItems error: $e');
      return [];
    }
  }

  static Future<bool> submitPartnerRequest({
    required String name,
    required String email,
    required String phone,
    required String brand,
    required String website,
    required String message,
    required String category,
  }) async {
    try {
      await SupabaseConfig.table('partner_requests_shop').insert({
        'user_id':    SupabaseConfig.userId,
        'name':       name,
        'email':      email,
        'phone':      phone,
        'brand':      brand,
        'website':    website,
        'message':    message,
        'category':   category,
        'status':     'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('ShopService.submitPartnerRequest error: $e');
      return false;
    }
  }

  static BoutiqueItem _fromRow(Map<String, dynamic> r) {
    final primaryRaw   = (r['primary_color']   as int?) ?? 0;
    final secondaryRaw = (r['secondary_color']  as int?) ?? 0;

    // Postgres stores Flutter Color ints as signed 32-bit. Mask to unsigned for Color().
    final primaryColor   = Color(primaryRaw   & 0xFFFFFFFF);
    final secondaryColor = Color(secondaryRaw & 0xFFFFFFFF);

    // '2026-07-19' → '19/07/2026'
    String validUntil = '';
    final vu = r['valid_until'] as String?;
    if (vu != null && vu.length == 10) {
      validUntil =
          '${vu.substring(8, 10)}/${vu.substring(5, 7)}/${vu.substring(0, 4)}';
    }

    return BoutiqueItem(
      id:             r['id'] as String,
      brand:          r['brand'] as String,
      title:          r['title'] as String,
      discount:       r['discount']     as String? ?? '',
      discountValue:  ((r['discount_value'] as num?) ?? 0).toInt(),
      etoiles:        (r['etoiles_cost'] as int?)  ?? 0,
      daysLeft:       (r['days_left']    as int?)  ?? 0,
      primaryColor:   primaryColor,
      secondaryColor: secondaryColor,
      imageUrl:       r['image_url']  as String? ?? '',
      promoCode:      r['promo_code'] as String? ?? '',
      validUntil:     validUntil,
      siteUrl:        r['site_url']   as String? ?? '',
      description:    r['description'] as String? ?? '',
      category:       r['category']   as String? ?? '',
    );
  }
}
