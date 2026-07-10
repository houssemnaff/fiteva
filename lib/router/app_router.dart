import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/main_layout.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/avatar_customization_screen.dart';
import '../screens/profile/trends_screen.dart';
import '../services/storage_service.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation:
      StorageService.isOnboardingCompleted() ? '/' : '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
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