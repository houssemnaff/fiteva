import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/FitEvaColors.dart';

class MoodSection extends StatelessWidget {
  final int selectedMood;
  final Color phaseColor;
  final void Function(int index) onSelect;

  const MoodSection({
    super.key,
    required this.selectedMood,
    required this.phaseColor,
    required this.onSelect,
  });

  final List<_MoodItem> moods = const [
    _MoodItem(icon: Icons.sentiment_very_satisfied_rounded, label: 'Great'),
    _MoodItem(icon: Icons.sentiment_satisfied_rounded, label: 'Good'),
    _MoodItem(icon: Icons.sentiment_neutral_rounded, label: 'Okay'),
    _MoodItem(icon: Icons.sentiment_dissatisfied_rounded, label: 'Low'),
    _MoodItem(icon: Icons.self_improvement_rounded, label: 'Calm'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood',
          style: TextStyle(
            fontSize: 20,
             letterSpacing: -0.2, // 👈 iOS style trick
            fontWeight: FontWeight.w600,
            color: FitEvaColors.text,
             fontFamily: '.SF Pro Display',
          ),
        ),

        const SizedBox(height: 10),

        // ✅ FIX ABSOLU overflow
        LayoutBuilder(
          builder: (context, constraints) {
            final size = (constraints.maxWidth / 3) - 10;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(moods.length, (i) {
                final isSelected = selectedMood == i;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSelect(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected
                          ? phaseColor.withOpacity(0.20)
                          : FitEvaColors.cardBg,
                      border: Border.all(
                        color: isSelected
                            ? phaseColor.withOpacity(0.6)
                            : Colors.transparent,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            moods[i].icon,
                            size: 36,
                            
                            color: isSelected
                                ? phaseColor
                                : FitEvaColors.text.withOpacity(0.4),
                                
                          ),
                          const SizedBox(height: 4),

                          // 🔥 label SAFE (no overflow)
                          Text(
                            moods[i].label,
                            style: TextStyle(
                                fontFamily: '.SF Pro Display',
                              fontSize: 10,
                              color: isSelected ? phaseColor : FitEvaColors.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _MoodItem {
  final IconData icon;
  final String label;

  const _MoodItem({
    required this.icon,
    required this.label,
  });
}