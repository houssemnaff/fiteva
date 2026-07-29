import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

import '../../providers/onboarding_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/mascot_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/communiter_provider.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'steps/onboarding_steps.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Steps — enum définissant chaque step
// (OnboardingData est défini dans steps/onboarding_steps.dart. Tout ce qui
// suit la langue — mascotte, objectifs, équipement, cycle, etc. — vit dans
// UN SEUL step `chat`, piloté par OnboardingChatFlow : un fil de chat continu
// avec un seul scroll, plutôt que des pages séparées par sujet.)
// ─────────────────────────────────────────────────────────────────────────────
enum OStep {
  languageChoice,
  intro,
  welcome,
  chat,
}

// ─────────────────────────────────────────────────────────────────────────────
// OnboardingScreen
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageCtrl = PageController();

  // Stack de navigation — permet le back conditionnel
  final List<OStep> _history = [OStep.intro];

  OStep get _current => _history.last;

  // Données collectées
  final OnboardingData _data = OnboardingData();

  // Controllers texte
  final TextEditingController _nameCtrl  = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl  = TextEditingController();

  // Ordre réel des pages dans le PageView — utilisé pour animateToPage.
  static const List<OStep> _pageOrder = [
    OStep.intro,
    OStep.welcome,
    OStep.languageChoice,
    OStep.chat,
  ];

  // Sous-ensemble linéaire utilisé pour calculer la fraction de la progress bar.
  static const List<OStep> _progressSteps = [
    OStep.intro,
    OStep.welcome,
    OStep.languageChoice,
    OStep.chat,
  ];

  double get _progress {
    final idx = _progressSteps.indexOf(_current);
    if (idx <= 0) return 0.0;
    return idx / (_progressSteps.length - 1);
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  // Le step `chat` gère lui-même toute sa séquence interne (mascotte →
  // objectifs → ... → cycle) ; il n'appelle plus `_goNext()` mais `_finish()`
  // directement via son callback `onFinish` une fois le fil de chat terminé.

  OStep _nextStepFor(OStep current) {
    switch (current) {
      case OStep.intro:          return OStep.welcome;
      case OStep.welcome:        return OStep.languageChoice;
      case OStep.languageChoice: return OStep.chat;
      case OStep.chat:           return OStep.chat;
    }
  }

  Future<void> _goNext() async {
    _syncDataFromControllers();
    await StorageService.saveOnboardingData(_data.toMap());

    final next = _nextStepFor(_current);
    setState(() => _history.add(next));

    await Future.delayed(const Duration(milliseconds: 50));
    _pageCtrl.animateToPage(
      _pageOrder.indexOf(next),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    if (_history.length <= 1) return;
    setState(() => _history.removeLast());

    _pageCtrl.animateToPage(
      _pageOrder.indexOf(_current),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    await StorageService.saveOnboardingData(_data.toMap());

    // ── Authentification Supabase ──────────────────────────────────────────
    if (_data.email.isNotEmpty && _data.password.isNotEmpty) {
      final result = await AuthService.signUpOrSignIn(
        email:    _data.email,
        password: _data.password,
        username: _data.username,
      );
      if (!result.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.error ?? 'Erreur d\'authentification'),
          backgroundColor: const Color(0xFFB00020),
          behavior: SnackBarBehavior.floating,
        ));
        // On continue quand même en mode local si le réseau est indisponible
      }
    }

    await ref.read(onboardingProvider.notifier).completeOnboarding();
    await StorageService.clearOnboardingData();
    ref.read(userProfileProvider.notifier).reload();
    ref.read(mascotProvider.notifier).reload();
    if (!mounted) return;
    context.go('/');
  }

  /// Connexion via Google (inscription ou connexion automatique).
  /// Un nouveau compte enchaîne sur la suite de l'onboarding pour compléter
  /// le profil ; un compte existant saute directement dans l'app.
  Future<void> _googleSignIn() async {
    final result = await AuthService.signInWithGoogle();
    if (!mounted) return;
    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.error ?? 'Erreur Google'),
        backgroundColor: const Color(0xFFB00020),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (result.isNewAccount) {
      _prefillFromOAuthUser(result.user);
      await _goNext();
      return;
    }
    StorageService.setOnboardingCompleted(true);
    ref.read(userProfileProvider.notifier).reload();
    ref.invalidate(postsNotifierProvider);
    ref.invalidate(eventsNotifierProvider);
    ref.invalidate(partnersNotifierProvider);
    context.go('/');
  }

  /// Renseigne nom/email à partir du compte OAuth pour que le fil de chat
  /// suivant (et la sync Supabase à la fin) dispose des bonnes valeurs —
  /// sinon `_finish()` écraserait le profil déjà créé avec des champs vides.
  void _prefillFromOAuthUser(User? user) {
    if (user == null) return;
    final meta = user.userMetadata;
    final displayName = (meta?['full_name'] ?? meta?['name']) as String?;
    final email = user.email ?? '';
    _nameCtrl.text  = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : email.split('@').first;
    _emailCtrl.text = email;
  }

  /// Connexion via Apple — iOS/macOS uniquement.
  Future<void> _appleSignIn() async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sign in with Apple disponible uniquement sur iPhone/Mac'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final result = await AuthService.signInWithApple();
    if (!mounted) return;
    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.error ?? 'Erreur Apple'),
        backgroundColor: const Color(0xFFB00020),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (result.isNewAccount) {
      _prefillFromOAuthUser(result.user);
      await _goNext();
      return;
    }
    StorageService.setOnboardingCompleted(true);
    ref.read(userProfileProvider.notifier).reload();
    ref.invalidate(postsNotifierProvider);
    ref.invalidate(eventsNotifierProvider);
    ref.invalidate(partnersNotifierProvider);
    context.go('/');
  }

  /// Création de compte depuis l'écran Welcome (onglet "Créer mon compte").
  /// Le prénom par défaut est le préfixe de l'email ; poursuit ensuite
  /// l'onboarding normal pour collecter le reste du profil.
  Future<String?> _handleSignUp(String email, String password) async {
    _nameCtrl.text = email.split('@').first;
    final result = await AuthService.signUp(
      email: email, password: password, username: _nameCtrl.text,
    );
    if (!mounted) return null;
    if (!result.isSuccess) return result.error ?? 'Erreur d\'inscription';
    await _goNext();
    return null;
  }

  /// Connexion depuis l'écran Welcome (onglet "Se connecter") — bypass
  /// l'onboarding complet, saute directement dans l'app.
  Future<String?> _handleLogin(String email, String password) async {
    final result = await AuthService.signIn(email: email, password: password);
    if (!mounted) return null;
    if (!result.isSuccess) return result.error ?? 'Connexion échouée';

    StorageService.setOnboardingCompleted(true);
    ref.read(userProfileProvider.notifier).reload();
    ref.invalidate(postsNotifierProvider);
    ref.invalidate(eventsNotifierProvider);
    ref.invalidate(partnersNotifierProvider);
    context.go('/');
    return null;
  }

  void _syncDataFromControllers() {
    _data.username = _nameCtrl.text.trim();
    _data.email    = _emailCtrl.text.trim();
    _data.password = _passCtrl.text.trim();
  }

  // ── Init / Dispose ────────────────────────────────────────────────────────

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── PageView — swipe désactivé, contrôlé par code uniquement ──────
          PageView(
            controller:   _pageCtrl,
            physics:      const NeverScrollableScrollPhysics(),
            children:     _buildPages(),
          ),

          // ── Progress bar — cachée sur l'intro ─────────────────────────────
          if (_current != OStep.intro)
            _ProgressBar(progress: _progress, totalSteps: _progressSteps.length),
        ],
      ),
    );
  }

  // ── Pages ─────────────────────────────────────────────────────────────────

  List<Widget> _buildPages() => [
    // 0 — Intro
    StepIntro(onNext: _goNext),

    // 1 — Welcome (toggle Inscription/Connexion, Google/Apple, champs à la demande)
    StepWelcome(
      onSignUp:           _handleSignUp,
      onLogin:            _handleLogin,
      onGoogleSignIn:     _googleSignIn,
      onAppleSignIn:      _appleSignIn,
      emailController:    _emailCtrl,
      passwordController: _passCtrl,
    ),

    // 2 — Language choice
    StepLanguageChoice(
      onNext: (locale) {
        ref.read(localeProvider.notifier).setLocale(locale);
        _goNext();
      },
    ),

    // 3 — Tout l'onboarding restant (mascotte → objectifs → ... → cycle),
    // un seul fil de chat continu. `onFinish` est appelé une fois seulement,
    // à la toute fin de la conversation.
    OnboardingChatFlow(
      data: _data,
      onBack: _goBack,
      onDataChanged: () {
        setState(() {});
        StorageService.saveOnboardingData(_data.toMap());
      },
      onFinish: _finish,
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Segmented progress strip — premium step indicator
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final double progress;
  final int totalSteps;
  const _ProgressBar({required this.progress, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final currentStep = (progress * (totalSteps - 1)).round();
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
          child: Row(
            children: List.generate(totalSteps, (i) {
              final done = i <= currentStep;
              final isCurrent = i == currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: isCurrent ? 4 : 2.5,
                  margin: EdgeInsets.only(right: i < totalSteps - 1 ? 3 : 0),
                  decoration: BoxDecoration(
                    color: done
                        ? const Color(0xFF7ABB98)
                        : const Color(0xFF2A3D30),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isCurrent
                        ? [BoxShadow(
                            color: const Color(0xFF7ABB98).withValues(alpha: 0.5),
                            blurRadius: 6)]
                        : [],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
