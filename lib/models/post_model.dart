class EventParticipant {
  final String id;
  final String name;
  final String avatarUrl;

  const EventParticipant({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });
}

class PostModel {
  final String id;
  final String username;
  final String userAvatarUrl;
  final String content;
  final String imageUrl;
  final int likes;
  final int comments;
  final String timeAgo;
  final String category;

  const PostModel({
    required this.id,
    required this.username,
    required this.userAvatarUrl,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    this.category = '',
  });
}