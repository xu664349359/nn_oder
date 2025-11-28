class Moment {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final String? imageUrl;
  final int likes;
  final List<String> comments;
  final DateTime timestamp;

  Moment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.imageUrl,
    this.likes = 0,
    this.comments = const [],
    required this.timestamp,
  });
}
