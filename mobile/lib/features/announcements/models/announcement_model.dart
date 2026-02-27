class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.startAt,
    required this.endAt,
  });

  final String id;
  final String title;
  final String content;
  final DateTime startAt;
  final DateTime endAt;

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
    );
  }
}
