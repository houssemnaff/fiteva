import 'video_model.dart';

class WorkoutModel {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String level;
  final String imageUrl;
  final String calories;
  final String phases;
  final int points;

  /// Source de vérité unique pour les exercices d'un workout — un
  /// VideoModel = un exercice (relation workouts.id → videos.workout_id).
  final List<VideoModel> videos;

  /// Colonne Supabase `workouts.exercises` (legacy) — conservée pour
  /// compatibilité avec le schéma existant, mais NE DOIT PLUS être lue par
  /// la logique UI. `exercises` et `videos` ne sont pas garantis alignés
  /// par index (longueurs différentes possibles) — toute logique doit
  /// utiliser exclusivement [videos] / [exerciseCount] / [videoAt] /
  /// [exerciseNameAt] / [videoIdAt] ci-dessous.
  final List<String> exercises;

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

  /// Nombre d'exercices — dérivé exclusivement de [videos].
  int get exerciseCount => videos.length;

  /// Exercice (vidéo) à [index], ou null si hors bornes.
  VideoModel? videoAt(int index) =>
      index >= 0 && index < videos.length ? videos[index] : null;

  /// Nom d'exercice affiché — vient de VideoModel.title.
  String exerciseNameAt(int index) => videoAt(index)?.title ?? '';

  /// Id Supabase de la vidéo à [index] — vient de VideoModel.id.
  String? videoIdAt(int index) => videoAt(index)?.id;
}
