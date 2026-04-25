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
}