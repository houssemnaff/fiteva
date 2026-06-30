import 'package:fiteva/providers/points_provider.dart';
import 'package:fiteva/screens/shop/models/boutique_item.dart';
import 'package:fiteva/services/points_service.dart';
import 'package:fiteva/services/shop_service.dart';
import 'package:fiteva/services/supabase_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────
class ShopState {
  final int         points;
  final Set<String> redeemed;

  const ShopState({required this.points, required this.redeemed});

  ShopState copyWith({int? points, Set<String>? redeemed}) => ShopState(
    points:   points   ?? this.points,
    redeemed: redeemed ?? this.redeemed,
  );

  bool isRedeemed(String id) => redeemed.contains(id);
  bool canAfford(int cost)   => points >= cost;
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────
class ShopNotifier extends Notifier<ShopState> {
  @override
  ShopState build() {
    _load();
    return const ShopState(points: 0, redeemed: {});
  }

  Future<void> _load() async {
    final pts      = await PointsService.getPoints();
    final redeemed = await _loadRedeemed();
    state = ShopState(points: pts, redeemed: redeemed);
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

  Future<void> addPoints(int amount) async {
    final updated = await PointsService.addPoints(amount, reason: 'reward');
    state = state.copyWith(points: updated);
    ref.read(pointsProvider.notifier).loadPoints();
  }

  /// Échange un article : déduit les points et enregistre dans shop_redemptions.
  Future<bool> redeem(BoutiqueItem item) async {
    if (state.isRedeemed(item.id)) return false;
    if (!state.canAfford(item.etoiles)) return false;

    final uid = SupabaseConfig.userId;

    // Enregistre le rachat dans Supabase
    if (uid != null) {
      try {
        await SupabaseConfig.table('shop_redemptions').insert({
          'user_id':      uid,
          'shop_item_id': item.id,
          'points_spent': item.etoiles,
          'promo_code':   item.promoCode,
          'redeemed_at':  DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }

    final updated = await PointsService.spendPoints(
      item.etoiles,
      reason: 'shop_${item.id}',
    );
    final newIds = {...state.redeemed, item.id};
    state = state.copyWith(points: updated, redeemed: newIds);
    ref.read(pointsProvider.notifier).loadPoints();
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
// CATALOGUE — charge shop_items depuis Supabase
// ─────────────────────────────────────────────────────────────────────────────
final shopItemsProvider = FutureProvider<List<BoutiqueItem>>(
  (_) => ShopService.loadItems(),
);
