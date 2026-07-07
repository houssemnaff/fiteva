class EventModel {
  final String id;
  final String title;
  final String organizer;
  final String organizerId;
  final String organizerAvatar;
  final String organizerMascotType;
  final String organizerMascotMood;
  final String type;
  final String date;
  final String dateIso;
  final String time;
  final String location;
  final int maxSpots;
  final int joinedCount;
  final List<String> participantAvatars;
  final String imageUrl;
  final String description;
  final String contactWhatsapp;
  final String contactInstagram;
  final String contactFacebook;
  bool isJoined;

  EventModel({
    required this.id,
    required this.title,
    required this.organizer,
    this.organizerId = '',
    required this.organizerAvatar,
    this.organizerMascotType = 'blob',
    this.organizerMascotMood = 'happy',
    required this.type,
    required this.date,
    this.dateIso = '',
    required this.time,
    required this.location,
    required this.maxSpots,
    required this.joinedCount,
    required this.participantAvatars,
    required this.imageUrl,
    this.description = '',
    this.contactWhatsapp = '',
    this.contactInstagram = '',
    this.contactFacebook = '',
    this.isJoined = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'organizer': organizer,
    'organizerId': organizerId,
    'organizerAvatar': organizerAvatar,
    'organizerMascotType': organizerMascotType,
    'organizerMascotMood': organizerMascotMood,
    'type': type,
    'date': date,
    'dateIso': dateIso,
    'time': time,
    'location': location,
    'maxSpots': maxSpots,
    'joinedCount': joinedCount,
    'participantAvatars': participantAvatars,
    'imageUrl': imageUrl,
    'description': description,
    'contactWhatsapp': contactWhatsapp,
    'contactInstagram': contactInstagram,
    'contactFacebook': contactFacebook,
  };

  factory EventModel.fromJson(Map<String, dynamic> j) => EventModel(
    id: j['id'] as String,
    title: j['title'] as String,
    organizer: j['organizer'] as String,
    organizerId: j['organizerId'] as String? ?? '',
    organizerAvatar: j['organizerAvatar'] as String? ?? '',
    organizerMascotType: j['organizerMascotType'] as String? ?? 'blob',
    organizerMascotMood: j['organizerMascotMood'] as String? ?? 'happy',
    type: j['type'] as String,
    date: j['date'] as String,
    dateIso: j['dateIso'] as String? ?? '',
    time: j['time'] as String,
    location: j['location'] as String,
    maxSpots: j['maxSpots'] as int? ?? 10,
    joinedCount: j['joinedCount'] as int? ?? 0,
    participantAvatars: (j['participantAvatars'] as List?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    imageUrl: j['imageUrl'] as String? ?? '',
    description: j['description'] as String? ?? '',
    contactWhatsapp: j['contactWhatsapp'] as String? ?? '',
    contactInstagram: j['contactInstagram'] as String? ?? '',
    contactFacebook: j['contactFacebook'] as String? ?? '',
  );

  EventModel copyWith({
    String? id,
    String? title,
    String? organizer,
    String? organizerId,
    String? organizerAvatar,
    String? organizerMascotType,
    String? organizerMascotMood,
    String? type,
    String? date,
    String? dateIso,
    String? time,
    String? location,
    int? maxSpots,
    int? joinedCount,
    List<String>? participantAvatars,
    String? imageUrl,
    String? description,
    String? contactWhatsapp,
    String? contactInstagram,
    String? contactFacebook,
    bool? isJoined,
  }) =>
      EventModel(
        id: id ?? this.id,
        title: title ?? this.title,
        organizer: organizer ?? this.organizer,
        organizerId: organizerId ?? this.organizerId,
        organizerAvatar: organizerAvatar ?? this.organizerAvatar,
        organizerMascotType: organizerMascotType ?? this.organizerMascotType,
        organizerMascotMood: organizerMascotMood ?? this.organizerMascotMood,
        type: type ?? this.type,
        date: date ?? this.date,
        dateIso: dateIso ?? this.dateIso,
        time: time ?? this.time,
        location: location ?? this.location,
        maxSpots: maxSpots ?? this.maxSpots,
        joinedCount: joinedCount ?? this.joinedCount,
        participantAvatars: participantAvatars ?? this.participantAvatars,
        imageUrl: imageUrl ?? this.imageUrl,
        description: description ?? this.description,
        contactWhatsapp: contactWhatsapp ?? this.contactWhatsapp,
        contactInstagram: contactInstagram ?? this.contactInstagram,
        contactFacebook: contactFacebook ?? this.contactFacebook,
        isJoined: isJoined ?? this.isJoined,
      );
}
