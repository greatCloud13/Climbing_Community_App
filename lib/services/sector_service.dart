import 'package:dio/dio.dart';
import '../models/sector.dart';
import '../models/sector_detail.dart';
import '../models/sector_dto.dart';
import 'api_service.dart';

/// 섹터 관리 서비스
class SectorService {
  final ApiService _apiService = ApiService();

  /// 특정 암장의 섹터 목록 조회
  Future<List<Sector>> getSectorsByGymId(int gymId) async {
    try {
      final response = await _apiService.get('/api/sector/list/$gymId');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Sector.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 섹터 상세 조회 (세팅 이력 포함)
  Future<SectorDetail> getSectorDetail(int sectorId) async {
    try {
      final response = await _apiService.get('/api/sector/$sectorId');
      return SectorDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 섹터 생성
  Future<Sector> createSector(SectorCreateDTO dto) async {
    try {
      final response = await _apiService.post(
        '/api/sector',
        queryParameters: dto.toJson(),
      );

      return Sector.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 섹터 수정 (세팅일 업데이트)
  Future<Sector> updateSector(int sectorId, SectorUpdateDTO dto) async {
    try {
      final response = await _apiService.put(
        '/api/sector/$sectorId',
        data: dto.toJson(),
      );

      return Sector.fromJson(response.data);
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
          return '섹터를 찾을 수 없습니다.';
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