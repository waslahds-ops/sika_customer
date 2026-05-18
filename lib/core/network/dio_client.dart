import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../error/exceptions.dart';

class DioClient {
  final Dio _dio;

  // Base URL configuration - loaded from .env file
  static String get baseUrl {
    return AppConfig.apiEndpoint;
  }

  DioClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(seconds: AppConfig.connectionTimeout),
          receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
          sendTimeout: Duration(seconds: AppConfig.sendTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          _handleDioError(error);
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('🔐 [DioClient] Auth token set: ${token.substring(0, 20)}...');
    print('🔐 [DioClient] Headers now: ${_dio.options.headers}');
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Convenience methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        final message = responseData is Map
            ? (responseData['message'] ?? 'An error occurred')
            : 'An error occurred';

        // Log detailed error information
        print('🔴 [DioClient] Bad Response Error:');
        print('   Status Code: $statusCode');
        print('   Message: $message');
        print('   Response Data: $responseData');
        print('   Endpoint: ${error.requestOptions.path}');

        if (statusCode == 401) {
          throw UnauthorizedException(message);
        } else if (statusCode == 403) {
          throw ForbiddenException(
            '$message - This usually means: 1) Your authentication token is invalid or expired, 2) You don\'t have permission to access this resource, or 3) The server is blocking your request.',
          );
        } else if (statusCode == 404) {
          throw NotFoundException(
            'Endpoint not found: ${error.requestOptions.path}. Please check your Laravel routes.',
          );
        } else if (statusCode == 422) {
          final errors = responseData is Map ? responseData['errors'] : null;
          throw ValidationException(message, errors);
        } else if (statusCode == 500) {
          throw ServerException(
            'Server error (500). Please check Laravel logs.',
          );
        } else {
          throw ServerException('$message (Status: $statusCode)');
        }
      case DioExceptionType.cancel:
        throw ServerException('Request cancelled');
      case DioExceptionType.unknown:
        // Log the unknown error with all details
        print('🔴 [DioClient] Unknown Error:');
        print('   Error Message: ${error.message}');
        print('   Error Type: ${error.type}');
        print('   Exception: ${error.error}');
        print('   Exception Type: ${error.error?.runtimeType}');
        print('   Response: ${error.response?.data}');
        print('   Status Code: ${error.response?.statusCode}');
        print('   Request Path: ${error.requestOptions.path}');

        // Check if error.error is actually an Exception we should re-throw
        if (error.error != null) {
          // If it's one of our custom exceptions, re-throw it
          if (error.error is ServerException ||
              error.error is NetworkException ||
              error.error is UnauthorizedException ||
              error.error is ForbiddenException) {
            print(
              '   ℹ️ Re-throwing custom exception: ${error.error.runtimeType}',
            );
            throw error.error as Exception;
          }
        }

        // Check if it's a connection error
        if (error.message?.contains('SocketException') ?? false) {
          throw NetworkException(
            'Cannot connect to server. Please check if the server is running at $baseUrl',
          );
        } else if (error.message?.contains('Connection refused') ?? false) {
          throw NetworkException(
            'Connection refused. Please make sure the Laravel server is running.',
          );
        } else if (error.message?.contains('Failed host lookup') ?? false) {
          throw NetworkException(
            'No internet connection or invalid server address.',
          );
        } else if (error.message?.contains('TimeoutException') ?? false) {
          throw NetworkException(
            'Request timeout. Server took too long to respond.',
          );
        } else {
          throw NetworkException(
            'Network error: ${error.message ?? "Unknown error"}',
          );
        }
      default:
        throw ServerException('An unexpected error occurred: ${error.message}');
    }
  }
}
