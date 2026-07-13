import 'package:fiteva/services/diamonds_service.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Solde de diamants (monnaie boutique). Alimenté UNIQUEMENT par les bonus de
/// passage de niveau (voir PointsNotifier._addPoints + trigger SQL) — aucune
/// action quotidienne ne crédite de diamants directement.
class DiamondsNotifier extends StateNotifier<int> {
  DiamondsNotifier() : super(0) {
    loadDiamonds();
  }

  Future<void> loadDiamonds() async {
    state = await DiamondsService.getDiamonds();
  }

  Future<void> resetDiamonds() async {
    await DiamondsService.resetDiamonds();
    state = 0;
  }
}

final diamondsProvider =
    StateNotifierProvider<DiamondsNotifier, int>((ref) {
  return DiamondsNotifier();
});
