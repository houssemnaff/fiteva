import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiteva/providers/mock_data_provider.dart';
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/services/storage_service.dart';

final programRecommendationsProvider = Provider<List<dynamic>>((ref) {
  final onboardingData   = StorageService.getOnboardingData();
  final trainingLocation = onboardingData['training_location'] as String? ?? 'salle';
  final profile          = ref.watch(userProfileProvider);
  final healthStatus     = profile.healthStatus;

  // Grossesse → programmes grossesse + récupération uniquement
  if (healthStatus == 'pregnant') {
    return ref.watch(grossesseProgramsProvider).take(6).toList();
  }

  // Postpartum → récupération + maison
  if (healthStatus == 'postpartum') {
    final recup = ref.watch(recuperationProgramsProvider);
    final home  = ref.watch(homeProgramsProvider);
    return [...recup, ...home].take(6).toList();
  }

  // Cycle normal → filtre par lieu d'entraînement
  final isHome = trainingLocation.toLowerCase().contains('maison') ||
                 trainingLocation.toLowerCase().contains('home') ||
                 trainingLocation.toLowerCase().contains('house');

  if (isHome) {
    return ref.watch(homeProgramsProvider).take(6).toList();
  }
  return ref.watch(salleProgramsProvider).take(6).toList();
});
