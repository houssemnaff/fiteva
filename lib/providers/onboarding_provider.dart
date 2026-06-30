import 'package:flutter_riverpod/legacy.dart';
import '../services/storage_service.dart';
import '../services/supabase_config.dart';

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _loadState();
  }

  void _loadState() {
    state = StorageService.isOnboardingCompleted();
  }

  Future<void> completeOnboarding() async {
    state = true;
    StorageService.setOnboardingCompleted(true);
    // Sync profil + biométrie vers Supabase
    await StorageService.syncOnboardingToSupabase();
    // Marque l'onboarding comme terminé dans Supabase
    final uid = SupabaseConfig.userId;
    if (uid != null) {
      SupabaseConfig.table('user_profiles').upsert({
        'id':              uid,
        'onboarding_done': true,
        'updated_at':      DateTime.now().toIso8601String(),
      }).catchError((_) {});
    }
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
