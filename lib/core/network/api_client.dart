import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_response.dart';
import 'network_logger.dart';

class ApiClient extends GetxService {
  late final Dio _dio;
  final String baseUrl;

  // Can be updated when user logs in
  String? _authToken;
  String? get authToken => _authToken;
  ApiClient({required this.baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(AuthInterceptor(this));
    _dio.interceptors.add(NetworkLogger());
  }

  void setToken(String token) {
    _authToken = token;
  }

  void clearToken() {
    _authToken = null;
  }

  Options _getOptions(Map<String, dynamic>? customHeaders) {
    final headers = <String, dynamic>{};

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return Options(headers: headers);
  }

  Future<ApiResponse<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _request(
      () => _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: _getOptions(headers),
      ),
    );
  }

  Future<ApiResponse<dynamic>> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _request(
      () => _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: _getOptions(headers),
      ),
    );
  }

  Future<ApiResponse<dynamic>> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _request(
      () => _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: _getOptions(headers),
      ),
    );
  }

  Future<ApiResponse<dynamic>> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _request(
      () => _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: _getOptions(headers),
      ),
    );
  }

  Future<ApiResponse<dynamic>> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    return _request(
      () => _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: _getOptions(headers),
      ),
    );
  }

  Future<ApiResponse<dynamic>> _request(
    Future<Response<dynamic>> Function() requestFunc,
  ) async {
    try {
      final response = await requestFunc();
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error occurred', statusCode: 0);
    }
  }

  ApiResponse<dynamic> _handleResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 500;
    final data = response.data;

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.success(
        data,
        statusCode: statusCode,
        message: 'Success',
      );
    } else {
      String errorMessage = 'Something went wrong';
      if (data is Map && data.containsKey('message')) {
        errorMessage = data['message'];
      }
      return ApiResponse.error(
        errorMessage,
        statusCode: statusCode,
        data: data,
      );
    }
  }

  ApiResponse<dynamic> _handleDioError(DioException error) {
    String errorMessage = 'Unexpected network error occurred';
    int statusCode = error.response?.statusCode ?? 0;
    dynamic data = error.response?.data;

    if (data is Map && data.containsKey('message')) {
      errorMessage = data['message'];
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timed out';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Server returned an error';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request to API server was cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No Internet Connection';
          break;
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            errorMessage = 'No Internet Connection';
          } else {
            errorMessage = 'Unexpected error occurred';
          }
          break;
        default:
          errorMessage = 'Something went wrong';
          break;
      }
    }

    return ApiResponse.error(errorMessage, statusCode: statusCode, data: data);
  }
}

class AuthInterceptor extends Interceptor {
  final ApiClient apiClient;
  AuthInterceptor(this.apiClient);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (apiClient._authToken != null) {
      options.headers['Authorization'] = 'Bearer ${apiClient._authToken}';
    } else {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null && token.isNotEmpty) {
        apiClient.setToken(token);
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }
}
