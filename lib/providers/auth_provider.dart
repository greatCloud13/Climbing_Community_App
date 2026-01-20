import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// 인증 상태 관리 Provider
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  /// 로그인
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final authResponse = await _authService.login(username, password);
      _user = authResponse.user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// 회원가입
  Future<bool> signup({
    required String username,
    required String nickname,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signup(
        username: username,
        nickname: nickname,
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  /// 자동 로그인 체크
  Future<bool> checkAutoLogin() async {
    return await _authService.checkAutoLogin();
  }

  /// 로딩 상태 설정
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 에러 메시지 설정
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// 에러 메시지 초기화
  void _clearError() {
    _errorMessage = null;
  }

  /// 에러 메시지 수동 초기화 (UI에서 사용)
  void clearError() {
    _clearError();
    notifyListeners();
  }
}