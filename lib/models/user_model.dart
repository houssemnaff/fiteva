class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final int level;
  final int xp;
  final int streak;

  UserModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.level,
    required this.xp,
    required this.streak,
  });
}
