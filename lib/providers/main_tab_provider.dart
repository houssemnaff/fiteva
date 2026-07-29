import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index de l'onglet actif dans [MainLayout] (0-3 = onglets principaux via
/// PageView, 4-6 = écrans secondaires ouverts via le bouton "+"). Permet à
/// des écrans hors de MainLayout (ex: les cartes stat de HomeScreen) de
/// changer d'onglet sans empiler un nouvel écran par-dessus le Scaffold —
/// ce qui masquerait la bottom nav bar.
final mainTabIndexProvider = NotifierProvider<MainTabIndexNotifier, int>(
  MainTabIndexNotifier.new,
);

class MainTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}
