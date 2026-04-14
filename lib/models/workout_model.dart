class WorkoutModel {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String level;
  final String imageUrl;
  final List<String> exercises;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.level,
    required this.imageUrl,
    required this.exercises,
  });
}
