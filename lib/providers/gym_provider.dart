import 'package:flutter/material.dart';
import '../models/gym.dart';
import '../services/gym_service.dart';

/// 암장 정보 상태 관리 Provider
class GymProvider extends ChangeNotifier {
  final GymService _gymService = GymService();

  Gym? _gym;
  bool _isLoading = false;
  String? _errorMessage;

  Gym? get gym => _gym;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 암장 정보 로드
  Future<void> loadGym(int gymId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _gym = await _gymService.getGymDetail(gymId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 암장 정보 초기화 (로그아웃 시)
  void clear() {
    _gym = null;
    _errorMessage = null;
    notifyListeners();
  }
}