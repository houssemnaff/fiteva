
import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/models/workout_model.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';


Widget buildSectionHeader({
  required BuildContext context,
  required String emoji,
  required String title,
  required String subtitle,
  required Color color,
  VoidCallback? onSeeAll,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textSecondary = theme.textTheme.bodyMedium?.color ?? colorScheme.onSurface.withOpacity(0.72);

  final sw = MediaQuery.of(context).size.width;
  final topPad    = sw < 360 ? 10.0 : 12.0;
  final bottomPad = sw < 360 ? 6.0  : 8.0;

  return Padding(
    padding: EdgeInsets.fromLTRB(16, topPad, 16, bottomPad),
    child: Row(
      children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: colorScheme.onSurface)),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Voir tout',
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    ),
  );
}
