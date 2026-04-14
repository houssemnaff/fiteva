import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _steps = [
    const _StepPlaceholder(title: 'Create Your Avatar', subtitle: 'Step 1 of 7'),
    const _StepPlaceholder(title: 'What are your goals?', subtitle: 'Step 2 of 7'),
    const _StepPlaceholder(title: 'Current Fitness Level', subtitle: 'Step 3 of 7'),
    const _StepPlaceholder(title: 'Equipment You Have', subtitle: 'Step 4 of 7'),
    const _StepPlaceholder(title: 'Plan Your Week', subtitle: 'Step 5 of 7'),
    const _StepPlaceholder(title: 'Basic Health Data', subtitle: 'Step 6 of 7'),
    const _StepPlaceholder(title: 'Sync Your Cycle', subtitle: 'Step 7 of 7'),
  ];

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  else
                    const SizedBox(width: 48),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            
            // Progress indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppTheme.primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: _steps,
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage == _steps.length - 1 ? 'FINISH' : 'CONTINUE'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepPlaceholder({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, size: 80, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 48),
          Text(title, style: Theme.of(context).textTheme.displayMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
