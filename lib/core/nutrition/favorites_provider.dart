import 'package:fiteva/services/supabase_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      final rows = await SupabaseConfig.table('user_recipe_favorites')
          .select('recipe_id')
          .eq('user_id', uid);
      state = {for (final r in rows as List) r['recipe_id'] as String};
    } catch (e) {
      debugPrint('recipe favorites load error: $e');
    }
  }

  Future<void> toggle(String id) async {
    final uid = SupabaseConfig.userId;
    final newSet = Set<String>.from(state);
    if (newSet.contains(id)) {
      newSet.remove(id);
      state = newSet;
      if (uid != null) {
        try {
          await SupabaseConfig.table('user_recipe_favorites')
              .delete()
              .eq('user_id', uid)
              .eq('recipe_id', id);
        } catch (e) {
          debugPrint('recipe favorites delete error: $e');
        }
      }
    } else {
      newSet.add(id);
      state = newSet;
      if (uid != null) {
        try {
          await SupabaseConfig.table('user_recipe_favorites')
              .upsert({'user_id': uid, 'recipe_id': id},
                  onConflict: 'user_id,recipe_id');
        } catch (e) {
          debugPrint('recipe favorites insert error: $e');
        }
      }
    }
  }

  bool isFav(String id) => state.contains(id);

  Future<void> reload() => _load();
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
