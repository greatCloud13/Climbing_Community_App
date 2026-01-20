import 'user.dart';

/// 로그인 응답 모델
class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  /// JSON을 AuthResponse 객체로 변환
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User(
        username: json['username'] as String,
        nickname: json['nickname'] as String,
        role: json['role'] as String,
      ),
    );
  }
}

/// 회원가입 응답 모델
class SignupResponse {
  final String message;

  SignupResponse({required this.message});

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      message: json['message'] as String,
    );
  }
}