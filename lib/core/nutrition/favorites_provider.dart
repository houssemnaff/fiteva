import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggle(String name) {
    if (state.contains(name)) {
      state = {...state}..remove(name);
    } else {
      state = {...state, name};
    }
  }

  bool isFav(String name) => state.contains(name);
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
