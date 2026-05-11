import 'package:flutter/material.dart';

class TimerBadge extends StatelessWidget {
  final int days;
  const TimerBadge({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final isUrgent = days <= 25;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.red.withOpacity(0.85)
            : Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUrgent ? Icons.local_fire_department : Icons.access_time,
            color: Colors.white,
            size: 11,
          ),
          const SizedBox(width: 3),
          Text(
            '$days j',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}