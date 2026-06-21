class VideoModel {
  final String id;
  final String title;
  final String duration;
  final int points;
  final String thumbnailUrl;
  final String url; // asset path or network URL — empty = use default cycling

  VideoModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.points,
    this.thumbnailUrl = '',
    this.url = '',
  });
}
