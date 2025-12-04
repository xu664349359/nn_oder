
enum UserRole { chef, foodie }

class User {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final String? backgroundImageUrl;
  final UserRole role;
  final String? partnerId;
  final String? invitationCode;
  final String phoneNumber;
  final String password;
  final int intimacyBalance;

  User({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.backgroundImageUrl,
    required this.role,
    this.partnerId,
    this.invitationCode,
    required this.phoneNumber,
    required this.password,
    this.intimacyBalance = 1000,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'role': role.toString(),
      'partnerId': partnerId,
      'invitationCode': invitationCode,
      'phoneNumber': phoneNumber,
      'password': password,
      'intimacy_balance': intimacyBalance,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      backgroundImageUrl: json['backgroundImageUrl'],
      role: json['role'] == 'UserRole.chef' ? UserRole.chef : UserRole.foodie,
      partnerId: json['partnerId'],
      invitationCode: json['invitationCode'],
      phoneNumber: json['phoneNumber'] ?? '',
      password: json['password'] ?? '',
      intimacyBalance: json['intimacy_balance'] ?? 1000,
    );
  }
  
  User copyWith({
    String? id,
    String? nickname,
    String? avatarUrl,
    String? backgroundImageUrl,
    UserRole? role,
    String? partnerId,
    String? invitationCode,
    String? phoneNumber,
    String? password,
    int? intimacyBalance,
  }) {
    return User(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      role: role ?? this.role,
      partnerId: partnerId ?? this.partnerId,
      invitationCode: invitationCode ?? this.invitationCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      intimacyBalance: intimacyBalance ?? this.intimacyBalance,
    );
  }
}
