/// Progression de l'utilisatrice : POINTS (ex-XP) → niveaux → bonus DIAMANTS.
/// Les points ne se dépensent jamais ; chaque passage de niveau crédite
/// automatiquement des diamants (monnaie boutique, voir DiamondsService).
class PointsModel {
  final int totalPoints;
  final int streak;
  final String? lastActiveDate;
  final List<String> badges;
  final Map<String, int> challengeProgress;
  final List<String> completedChallenges;
  final bool loginRewardedToday;

  /// Nombre total de jours de connexion distincts (pas forcément consécutifs).
  /// Calculé et maintenu PAR LE SERVEUR (trigger fn_track_login_day) — jamais
  /// écrit par le client, seulement lu.
  final int totalLoginDays;

  /// Diamants gagnés lors du dernier passage de niveau — champ transient
  /// (jamais persisté) consommé par l'UI pour afficher l'animation "+N 💎".
  final int? recentLevelUpDiamonds;

  const PointsModel({
    this.totalPoints = 0,
    this.streak = 0,
    this.lastActiveDate,
    this.badges = const [],
    this.challengeProgress = const {},
    this.completedChallenges = const [],
    this.loginRewardedToday = false,
    this.totalLoginDays = 0,
    this.recentLevelUpDiamonds,
  });

  // ── Level thresholds ───────────────────────────────────────────────────────
  // Barème UNIQUE pour toute l'app (profil, communauté, header) — remplace
  // les deux barèmes divergents qui coexistaient (XpModel vs UserProfileScreen).
  static const List<int> _thresholds = [0, 100, 300, 600, 1000, 1600, 2400];
  static const int maxLevel = 7;

  static const List<String> levelTitles = [
    '', 'Débutante', 'Exploratrice', 'Engagée', 'Championne',
    'Étoile', 'Inspirante', 'Légende',
  ];
  static const List<String> levelEmojis = [
    '', '🌱', '🌸', '💪', '🏆', '🌟', '✨', '👑',
  ];

  /// Diamants offerts au passage du niveau (index = niveau atteint).
  /// Doit rester aligné avec fn_award_level_up_diamonds (migration SQL).
  static const List<int> _diamondsPerLevel = [0, 0, 10, 15, 20, 30, 40, 60];

  static int diamondsForLevel(int level) =>
      (level >= 2 && level <= maxLevel) ? _diamondsPerLevel[level] : 0;

  /// Seuil de points auquel commence le niveau [level] (1..maxLevel).
  static int thresholdForLevel(int level) =>
      _thresholds[(level - 1).clamp(0, _thresholds.length - 1)];

  /// Niveau N couvre [_thresholds[N-1], _thresholds[N]) :
  /// L1 0-99, L2 100-299, L3 300-599, L4 600-999, L5 1000-1599,
  /// L6 1600-2399, L7 ≥ 2400.
  static int levelForPoints(int points) {
    for (int i = _thresholds.length - 1; i >= 0; i--) {
      if (points >= _thresholds[i]) return i + 1;
    }
    return 1;
  }

  int get level => levelForPoints(totalPoints);

  int get pointsForCurrentLevel => _thresholds[level - 1];
  int get pointsForNextLevel =>
      level < maxLevel ? _thresholds[level] : _thresholds[maxLevel - 1];
  int get pointsInCurrentLevel  => totalPoints - pointsForCurrentLevel;
  int get pointsNeededForNextLevel => pointsForNextLevel - pointsForCurrentLevel;

  double get levelProgress {
    if (level >= maxLevel) return 1.0;
    return (pointsInCurrentLevel / pointsNeededForNextLevel).clamp(0.0, 1.0);
  }

  PointsModel copyWith({
    int? totalPoints,
    int? streak,
    String? lastActiveDate,
    List<String>? badges,
    Map<String, int>? challengeProgress,
    List<String>? completedChallenges,
    bool? loginRewardedToday,
    int? totalLoginDays,
    int? recentLevelUpDiamonds,
  }) {
    return PointsModel(
      totalPoints: totalPoints ?? this.totalPoints,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      badges: badges ?? this.badges,
      challengeProgress: challengeProgress ?? this.challengeProgress,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      loginRewardedToday: loginRewardedToday ?? this.loginRewardedToday,
      totalLoginDays: totalLoginDays ?? this.totalLoginDays,
      recentLevelUpDiamonds:
          recentLevelUpDiamonds ?? this.recentLevelUpDiamonds,
    );
  }

  /// copyWith ne peut pas remettre le champ à null (pattern `??`) — méthode
  /// dédiée pour "consommer" l'animation de level-up.
  PointsModel clearLevelUp() => PointsModel(
        totalPoints: totalPoints,
        streak: streak,
        lastActiveDate: lastActiveDate,
        badges: badges,
        challengeProgress: challengeProgress,
        completedChallenges: completedChallenges,
        loginRewardedToday: loginRewardedToday,
        totalLoginDays: totalLoginDays,
      );
}

// ── Challenge definitions ────────────────────────────────────────────────────
class PointsChallenge {
  final String key;
  final String titleFr;
  final String titleEn;
  final String emoji;
  final int targetDays;
  final int pointsReward;

  const PointsChallenge({
    required this.key,
    required this.titleFr,
    required this.titleEn,
    required this.emoji,
    required this.targetDays,
    required this.pointsReward,
  });

  static const List<PointsChallenge> all = [
    PointsChallenge(key: 'water',     titleFr: 'Boire de l\'eau',     titleEn: 'Drink water',       emoji: '💧', targetDays: 7,  pointsReward: 30),
    PointsChallenge(key: 'mood7',     titleFr: 'Humeur 7 jours',      titleEn: 'Mood tracking 7d',  emoji: '😊', targetDays: 7,  pointsReward: 40),
    PointsChallenge(key: 'cycleWeek', titleFr: 'Semaine cycle',       titleEn: 'Cycle awareness',   emoji: '🌸', targetDays: 7,  pointsReward: 50),
  ];
}
