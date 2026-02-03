import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'token_storage_service.dart';

/// API 통신 기본 서비스
class ApiService {
  late final Dio _dio;
  final TokenStorageService _tokenStorage = TokenStorageService();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // 인터셉터 추가 - 모든 요청에 토큰 자동 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  /// GET 요청
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  /// POST 요청
  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// PUT 요청
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  /// DELETE 요청
  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}