import 'video_model.dart';

class WorkoutModel {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String level;
  final String imageUrl;
  final String calories;
  final List<String> exercises;
  final String phases;
  final int points;
  final List<VideoModel> videos;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.level,
    required this.imageUrl,
    required this.exercises,
    required this.calories,
    this.phases = '',
    this.points = 0,
    this.videos = const [],
  });
}
