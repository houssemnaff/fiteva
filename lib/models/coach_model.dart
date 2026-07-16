/// Coach créateur d'un programme (table `coaches`, liée via
/// `programs.coach_id`). Alimente la carte Coach du détail programme.
class CoachModel {
  final String id;
  final String name;
  final String title;
  final String avatarUrl;
  final double rating;
  final int reviewsCount;
  final String bio;
  final String instagram;

  const CoachModel({
    required this.id,
    required this.name,
    this.title = '',
    this.avatarUrl = '',
    this.rating = 5.0,
    this.reviewsCount = 0,
    this.bio = '',
    this.instagram = '',
  });

  factory CoachModel.fromRow(Map<String, dynamic> r) => CoachModel(
        id:           r['id']            as String,
        name:         r['name']          as String? ?? '',
        title:        r['title']         as String? ?? '',
        avatarUrl:    r['avatar_url']    as String? ?? '',
        rating:       (r['rating']       as num?)?.toDouble() ?? 5.0,
        reviewsCount: r['reviews_count'] as int? ?? 0,
        bio:          r['bio']           as String? ?? '',
        instagram:    r['instagram']     as String? ?? '',
      );
}
