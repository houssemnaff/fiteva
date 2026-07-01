import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/step_service.dart';

/// Steps d'une date précise depuis Supabase (pour l'historique / profil)
final stepHistoryProvider = FutureProvider.family<int, DateTime>((ref, date) async {
  return StepService.fetchStepsForDate(date);
});
