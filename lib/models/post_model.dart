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
  final bool isEvent;
  final String? eventTitle;
  final String? eventDate;
  final String? eventTime;
  final String? eventLocation;
  final int? maxParticipants;
  final List<EventParticipant> initialParticipants;

  PostModel({
    required this.id,
    required this.username,
    required this.userAvatarUrl,
    required this.content,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    this.isEvent = false,
    this.eventTitle,
    this.eventDate,
    this.eventTime,
    this.eventLocation,
    this.maxParticipants,
    this.initialParticipants = const [],
  });
}
