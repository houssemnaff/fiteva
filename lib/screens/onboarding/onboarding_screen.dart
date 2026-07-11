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
// Onboarding Data — état centralisé transmis entre les steps
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingData {
  String username       = '';
  String email          = '';
  String password       = '';
  List<String> goals    = [];
  String? fitnessLevel;
  List<String> equipment = [];
  String? frequency;
  int    heightCm       = 165;
  double weightKg       = 60.0;
  int    age            = 25;
  // Santé féminine
  String? healthStatus;     // 'cycle' | 'pregnant' | 'postpartum'
  int?    pregnancyWeekSA;
  String? ppRecovery;       // 'recent' | 'slowly' | 'active'
  String? ppDuration;       // '0-2' | '2-6' | '6-12' | '3-6m' | '6m+'
  String? cycleDuration;
  DateTime? lastPeriod = DateTime.now().subtract(const Duration(days: 14));
  String avatarSeed  = 'fiteva';
  String avatarStyle = 'lorelei';
  String avatarBg    = 'b6e3f4';
  String mascotType  = 'blob';
  String? trainingLocation;

  Map<String, dynamic> toMap() => {
    'username':           username,
    'email':              email,
    'goals':              goals,
    'fitness_level':      fitnessLevel,
    'equipment':          equipment,
    'frequency':          frequency,
    'training_location':  trainingLocation,
    'height_cm':          heightCm,
    'weight_kg':          weightKg,
    'age':                age,
    'health_status':      healthStatus,
    'pregnancy_week':     pregnancyWeekSA,
    'pp_recovery':        ppRecovery,
    'pp_duration':        ppDuration,
    'cycle_duration':     cycleDuration,
    'last_period':        lastPeriod?.toIso8601String(),
    'mascot_type':        mascotType,
    'mascot_mood':        'happy',
    'avatar_seed':        avatarSeed,
    'avatar_style':       avatarStyle,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Steps — enum définissant chaque step
// ─────────────────────────────────────────────────────────────────────────────
enum OStep {
  languageChoice,
  intro,
  welcome,
  goals,
  fitnessLevel,
  equipment,
  trainingLocation,
  frequency,
  healthProfile,
  cycleAndPregnancy,
  avatar,
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
    OStep.goals,
    OStep.fitnessLevel,
    OStep.equipment,
    OStep.trainingLocation,
    OStep.frequency,
    OStep.healthProfile,
    OStep.cycleAndPregnancy,
    OStep.avatar,
  ];

  // Sous-ensemble linéaire utilisé pour calculer la fraction de la progress bar.
  static const List<OStep> _progressSteps = [
    OStep.intro,
    OStep.welcome,
    OStep.languageChoice,
    OStep.goals,
    OStep.fitnessLevel,
    OStep.equipment,
    OStep.trainingLocation,
    OStep.frequency,
    OStep.healthProfile,
    OStep.cycleAndPregnancy,
    OStep.avatar,
  ];

  double get _progress {
    final idx = _progressSteps.indexOf(_current);
    if (idx <= 0) return 0.0;
    return idx / (_progressSteps.length - 1);
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  OStep _nextStepFor(OStep current) {
    switch (current) {
      case OStep.intro:             return OStep.welcome;
      case OStep.welcome:           return OStep.languageChoice;
      case OStep.languageChoice:    return OStep.goals;
      case OStep.goals:             return OStep.fitnessLevel;
      case OStep.fitnessLevel:      return OStep.equipment;
      case OStep.equipment:         return OStep.trainingLocation;
      case OStep.trainingLocation:  return OStep.frequency;
      case OStep.frequency:         return OStep.healthProfile;
      case OStep.healthProfile:     return OStep.cycleAndPregnancy;
      case OStep.cycleAndPregnancy: return OStep.avatar;
      case OStep.avatar:            return OStep.avatar; // finish
    }
  }

  Future<void> _goNext() async {
    _syncDataFromControllers();
    await StorageService.saveOnboardingData(_data.toMap());

    if (_current == OStep.avatar) {
      await _finish();
      return;
    }

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

  /// Renseigne nom/email à partir du compte OAuth pour que les steps suivants
  /// (avatar, sync Supabase à la fin) disposent des bonnes valeurs — sinon
  /// `_finish()` écraserait le profil déjà créé avec des champs vides.
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
            _ProgressBar(progress: _progress),
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

    // 3 — Goals
    StepGoals(
      selectedGoals:  _data.goals,
      onBack:         _goBack,
      onToggleGoal:   (g) => setState(() =>
        _data.goals.contains(g) ? _data.goals.remove(g) : _data.goals.add(g)),
      onNext:         _goNext,
    ),

    // 3 — Fitness level
    StepFitnessLevel(
      selectedLevel: _data.fitnessLevel,
      onBack:        _goBack,
      onChanged:     (v) => setState(() => _data.fitnessLevel = v),
      onNext:        _goNext,
    ),

    // 4 — Equipment
    StepEquipment(
      selectedEquipment:  _data.equipment,
      onBack:             _goBack,
      onToggleEquipment:  (item) => setState(() =>
        _data.equipment.contains(item)
            ? _data.equipment.remove(item)
            : _data.equipment.add(item)),
      onNext:             _goNext,
    ),

    // 5 — Training location
    StepTrainingLocation(
      selectedLocation: _data.trainingLocation,
      onBack:           _goBack,
      onChanged:        (v) => setState(() => _data.trainingLocation = v),
      onNext:           _goNext,
    ),

    // 6 — Frequency
    StepFrequency(
      selectedFrequency: _data.frequency,
      onBack:            _goBack,
      onChanged:         (v) => setState(() => _data.frequency = v),
      onNext:            _goNext,
    ),

    // 7 — Health profile (height / weight / age)
    StepHealthProfile(
      onNext:            _goNext,
      onBack:            _goBack,
      initialHeightCm:   _data.heightCm,
      initialWeightKg:   _data.weightKg,
      initialAge:        _data.age,
      onHeightChanged:   (v) => setState(() => _data.heightCm = v),
      onWeightChanged:   (v) => setState(() => _data.weightKg = v),
      onAgeChanged:      (v) => setState(() => _data.age = v),
    ),

    // 8 — Cycle & pregnancy
    StepCycleAndPregnancy(
      onNext:  _goNext,
      onBack:  _goBack,
      onHealthStatusChanged:  (v) => setState(() => _data.healthStatus  = v),
      onLastPeriodChanged:    (v) => setState(() => _data.lastPeriod    = v),
      onCycleDurationChanged: (v) => setState(() => _data.cycleDuration = v),
      onPregnancyWeekChanged: (v) => setState(() => _data.pregnancyWeekSA = v),
      onPpRecoveryChanged:    (v) => setState(() => _data.ppRecovery    = v),
      onPpDurationChanged:    (v) => setState(() => _data.ppDuration    = v),
    ),

    // 9 — Mascotte
    StepAvatar(
      userName: _data.username.isNotEmpty ? _data.username : 'fiteva',
      onBack:   _goBack,
      onNext:   _goNext,
      onAvatarChanged: (seed, style, bg) => setState(() {
        _data.avatarSeed  = seed;
        _data.avatarStyle = style;
        _data.avatarBg    = bg;
        _data.mascotType  = seed; // seed = type.name from StepAvatar
      }),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress bar widget — custom (pas de shader GPU)
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
          child: LayoutBuilder(
            builder: (_, constraints) {
              final totalW = constraints.maxWidth;
              return Container(
                height: 3,
                width: totalW,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0EBE0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: totalW * progress,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D4A2D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
