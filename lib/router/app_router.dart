import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent, AuthState;
import '../screens/main_layout.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/steps/restpaswword_screens.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/avatar_customization_screen.dart';
import '../screens/profile/trends_screen.dart';
import '../services/storage_service.dart';
import '../services/supabase_config.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Transforme le flux d'auth Supabase en Listenable pour GoRouter — sans ça,
/// `redirect` ne serait ré-évalué qu'au prochain changement de route, pas
/// immédiatement quand la session expire/se déconnecte pendant que
/// l'utilisatrice est déjà profondément dans l'app. Garde aussi le dernier
/// event pour détecter le lien de réinitialisation de mot de passe
/// (AuthChangeEvent.passwordRecovery), qui doit rediriger vers un écran
/// dédié plutôt que suivre les règles normales de session.
class _AuthRefreshStream extends ChangeNotifier {
  _AuthRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _sub = stream.listen((state) {
      lastEvent = state.event;
      notifyListeners();
    });
  }
  late final StreamSubscription<AuthState> _sub;
  AuthChangeEvent? lastEvent;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authRefreshStream =
    _AuthRefreshStream(SupabaseConfig.client.auth.onAuthStateChange);

/// À appeler une fois le mot de passe mis à jour, pour ne pas rester coincé
/// sur /reset-password (le redirect resterait sinon actif indéfiniment,
/// aucun nouvel évènement auth ne survenant ensuite).
void clearPasswordRecoveryRedirect() {
  _authRefreshStream.lastEvent = null;
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation:
      StorageService.isOnboardingCompleted() ? '/' : '/onboarding',
  refreshListenable: _authRefreshStream,
  // Garde-fou d'auth — avant, seul un flag LOCAL (isOnboardingCompleted)
  // décidait de l'accès à l'app, jamais la vraie session Supabase. Une
  // session absente/expirée (token non rafraîchi, réinstall gardant le
  // SharedPreferences local, déconnexion serveur…) laissait l'utilisatrice
  // naviguer dans tout l'écran workout avec un user_id null — chaque
  // écriture Supabase (points, progression vidéo…) était alors
  // silencieusement ignorée sans qu'aucun symptôme visible n'apparaisse.
  redirect: (context, state) {
    if (_authRefreshStream.lastEvent == AuthChangeEvent.passwordRecovery) {
      return state.matchedLocation == '/reset-password' ? null : '/reset-password';
    }
    final hasSession = SupabaseConfig.currentUser != null;
    final onOnboarding = state.matchedLocation == '/onboarding';
    if (!hasSession && !onOnboarding) return '/onboarding';
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const MainLayout(),
        transitionDuration: const Duration(milliseconds: 750),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // L'accueil zoom depuis 0.08 (minuscule au centre) → 1.0
          final scaleIn = Tween<double>(begin: 0.08, end: 1.0).animate(
              CurvedAnimation(parent: animation,
                  curve: const Interval(0.0, 0.85, curve: Curves.easeOutExpo)));
          // Fade in de l'accueil : démarre à 20% de l'anim
          final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation,
                  curve: const Interval(0.10, 0.60, curve: Curves.easeOut)));
          // L'onboarding s'efface pendant que l'accueil arrive
          final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(parent: secondaryAnimation,
                  curve: const Interval(0.0, 0.50, curve: Curves.easeIn)));

          return Stack(children: [
            // Onboarding qui disparaît
            FadeTransition(opacity: fadeOut, child: Container(color: Colors.white)),
            // Accueil qui zoom depuis le centre
            FadeTransition(
              opacity: fadeIn,
              child: ScaleTransition(
                scale: scaleIn,
                alignment: Alignment.center,
                child: child,
              ),
            ),
          ]);
        },
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-avatar',
      builder: (context, state) => const AvatarCustomizationScreen(userName: 'Sarra'),
    ),
    GoRoute(
      path: '/trends',
      builder: (context, state) => const TrendsScreen(),
    ),
  ],
);