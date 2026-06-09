class EventParticipant {
  final String id;
  final String name;
  final String avatarUrl;
  const EventParticipant({required this.id, required this.name, required this.avatarUrl});
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'userAvatarUrl': userAvatarUrl,
    'content': content,
    'imageUrl': imageUrl,
    'likes': likes,
    'comments': comments,
    'timeAgo': timeAgo,
    'category': category,
  };

  factory PostModel.fromJson(Map<String, dynamic> j) => PostModel(
    id: j['id'] as String,
    username: j['username'] as String,
    userAvatarUrl: j['userAvatarUrl'] as String,
    content: j['content'] as String,
    imageUrl: j['imageUrl'] as String? ?? '',
    likes: j['likes'] as int? ?? 0,
    comments: j['comments'] as int? ?? 0,
    timeAgo: j['timeAgo'] as String? ?? '',
    category: j['category'] as String? ?? '',
  );

  PostModel copyWith({
    String? id,
    String? username,
    String? userAvatarUrl,
    String? content,
    String? imageUrl,
    int? likes,
    int? comments,
    String? timeAgo,
    String? category,
  }) =>
      PostModel(
        id: id ?? this.id,
        username: username ?? this.username,
        userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
        content: content ?? this.content,
        imageUrl: imageUrl ?? this.imageUrl,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
        timeAgo: timeAgo ?? this.timeAgo,
        category: category ?? this.category,
      );
}
