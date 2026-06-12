import 'package:flutter/material.dart';
import 'workout_model.dart';

class HomeProgramModel {
  final String id;
  final String name;
  final String duration;
  final String phases;
  final String sessions;
  final Color color;
  final String imageUrl;
  final List<WorkoutModel> workouts;
  final List<String> compatibleCycles;
  final int totalPoints;

  HomeProgramModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.phases,
    required this.sessions,
    required this.color,
    required this.imageUrl,
    required this.workouts,
    this.compatibleCycles = const [],
    this.totalPoints = 100,
  });
}