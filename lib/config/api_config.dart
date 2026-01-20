/// API 기본 설정
class ApiConfig {
  // 베이스 URL - 나중에 실제 서버 주소로 변경 가능
  static const String baseUrl = 'http://localhost:8080';

  // API 엔드포인트
  static const String loginEndpoint = '/api/auth/login';
  static const String signupEndpoint = '/api/auth/signup';
  static const String withdrawEndpoint = '/api/auth/withdraw';

  // 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}