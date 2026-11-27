class Announcement {
  final int id;
  final String title;
  final String body;
  final String author;
  final String publishedAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    required this.publishedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: json['id'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
        author: json['author'] as String? ?? 'Administration',
        publishedAt: json['publishedAt'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'author': author,
        'publishedAt': publishedAt,
      };

  static Announcement fromMap(Map<String, dynamic> map) => Announcement(
        id: map['id'] as int,
        title: map['title'] as String,
        body: map['body'] as String,
        author: map['author'] as String,
        publishedAt: map['publishedAt'] as String,
      );
}
