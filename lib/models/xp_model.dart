class XpModel {
  final int totalXp;
  final int streak;
  final String? lastActiveDate;
  final List<String> badges;
  final Map<String, int> challengeProgress;
  final List<String> completedChallenges;
  final bool loginRewardedToday;

  const XpModel({
    this.totalXp = 0,
    this.streak = 0,
    this.lastActiveDate,
    this.badges = const [],
    this.challengeProgress = const {},
    this.completedChallenges = const [],
    this.loginRewardedToday = false,
  });

  // ── Level thresholds ───────────────────────────────────────────────────────
  static const List<int> _thresholds = [0, 100, 300, 600, 1000];
  static const List<String> levelTitles = [
    '', 'Débutante', 'Exploratrice', 'Engagée', 'Championne',
  ];
  static const List<String> levelEmojis = ['', '🌱', '🌸', '💪', '🏆'];

  int get level {
    for (int i = _thresholds.length - 1; i >= 1; i--) {
      if (totalXp >= _thresholds[i]) return i;
    }
    return 1;
  }

  int get xpForCurrentLevel => _thresholds[level - 1];
  int get xpForNextLevel    => level < 4 ? _thresholds[level] : _thresholds[4];
  int get xpInCurrentLevel  => totalXp - xpForCurrentLevel;
  int get xpNeededForNextLevel => xpForNextLevel - xpForCurrentLevel;

  double get levelProgress {
    if (level >= 4) return 1.0;
    return (xpInCurrentLevel / xpNeededForNextLevel).clamp(0.0, 1.0);
  }

  XpModel copyWith({
    int? totalXp,
    int? streak,
    String? lastActiveDate,
    List<String>? badges,
    Map<String, int>? challengeProgress,
    List<String>? completedChallenges,
    bool? loginRewardedToday,
  }) {
    return XpModel(
      totalXp: totalXp ?? this.totalXp,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      badges: badges ?? this.badges,
      challengeProgress: challengeProgress ?? this.challengeProgress,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      loginRewardedToday: loginRewardedToday ?? this.loginRewardedToday,
    );
  }
}

// ── Challenge definitions ────────────────────────────────────────────────────
class XpChallenge {
  final String key;
  final String titleFr;
  final String titleEn;
  final String emoji;
  final int targetDays;
  final int xpReward;

  const XpChallenge({
    required this.key,
    required this.titleFr,
    required this.titleEn,
    required this.emoji,
    required this.targetDays,
    required this.xpReward,
  });

  static const List<XpChallenge> all = [
    XpChallenge(key: 'water',     titleFr: 'Boire de l\'eau',     titleEn: 'Drink water',       emoji: '💧', targetDays: 7,  xpReward: 30),
    XpChallenge(key: 'mood7',     titleFr: 'Humeur 7 jours',      titleEn: 'Mood tracking 7d',  emoji: '😊', targetDays: 7,  xpReward: 40),
    XpChallenge(key: 'cycleWeek', titleFr: 'Semaine cycle',       titleEn: 'Cycle awareness',   emoji: '🌸', targetDays: 7,  xpReward: 50),
  ];
}
