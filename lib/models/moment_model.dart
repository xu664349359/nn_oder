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

  factory Moment.fromMap(Map<String, dynamic> map) {
    return Moment(
      id: map['id'],
      userId: map['user_id'],
      userName: map['profiles']?['nickname'] ?? 'User', // Joined from profiles
      userAvatar: map['profiles']?['avatar_url'],
      content: map['content'] ?? '',
      imageUrl: map['image_url'],
      // likes will be a count join usually, or separate query. For now assuming simplified count or local logic
      likes: map['moment_likes'] != null ? (map['moment_likes'] as List).length : 0, 
      timestamp: DateTime.parse(map['created_at']).toLocal(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      // 'created_at': timestamp.toIso8601String(), // Let DB handle default
    };
  }
}
