/// 사용자 모델
class User {
  final String username;
  final String nickname;
  final String role;

  User({
    required this.username,
    required this.nickname,
    required this.role,
  });

  /// JSON을 User 객체로 변환
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      role: json['role'] as String,
    );
  }

  /// User 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'nickname': nickname,
      'role': role,
    };
  }

  /// 사용자 역할 확인 메서드
  bool isAdmin() => role == 'ADMIN';
  bool isGymManager() => role == 'GYM_MANAGER';
  bool isMember() => role == 'MEMBER';
}