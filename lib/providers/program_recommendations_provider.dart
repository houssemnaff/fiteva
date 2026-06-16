import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fiteva/providers/mock_data_provider.dart';
import 'package:fiteva/services/storage_service.dart';

final programRecommendationsProvider = Provider<List<dynamic>>((ref) {
  // Get onboarding data
  final onboardingData = StorageService.getOnboardingData();

  debugPrint('=== ONBOARDING DATA ===');
  debugPrint(onboardingData.toString());

  final trainingLocation = onboardingData['training_location'] as String? ?? 'salle';
  final fitnessLevel = onboardingData['fitness_level'] as String?;
  final equipment = List<String>.from(onboardingData['equipment'] ?? []);

  debugPrint('trainingLocation: $trainingLocation');
  debugPrint('fitnessLevel: $fitnessLevel');
  debugPrint('equipment: $equipment');

  // Get programs based on training location
  List<dynamic> programs = [];

  // Check for 'maison', 'gym', 'salle', or any home-related location
  final isHome = trainingLocation.toLowerCase().contains('maison') ||
                 trainingLocation.toLowerCase().contains('home') ||
                 trainingLocation.toLowerCase().contains('house');

  if (isHome) {
    final homePrograms = ref.watch(homeProgramsProvider);
    debugPrint('Home programs count: ${homePrograms.length}');
    programs.addAll(homePrograms);
  } else {
    final sallePrograms = ref.watch(salleProgramsProvider);
    debugPrint('Salle programs count: ${sallePrograms.length}');
    programs.addAll(sallePrograms);
  }

  // Limit to top 6 recommendations
  final recommendations = programs.take(6).toList();

  debugPrint('=== RECOMMENDATIONS ===');
  debugPrint('Recommendations length: ${recommendations.length}');
  for (final program in recommendations) {
    debugPrint('Program: ${program.name}');
  }

  return recommendations;
});
