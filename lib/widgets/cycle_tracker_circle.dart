import 'package:flutter/material.dart';
import 'painter_cycle_tracker_circle.dart';


class CycleTrackerCircle extends StatelessWidget {
  final double value; // 0.0 → 1.0

  const CycleTrackerCircle({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: CustomPaint(
        painter: CycleCirclePainter(value: value),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(value * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cycle Progress',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}