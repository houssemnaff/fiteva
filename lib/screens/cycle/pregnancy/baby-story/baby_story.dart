class BabyStory {
  final int week;
  final String title;
  final String story;
  final String fact;
  final List<String> milestones;

  const BabyStory({
    required this.week,
    required this.title,
    required this.story,
    required this.fact,
    this.milestones = const [],
  });
}
