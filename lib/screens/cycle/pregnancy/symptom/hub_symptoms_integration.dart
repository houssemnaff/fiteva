// ─────────────────────────────────────────────
// hub_symptoms_integration.dart
//
// Add this navigation card to PregnancyHubScreen.
// Copy _SymptomsHubCard into your hub's widget tree.
// ─────────────────────────────────────────────

import 'package:fiteva/screens/cycle/pregnancy/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'symptoms_home_screen.dart'; // adjust import path as needed

// ─────────────────────────────────────────────
// Drop _SymptomsHubCard anywhere in your Hub
// grid / list of feature cards.
// ─────────────────────────────────────────────

class _SymptomsHubCard extends StatelessWidget {
  const _SymptomsHubCard({required this.currentWeek});

  final int currentWeek;

  Color get _accent => ThreadTheme.threadForWeek(currentWeek);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                SymptomsHomeScreen(currentWeek: currentWeek),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ThreadTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ThreadTheme.bgCardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text('🩺', style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 12),

            // Title
            const Text(
              'Symptoms',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ThreadTheme.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),

            // Subtitle
            Text(
              'Track & understand\nyour daily symptoms',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.45,
                color: ThreadTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 12),

            // Arrow row
            Row(
              children: [
                Text(
                  'Week $currentWeek',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: _accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Usage in PregnancyHubScreen:
//
//   GridView(
//     ...
//     children: [
//       _DailyInsightHubCard(...),   // your existing card
//       _SymptomsHubCard(currentWeek: currentWeek),
//       // other hub cards
//     ],
//   )
// ─────────────────────────────────────────────