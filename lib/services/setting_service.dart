import 'package:dio/dio.dart';
import '../models/setting.dart';
import '../models/setting_dto.dart';
import 'api_service.dart';

/// 세팅 관리 서비스
class SettingService {
  final ApiService _apiService = ApiService();

  /// 세팅 생성
  /// POST /api/setting
  Future<Setting> createSetting(SettingCreateDTO dto) async {
    try {
      final response = await _apiService.post(
        '/api/setting',
        data: dto.toJson(),
      );

      return Setting.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 세팅 상세 조회
  /// GET /api/setting/{id}
  Future<Setting> getSettingDetail(int settingId) async {
    try {
      final response = await _apiService.get('/api/setting/$settingId');
      return Setting.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 세팅 날짜 수정
  /// PUT /api/setting/{id}
  Future<Setting> updateSetting(int settingId, SettingUpdateDTO dto) async {
    try {
      final response = await _apiService.put(
        '/api/setting/$settingId',
        data: dto.toJson(),
      );

      return Setting.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 에러 처리
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;

      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'] as String;
      }

      switch (error.response!.statusCode) {
        case 400:
          return '입력 정보를 확인해주세요.';
        case 401:
          return '인증이 필요합니다.';
        case 403:
          return '권한이 없습니다.';
        case 404:
          return '세팅을 찾을 수 없습니다.';
        case 500:
          return '서버 오류가 발생했습니다.';
        default:
          return '오류가 발생했습니다. (${error.response!.statusCode})';
      }
    }

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