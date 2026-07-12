class VideoModel {
  final String id;
  final String title;
  final String duration;
  final int points;
  final String thumbnailUrl;
  final String url; // asset path or network URL — empty = use default cycling
  final String category; // 'dance' | 'cardio' | 'recuperation' — only set for standalone videos
  final String phases; // phases du cycle compatibles — même format que HomeProgramModel.phases

  // ── Contenu pédagogique de l'écran ExercisePlayerScreen ─────────────────
  // Vide/valeurs par défaut = l'écran retombe sur son contenu générique
  // existant (voir exercise_player_screen.dart) tant que la vidéo n'a pas
  // été enrichie en base.
  final String techniqueDescription;
  final List<String> techniqueSteps;
  final List<({String name, double level})> musclesPrimary;
  final List<String> musclesSecondary;
  final List<({String title, String tip})> tips;
  final int sets;
  final int workSeconds;
  final int restSeconds;

  VideoModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.points,
    this.thumbnailUrl = '',
    this.url = '',
    this.category = '',
    this.phases = '',
    this.techniqueDescription = '',
    this.techniqueSteps = const [],
    this.musclesPrimary = const [],
    this.musclesSecondary = const [],
    this.tips = const [],
    this.sets = 3,
    this.workSeconds = 45,
    this.restSeconds = 15,
  });
}
