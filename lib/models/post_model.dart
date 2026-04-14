class PostModel {
  final String id;
  final String username;
  final String userAvatarUrl;
  final String content;
  final String imageUrl;
  final int likes;
  final int comments;
  final String timeAgo;

  PostModel({
    required this.id,
    required this.username,
    required this.userAvatarUrl,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.timeAgo,
  });
}
