class EventParticipant {
  final String id;
  final String name;
  final String avatarUrl;
  const EventParticipant({required this.id, required this.name, required this.avatarUrl});
}

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  final String mascotType;
  final String mascotMood;
  final String title;
  final String content;
  final String imageUrl;
  final int likes;
  final int comments;
  final String timeAgo;
  final String category;

  const PostModel({
    required this.id,
    this.userId = '',
    required this.username,
    required this.userAvatarUrl,
    this.mascotType = 'blob',
    this.mascotMood = 'happy',
    this.title = '',
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    this.category = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'username': username,
    'userAvatarUrl': userAvatarUrl,
    'mascotType': mascotType,
    'mascotMood': mascotMood,
    'title': title,
    'content': content,
    'imageUrl': imageUrl,
    'likes': likes,
    'comments': comments,
    'timeAgo': timeAgo,
    'category': category,
  };

  factory PostModel.fromJson(Map<String, dynamic> j) => PostModel(
    id: j['id'] as String,
    userId: j['userId'] as String? ?? '',
    username: j['username'] as String,
    userAvatarUrl: j['userAvatarUrl'] as String,
    mascotType: j['mascotType'] as String? ?? 'blob',
    mascotMood: j['mascotMood'] as String? ?? 'happy',
    title: j['title'] as String? ?? '',
    content: j['content'] as String,
    imageUrl: j['imageUrl'] as String? ?? '',
    likes: j['likes'] as int? ?? 0,
    comments: j['comments'] as int? ?? 0,
    timeAgo: j['timeAgo'] as String? ?? '',
    category: j['category'] as String? ?? '',
  );

  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatarUrl,
    String? mascotType,
    String? mascotMood,
    String? title,
    String? content,
    String? imageUrl,
    int? likes,
    int? comments,
    String? timeAgo,
    String? category,
  }) =>
      PostModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        username: username ?? this.username,
        userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
        mascotType: mascotType ?? this.mascotType,
        mascotMood: mascotMood ?? this.mascotMood,
        title: title ?? this.title,
        content: content ?? this.content,
        imageUrl: imageUrl ?? this.imageUrl,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
        timeAgo: timeAgo ?? this.timeAgo,
        category: category ?? this.category,
      );
}
