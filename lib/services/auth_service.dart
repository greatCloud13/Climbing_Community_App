import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/auth_response.dart';
import 'api_service.dart';
import 'token_storage_service.dart';

/// 인증 관련 서비스
class AuthService {
  final ApiService _apiService = ApiService();
  final TokenStorageService _tokenStorage = TokenStorageService();

  /// 로그인
  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // 토큰 저장
      await _tokenStorage.saveToken(authResponse.token);

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 회원가입
  Future<SignupResponse> signup({
    required String username,
    required String nickname,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.signupEndpoint,
        data: {
          'username': username,
          'nickname': nickname,
          'email': email,
          'password': password,
        },
      );

      return SignupResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  /// 자동 로그인 체크
  Future<bool> checkAutoLogin() async {
    return await _tokenStorage.hasToken();
  }

  /// 에러 처리
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;

      // message 필드가 있으면 사용
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String;
      }

      // status 코드에 따른 기본 메시지
      switch (error.response!.statusCode) {
        case 400:
          return '입력 정보를 확인해주세요.';
        case 401:
          return '아이디 또는 비밀번호가 올바르지 않습니다.';
        case 409:
          return '이미 존재하는 사용자입니다.';
        case 500:
          return '서버 오류가 발생했습니다.';
        default:
          return '오류가 발생했습니다. (${error.response!.statusCode})';
      }
    }

    // 네트워크 오류
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return '서버 응답 시간이 초과되었습니다.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return '네트워크 연결을 확인해주세요.';
    }

    return '알 수 없는 오류가 발생했습니다.';
  }
}