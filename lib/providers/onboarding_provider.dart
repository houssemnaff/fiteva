import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/storage_service.dart';

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _loadState();
  }

  void _loadState() {
    state = StorageService.isOnboardingCompleted();
  }

  void completeOnboarding() {
    state = true;
    StorageService.setOnboardingCompleted(true);
  }

  void reset() {
    state = false;
    StorageService.setOnboardingCompleted(false);
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((
  ref,
) {
  return OnboardingNotifier();
});
