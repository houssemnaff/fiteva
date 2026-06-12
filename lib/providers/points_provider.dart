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

  Future<void> resetPoints() async {
    await PointsService.resetPoints();
    state = 0;
  }
}

final pointsProvider =
    StateNotifierProvider<PointsNotifier, int>((ref) {
  return PointsNotifier();
});