class PartnerModel {
  final String id;
  final String name;
  final String avatar;
  final String goal;
  final String level;
  final String region;
  final String frequency;
  final String description;
  final List<String> tags;

  const PartnerModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.goal,
    required this.level,
    required this.region,
    required this.frequency,
    required this.description,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'goal': goal,
    'level': level,
    'region': region,
    'frequency': frequency,
    'description': description,
    'tags': tags,
  };

  factory PartnerModel.fromJson(Map<String, dynamic> j) => PartnerModel(
    id: j['id'] as String,
    name: j['name'] as String,
    avatar: j['avatar'] as String? ?? '',
    goal: j['goal'] as String? ?? '',
    level: j['level'] as String? ?? '',
    region: j['region'] as String? ?? '',
    frequency: j['frequency'] as String? ?? '',
    description: j['description'] as String? ?? '',
    tags: (j['tags'] as List?)?.map((e) => e as String).toList() ?? [],
  );
}
