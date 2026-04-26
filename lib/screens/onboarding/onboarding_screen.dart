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
class SwipeHintOverlay extends StatefulWidget {
  final bool visible;

  const SwipeHintOverlay({super.key, required this.visible});

  @override
  State<SwipeHintOverlay> createState() => _SwipeHintOverlayState();
}

class _SwipeHintOverlayState extends State<SwipeHintOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-0.25, 0), // 👈 mouvement vers la gauche
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return IgnorePointer(
      child: Align(
        alignment: Alignment.centerRight, // 👈 PAS au centre
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: SlideTransition(
            position: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.swipe_left, size: 55, color: Colors.white70),
                SizedBox(height: 6),
                Text(
                  "Swipe right",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _showSwipeHint = true;
  bool _loadedHintFlag = false;

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
  static const String _seenSwipeHintKey = 'seen_swipe_hint';

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
    final seen = StorageService.getBool(_seenSwipeHintKey) ?? false;

    _nameController.text = data['username'] ?? '';

    _goals = (data[_goalsKey] is List)
        ? List<String>.from(data[_goalsKey])
        : [];

    _fitnessLevel = data[_fitnessLevelKey];

    _equipment = (data[_equipmentKey] is List)
        ? List<String>.from(data[_equipmentKey])
        : [];

    _frequency = data[_frequencyKey]?.toString();

    if (mounted) {
      setState(() {
        _showSwipeHint = !seen;
        _loadedHintFlag = true;
      });
    }
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
    Future<void> _markSwipeHintSeen() async {
    if (_loadedHintFlag && _showSwipeHint) {
      await StorageService.setBool(_seenSwipeHintKey, true);
      setState(() => _showSwipeHint = false);
    }
  }
  void _onPageChanged(int index) {
    setState(() => _currentPage = index);

    if (index > 0) {
      _markSwipeHintSeen();
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
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: _onPageChanged,
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
                    _goals.contains(goal)
                        ? _goals.remove(goal)
                        : _goals.add(goal);
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
                    _equipment.contains(item)
                        ? _equipment.remove(item)
                        : _equipment.add(item);
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

          SwipeHintOverlay(
            visible: _currentPage == 0 && _showSwipeHint,
          ),
        ],
      ),
    );
  }
}