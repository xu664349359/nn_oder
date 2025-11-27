
enum UserRole { chef, foodie }

class User {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final UserRole role;
  final String? partnerId;
  final String? invitationCode;

  User({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.role,
    this.partnerId,
    this.invitationCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'role': role.toString(),
      'partnerId': partnerId,
      'invitationCode': invitationCode,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      role: json['role'] == 'UserRole.chef' ? UserRole.chef : UserRole.foodie,
      partnerId: json['partnerId'],
      invitationCode: json['invitationCode'],
    );
  }
  
  User copyWith({
    String? id,
    String? nickname,
    String? avatarUrl,
    UserRole? role,
    String? partnerId,
    String? invitationCode,
  }) {
    return User(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      partnerId: partnerId ?? this.partnerId,
      invitationCode: invitationCode ?? this.invitationCode,
    );
  }
}
