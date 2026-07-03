import 'package:fiteva/services/points_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class PointsNotifier extends StateNotifier<int> {
  PointsNotifier() : super(0) {
    loadPoints();
  }

  Future<void> loadPoints() async {
    state = await PointsService.getPoints();
  }

  Future<void> addPoints(int amount) async {
    state = await PointsService.addPoints(amount);
  }

  /// Récompense l'objectif calorique du jour (une seule fois par jour).
  /// Retourne true si des points viennent d'être crédités.
  Future<bool> awardCalorieGoalIfNeeded() async {
    final updated = await PointsService.awardCalorieGoalReached();
    if (updated == null) return false;
    state = updated;
    return true;
  }

  Future<void> resetPoints() async {
    await PointsService.resetPoints();
    state = 0;
  }
}

final pointsProvider =
    StateNotifierProvider<PointsNotifier, int>((ref) {
  return PointsNotifier();
});