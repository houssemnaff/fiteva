class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final ChallengeType type;
  final int durationDays;
  final String? cyclePhase;
  final DateTime startDate;
  final DateTime endDate;
  final int participantCount;
  final bool isJoined;
  final int completedDays;
  final List<ChallengeLeaderEntry> leaderboard;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.type,
    required this.durationDays,
    this.cyclePhase,
    required this.startDate,
    required this.endDate,
    this.participantCount = 0,
    this.isJoined = false,
    this.completedDays = 0,
    this.leaderboard = const [],
  });

  double get progress =>
      durationDays > 0 ? (completedDays / durationDays).clamp(0.0, 1.0) : 0.0;

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  int get daysLeft {
    final now = DateTime.now();
    return endDate.difference(now).inDays.clamp(0, durationDays);
  }

  ChallengeModel copyWith({
    bool? isJoined,
    int? completedDays,
    int? participantCount,
    List<ChallengeLeaderEntry>? leaderboard,
  }) =>
      ChallengeModel(
        id: id,
        title: title,
        description: description,
        emoji: emoji,
        type: type,
        durationDays: durationDays,
        cyclePhase: cyclePhase,
        startDate: startDate,
        endDate: endDate,
        participantCount: participantCount ?? this.participantCount,
        isJoined: isJoined ?? this.isJoined,
        completedDays: completedDays ?? this.completedDays,
        leaderboard: leaderboard ?? this.leaderboard,
      );
}

enum ChallengeType { weekly, thirtyDay, cycleSynced }

class ChallengeLeaderEntry {
  final String userId;
  final String username;
  final String mascotType;
  final String mascotMood;
  final int completedDays;
  final int rank;

  const ChallengeLeaderEntry({
    required this.userId,
    required this.username,
    this.mascotType = 'blob',
    this.mascotMood = 'happy',
    required this.completedDays,
    required this.rank,
  });
}
