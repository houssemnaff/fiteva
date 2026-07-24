class PartnerModel {
  final String id;
  final String userId; // UUID Supabase de l'auteur
  final String name;
  final String avatar;
  final String mascotType;
  final String mascotMood;
  final String goal;
  final String level;
  final String region;
  final String frequency;
  final String description;
  final List<String> tags;
  final String contactWhatsapp;
  final String contactInstagram;
  final String contactFacebook;
  final bool isPro;

  const PartnerModel({
    required this.id,
    this.userId = '',
    required this.name,
    required this.avatar,
    this.mascotType = 'blob',
    this.mascotMood = 'happy',
    required this.goal,
    required this.level,
    required this.region,
    required this.frequency,
    required this.description,
    required this.tags,
    this.contactWhatsapp = '',
    this.contactInstagram = '',
    this.contactFacebook = '',
    this.isPro = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'avatar': avatar,
    'mascotType': mascotType,
    'mascotMood': mascotMood,
    'goal': goal,
    'level': level,
    'region': region,
    'frequency': frequency,
    'description': description,
    'tags': tags,
    'contactWhatsapp': contactWhatsapp,
    'contactInstagram': contactInstagram,
    'contactFacebook': contactFacebook,
    'isPro': isPro,
  };

  factory PartnerModel.fromJson(Map<String, dynamic> j) => PartnerModel(
    id: j['id'] as String,
    userId: j['userId'] as String? ?? '',
    name: j['name'] as String,
    avatar: j['avatar'] as String? ?? '',
    mascotType: j['mascotType'] as String? ?? 'blob',
    mascotMood: j['mascotMood'] as String? ?? 'happy',
    goal: j['goal'] as String? ?? '',
    level: j['level'] as String? ?? '',
    region: j['region'] as String? ?? '',
    frequency: j['frequency'] as String? ?? '',
    description: j['description'] as String? ?? '',
    tags: (j['tags'] as List?)?.map((e) => e as String).toList() ?? [],
    contactWhatsapp: j['contactWhatsapp'] as String? ?? '',
    contactInstagram: j['contactInstagram'] as String? ?? '',
    contactFacebook: j['contactFacebook'] as String? ?? '',
    isPro: j['isPro'] as bool? ?? false,
  );

  PartnerModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? avatar,
    String? mascotType,
    String? mascotMood,
    String? goal,
    String? level,
    String? region,
    String? frequency,
    String? description,
    List<String>? tags,
    String? contactWhatsapp,
    String? contactInstagram,
    String? contactFacebook,
    bool? isPro,
  }) =>
      PartnerModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        avatar: avatar ?? this.avatar,
        mascotType: mascotType ?? this.mascotType,
        mascotMood: mascotMood ?? this.mascotMood,
        goal: goal ?? this.goal,
        level: level ?? this.level,
        region: region ?? this.region,
        frequency: frequency ?? this.frequency,
        description: description ?? this.description,
        tags: tags ?? this.tags,
        contactWhatsapp: contactWhatsapp ?? this.contactWhatsapp,
        contactInstagram: contactInstagram ?? this.contactInstagram,
        contactFacebook: contactFacebook ?? this.contactFacebook,
        isPro: isPro ?? this.isPro,
      );
}

/// Demande de mise en relation reçue par le propriétaire d'un post partenaire.
class PartnerJoinRequest {
  final String id;
  final String partnerId;
  final String requesterId;
  final String requesterName;
  final String requesterMascotType;
  final String requesterMascotMood;
  final String status; // 'pending' | 'accepted' | 'declined'
  final DateTime createdAt;
  // À quel post partenaire (le propriétaire peut en avoir plusieurs) la
  // demande se rapporte — nécessaire pour l'afficher dans la liste des demandes.
  final String partnerGoal;
  final String partnerRegion;

  const PartnerJoinRequest({
    required this.id,
    required this.partnerId,
    required this.requesterId,
    required this.requesterName,
    this.requesterMascotType = 'blob',
    this.requesterMascotMood = 'happy',
    required this.status,
    required this.createdAt,
    this.partnerGoal = '',
    this.partnerRegion = '',
  });
}
