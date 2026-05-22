import 'package:flutter/material.dart';

class TimerBadge extends StatelessWidget {
  final int days;
  const TimerBadge({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUrgent = days <= 25;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUrgent
            ? colorScheme.error.withOpacity(0.85)
            : colorScheme.scrim.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUrgent ? Icons.local_fire_department : Icons.access_time,
            color: colorScheme.onError,
            size: 11,
          ),
          const SizedBox(width: 3),
          Text(
            '$days j',
            style: TextStyle(
              color: colorScheme.onError,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}