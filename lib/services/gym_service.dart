import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/gym.dart';
import '../models/gym_create_dto.dart';
import '../models/paged_response.dart';
import 'api_service.dart';

/// 암장 관리 서비스
class GymService {
  final ApiService _apiService = ApiService();

  /// 암장 등록
  Future<Gym> createGym(GymCreateDTO dto) async {
    try {
      final jsonData = dto.toJson();

      final response = await _apiService.post(
        '/api/gym',
        data: jsonData,
      );

      return Gym.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 암장 목록 조회 (페이지네이션)
  Future<PagedResponse<Gym>> getGyms({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/api/gym',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      return PagedResponse.fromJson(
        response.data,
            (json) => Gym.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 암장 상세 조회
  Future<Gym> getGymDetail(int id) async {
    try {
      final response = await _apiService.get('/api/gym/$id');
      return Gym.fromJson(response.data);
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
          return '암장을 찾을 수 없습니다.';
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