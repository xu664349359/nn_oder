
enum UserRole { chef, foodie }

class User {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final UserRole role;
  final String? partnerId;
  final String? invitationCode;
  final String phoneNumber;
  final String password;

  User({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.role,
    this.partnerId,
    this.invitationCode,
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'role': role.toString(),
      'partnerId': partnerId,
      'invitationCode': invitationCode,
      'phoneNumber': phoneNumber,
      'password': password,
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
      phoneNumber: json['phoneNumber'] ?? '',
      password: json['password'] ?? '',
    );
  }
  
  User copyWith({
    String? id,
    String? nickname,
    String? avatarUrl,
    UserRole? role,
    String? partnerId,
    String? invitationCode,
    String? phoneNumber,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      partnerId: partnerId ?? this.partnerId,
      invitationCode: invitationCode ?? this.invitationCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
    );
  }
}
