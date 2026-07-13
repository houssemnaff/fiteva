import 'package:fiteva/providers/diamonds_provider.dart';
import 'package:fiteva/screens/shop/models/boutique_item.dart';
import 'package:fiteva/services/diamonds_service.dart';
import 'package:fiteva/services/shop_service.dart';
import 'package:fiteva/services/supabase_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATE — la boutique ne débite QUE des diamants (bonus de level-up).
// ─────────────────────────────────────────────────────────────────────────────
class ShopState {
  final int         diamonds;
  final Set<String> redeemed;

  const ShopState({required this.diamonds, required this.redeemed});

  ShopState copyWith({int? diamonds, Set<String>? redeemed}) => ShopState(
    diamonds: diamonds ?? this.diamonds,
    redeemed: redeemed ?? this.redeemed,
  );

  bool isRedeemed(String id) => redeemed.contains(id);
  bool canAfford(int cost)   => diamonds >= cost;
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────
class ShopNotifier extends Notifier<ShopState> {
  @override
  ShopState build() {
    _load();
    return const ShopState(diamonds: 0, redeemed: {});
  }

  Future<void> _load() async {
    final diamonds = await DiamondsService.getDiamonds();
    final redeemed = await _loadRedeemed();
    state = ShopState(diamonds: diamonds, redeemed: redeemed);
  }

  Future<Set<String>> _loadRedeemed() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('shop_redemptions')
          .select('shop_item_id')
          .eq('user_id', uid);
      return {for (final r in rows as List) r['shop_item_id'] as String};
    } catch (_) {
      return {};
    }
  }

  Future<void> refresh() => _load();

  /// Échange un article : déduit les diamants et enregistre dans shop_redemptions.
  Future<bool> redeem(BoutiqueItem item) async {
    if (state.isRedeemed(item.id)) return false;
    if (!state.canAfford(item.diamonds)) return false;

    final uid = SupabaseConfig.userId;

    // Enregistre le rachat dans Supabase
    if (uid != null) {
      try {
        await SupabaseConfig.table('shop_redemptions').insert({
          'user_id':      uid,
          'shop_item_id': item.id,
          'points_spent': item.diamonds,
          'promo_code':   item.promoCode,
          'redeemed_at':  DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }

    final updated = await DiamondsService.spendDiamonds(
      item.diamonds,
      reason: 'shop_${item.id}',
    );
    final newIds = {...state.redeemed, item.id};
    state = state.copyWith(diamonds: updated, redeemed: newIds);
    ref.read(diamondsProvider.notifier).loadDiamonds();
    return true;
  }
}

final shopProvider = NotifierProvider<ShopNotifier, ShopState>(ShopNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// WISHLIST — stockée dans shop_wishlist (Supabase)
// ─────────────────────────────────────────────────────────────────────────────
class ShopWishlistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _loadWishlist();
    return {};
  }

  Future<void> _loadWishlist() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      final rows = await SupabaseConfig.table('shop_wishlist')
          .select('shop_item_id')
          .eq('user_id', uid);
      state = {for (final r in rows as List) r['shop_item_id'] as String};
    } catch (_) {}
  }

  Future<void> toggleWishlist(String id) async {
    if (state.contains(id)) {
      await removeFromWishlist(id);
    } else {
      await addToWishlist(id);
    }
  }

  Future<void> addToWishlist(String id) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      await SupabaseConfig.table('shop_wishlist')
          .upsert({'user_id': uid, 'shop_item_id': id});
      state = {...state, id};
    } catch (_) {}
  }

  Future<void> removeFromWishlist(String id) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      await SupabaseConfig.table('shop_wishlist')
          .delete()
          .eq('user_id', uid)
          .eq('shop_item_id', id);
      state = state.difference({id});
    } catch (_) {}
  }

  Future<void> setWishlist(Set<String> wishlist) async {
    for (final id in wishlist) {
      await addToWishlist(id);
    }
  }
}

final shopWishlistProvider = NotifierProvider<ShopWishlistNotifier, Set<String>>(
  ShopWishlistNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// REDEMPTION HISTORY — "contre quoi j'ai échangé mes diamants" (shop_redemptions)
// ─────────────────────────────────────────────────────────────────────────────
class RedemptionEntry {
  final String shopItemId;
  final int pointsSpent;
  final String promoCode;
  final DateTime redeemedAt;

  const RedemptionEntry({
    required this.shopItemId,
    required this.pointsSpent,
    required this.promoCode,
    required this.redeemedAt,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MY PARTNER REQUESTS — candidatures "devenir partenaire" de l'utilisateur
// ─────────────────────────────────────────────────────────────────────────────
class PartnerRequestEntry {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String brand;
  final String website;
  final String message;
  final String category;
  final String status; // pending | approved | rejected
  final DateTime createdAt;

  const PartnerRequestEntry({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.brand,
    required this.website,
    required this.message,
    required this.category,
    required this.status,
    required this.createdAt,
  });
}

final myPartnerRequestsProvider = FutureProvider<List<PartnerRequestEntry>>((ref) async {
  final rows = await ShopService.loadMyPartnerRequests();
  return rows.map((r) => PartnerRequestEntry(
    id:        r['id']?.toString() ?? '',
    name:      r['name'] as String? ?? '',
    email:     r['email'] as String? ?? '',
    phone:     r['phone'] as String? ?? '',
    brand:     r['brand'] as String? ?? '',
    website:   r['website'] as String? ?? '',
    message:   r['message'] as String? ?? '',
    category:  r['category'] as String? ?? '',
    status:    r['status'] as String? ?? 'pending',
    createdAt: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
  )).toList();
});

final shopRedemptionHistoryProvider = FutureProvider<List<RedemptionEntry>>((ref) async {
  final uid = SupabaseConfig.userId;
  if (uid == null) return [];
  try {
    final rows = await SupabaseConfig.table('shop_redemptions')
        .select('shop_item_id, points_spent, promo_code, redeemed_at')
        .eq('user_id', uid)
        .order('redeemed_at', ascending: false);
    return (rows as List).map((r) => RedemptionEntry(
      shopItemId:  r['shop_item_id'] as String,
      pointsSpent: (r['points_spent'] as num?)?.toInt() ?? 0,
      promoCode:   r['promo_code'] as String? ?? '',
      redeemedAt:  DateTime.tryParse(r['redeemed_at'] as String? ?? '') ?? DateTime.now(),
    )).toList();
  } catch (_) {
    return [];
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// CATALOGUE — charge shop_items depuis Supabase
// ─────────────────────────────────────────────────────────────────────────────
final shopItemsProvider = FutureProvider<List<BoutiqueItem>>(
  (_) => ShopService.loadItems(),
);
