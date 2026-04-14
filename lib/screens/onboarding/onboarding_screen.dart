import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/onboarding_provider.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import 'steps/onboarding_steps.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 7;

  final TextEditingController _nameController = TextEditingController();

  static const String _goalsKey = 'goals';
  static const String _fitnessLevelKey = 'fitness_level';
  static const String _equipmentKey = 'equipment';
  static const String _cycleKey = 'cycle_info';

  List<String> _goals = <String>[];
  String _fitnessLevel = '';
  List<String> _equipment = <String>[];
  String _cycleInfo = '';

  @override
  void initState() {
    super.initState();
    _loadSavedOnboardingData();
  }

  Future<void> _loadSavedOnboardingData() async {
    final data = StorageService.getOnboardingData();
    _nameController.text = data['username']?.toString() ?? '';
    _goals = (data[_goalsKey] is List)
        ? (data[_goalsKey] as List).map((e) => e.toString()).toList()
        : <String>[];
    _fitnessLevel = data[_fitnessLevelKey]?.toString() ?? '';
    _equipment = (data[_equipmentKey] is List)
        ? (data[_equipmentKey] as List).map((e) => e.toString()).toList()
        : <String>[];
    _cycleInfo = data[_cycleKey]?.toString() ?? '';

    if (mounted) {
      setState(() {});
    }
  }

  Map<String, dynamic> _collectOnboardingData() {
    return {
      'username': _nameController.text.trim(),
      _goalsKey: _goals,
      _fitnessLevelKey: _fitnessLevel,
      _equipmentKey: _equipment,
      _cycleKey: _cycleInfo,
    };
  }

  Future<void> _persistOnboardingData() async {
    await StorageService.saveOnboardingData(_collectOnboardingData());
  }

  Future<void> _finishOnboarding() async {
    await _persistOnboardingData();
    ref.read(onboardingProvider.notifier).completeOnboarding();
    if (!mounted) {
      return;
    }
    context.go('/');
  }

  Future<void> _nextPage() async {
    await _persistOnboardingData();

    if (_currentPage < _totalPages - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _finishOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(
                  _totalPages,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 6,
                      decoration: BoxDecoration(
                        color:
                            index <= _currentPage ? AppTheme.primaryColor : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Prevent swipe to force button clicks
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  StepWelcome(onNext: () {
                    _nextPage();
                  }),
                  StepAvatar(onNext: () {
                    _nextPage();
                  }),
                  StepName(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    onNext: () {
                      _nextPage();
                    },
                  ),
                  StepGoals(
                    selectedGoals: _goals,
                    onToggleGoal: (goal) {
                      setState(() {
                        if (_goals.contains(goal)) {
                          _goals.remove(goal);
                        } else {
                          _goals.add(goal);
                        }
                      });
                    },
                    onNext: () {
                      _nextPage();
                    },
                  ),
                  StepFitnessLevel(
                    selectedLevel: _fitnessLevel,
                    onChanged: (level) {
                      setState(() {
                        _fitnessLevel = level;
                      });
                    },
                    onNext: () {
                      _nextPage();
                    },
                  ),
                  StepEquipment(
                    selectedEquipment: _equipment,
                    onToggleEquipment: (item) {
                      setState(() {
                        if (_equipment.contains(item)) {
                          _equipment.remove(item);
                        } else {
                          _equipment.add(item);
                        }
                      });
                    },
                    onNext: () {
                      _nextPage();
                    },
                  ),
                  StepCycle(
                    selectedCycle: _cycleInfo,
                    onChanged: (value) {
                      setState(() {
                        _cycleInfo = value;
                      });
                    },
                    onNext: () {
                      _nextPage();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
