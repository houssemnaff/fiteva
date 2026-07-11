import 'package:flutter/material.dart';
import 'program_week_model.dart';
import 'workout_model.dart';

class HomeProgramModel {
  final String id;
  final String name;
  final String duration;
  final String phases;
  final Color color;
  final String imageUrl;
  final String description;
  final List<String> goals;

  /// Semaines du programme (1..n), chacune avec ses workouts.
  final List<ProgramWeekModel> weeks;

  /// Tous les workouts du programme, toutes semaines confondues
  /// (conservé à plat pour les écrans qui n'affichent pas les semaines).
  final List<WorkoutModel> workouts;
  final List<String> compatibleCycles;
  final int totalPoints;
  final String? level;
  final List<String> equipment;
  final String category; // 'home' | 'salle' | 'dance' | 'recuperation' | 'grossesse'

  HomeProgramModel({
    required this.id,
    required this.name,
    required this.duration,
    required this.phases,
    required this.color,
    required this.imageUrl,
    required this.workouts,
    this.description = '',
    this.goals = const [],
    this.weeks = const [],
    this.compatibleCycles = const [],
    this.totalPoints = 100,
    this.level,
    this.equipment = const [],
    this.category = 'home',
  });
}