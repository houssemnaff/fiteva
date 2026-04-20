  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:go_router/go_router.dart';

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
    int _currentPage = 0;

    // ✅ Controllers partagés
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _ageController = TextEditingController();

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

    @override
    void initState() {
      super.initState();
      _loadSavedOnboardingData();
    }

    // ─────────────────────────────────────────────
    // LOAD DATA
    // ─────────────────────────────────────────────
    Future<void> _loadSavedOnboardingData() async {
      final data = StorageService.getOnboardingData();

      _nameController.text = data['username'] ?? '';

      _goals = (data[_goalsKey] is List)
          ? List<String>.from(data[_goalsKey])
          : [];

      _fitnessLevel = data[_fitnessLevelKey];

      _equipment = (data[_equipmentKey] is List)
          ? List<String>.from(data[_equipmentKey])
          : [];

      _frequency = data[_frequencyKey]?.toString();

      if (mounted) setState(() {});
    }

    // ─────────────────────────────────────────────
    // SAVE DATA
    // ─────────────────────────────────────────────
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

    // ─────────────────────────────────────────────
    // NAVIGATION
    // ─────────────────────────────────────────────
    Future<void> _nextPage() async {
      await _saveData();

      if (!mounted) return;

      if (_currentPage < 6) {
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

    // ─────────────────────────────────────────────
    @override
    void dispose() {
      _pageController.dispose();
      _nameController.dispose();
      _ageController.dispose();
      super.dispose();
    }

    // ─────────────────────────────────────────────
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: PageView(
          controller: _pageController,
          // ynajm yscroli le page bil swipe
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
          children: [
            //step 0
              StepIntro(onNext: _nextPage), // 👈 AJOUT ICI

            // ✅ STEP 1
            StepWelcome(
              onNext: _nextPage,
              onBack: _previousPage,
              nameController: _nameController,
              ageController: _ageController,
            ),

            // ✅ STEP 2
            StepGoals(
              selectedGoals: _goals,
              onBack: _previousPage,
              onToggleGoal: (goal) {
                setState(() {
                  _goals.contains(goal)
                      ? _goals.remove(goal)
                      : _goals.add(goal);
                });
              },
              onNext: _nextPage,
            ),

            // ✅ STEP 3
            StepFitnessLevel(
              selectedLevel: _fitnessLevel,
              onBack: _previousPage,
              onChanged: (level) {
                setState(() => _fitnessLevel = level);
              },
              onNext: _nextPage,
            ),

            // ✅ STEP 4
            StepEquipment(
              selectedEquipment: _equipment,
              onBack: _previousPage,
              onToggleEquipment: (item) {
                setState(() {
                  _equipment.contains(item)
                      ? _equipment.remove(item)
                      : _equipment.add(item);
                });
              },
              onNext: _nextPage,
            ),

            // ✅ STEP 5
            StepFrequency(
              selectedFrequency: _frequency,
              onBack: _previousPage,
              onChanged: (value) {
                setState(() => _frequency = value);
              },
              onNext: _nextPage,
            ),

            // ✅ STEP 6
            StepHealthProfile(onNext: _nextPage, onBack: _previousPage),

            // ✅ STEP 7
            StepCycle(onNext: _nextPage, onBack: _previousPage),
          ],
        ),
      );
    }
  }