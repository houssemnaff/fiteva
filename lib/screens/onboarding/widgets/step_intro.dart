import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ══════════════════════════════════════════════════════════════════════════════
// STEP 0 — StepIntro
// ══════════════════════════════════════════════════════════════════════════════
class StepIntro extends StatelessWidget {
  final VoidCallback onNext;
  const StepIntro({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF244D2A)),
        child: Stack(
          children: [
            Positioned(
              top: -100, left: -80,
              child: _circle(300, const Color(0xFF2E5E35)),
            ),
            Positioned(
              bottom: -120, right: -80,
              child: _circle(280, const Color(0xFF2E5E35)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/images/logfiteva.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "FITEVA",
                          style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold,
                            letterSpacing: 2, color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "fit, c'est moi.",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SafeArea(
                    child: GestureDetector(
                      onTap: onNext,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Commencer",
                              style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold,
                                color: Color(0xFF244D2A),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, color: Color(0xFF244D2A)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.4), shape: BoxShape.circle,
        ),
      );
}
