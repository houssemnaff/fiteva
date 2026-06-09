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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'organizer': organizer,
    'organizerAvatar': organizerAvatar,
    'type': type,
    'date': date,
    'time': time,
    'location': location,
    'maxSpots': maxSpots,
    'joinedCount': joinedCount,
    'participantAvatars': participantAvatars,
    'imageUrl': imageUrl,
  };

  factory EventModel.fromJson(Map<String, dynamic> j) => EventModel(
    id: j['id'] as String,
    title: j['title'] as String,
    organizer: j['organizer'] as String,
    organizerAvatar: j['organizerAvatar'] as String? ?? '',
    type: j['type'] as String,
    date: j['date'] as String,
    time: j['time'] as String,
    location: j['location'] as String,
    maxSpots: j['maxSpots'] as int? ?? 10,
    joinedCount: j['joinedCount'] as int? ?? 0,
    participantAvatars: (j['participantAvatars'] as List?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    imageUrl: j['imageUrl'] as String? ?? '',
  );

  EventModel copyWith({
    String? id,
    String? title,
    String? organizer,
    String? organizerAvatar,
    String? type,
    String? date,
    String? time,
    String? location,
    int? maxSpots,
    int? joinedCount,
    List<String>? participantAvatars,
    String? imageUrl,
    bool? isJoined,
  }) =>
      EventModel(
        id: id ?? this.id,
        title: title ?? this.title,
        organizer: organizer ?? this.organizer,
        organizerAvatar: organizerAvatar ?? this.organizerAvatar,
        type: type ?? this.type,
        date: date ?? this.date,
        time: time ?? this.time,
        location: location ?? this.location,
        maxSpots: maxSpots ?? this.maxSpots,
        joinedCount: joinedCount ?? this.joinedCount,
        participantAvatars: participantAvatars ?? this.participantAvatars,
        imageUrl: imageUrl ?? this.imageUrl,
        isJoined: isJoined ?? this.isJoined,
      );
}
