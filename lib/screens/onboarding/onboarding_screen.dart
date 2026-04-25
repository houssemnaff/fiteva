import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../providers/onboarding_provider.dart';
import '../../services/storage_service.dart';
import 'steps/onboarding_steps.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final GlobalKey _swipeShowcaseKey = GlobalKey();
  int _currentPage = 0;
  bool _didShowSwipeHint = false;

  // ✅ Controllers partagés
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ✅ Keys
  static const String _goalsKey = 'goals';
  static const String _fitnessLevelKey = 'fitness_level';
  static const String _equipmentKey = 'equipment';
  static const String _frequencyKey = 'frequency';

  // ✅ State
  List<String> _goals = [];
  String? _fitnessLevel;
  List<String> _equipment = [];
  String? _frequency;

  // 🎨 Couleurs bestach (vert menthe professionnel)
  static const Color _bestachGreen = Color(0xFF4CAF7D);       // vert principal
  static const Color _bestachLight = Color(0xFFE8F5EE);       // fond clair
  static const Color _bestachDark = Color(0xFF2E7D52);        // vert foncé
  static const Color _bestachAccent = Color(0xFF00C47D);      // accent vif

  @override
  void initState() {
    super.initState();
    _loadSavedOnboardingData();
  }

  Future<void> _loadSavedOnboardingData() async {
    final data = StorageService.getOnboardingData();
    _nameController.text = data['username'] ?? '';
    _goals = (data[_goalsKey] is List) ? List<String>.from(data[_goalsKey]) : [];
    _fitnessLevel = data[_fitnessLevelKey];
    _equipment = (data[_equipmentKey] is List) ? List<String>.from(data[_equipmentKey]) : [];
    _frequency = data[_frequencyKey]?.toString();
    if (mounted) setState(() {});
  }

  Map<String, dynamic> _collectData() {
    return {
      'username': _nameController.text.trim(),
      'age': _ageController.text.trim(),
      _goalsKey: _goals,
      _fitnessLevelKey: _fitnessLevel,
      _equipmentKey: _equipment,
      _frequencyKey: _frequency,
    };
  }

  Future<void> _saveData() async {
    await StorageService.saveOnboardingData(_collectData());
  }

  Future<void> _nextPage() async {
    await _saveData();
    if (!mounted) return;
    if (_currentPage < 7) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _finishOnboarding();
    }
  }

  void _previousPage() {
    if (!mounted) return;
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    await _saveData();
    ref.read(onboardingProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      // 🎨 Overlay sombre élégant
    
      builder: (showcaseContext) {
        if (!_didShowSwipeHint) {
          _didShowSwipeHint = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ShowCaseWidget.of(showcaseContext).startShowCase([_swipeShowcaseKey]);
          });
        }

        return Scaffold(
          body: Showcase(
            key: _swipeShowcaseKey,

            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // 🎨 DESIGN MODERNE BESTACH
            // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

            // Bulle tooltip avec fond vert bestach
            tooltipBackgroundColor: _bestachGreen,

            // Bordure lumineuse autour de l'élément mis en avant
           
            // Titre moderne
            title: '✦  Navigation rapide',
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),

            // Description claire et minimaliste
            description: 'Glisse à gauche ou à droite pour passer d\'une étape à l\'autre.',
            descTextStyle: const TextStyle(
              color: Color(0xFFDCF5EB),  // blanc verdâtre doux
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),

            // Bouton "OK / Got it" stylisé
            tooltipActionConfig: TooltipActionConfig(
              position: TooltipActionPosition.outside,
              alignment: MainAxisAlignment.end,
            ),
            tooltipActions: [
              TooltipActionButton(
                type: TooltipDefaultActionType.skip,
                name: 'Compris  ✓',
                textStyle: const TextStyle(
                  color: _bestachGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                backgroundColor: Colors.white,
                borderRadius: BorderRadius.circular(30),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ],

            // Bordure verte autour du widget showcased
            targetBorderRadius: BorderRadius.circular(20),
            targetPadding: const EdgeInsets.all(10),

            // Flèche pointant vers l'élément
            disableMovingAnimation: false,
            disableScaleAnimation: false,

            // Ombre portée sur le tooltip
            toolTipSlideEndDistance: 12,
            tooltipBorderRadius: BorderRadius.circular(20),

            child: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                StepIntro(onNext: _nextPage),
                StepWelcome(
                  onNext: _nextPage,
                  onBack: _previousPage,
                  nameController: _nameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
                StepGoals(
                  selectedGoals: _goals,
                  onBack: _previousPage,
                  onToggleGoal: (goal) {
                    setState(() {
                      _goals.contains(goal) ? _goals.remove(goal) : _goals.add(goal);
                    });
                  },
                  onNext: _nextPage,
                ),
                StepFitnessLevel(
                  selectedLevel: _fitnessLevel,
                  onBack: _previousPage,
                  onChanged: (level) => setState(() => _fitnessLevel = level),
                  onNext: _nextPage,
                ),
                StepEquipment(
                  selectedEquipment: _equipment,
                  onBack: _previousPage,
                  onToggleEquipment: (item) {
                    setState(() {
                      _equipment.contains(item) ? _equipment.remove(item) : _equipment.add(item);
                    });
                  },
                  onNext: _nextPage,
                ),
                StepFrequency(
                  selectedFrequency: _frequency,
                  onBack: _previousPage,
                  onChanged: (value) => setState(() => _frequency = value),
                  onNext: _nextPage,
                ),
                StepHealthProfile(onNext: _nextPage, onBack: _previousPage),
                StepCycle(onNext: _nextPage, onBack: _previousPage),
              ],
            ),
          ),
        );
      },
    );
  }
}