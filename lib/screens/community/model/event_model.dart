class EventModel {
  final String id;
  final String title;
  final String organizer;
  final String organizerAvatar;
  final String type;
  final String date;
  final String time;
  final String location;
  final int maxSpots;
  final int joinedCount;
  final List<String> participantAvatars;
  final String imageUrl;
  bool isJoined;

  EventModel({
    required this.id,
    required this.title,
    required this.organizer,
    required this.organizerAvatar,
    required this.type,
    required this.date,
    required this.time,
    required this.location,
    required this.maxSpots,
    required this.joinedCount,
    required this.participantAvatars,
    required this.imageUrl,
    this.isJoined = false,
  });
}