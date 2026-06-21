import 'package:fiteva/providers/points_provider.dart';
import 'package:fiteva/screens/shop/models/boutique_item.dart';
import 'package:fiteva/services/points_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────
class ShopState {
  final int        points;
  final Set<String> redeemed; // item IDs already exchanged

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
  static const _redeemedKey = 'shop_redeemed_ids';

  @override
  ShopState build() {
    _load();
    return const ShopState(points: 0, redeemed: {});
  }

  Future<void> _load() async {
    final prefs   = await SharedPreferences.getInstance();
    final pts     = prefs.getInt(PointsService.pointsKey) ?? 0;
    final ids     = prefs.getStringList(_redeemedKey) ?? [];
    state = ShopState(points: pts, redeemed: Set.from(ids));
  }

  /// Reload points from storage (call after PointsService.addPoints externally).
  Future<void> refresh() => _load();

  /// Add points (e.g. after completing a workout/video).
  Future<void> addPoints(int amount) async {
    final updated = await PointsService.addPoints(amount);
    state = state.copyWith(points: updated);
    ref.read(pointsProvider.notifier).loadPoints();
  }

  /// Redeem an offer — deducts points and marks item as redeemed.
  /// Returns false if not enough points or already redeemed.
  Future<bool> redeem(BoutiqueItem item) async {
    if (state.isRedeemed(item.id)) return false;
    if (!state.canAfford(item.etoiles)) return false;

    final updated  = await PointsService.spendPoints(item.etoiles);
    final newIds   = {...state.redeemed, item.id};
    final prefs    = await SharedPreferences.getInstance();
    await prefs.setStringList(_redeemedKey, newIds.toList());

    state = state.copyWith(points: updated, redeemed: newIds);
    ref.read(pointsProvider.notifier).loadPoints();
    return true;
  }
}

final shopProvider = NotifierProvider<ShopNotifier, ShopState>(ShopNotifier.new);

// ─────────────────────────────────────────────────────────────────────────────
// WISHLIST NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────
class ShopWishlistNotifier extends Notifier<Set<String>> {
  static const _wishlistKey = 'shop_wishlist';

  @override
  Set<String> build() {
    _loadWishlist();
    return {};
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_wishlistKey) ?? [];
    state = Set.from(ids);
  }

  Future<void> toggleWishlist(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final newSet = Set<String>.from(state);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    await prefs.setStringList(_wishlistKey, newSet.toList());
    state = newSet;
  }

  Future<void> addToWishlist(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final newSet = Set<String>.from(state);
    newSet.add(id);
    await prefs.setStringList(_wishlistKey, newSet.toList());
    state = newSet;
  }

  Future<void> removeFromWishlist(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final newSet = Set<String>.from(state);
    newSet.remove(id);
    await prefs.setStringList(_wishlistKey, newSet.toList());
    state = newSet;
  }

  Future<void> setWishlist(Set<String> wishlist) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_wishlistKey, wishlist.toList());
    state = Set<String>.from(wishlist);
  }
}

final shopWishlistProvider = NotifierProvider<ShopWishlistNotifier, Set<String>>(
  ShopWishlistNotifier.new,
);
